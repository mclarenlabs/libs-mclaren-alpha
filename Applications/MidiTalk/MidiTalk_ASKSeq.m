/** -*- mode: objc -*-
 *
 * A specialization of ASKSeq for MidiTalk that indicates input/output
 * activity.
 *
 * McLaren Labs 2024
 */

#import "MidiTalk_ASKSeq.h"

@implementation MidiTalk_ASKSeq

- (id) initWithOptions:(ASKSeqOptions*)options error:(NSError**)error {
  if (self = [super initWithOptions:options error:error]) {

  // connect up listener for the MIDI IN activity indicator
  __weak MidiTalk_ASKSeq *wself = self;
  int myOwnClient = [self getClient];
  [self addListener:^(NSArray *evts) {
      // [wself.midiInActivity tickle];
      for (ASKSeqEvent *e in evts) {

	// Only trigger events from outside.  We do not want to show activity
	// for every Metronome event that fires!
	if (e->_ev.source.client != myOwnClient) {
	  [wself.midiInActivity tickle];
	}

	// Metronome events are from ourselves.  The MIDI CLOCK
	// message is triggered with each USR2.
	if (e->_ev.source.client == myOwnClient) {
	  if (e->_ev.type == SND_SEQ_EVENT_USR2) {
	    int beat = e->_ev.data.raw32.d[0];
	    int clock = e->_ev.data.raw32.d[1];
	    if (beat == 0 && clock == 0) {
	      [wself.metronomeBeatActivity tickle];
	    }
	  }
	}
      }
    }];
    
    
  }
  return self;
}

- (void) output:(ASKSeqEvent*) ev {
  [super output:ev];
  [_midiOutActivity tickle];
}

- (void) outputDirect:(ASKSeqEvent*) ev {
  [super output:ev];
  [_midiOutActivity tickle];
}

@end
