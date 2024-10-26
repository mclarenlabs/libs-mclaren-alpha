/* -*- mode: objc -*-
 *
 * Convenience methods for creating, accessing and parsing seq events.
 *
 * $copyright$
 *
 */

#include "AlsaSoundKit/ASKSeqEvent.h"

@interface ASKSeqEvent(additions)

//
// Create a new Sequencer Event
//

+ (ASKSeqEvent*) eventWithNoteOn:(unsigned)note vel:(unsigned)vel chan:(unsigned)chan;
+ (ASKSeqEvent*) eventWithNoteOff:(unsigned)note vel:(unsigned)vel chan:(unsigned)chan;
+ (ASKSeqEvent*) eventWithKeyPressure:(unsigned)note vel:(unsigned)vel chan:(unsigned)chan;
+ (ASKSeqEvent*) eventWithControlChange:(unsigned)param val:(unsigned)val chan:(unsigned)chan;
+ (ASKSeqEvent*) eventWithPgmChange:(unsigned)val chan:(unsigned)chan;
+ (ASKSeqEvent*) eventWithChanPressure:(unsigned)val chan:(unsigned)chan;
+ (ASKSeqEvent*) eventWithPitchBend:(signed int)val chan:(unsigned)chan;

+ (ASKSeqEvent*) eventWithUsr1:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2;
+ (ASKSeqEvent*) eventWithUsr2:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2;;

//
// Modify a created Sequencer Event - set destination
//

- (void) setSubs; // send to all subscribers, dest port unknown
- (void) setBroadcast; // all clients/ports
- (void) setDest:(unsigned char)client port:(unsigned char)port; // explicit client/port

//
// Modify a created Sequencer Event - set queue
//

- (void) setDirect; // no queue
- (void) setScheduleTick:(unsigned char)queue isRelative:(BOOL)isRelative ttick:(unsigned)ttick;
- (void) setScheduleReal:(unsigned char)queue isRelative:(BOOL)isRelative sec:(unsigned)sec nsec:(unsigned)nsec;

//
// Predicates
//

- (BOOL) isNoteOn;
- (BOOL) isNoteOff;
- (BOOL) isKeyPressure;
- (BOOL) isControlChange;
- (BOOL) isPgmChange;
- (BOOL) isChanPressure;
- (BOOL) isPitchBend;
- (BOOL) isUsr1;
- (BOOL) isUsr2 ;

//
// Parsers
//

- (BOOL) parseNoteOn:(NSObject*)block;
- (BOOL) parseNoteOff:(NSObject*)block;
- (BOOL) parseKeyPressure:(NSObject*)block;
- (BOOL) parseControlChange:(NSObject*)block;
- (BOOL) parsePgmChange:(NSObject*)block;
- (BOOL) parseChanPressure:(NSObject*)block;
- (BOOL) parsePitchBend:(NSObject*)block;
- (BOOL) parseUsr1:(NSObject*)block;
- (BOOL) parseUsr2:(NSObject*)block;


@end
