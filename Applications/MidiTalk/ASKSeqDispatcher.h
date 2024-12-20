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

// @property (readwrite, nonatomic, weak) id target;

@property (readwrite, nonatomic) id anyEventTarget;
@property (readwrite, nonatomic) id noteOnTarget;
@property (readwrite, nonatomic) id noteOffTarget;
@property (readwrite, nonatomic) id keyPressureTarget;
@property (readwrite, nonatomic) id controlChangeTarget;
@property (readwrite, nonatomic) id pgmChangeTarget;
@property (readwrite, nonatomic) id chanPressTarget;
@property (readwrite, nonatomic) id pitchBendTarget;
@property (readwrite, nonatomic) id usr1Target;
@property (readwrite, nonatomic) id usr2Target;

@property (readwrite, nonatomic, assign) SEL anyEventSelector; // @selector(seqEvent:
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
- (void) sendAnyEvent:(ASKSeqEvent*)evt;
- (void) sendNoteOn:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned)chan;
- (void) sendNoteOff:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned)chan;
- (void) sendKeyPressure:(NSUInteger)midiNote vel:(unsigned)vel chan:(unsigned)chan;
- (void) sendControlChange:(NSUInteger)midiParam val:(unsigned)val chan:(unsigned)chan;

- (void) sendPgmChange:(NSUInteger)midiPgm chan:(unsigned)chan;
- (void) sendChanPress:(NSUInteger)pressure chan:(unsigned)chan;
- (void) sendPitchBend:(NSInteger)pitch chan:(unsigned)chan;

- (void) sendUsr1:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2;
- (void) sendUsr2:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2;

//
// USER: Register Callbacks
//

- (void) onAnyEvent:(id)block;
- (void) onAnyEvent:(SEL)sel target:(id)target;

- (void) onNoteOn:(id)block;
- (void) onNoteOn:(SEL)sel target:(id)target;

- (void) onNoteOff:(id)block;
- (void) onNoteOff:(SEL)sel target:(id)target;

- (void) onKeyPressure:(id)block;
- (void) onKeyPressure:(SEL)sel target:(id)target;

- (void) onControlChange:(id)block;
- (void) onControlChange:(SEL)sel target:(id)target;

- (void) onPgmChange:(id)block;
- (void) onPgmChange:(SEL)sel target:(id)target;

- (void) onChanPress:(id)block;
- (void) onChanPress:(SEL)sel target:(id)target;

- (void) onPitchBend:(id)block;
- (void) onPitchBend:(SEL)sel target:(id)target;

- (void) onUsr1:(id)block;
- (void) onUsr1:(SEL)sel target:(id)target;

- (void) onUsr2:(id)block;
- (void) onUsr2:(SEL)sel target:(id)target;
@end
