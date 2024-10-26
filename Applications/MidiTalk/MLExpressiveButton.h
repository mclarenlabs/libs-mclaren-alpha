/** -*- mode: objc -*-
 *
 * A Button-like control that emits noteOn, noteOff and keyPressure (aftertouch) events.
 *
 * This control also applies keyboard event de-repeating so that it can be 
 * played from the laptop keyboard.
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MLExpressiveButtonCell : NSButtonCell
@property (readwrite, atomic) NSColor *color;
@end

@interface MLExpressiveButton : NSButton

+ (Class) cellClass;
- (MLExpressiveButtonCell*) cell;

// Event methods IN
- (void) noteOn:(unsigned)midiNote vel:(unsigned)vel;
- (void) noteOff:(unsigned)midiNote vel:(unsigned)vel;

// MIDI map - what it sends and responds to
@property (readwrite, atomic) int midiNote; // default 0
@property (readwrite) unsigned velocity; // defaults to 127

// Event protocol OUT
@property (readwrite, nonatomic) id noteOnTarget;
@property (readwrite, nonatomic) id noteOffTarget;
@property (readwrite, nonatomic) id keyPressureTarget;

@property (readwrite, nonatomic, assign) SEL noteOnSelector; // @selector(butNoteOn:vel:)
@property (readwrite, nonatomic, assign) SEL noteOffSelector; // @selector(butNoteOff:vel:)
@property (readwrite, nonatomic, assign) SEL keyPressureSelector; // @selector(butKeyPressure:vel:)

// internal
- (void) sendNoteOn:(unsigned)midiNote vel:(unsigned)vel;
- (void) sendNoteOff:(unsigned)midiNote vel:(unsigned)vel;
- (void) sendKeyPressure:(unsigned)midiNote vel:(unsigned)vel;

//
// USER: Register Callbacks
//

- (void) onNoteOn:(id)block;
- (void) onNoteOn:(SEL)sel target:(id)target;

- (void) onNoteOff:(id)block;
- (void) onNoteOff:(SEL)sel target:(id)target;

- (void) onKeyPressure:(id)block;
- (void) onKeyPressure:(SEL)sel target:(id)target;


@end

