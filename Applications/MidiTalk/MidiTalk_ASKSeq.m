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
  [self addListener:^(NSArray *evts) {
      [wself.midiInActivity tickle];
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
