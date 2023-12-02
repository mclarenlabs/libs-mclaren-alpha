/** -*- mode: objc -*-
 *
 * MLPad: a 4x4 grid of pads to click, press or keystroke.
 *
 * mouse coords (X, Y).  Cell coords (i, j)
 *
 * McLaren 2023
 */

#import <Cocoa/Cocoa.h>
#import "MLInputView.h"

@interface MLPad : MLInputView // inherit keyboard handling

// background and color of each column
@property (readwrite) NSColor* bgColor;
@property (readwrite) NSArray<NSColor*>* colors;

// the sizes of the cells and the margins
@property (readwrite) double xwid;
@property (readwrite) double ywid;
@property (readwrite) double margin;

// internal maps
- (NSRect) rectForCell:(int)i j:(int)j;
- (NSColor*) colorForCell:(int)i j:(int)j;
- (BOOL) isHighlighted:(int)i j:(int)j;

// character accelerators [16] chars!!
@property (readwrite) NSString *accel;
@property (readwrite) NSFont *accelFont;
@property (readwrite) NSColor *accelColor;

// labels in each cell
@property (readwrite) NSMutableArray<NSString*>* labels;
@property (readwrite) NSFont *labelFont;
@property (readwrite) NSColor *labelColor;

// Event methods IN
- (void) padNoteOn:(unsigned)midiNote vel:(unsigned)vel;
- (void) padNoteOff:(unsigned)midiNote vel:(unsigned)vel;

// Event protocol OUT
@property (readonly) NSMutableArray<NSNumber*>* midiMap; // map[0..15] => midi
@property (readwrite) unsigned velocity; // defaults to 127
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic, assign) SEL noteOnSelector; // @selector(padNoteOn:)
@property (readwrite, nonatomic, assign) SEL noteOffSelector; // @selector(padNoteOff:)

// internal - translate index to midiNote out
- (void) sendNoteOn:(unsigned)index vel:(unsigned)vel;
- (void) sendNoteOff:(unsigned)index vel:(unsigned)vel;

@end
