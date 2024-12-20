/** -*- mode: objc -*-
 *
 * A specialization of ASKSeq for MidiTalk that indicates input/output
 * activity.
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"
#import "MLActivity.h"

@interface MidiTalk_ASKSeq : ASKSeq

@property (readwrite) MLActivity *metronomeBeatActivity;
@property (readwrite) MLActivity *midiInActivity;
@property (readwrite) MLActivity *midiOutActivity;

@end
