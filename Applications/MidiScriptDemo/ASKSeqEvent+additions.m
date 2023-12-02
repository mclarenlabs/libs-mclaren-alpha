/* -*- mode: objc -*-
 *
 * Convenience methods for creating, accessing and parsing seq events.
 *
 * $copyright$
 *
 */

#include "ASKSeqEvent+additions.h"
#include "NSObject+additions.h"

@implementation ASKSeqEvent(additions)

+ (ASKSeqEvent*) eventWithNoteOn:(unsigned)note vel:(unsigned)vel chan:(unsigned)chan
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_NOTEON;
  evt->_ev.data.note.channel = (chan & 0xF);
  evt->_ev.data.note.note = (note & 0x7F);
  evt->_ev.data.note.velocity = (vel & 0x7F);
  return evt;
}

+ (ASKSeqEvent*) eventWithNoteOff:(unsigned)note vel:(unsigned)vel chan:(unsigned)chan
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_NOTEOFF;
  evt->_ev.data.note.channel = (chan & 0xF);
  evt->_ev.data.note.note = (note & 0x7F);
  evt->_ev.data.note.velocity = (vel & 0x7F);
  return evt;
}

+ (ASKSeqEvent*) eventWithKeyPressure:(unsigned)note vel:(unsigned)vel chan:(unsigned)chan
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_KEYPRESS;
  evt->_ev.data.note.channel = (chan & 0xF);
  evt->_ev.data.note.note = (note & 0x7F);
  evt->_ev.data.note.velocity = (vel & 0x7F);
  return evt;

}

+ (ASKSeqEvent*) eventWithControlChange:(unsigned)param val:(unsigned)val chan:(unsigned)chan
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_CONTROLLER;
  evt->_ev.data.control.channel = (chan & 0xF);
  evt->_ev.data.control.param = (param & 0x7F);
  evt->_ev.data.control.value = (val & 0x7F);
  return evt;
}

+ (ASKSeqEvent*) eventWithPgmChange:(unsigned)val chan:(unsigned)chan
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_PGMCHANGE;
  evt->_ev.data.control.channel = (chan & 0xF);
  evt->_ev.data.control.value = (val & 0x7F);
  return evt;
}

+ (ASKSeqEvent*) eventWithChanPressure:(unsigned)val chan:(unsigned)chan
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_CHANPRESS;
  evt->_ev.data.control.channel = (chan & 0xF);
  evt->_ev.data.control.value = (val & 0x7F);
  return evt;
}

+ (ASKSeqEvent*) eventWithPitchBend:(signed int)val chan:(unsigned)chan
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_PITCHBEND;
  evt->_ev.data.control.channel = (chan & 0xF);

  if (val < -8192) val = -8192;
  if (val > 8191) val = 8191;

  evt->_ev.data.control.value = val;
  return evt;
}

+ (ASKSeqEvent*) eventWithUsr1:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_USR1;
  evt->_ev.data.raw32.d[0] = d0;
  evt->_ev.data.raw32.d[1] = d1;
  evt->_ev.data.raw32.d[2] = d2;
  return evt;
}

+ (ASKSeqEvent*) eventWithUsr2:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2
{
  ASKSeqEvent *evt = [[ASKSeqEvent alloc] init];

  evt->_ev.type = SND_SEQ_EVENT_USR2;
  evt->_ev.data.raw32.d[0] = d0;
  evt->_ev.data.raw32.d[1] = d1;
  evt->_ev.data.raw32.d[2] = d2;
  return evt;
}

//
// Set Destination
//

- (void) setSubs
{
  snd_seq_ev_set_subs(&_ev);
}

- (void) setBroadcast
{
  snd_seq_ev_set_broadcast(&_ev);
}

- (void) setDest:(unsigned char)client port:(unsigned char)port
{
  snd_seq_ev_set_dest(&_ev, client, port);
}

//
// Scheduling and Queue
//

- (void) setDirect
{
  snd_seq_ev_set_direct(&_ev);
}

- (void) setScheduleTick:(unsigned char)queue isRelative:(BOOL)isRelative ttick:(unsigned)ttick
{
  snd_seq_ev_schedule_tick(&_ev, queue, isRelative, ttick);
}

- (void) setScheduleReal:(unsigned char)queue isRelative:(BOOL)isRelative sec:(unsigned)sec nsec:(unsigned)nsec {
  snd_seq_real_time_t time;
  time.tv_sec = sec;
  time.tv_nsec = nsec;
  snd_seq_ev_schedule_real(&_ev, queue, isRelative, &time);
}



//
// Predicates
//

- (BOOL) isNoteOn {
  return (_ev.type == SND_SEQ_EVENT_NOTEON);
}

- (BOOL) isNoteOff {
  return (_ev.type == SND_SEQ_EVENT_NOTEOFF);
}

- (BOOL) isKeyPressure {
  return (_ev.type == SND_SEQ_EVENT_KEYPRESS);
}

- (BOOL) isControlChange {
  return (_ev.type == SND_SEQ_EVENT_CONTROLLER);
}

- (BOOL) isPgmChange {
  return (_ev.type == SND_SEQ_EVENT_PGMCHANGE);
}

- (BOOL) isChanPressure {
  return (_ev.type == SND_SEQ_EVENT_CHANPRESS);
}

- (BOOL) isPitchBend {
  return (_ev.type == SND_SEQ_EVENT_PITCHBEND);
}

- (BOOL) isUsr1 {
  return (_ev.type == SND_SEQ_EVENT_USR1);
}

- (BOOL) isUsr2 {
  return (_ev.type == SND_SEQ_EVENT_USR2);
}

//
// Parsers
//

- (BOOL) parseNoteOn:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_NOTEON)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:value:)]) {
    unsigned note = _ev.data.note.note;
    unsigned vel = _ev.data.note.velocity;
    unsigned chan = _ev.data.note.channel;

    // id res = [block value:@(note) value:@(vel) value:@(chan)];
    id res = [block performSelector:@selector(value:value:value:)
			 withObject:@(note)
			 withObject:@(vel)
			 withObject:@(chan)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}

- (BOOL) parseNoteOff:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_NOTEOFF)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:value:)]) {
    unsigned note = _ev.data.note.note;
    unsigned vel = _ev.data.note.velocity;
    unsigned chan = _ev.data.note.channel;

    // id res = [block value:@(note) value:@(vel) value:@(chan)];
    id res = [block performSelector:@selector(value:value:value:)
			 withObject:@(note)
			 withObject:@(vel)
			 withObject:@(chan)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}

- (BOOL) parseKeyPressure:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_KEYPRESS)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:value:)]) {
    unsigned note = _ev.data.note.note;
    unsigned vel = _ev.data.note.velocity;
    unsigned chan = _ev.data.note.channel;

    // id res = [block value:@(note) value:@(vel) value:@(chan)];
    id res = [block performSelector:@selector(value:value:value:)
			 withObject:@(note)
			 withObject:@(vel)
			 withObject:@(chan)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}

- (BOOL) parseControlChange:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_CONTROLLER)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:value:)]) {
    unsigned param = _ev.data.control.param;
    unsigned val = _ev.data.control.value;
    unsigned chan = _ev.data.control.channel;

    id res = [block performSelector:@selector(value:value:value:)
			 withObject:@(param)
			 withObject:@(val)
			 withObject:@(chan)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}

- (BOOL) parsePgmChange:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_PGMCHANGE)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:)]) {
    unsigned val = _ev.data.control.value;
    unsigned chan = _ev.data.control.channel;

    id res = [block performSelector:@selector(value:value:)
			 withObject:@(val)
			 withObject:@(chan)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}

- (BOOL) parseChanPressure:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_CHANPRESS)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:)]) {
    unsigned val = _ev.data.control.value;
    unsigned chan = _ev.data.control.channel;

    id res = [block performSelector:@selector(value:value:)
			 withObject:@(val)
			 withObject:@(chan)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}

- (BOOL) parsePitchBend:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_PITCHBEND)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:)]) {
    unsigned val = _ev.data.control.value;
    unsigned chan = _ev.data.control.channel;

    id res = [block performSelector:@selector(value:value:)
			 withObject:@(val)
			 withObject:@(chan)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}

- (BOOL) parseUsr1:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_USR1)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:value:)]) {
    unsigned d0 = _ev.data.raw32.d[0];
    unsigned d1 = _ev.data.raw32.d[1];
    unsigned d2 = _ev.data.raw32.d[2];

    id res = [block performSelector:@selector(value:value:value:)
			 withObject:@(d0)
			 withObject:@(d1)
			 withObject:@(d2)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}

- (BOOL) parseUsr2:(NSObject*)block
{
  if (_ev.type != SND_SEQ_EVENT_USR2)
    return NO;
  
  if ([block respondsToSelector:@selector(value:value:value:)]) {
    unsigned d0 = _ev.data.raw32.d[0];
    unsigned d1 = _ev.data.raw32.d[1];
    unsigned d2 = _ev.data.raw32.d[2];

    id res = [block performSelector:@selector(value:value:value:)
			 withObject:@(d0)
			 withObject:@(d1)
			 withObject:@(d2)];
    (void) res;
    return YES;
  }
  else {
    return NO;
  }

}


@end
