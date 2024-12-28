/* -*- mode: objc -*-
 *
 * Wrapper of seq_event.h
 *
 * $copyright$
 *
 */

#include "AlsaSoundKit/ASKSeqEvent.h"

/*
 * Sequencer Address
 */

@implementation ASKSeqAddr

- (unsigned char) getClient {
  return _addr.client;
}

- (void) setClient:(unsigned char)client {
  _addr.client = client;
}

- (unsigned char) getPort {
  return _addr.port;
}

- (void) setPort:(unsigned char)port {
  _addr.port = port;
}

- (NSString*) description {
  return [NSString stringWithFormat:@"ASKSeqAddr:(%u,%u)", _addr.client, _addr.port];
}

@end

/*
 * Sequencer Connection (subscription)
 */

@implementation ASKSeqConnect

- (ASKSeqAddr*) getSender {
  ASKSeqAddr *addr = [[ASKSeqAddr alloc] init];
  addr.client = _connect.sender.client;
  addr.port = _connect.sender.port;
  return addr;
}

- (void) setSender:(ASKSeqAddr*)addr {
  _connect.sender.client = addr.client;
  _connect.sender.port = addr.port;
}

- (ASKSeqAddr*) getDest {
  ASKSeqAddr *addr = [[ASKSeqAddr alloc] init];
  addr.client = _connect.dest.client;
  addr.port = _connect.dest.port;
  return addr;
}

- (void) setDest:(ASKSeqAddr*)addr {
  _connect.dest.client = addr.client;
  _connect.dest.port = addr.port;
}


- (NSString*) description {
  return [NSString stringWithFormat:@"ASKSeqConnect:((%u,%u)(%u,%u))",
                   _connect.sender.client, _connect.sender.port,
                   _connect.dest.client, _connect.dest.port];
}

@end

/*
 * Sequencer Time Stamp
 */

@implementation ASKSeqTimestamp

@end

/*
 * Sequencer Event
 */

@implementation ASKSeqEvent

- (id) initWithEvent:(snd_seq_event_t*)ev {
  if (self = [super init]) {
    _ev = *ev;
    if (ev->type == SND_SEQ_EVENT_SYSEX) {
      // _ev.data.ext.len is already copied

      // TOM: deleted 2020-08-15
      // _ev.data.ext.ptr = (void*) malloc(ev->data.ext.len);
      // memcpy(_ev.data.ext.ptr, ev->data.ext.ptr, ev->data.ext.len);

      // TOM: 2020-08-15 - safer?
      _data = [NSData dataWithBytes:ev->data.ext.ptr length:ev->data.ext.len];
      _ev.data.ext.ptr = (void*) [_data bytes];
    }
  }
  return self;
}

- (NSData*) getExt {
  return _data;
}

- (void) setExt:(NSData*)ext {
  _data = ext;
  // 2020-08-21
  // _ev.data.ext.ptr = (void*) [_data bytes];
  snd_seq_ev_set_variable(&(_ev), [_data length], (void*) [_data bytes]);
}

- (NSString*) description {
  snd_seq_event_t *ev = &(_ev);

  BOOL isRealtime = snd_seq_ev_is_real(ev) == 1;

  NSString *s1 = [NSString stringWithFormat:@"%3d:%-3d ", ev->source.client, ev->source.port];
  NSString *s2;

  if (isRealtime) {
    double time = ev->time.time.tv_sec + (ev->time.time.tv_nsec / 1000000000.0);
    NSString *t = [NSString stringWithFormat:@"%5.2f ", time];
    s1 = [s1 stringByAppendingString:t];
  }
  else {
    NSString *t = [NSString stringWithFormat:@"%d ", ev->time.tick];
    s1 = [s1 stringByAppendingString:t];
  }

  switch (ev->type) {
  case SND_SEQ_EVENT_NOTEON:
    if (ev->data.note.velocity)
      s2 = [NSString stringWithFormat:@"Note on                %2d, note %d, velocity %d",
                               ev->data.note.channel, ev->data.note.note, ev->data.note.velocity];
    else
      s2 = [NSString stringWithFormat:@"Note off               %2d, note %d",
                     ev->data.note.channel, ev->data.note.note];
                break;
  case SND_SEQ_EVENT_NOTEOFF:
    s2 = [NSString stringWithFormat:@"Note off               %2d, note %d, velocity %d",
                   ev->data.note.channel, ev->data.note.note, ev->data.note.velocity];
    break;
  case SND_SEQ_EVENT_KEYPRESS:
    s2 = [NSString stringWithFormat:@"Polyphonic aftertouch  %2d, note %d, value %d",
                   ev->data.note.channel, ev->data.note.note, ev->data.note.velocity];
    break;
  case SND_SEQ_EVENT_CONTROLLER:
    s2 = [NSString stringWithFormat:@"Control change         %2d, controller %d, value %d",
                   ev->data.control.channel, ev->data.control.param, ev->data.control.value];
    break;
  case SND_SEQ_EVENT_PGMCHANGE:
    s2 = [NSString stringWithFormat:@"Program change         %2d, program %d",
                   ev->data.control.channel, ev->data.control.value];
    break;
  case SND_SEQ_EVENT_CHANPRESS:
    s2 = [NSString stringWithFormat:@"Channel aftertouch     %2d, value %d",
                   ev->data.control.channel, ev->data.control.value];
    break;
  case SND_SEQ_EVENT_PITCHBEND:
    s2 = [NSString stringWithFormat:@"Pitch bend             %2d, value %d",
                   ev->data.control.channel, ev->data.control.value];
    break;
  case SND_SEQ_EVENT_CONTROL14:
    s2 = [NSString stringWithFormat:@"Control change         %2d, controller %d, value %5d",
                   ev->data.control.channel, ev->data.control.param, ev->data.control.value];
    break;
  case SND_SEQ_EVENT_NONREGPARAM:
    s2 = [NSString stringWithFormat:@"Non-reg. parameter     %2d, parameter %d, value %d",
                   ev->data.control.channel, ev->data.control.param, ev->data.control.value];
    break;
  case SND_SEQ_EVENT_REGPARAM:
    s2 = [NSString stringWithFormat:@"Reg. parameter         %2d, parameter %d, value %d",
                   ev->data.control.channel, ev->data.control.param, ev->data.control.value];
    break;
  case SND_SEQ_EVENT_SONGPOS:
    s2 = [NSString stringWithFormat:@"Song position pointer      value %d",
                   ev->data.control.value];
    break;
  case SND_SEQ_EVENT_SONGSEL:
    s2 = [NSString stringWithFormat:@"Song select                value %d",
                   ev->data.control.value];
    break;
  case SND_SEQ_EVENT_QFRAME:
    s2 = [NSString stringWithFormat:@"MTC quarter frame          %02xh",
                   ev->data.control.value];
    break;
  case SND_SEQ_EVENT_TIMESIGN:
    // XXX how is this encoded?
    s2 = [NSString stringWithFormat:@"SMF time signature         (%#010x)",
                   ev->data.control.value];
    break;
  case SND_SEQ_EVENT_KEYSIGN:
    // XXX how is this encoded?
    s2 = [NSString stringWithFormat:@"SMF key signature          (%#010x)",
                   ev->data.control.value];
    break;
  case SND_SEQ_EVENT_START:
    if (ev->source.client == SND_SEQ_CLIENT_SYSTEM &&
        ev->source.port == SND_SEQ_PORT_SYSTEM_TIMER)
      s2 = [NSString stringWithFormat:@"Queue start                queue %d",
                     ev->data.queue.queue];
    else
      s2 = [NSString stringWithFormat:@"Start"];
    break;
  case SND_SEQ_EVENT_CONTINUE:
    if (ev->source.client == SND_SEQ_CLIENT_SYSTEM &&
        ev->source.port == SND_SEQ_PORT_SYSTEM_TIMER)
      s2 = [NSString stringWithFormat:@"Queue continue             queue %d",
                     ev->data.queue.queue];
    else
      s2 = [NSString stringWithFormat:@"Continue"];
    break;
  case SND_SEQ_EVENT_STOP:
    if (ev->source.client == SND_SEQ_CLIENT_SYSTEM &&
        ev->source.port == SND_SEQ_PORT_SYSTEM_TIMER)
      s2 = [NSString stringWithFormat:@"Queue stop                 queue %d",
                     ev->data.queue.queue];
    else
      s2 = [NSString stringWithFormat:@"Stop"];
    break;
  case SND_SEQ_EVENT_SETPOS_TICK:
    s2 = [NSString stringWithFormat:@"Set tick queue pos.        queue %d", ev->data.queue.queue];
    break;
  case SND_SEQ_EVENT_SETPOS_TIME:
    s2 = [NSString stringWithFormat:@"Set rt queue pos.          queue %d", ev->data.queue.queue];
    break;
  case SND_SEQ_EVENT_TEMPO:
    s2 = [NSString stringWithFormat:@"Set queue tempo            queue %d", ev->data.queue.queue];
    break;
  case SND_SEQ_EVENT_CLOCK:
    s2 = [NSString stringWithFormat:@"Clock"];
    break;
  case SND_SEQ_EVENT_TICK:
    s2 = [NSString stringWithFormat:@"Tick"];
    break;
  case SND_SEQ_EVENT_QUEUE_SKEW:
    s2 = [NSString stringWithFormat:@"Queue timer skew           queue %d", ev->data.queue.queue];
    break;
  case SND_SEQ_EVENT_TUNE_REQUEST:
    s2 = [NSString stringWithFormat:@"Tune request"];
    break;
  case SND_SEQ_EVENT_RESET:
    s2 = [NSString stringWithFormat:@"Reset"];
    break;
  case SND_SEQ_EVENT_SENSING:
    s2 = [NSString stringWithFormat:@"Active Sensing"];
    break;
  case SND_SEQ_EVENT_CLIENT_START:
    s2 = [NSString stringWithFormat:@"Client start               client %d",
                   ev->data.addr.client];
    break;
  case SND_SEQ_EVENT_CLIENT_EXIT:
    s2 = [NSString stringWithFormat:@"Client exit                client %d",
                   ev->data.addr.client];
    break;
  case SND_SEQ_EVENT_CLIENT_CHANGE:
    s2 = [NSString stringWithFormat:@"Client changed             client %d",
                   ev->data.addr.client];
    break;
  case SND_SEQ_EVENT_PORT_START:
    s2 = [NSString stringWithFormat:@"Port start                 %d:%d",
                   ev->data.addr.client, ev->data.addr.port];
    break;
  case SND_SEQ_EVENT_PORT_EXIT:
    s2 = [NSString stringWithFormat:@"Port exit                  %d:%d",
                   ev->data.addr.client, ev->data.addr.port];
    break;
  case SND_SEQ_EVENT_PORT_CHANGE:
    s2 = [NSString stringWithFormat:@"Port changed               %d:%d",
                   ev->data.addr.client, ev->data.addr.port];
    break;
  case SND_SEQ_EVENT_PORT_SUBSCRIBED:
    s2 = [NSString stringWithFormat:@"Port subscribed            %d:%d -> %d:%d",
                   ev->data.connect.sender.client, ev->data.connect.sender.port,
                   ev->data.connect.dest.client, ev->data.connect.dest.port];
    break;
  case SND_SEQ_EVENT_PORT_UNSUBSCRIBED:
    s2 = [NSString stringWithFormat:@"Port unsubscribed          %d:%d -> %d:%d",
                   ev->data.connect.sender.client, ev->data.connect.sender.port,
                   ev->data.connect.dest.client, ev->data.connect.dest.port];
    break;
  case SND_SEQ_EVENT_SYSEX:
    {
      unsigned int i;
      s2 = [NSString stringWithFormat:@"System exclusive          "];
      for (i = 0; i < ev->data.ext.len; ++i) {
        NSString *s3 = [NSString stringWithFormat:@" %02X", ((unsigned char*)ev->data.ext.ptr)[i]];
        s2 = [s2 stringByAppendingString:s3];
      }
    }
    break;
  default:
    s2 = [NSString stringWithFormat:@"Event type %d",  ev->type];
  }
  s1 = [s1 stringByAppendingString:s2];
  return s1;
}


@end
