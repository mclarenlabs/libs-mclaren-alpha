/* -*- mode: objc -*-
 *
 * An object that registers as an ASKSeq listener and dispatches on the main queue.
 *
 * $copyright$
 *
 */

#include "NSObject+additions.h"
#include "ASKSeqDispatcher.h"
#include "apply.h"

@implementation ASKSeqDispatcher {
  ASKSeq *_seq;
  ASKSeqListener _block;
}

- (void) handleEvent:(ASKSeqEvent*)e
{
  // NSLog(@"handleEvent:%@", e);

  [self sendAnyEvent:e];	// handle any event
  
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
    _anyEventSelector = @selector(seqEvent:);
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

/*
 * The Senders
 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void) sendAnyEvent:(ASKSeqEvent*)evt
{
  if (_anyEventTarget != nil) {
    if ([_anyEventTarget respondsToSelector:_anyEventSelector] == YES) {
      [_anyEventTarget performSelector:_anyEventSelector withObject:evt];
    }
  }
  
}
#pragma clang diagnostic pop

- (void) sendNoteOn:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned) chan
{
  applyWithThreeInts(_noteOnTarget, _noteOnSelector, midiNote, vel, chan);
}

- (void) sendNoteOff:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned) chan
{
  applyWithThreeInts(_noteOffTarget, _noteOffSelector, midiNote, vel, chan);
}

- (void) sendKeyPressure:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned)chan
{
  applyWithThreeInts(_keyPressureTarget, _keyPressureSelector, midiNote, vel, chan);
}

- (void) sendControlChange:(NSUInteger)midiParam val:(unsigned)val chan:(unsigned)chan
{
  applyWithThreeInts(_controlChangeTarget, _controlChangeSelector, midiParam, val, chan);
}

- (void) sendPgmChange:(NSUInteger)midiPgm chan:(unsigned)chan
{
  applyWithTwoInts(_pgmChangeTarget, _pgmChangeSelector, midiPgm, chan);
}

- (void) sendChanPress:(NSUInteger)pressure chan:(unsigned)chan {
  applyWithTwoInts(_pgmChangeTarget, _pgmChangeSelector, pressure, chan);
}

- (void) sendPitchBend:(NSInteger)pitch chan:(unsigned)chan {
  applyWithTwoInts(_pitchBendTarget, _pitchBendSelector, pitch, chan);
}


- (void) sendUsr1:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2
{
  applyWithThreeInts(_usr1Target, _usr1Selector, d0, d1, d2);
}

- (void) sendUsr2:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2
{
  applyWithThreeInts(_usr2Target, _usr2Selector, d0, d1, d2);
}

/*
 * USER: register callbacks
 */

- (void) onAnyEvent:(SEL)sel target:(id)target {
  _anyEventTarget = target;
  _anyEventSelector = sel;
}

- (void) onAnyEvent:(id)block {
  [self onAnyEvent:@selector(value:) target:block];
}

- (void) onNoteOn:(SEL)sel target:(id)target {
  _noteOnTarget = target;
  _noteOnSelector = sel;
}

- (void) onNoteOn:(id)block {
  [self onNoteOn:@selector(value:value:value:) target:block];
}

- (void) onNoteOff:(SEL)sel target:(id)target {
  _noteOffTarget = target;
  _noteOffSelector = sel;
}

- (void) onNoteOff:(id)block {
  [self onNoteOff:@selector(value:value:value:) target:block];
}

- (void) onKeyPressure:(SEL)sel target:(id)target {
  _keyPressureTarget = target;
  _keyPressureSelector = sel;
}
  
- (void) onKeyPressure:(id)block {
  [self onKeyPressure:@selector(value:value:value:) target:block];
}
  
- (void) onControlChange:(SEL)sel target:(id)target {
  _controlChangeTarget = target;
  _controlChangeSelector = sel;
}

- (void) onControlChange:(id)block {
  [self onControlChange:@selector(value:value:value:) target:block];
}

- (void) onPgmChange:(SEL)sel target:(id)target {
  _pgmChangeTarget = target;
  _pgmChangeSelector = sel;
}

- (void) onPgmChange:(id)block {
  [self onPgmChange:@selector(value:value:) target:block];
}

- (void) onChanPress:(SEL)sel target:(id)target {
  _chanPressTarget = target;
  _chanPressSelector = sel;
}

- (void) onChanPress:(id)block {
  [self onChanPress:@selector(value:value:) target:block];
}

- (void) onPitchBend:(SEL)sel target:(id)target {
  _pitchBendTarget = target;
  _pitchBendSelector = sel;
}

- (void) onPitchBend:(id)block {
  [self onPitchBend:@selector(value:value:) target:block];
}

- (void) onUsr1:(SEL)sel target:(id)target {
  _usr1Target = target;
  _usr1Selector = sel;
}

- (void) onUsr1:(id)block {
  [self onUsr1:@selector(value:value:) target:block];
}

- (void) onUsr2:(SEL)sel target:(id)target {
  _usr2Target = target;
  _usr2Selector = sel;
}

- (void) onUsr2:(id)block {
  [self onUsr2:@selector(value:value:) target:block];
}



@end
