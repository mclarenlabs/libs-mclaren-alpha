/* -*- mode: objc -*-
 *
 * An object that registers as an ASKSeq listener and dispatches on the main queue.
 *
 * $copyright$
 *
 */

#include "NSObject+additions.h"
#include "ASKSeqDispatcher.h"

@implementation ASKSeqDispatcher {
  ASKSeq *_seq;
  ASKSeqListener _block;
}

- (void) handleEvent:(ASKSeqEvent*)e
{
  // NSLog(@"handleEvent:%@", e);
  switch (e->_ev.type) {

  case SND_SEQ_EVENT_NOTEON:
    [self sendNoteOn:e->_ev.data.note.note
		  vel:e->_ev.data.note.velocity
		 chan:e->_ev.data.note.channel];
    break;
	
  case SND_SEQ_EVENT_NOTEOFF:
    [self sendNoteOff:e->_ev.data.note.note
		   vel:e->_ev.data.note.velocity
		  chan:e->_ev.data.note.channel];
    break;

  case SND_SEQ_EVENT_KEYPRESS:
    [self sendKeyPressure:e->_ev.data.note.note
		      vel:e->_ev.data.note.velocity
		     chan:e->_ev.data.note.channel];
    break;
      
  case SND_SEQ_EVENT_CONTROLLER:
      [self sendControlChange:e->_ev.data.control.param
		       val:e->_ev.data.control.value
		      chan:e->_ev.data.note.channel];
    break;

  case SND_SEQ_EVENT_PGMCHANGE:
    [self sendPgmChange:e->_ev.data.control.value
		   chan:e->_ev.data.control.channel];
    break;

  case SND_SEQ_EVENT_CHANPRESS:
    [self sendChanPress:e->_ev.data.control.value
		   chan:e->_ev.data.control.channel];
    break;

  case SND_SEQ_EVENT_PITCHBEND:
    [self sendPitchBend:e->_ev.data.control.value
		   chan:e->_ev.data.control.channel];
    break;

  case SND_SEQ_EVENT_USR1:
    [self sendUsr1:e->_ev.data.raw32.d[0]
		d1:e->_ev.data.raw32.d[1]
		d2:e->_ev.data.raw32.d[2]];
	  
    break;

  case SND_SEQ_EVENT_USR2:
    [self sendUsr2:e->_ev.data.raw32.d[0]
		d1:e->_ev.data.raw32.d[1]
		d2:e->_ev.data.raw32.d[2]];
    break;


    // To Do: Implement all the rest of these
  }
}

- (id) initWithSeq:(ASKSeq*)seq
{
  if (self = [super init]) {
    _seq = seq;
    _noteOnSelector = @selector(seqNoteOn:vel:chan:);
    _noteOffSelector = @selector(seqNoteOff:vel:chan:);
    _keyPressureSelector = @selector(seqKeyPressure:vel:chan:);
    _controlChangeSelector = @selector(seqControlChange:val:chan:);
    _pgmChangeSelector = @selector(seqPgmChange:chan:);
    _chanPressSelector = @selector(seqChanPress:chan:);
    _usr1Selector = @selector(seqUsr1:d1:d2:);
    _usr2Selector = @selector(seqUsr2:d1:d2:);

    __weak ASKSeqDispatcher* wself = self; // weakly capture self

    _block = ^(NSArray *evts) {
      for (ASKSeqEvent *e in evts) {
	[wself performSelectorOnMainThread:@selector(handleEvent:)
				withObject:e
			     waitUntilDone:NO];
      }
    };

    // register for callbacks
    [_seq addListener:_block];
    
  }
  return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void) sendNoteOn:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned) chan
{
  if (_target != nil) {
    if ([_target respondsToSelector:_noteOnSelector] == YES) {
      [_target performSelector:_noteOnSelector withObject:@(midiNote) withObject:@(vel) withObject:@(chan)];
    }
  }
}

- (void) sendNoteOff:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned) chan
{
  if (_target != nil) {
    if ([_target respondsToSelector:_noteOffSelector] == YES) {
      [_target performSelector:_noteOffSelector withObject:@(midiNote) withObject:@(vel) withObject:@(chan)];
    }
  }
}

- (void) sendKeyPressure:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned)chan
{
  if (_target != nil) {
    if ([_target respondsToSelector:_keyPressureSelector] == YES) {
      [_target performSelector:_keyPressureSelector withObject:@(midiNote) withObject:@(vel) withObject:@(chan)];
    }

  }
}

- (void) sendControlChange:(NSUInteger)midiParam val:(unsigned)val chan:(unsigned)chan
{
  if (_target != nil) {
    if ([_target respondsToSelector:_controlChangeSelector] == YES) {
      [_target performSelector:_controlChangeSelector withObject:@(midiParam) withObject:@(val) withObject:@(chan)];
    }
  }
}

- (void) sendPgmChange:(NSUInteger)midiPgm chan:(unsigned)chan
{
  if (_target != nil) {
    if ([_target respondsToSelector:_pgmChangeSelector] == YES) {
      [_target performSelector:_pgmChangeSelector withObject:@(midiPgm) withObject:@(chan)];
    }
  }
}

- (void) sendChanPress:(NSUInteger)pressure chan:(unsigned)chan {
  if (_target != nil) {
    if ([_target respondsToSelector:_chanPressSelector] == YES) {
      [_target performSelector:_chanPressSelector withObject:@(pressure) withObject:@(chan)];
    }
  }
}

- (void) sendPitchBend:(NSInteger)pitch chan:(unsigned)chan {
  if (_target != nil) {
    if ([_target respondsToSelector:_pitchBendSelector] == YES) {
      [_target performSelector:_pitchBendSelector withObject:@(pitch) withObject:@(chan)];
    }
  }
}


- (void) sendUsr1:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2
{
  if (_target != nil) {
    if ([_target respondsToSelector:_usr1Selector] == YES) {
      [_target performSelector:_usr1Selector withObject:@(d0) withObject:@(d1) withObject:@(d2)];
    }
  }
}

- (void) sendUsr2:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2
{
  if (_target != nil) {
    if ([_target respondsToSelector:_usr2Selector] == YES) {
      [_target performSelector:_usr2Selector withObject:@(d0) withObject:@(d1) withObject:@(d2)];
    }
  }
}



#pragma clang diagnostic pop

@end
