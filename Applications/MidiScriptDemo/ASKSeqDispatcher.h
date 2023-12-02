/* -*- mode: objc -*-
 *
 * An object that registers as an ASKSeq listener and dispatches on the main queue.
 *
 * For each event received from the Seq, a message is sent to the target with
 * a specific selector.  This technique makes it easy to use in StepTalk scripts
 * where each event received will invoke a different method in the script.
 *
 * $copyright$
 *
 */

#include "AlsaSoundKit/ASKSeq.h"

@interface ASKSeqDispatcher : NSObject

@property (readwrite, nonatomic, weak) id target;

@property (readwrite, nonatomic, assign) SEL noteOnSelector; // @selector(seqNoteOn:vel:chan:)
@property (readwrite, nonatomic, assign) SEL noteOffSelector; // @selector(seqNoteOff:vel:chan:)
@property (readwrite, nonatomic, assign) SEL keyPressureSelector; // @selector(seqKeyPressure:vel:chan:);
@property (readwrite, nonatomic, assign) SEL controlChangeSelector; // @selector(seqControlChange:val:chan:);
@property (readwrite, nonatomic, assign) SEL pgmChangeSelector; // @selector(seqPgmChange:chan:);
@property (readwrite, nonatomic, assign) SEL chanPressSelector; // @selector(seqChanPress:chan:);
@property (readwrite, nonatomic, assign) SEL pitchBendSelector; // @selector(seqPitchBend:chan:);
@property (readwrite, nonatomic, assign) SEL usr1Selector; // @selector(seqUsr1:d1:d2:)
@property (readwrite, nonatomic, assign) SEL usr2Selector; // @selector(seqUsr2:d1:d2:)

- (id) initWithSeq:(ASKSeq*)seq;

//
// Private - used internally - but could potentially be overridden
//
- (void) sendNoteOn:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned)chan;
- (void) sendNoteOff:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned)chan;
- (void) sendKeyPressure:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned)chan;
- (void) sendControlChange:(NSUInteger)midiParam val:(unsigned)val chan:(unsigned)chan;

- (void) sendPgmChange:(NSUInteger)midiPgm chan:(unsigned)chan;
- (void) sendChanPress:(NSUInteger)pressure chan:(unsigned)chan;
- (void) sendPitchBend:(NSInteger)pitch chan:(unsigned)chan;

- (void) sendUsr1:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2;
- (void) sendUsr2:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2;

@end
