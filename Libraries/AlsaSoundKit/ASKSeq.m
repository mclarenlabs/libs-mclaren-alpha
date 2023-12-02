/** -*- mode:objc -*-
 *
 * Wrap an Alsa sequencer
 *
 * $copyright$
 */

#import <dispatch/dispatch.h>

#import "AlsaSoundKit/ASKError.h"
#import "AlsaSoundKit/ASKSeq.h"
#import "AlsaSoundKit/ASKSeqEvent.h"
#import "AlsaSoundKit/ASKSeqSystem.h"

const int SEQDEBUG = 0;

@implementation ASKSeqOptions

- (id) init {
  if (self = [super init]) {
    // Default Values for Sequencer Properties
    _sequencer_name = "mclaren";
    _sequencer_type = "default"; // also "hw"
    _sequencer_streams = SND_SEQ_OPEN_DUPLEX; // also SND_SEQ_OPEN_OUTPUT, SND_SEQ_OPEN_INPUT
    _sequencer_mode = SND_SEQ_NONBLOCK;

    _port_name = "__port__";
    _port_caps =  (SND_SEQ_PORT_CAP_READ | SND_SEQ_PORT_CAP_WRITE |
                   SND_SEQ_PORT_CAP_SUBS_READ | SND_SEQ_PORT_CAP_SUBS_WRITE);
    _port_type = SND_SEQ_PORT_TYPE_MIDI_GENERIC;

    _queue_name = "__queue__";
    _queue_tempo = (60.0 * 1000000 / 120); // initial tempo 120 bpm
    _queue_resolution = 120;  // PPQ

  }
  return self;
}

@end


@implementation ASKSeq {

  ASKSeqOptions       *_options; // configuration options

  snd_seq_t             *_handle;
  int                   _client;
  int                   _port;

  int                   _queue;
  int			_tempo;
  int			_resolution;

  NSMutableArray        *_listeners;

  int                   _isrunning;
  dispatch_queue_t      _dqueue;
  dispatch_source_t     _dsource;
}

- (id) initWithError:(NSError**)error {

  // get a default options
  ASKSeqOptions * options = [[ASKSeqOptions alloc] init];

  return [self initWithOptions:options error:error];
}


- (id) initWithOptions:(ASKSeqOptions*)options error:(NSError**)error {

  if (self = [super init]) {

    _options = options;

    _handle = NULL;
    _client = -1;
    _port = -1;
    _queue = -1;

    _listeners = [[NSMutableArray alloc] init];

    _isrunning = 0;

    _dqueue = NULL;
    _dsource = NULL;

    BOOL ok;
    
    ok = [self initHandleWithError:error];
    if (ok == NO) goto END;

    ok = [self initQueueWithError:error];
    if (ok == NO) goto END;
    
    ok = [self initPortWithError:error];
    if (ok == NO) goto END;
    
    ok = [self initDispatchWithError:error];
    if (ok == NO) goto END;
  }

 END:

  return self;
}

- (BOOL) initHandleWithError:(NSError**)error {

  int err = snd_seq_open(&_handle,
                         _options->_sequencer_type,
                         _options->_sequencer_streams,
                         _options->_sequencer_mode);

  if (err < 0) {
    if (SEQDEBUG)
      NSLog(@"initHandle error - snd_seq_open (%s)", snd_strerror(err));
    *error = [NSError errorWithASKAlsaError:err];
    return NO;
  }

  // Set the name
  err = snd_seq_set_client_name(_handle, _options->_sequencer_name);

  if (err < 0) {
    if (SEQDEBUG)
      NSLog(@"initHandle error - snd_set_set_client_name %s (%s)",
            _options->_sequencer_name,
            snd_strerror(err));
    *error = [NSError errorWithASKAlsaError:err];
    return NO;
  }

  // Get the Client ID for this sequencer
  _client = snd_seq_client_id(_handle);

  return YES;
}

/*
 * utility helper to set queue tempo
 */

static int init_queue_tempo(snd_seq_t *handle, int queue, int qtempo, int ppq) {
  snd_seq_queue_tempo_t *tempo;
  snd_seq_queue_tempo_alloca(&tempo);
  snd_seq_queue_tempo_set_tempo(tempo, qtempo);
  snd_seq_queue_tempo_set_ppq(tempo, ppq);
  return snd_seq_set_queue_tempo(handle, queue, tempo);
}

- (BOOL) initQueueWithError:(NSError**)error {

  _queue = snd_seq_alloc_named_queue(_handle, _options->_queue_name);
  if (_queue < 0) {
    if (SEQDEBUG)
      NSLog(@"initQueue - error - snd_seq_alloc_named_queue:%s", snd_strerror(_queue));
    *error = [NSError errorWithASKAlsaError:_queue];
    return NO;
  }

  _tempo = _options->_queue_tempo;
  _resolution = _options->_queue_resolution;

  int err = init_queue_tempo(_handle, _queue, _tempo, _resolution);

  if (err < 0) {
    if (SEQDEBUG)
      NSLog(@"initQueueTempo - error - snd_seq_set_queue_tempo (%s)", snd_strerror(err));
    // 2023-11-20
    // *error = [NSError errorWithASKAlsaError:_queue];
    *error = [NSError errorWithASKAlsaError:err];
    return NO;
  }

  return YES;
}

- (BOOL) initPortWithError:(NSError**)error {
  _port = snd_seq_create_simple_port(_handle,
                                     _options->_port_name,
                                     _options->_port_caps,
                                     _options->_port_type);

  if (_port < 0) {
    if (SEQDEBUG)
      NSLog(@"initPort error - snd_seq_create_simple_port (%s)", snd_strerror(_port));
    *error = [NSError errorWithASKAlsaError:_port];
    return NO;
  }

  return YES;
}


////////////////////////////////////////////////////////////////
//
// DISPATCH

+ (dispatch_queue_t) sharedQueue {
  static dispatch_queue_t dqueue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      dqueue = dispatch_queue_create("midi", NULL);
      // TOM: 2018-07-10 - always dispatch to high-priority queue
      dispatch_set_target_queue(dqueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    });
  return dqueue;
}


- (BOOL) initDispatchWithError:(NSError**)error {
  // NSLog(@"initDispatch");

  // Use the shared MIDI queue
  _dqueue = [ASKSeq sharedQueue];

  int npfd;
  struct pollfd *pfd;
  int idx;

  // Populate a structure with the Poll Descriptors for this Sequencer
  npfd = snd_seq_poll_descriptors_count(_handle, POLLIN);
  pfd = (struct pollfd *) calloc(npfd, sizeof(struct pollfd));
  snd_seq_poll_descriptors(_handle, pfd, npfd, POLLIN);

  // Tie each Poll Descriptor to a Dispatch Source and Handler block
  for (idx = 0; idx < npfd; idx++) {
    // NSLog(@"DispatchSourceCreate:%d fd:%d", idx, pfd[idx].fd);
    _dsource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                     pfd[idx].fd,
                                     0,
                                     _dqueue);

    if (_dsource == NULL) {
      if (SEQDEBUG)
        NSLog(@"dispatch_source_create - could not create");
      *error = [NSError errorWithASKSeqError:kASKSeqErrorCannotConfigureDevice
                                         str:@"error calling dispatch_source_create"];
      return NO;
    }
                            

    dispatch_source_set_event_handler(_dsource, ^{
        // NSLog(@"Did get event");
        NSMutableArray *events = [[NSMutableArray alloc] init];
        snd_seq_event_t *ev;

        // Gather up the ready events
        do {
          snd_seq_event_input(_handle, &ev);
          if (ev != NULL) {
            ASKSeqEvent *evt = [[ASKSeqEvent alloc] initWithEvent:ev];
            snd_seq_free_event(ev); // TOM: this line may be meaningless
            [events addObject:evt];
          }
          else {
            NSLog(@"Warn: NULL MIDI EVENT");
          }
        } while (snd_seq_event_input_pending(_handle, 0) > 0);

        // Broadcast the event lists to all listeners
        for (ASKSeqListener listener in _listeners) {
          listener(events);
        }

      });

    dispatch_resume(_dsource);
  }

  return YES;
}

- (void) controlQueue:(int) ctype withValue:(int)cvalue withEvent:(snd_seq_event_t*)event {
  int err;

  err = snd_seq_control_queue(_handle, _queue, ctype, cvalue, event);
  if (err < 0) {
    const char *s = snd_strerror(err);
    NSLog(@"controlQueueType error - snd_seq_open:%s", s);
    return;
  }
}

- (void) startSequencer {
  if (! _isrunning) {
    [self controlQueue:SND_SEQ_EVENT_START withValue:0 withEvent:NULL];
    _isrunning = 1;
  }
}

- (void) stopSequencer {
  if (_isrunning) {
    [self controlQueue:SND_SEQ_EVENT_STOP withValue:0 withEvent:NULL];
    _isrunning = 0;
  }
}

- (void) continueSequencer {
  if (_isrunning) {
    [self controlQueue:SND_SEQ_EVENT_CONTINUE withValue:0 withEvent:NULL];
    _isrunning = 1;
  }
}

- (snd_seq_t*) getHandle {
  return _handle;
}

- (int) getClient {
  return _client;
}

- (int) getPort {
  return _port;
}

- (int) getQueue {
  return _queue;
}


- (ASKSeqAddr*) myAddress {
  ASKSeqAddr *a = [[ASKSeqAddr alloc] init];
  a->_addr.client = _client;
  a->_addr.port = _port;
  return a;
}

- (ASKSeqAddr*) parseAddress:(NSString*)addrstr error:(NSError**)error {
  ASKSeqAddr *a = [[ASKSeqAddr alloc] init];
  const char *str = [addrstr cStringUsingEncoding:NSASCIIStringEncoding];
  int err = snd_seq_parse_address(_handle, &(a->_addr), str);

  if (err < 0) {
    if (SEQDEBUG)
      NSLog(@"ASKSeq cannot find ALSA Client '%@' (%s)", addrstr, snd_strerror(err));
    *error = [NSError errorWithASKAlsaError:err];
    return nil;
  }
  return a;
}


- (void) addListener:(ASKSeqListener)block {
  // TOM: 2017-06-02
  dispatch_async(_dqueue, ^{
      [_listeners addObject:block];
    });
}

- (void) delListener:(ASKSeqListener)block {
  // TOM: 2017-06-02
  dispatch_async(_dqueue, ^{
      [_listeners removeObject:block];
    });
}

// Send this event to the system - as is.
- (void) output:(ASKSeqEvent*) ev {
  // Place this event on the output buffer.
  // Return total size of byte data on output buffer (or 0 if empty)
  int err = snd_seq_event_output(_handle, &(ev->_ev));
  if (err < 0) {
    const char *s = snd_strerror(err);
    NSLog(@"ASKSeq output error:%s", s);
  }
  // Drain the output buffer
  snd_seq_drain_output(_handle);
}

// Place an event directly to the sequencer NOT through the output buffer
- (void) outputDirect:(ASKSeqEvent*) ev {
  // Place this event on the output buffer.
  // Return total size of byte data on output buffer (or 0 if empty)
  int err = snd_seq_event_output_direct(_handle, &(ev->_ev));
  if (err < 0) {
    const char *s = snd_strerror(err);
    NSLog(@"ASKSeq outputDirect error:%s", s);
  }
}

// Get the current time of this sequencer by reading from its queue
- (snd_seq_real_time_t) getTime {

  snd_seq_queue_status_t *status;
  snd_seq_real_time_t rtime;
  snd_seq_queue_status_alloca(&status);

  snd_seq_get_queue_status(_handle, _queue, status);
  rtime = *snd_seq_queue_status_get_real_time(status);
  return rtime;
}

// Convenience methods
- (double) getSeconds {
  snd_seq_real_time_t rtime = [self getTime];
  return (rtime.tv_sec + (rtime.tv_nsec / 1.0e9));
}

- (uint64_t) getNanoseconds {
  snd_seq_real_time_t rtime = [self getTime];
  uint64_t tv_sec64 = rtime.tv_sec;
  uint64_t tv_nsec64 = rtime.tv_nsec;
  return (tv_sec64 * 1000000000) + tv_nsec64;
}

// change the tempo
- (BOOL) setTempo:(int)bpm error:(NSError**)error
{
  BOOL ok = YES;
  
  // _queue_tempo = (60.0 * 1000000 * (_den / 4.0) / bpm);
  _tempo = (60.0 * 1000000 / bpm);
  
  snd_seq_queue_tempo_t *tempo;
  snd_seq_queue_tempo_alloca(&tempo);
  snd_seq_queue_tempo_set_tempo(tempo, _tempo);
  snd_seq_queue_tempo_set_ppq(tempo, _resolution);
  int err = snd_seq_set_queue_tempo(_handle, _queue, tempo);

  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

  
  

// Connect a reader
- (BOOL) connectFrom:(int)client port:(int)port error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_seq_connect_from(_handle, _port, client, port);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

// Connect a reader and ask for realtime updates
- (BOOL) connectFromReal:(int)client port:(int)port error:(NSError**)error {
  BOOL ok = YES;
  snd_seq_port_subscribe_t *subs;
  snd_seq_addr_t sender, dest;

  sender.client = client;
  sender.port = port;
  dest.client = _client;
  dest.port = _port;

  snd_seq_port_subscribe_alloca(&subs);
  snd_seq_port_subscribe_set_sender(subs, &sender);
  snd_seq_port_subscribe_set_dest(subs, &dest);
  snd_seq_port_subscribe_set_queue(subs, _queue);

  // Set realtime conversion (see aconnect.c for example)
  snd_seq_port_subscribe_set_time_update(subs, 1); // convert_time
  snd_seq_port_subscribe_set_time_real(subs, 1); // convert_real

  int err = snd_seq_subscribe_port(_handle, subs);

  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) disconnectFrom:(int)client port:(int)port error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_seq_disconnect_from(_handle, _port, client, port);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

// Connect a writer
- (BOOL) connectTo:(int)client port:(int)port error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_seq_connect_to(_handle, _port, client, port);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}


- (BOOL) disconnectTo:(int)client port:(int)port error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_seq_disconnect_to(_handle, _port, client, port);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

// client info, iterators

- (ASKSeqClientInfo*) clientInfo {
  ASKSeqClientInfo *info = [[ASKSeqClientInfo alloc] init];
  int err = snd_seq_get_client_info(_handle, info.client_info);
  if (err < 0) {
    info = nil;
    if (1) {
      fprintf(stderr, "snd_seq_get_client_info error (%s)\n",
              snd_strerror(err));
    }
  }
  return info;
}

- (ASKSeqClientInfo*) clientInfo:(int)client {
  ASKSeqClientInfo *info = [[ASKSeqClientInfo alloc] init];
  int err = snd_seq_get_any_client_info(_handle, client, info.client_info);
  if (err < 0) {
    info = nil;
    if (1) {
      fprintf(stderr, "snd_seq_get_any_client_info error:%d (%s)\n",
              client, snd_strerror(err));
    }
  }
  return info;
}

- (int) nextClient:(ASKSeqClientInfo*)info {
  return snd_seq_query_next_client(_handle, info.client_info);
}


// port info, iterators

- (ASKSeqPortInfo*) portInfo:(int)port {
  ASKSeqPortInfo *info = [[ASKSeqPortInfo alloc] init];
  int err = snd_seq_get_port_info(_handle, port, info.port_info);
  if (err < 0) {
    info = nil;
    if (1) {
      fprintf(stderr, "snd_seq_get_port_info error (%s)\n",
              snd_strerror(err));
    }
  }
  return info;
}

- (ASKSeqPortInfo*) portInfo:(int)port forClient:(int)client {
  ASKSeqPortInfo *info = [[ASKSeqPortInfo alloc] init];
  int err = snd_seq_get_any_port_info(_handle, client, port, info.port_info);
  if (err < 0) {
    info = nil;
    if (1) {
      fprintf(stderr, "snd_seq_get_any_port_info error:%d,%d (%s)\n",
              client, port, snd_strerror(err));
    }
  }
  return info;
}


- (int) nextPort:(ASKSeqPortInfo*)info {
  return snd_seq_query_next_port(_handle, info.port_info);
}

- (void) dispatchAsync:(void(^)())block {
  // TOM: 2017-11-25
  dispatch_async(_dqueue, block);
}
   
- (void) dealloc {
  snd_seq_close(_handle);
  // [super dealloc];
}

@end
