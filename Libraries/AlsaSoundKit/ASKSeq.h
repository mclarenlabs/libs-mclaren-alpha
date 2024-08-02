/** -*- mode:objc -*-
 *
 * Wrap an Alsa sequencer
 *
 * (c) McLaren Labs 2022
 */

#include <alsa/asoundlib.h>
#include <alsa/seq.h>
#include <dispatch/dispatch.h>

#import <Foundation/Foundation.h>
#import "ASKSeqEvent.h"
#import "ASKSeqSystem.h"

typedef void (^ASKSeqListener)(NSArray*); // receives an array of ASKSeqEvt structs

/**
 * An options object is used to configure a new sequencer.
 * Note: C-types are used, because they are what ALSA expects.
 *
 * To use: alloc/init an options object, and override paramteters.
 */

@interface ASKSeqOptions : NSObject  {
@public
  char *_sequencer_name;	// arg to snd_seq_set_client_name

  char *_sequencer_type;	// arg to snd_seq_open
  int _sequencer_streams;	// arg to snd_seq_open
  int _sequencer_mode;		// arg to snd_seq_open

  char *_port_name;		// arg to snd_seq_create_simple_port
  int _port_caps;		// arg to snd_seq_create_simple_port
  int _port_type;		// arg to snd_seq_create_simple_port

  char *_queue_name;		// arg to snd_seq_alloc_named_queue
  int _queue_tempo;
  int _queue_resolution;
}

@property (readwrite) char *sequencer_name;
@property (readwrite) char *port_name;

@end


/**
 * An Alsa Midi Sequencer implements two protocols: a source and a sink.
 * Other classes can source and sink Alsa events by implementing these protocols.
 */

@protocol ASKSeqSink
- (void) output:(ASKSeqEvent*) ev;
- (void) outputDirect:(ASKSeqEvent*) ev;
- (void) dispatchAsync:(void(^)())block;
- (int) getQueue;
@end

@protocol ASKSeqSource
- (void) addListener:(ASKSeqListener)block;
- (void) delListener:(ASKSeqListener)block;
@end

/**
 * An ASKSeq is a sender and receiver of MIDI messages.  It is also capable
 * of receiving messages from othe MIDI devices and sequencers in the system.
 */

@interface ASKSeq : NSObject<ASKSeqSink, ASKSeqSource>

- (id) init __attribute__((unavailable("This method is not available.  Please use initWithOptions:error:")));

// a sequencer with default options
- (id) initWithError:(NSError**)error;

// customize the sequencer options
- (id) initWithOptions:(ASKSeqOptions*)options error:(NSError**)error;

+ (dispatch_queue_t) sharedQueue;

- (void) startSequencer;
- (void) stopSequencer;
- (void) continueSequencer;

- (snd_seq_t*) getHandle;
- (int) getClient;
- (int) getPort;
- (int) getQueue;
- (ASKSeqAddr*) myAddress;
- (ASKSeqAddr*) parseAddress:(NSString*)addrstr error:(NSError**)error;
- (void) addListener:(ASKSeqListener)block;
- (void) delListener:(ASKSeqListener)block;
- (void) output:(ASKSeqEvent*) ev;
- (void) outputDirect:(ASKSeqEvent*) ev;

- (snd_seq_real_time_t) getTime; // get current time of queue
- (double) getSeconds;
- (uint64_t) getNanoseconds;

// change the tempo
- (BOOL) setTempo:(int)bpm error:(NSError**)error;
- (int) getResolution;


// Simple subscription (w/o exclusive and time conversion)
- (BOOL) connectFrom:(int)client port:(int)port error:(NSError**)error;
- (BOOL) connectFromReal:(int)client port:(int)port error:(NSError**)error; // receive timestamps in realtime form
- (BOOL) disconnectFrom:(int)client port:(int)port error:(NSError**)error;
- (BOOL) connectTo:(int)client port:(int)port error:(NSError**)error;
- (BOOL) disconnectTo:(int)client port:(int)port error:(NSError**)error;

// client info, iterator
- (ASKSeqClientInfo*) clientInfo;
- (ASKSeqClientInfo*) clientInfo:(int)client;
- (int) nextClient:(ASKSeqClientInfo*)info;

// port info, iterator
- (ASKSeqPortInfo*) portInfo:(int)port;
- (ASKSeqPortInfo*) portInfo:(int)port forClient:(int)client;
- (int) nextPort:(ASKSeqPortInfo*)info;

// to run other things on this queue
- (void) dispatchAsync:(void(^)())block;

@end
