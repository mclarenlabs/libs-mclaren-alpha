/** -*- mode: objc -*-
 *
 * MLPiano: a piano keyboard
 *
 * McLaren 2023
 */

#import <Cocoa/Cocoa.h>
#import "MLInputView.h"

@interface MLPiano : MLInputView

// background color
@property (readwrite) NSColor* bgColor;

// Keys start at C, how many whole notes to draw
//   keyboard widget needs (totalWholeNotes * ww) of horizontal space
//   8=octave, 15=two-octaves 22=three-octaves 29=four-octaves
@property (readwrite) int totalWholeNotes;

// white key properties
@property (readwrite) int ww; // white width
@property (readwrite) int wh; // white height
@property (readwrite) NSColor *wc; // white color

// black key properties
@property (readwrite) int bw; // black width
@property (readwrite) int bh; // black height
@property (readwrite) NSColor *bc; // black color

// internal: for drawing, mapping of index to coordinates
- (NSRect) whiteCoords:(int)i;
- (NSRect) blackCoords:(int)i;

// internal: for mapping mouse hits to index
- (BOOL) isBlackKey:(int)x y:(int)y index:(int*)index;
- (BOOL) isWhiteKey:(int)x y:(int)y index:(int*)index;

// config: MIDI translation
@property (readwrite) int octave; // 4 is C4 for middle C (midi 60)
@property (readwrite) unsigned velocity; // defaults to 127

// internal: mapping MIDI to indexes
- (int) midiNoteForIndex:(int)index isBlack:(BOOL)isBlack;
- (int) indexForMidiNote:(int)midiNote isBlack:(int*)isBlack;

// Event methods IN
- (void) noteOn:(unsigned)midiNote vel:(unsigned)vel;
- (void) noteOff:(unsigned)midiNote vel:(unsigned)vel;

// Keyboard map accelerator keys - "awsedftgyhujkolp;'"
@property (readwrite) NSString *accel;
@property (readwrite) NSFont *accelFont;

// Event protocol OUT
@property (readwrite, nonatomic) id noteOnTarget;
@property (readwrite, nonatomic) id noteOffTarget;

@property (readwrite, nonatomic, assign) SEL noteOnSelector; // @selector(pianoNoteOn:vel:)
@property (readwrite, nonatomic, assign) SEL noteOffSelector; // @selector(pianoNoteOff:vel:)

// internal
- (void) sendNoteOn:(unsigned)midiNoteNote vel:(unsigned)vel;
- (void) sendNoteOff:(unsigned)midiNoteNote vel:(unsigned)vel;

//
// USER: Register Callbacks
//

- (void) onNoteOn:(id)block;
- (void) onNoteOn:(SEL)sel target:(id)target;

- (void) onNoteOff:(id)block;
- (void) onNoteOff:(SEL)sel target:(id)target;

@end
