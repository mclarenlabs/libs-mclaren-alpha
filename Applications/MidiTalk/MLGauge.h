/** -*- mode: objc -*-
 * 
 * A Gauge is rotary display and control.
 * It maps a one-dimensional value onto an arc and displays its value 
 * inside the circle.
 *
 */

#import <AppKit/AppKit.h>

typedef void (^MLGaugeCallbackBlock)(double);

@interface MLGauge : NSView

// these properties describe the arc of the gauge
@property (readwrite) double centerx;
@property (readwrite) double centery;
@property (readwrite) double radius;

// the gauge begins at ends at the degress shown (clock-wise, origin is at 3:00)
@property (readwrite) double degStart;
@property (readwrite) double degEnd;

// The color used to draw and lighten/darken
@property (readwrite) NSColor *color;

// how wide the arc is drawn
@property (readwrite) double arcWidth;

// ticks - how many ticks and their Y coordinates
@property (readwrite) int ticks;
@property (readwrite) int tick_ylo;
@property (readwrite) int tick_yhi;

// the user coordinates map [userstart..userend] onto [radstart..radend]
@property (readwrite) double userStart;
@property (readwrite) double userEnd;

// the increment step size for normal adjustment, and fine adjustment
@property (readwrite) double coarseAdj;
@property (readwrite) double fineAdj;

// the progress in user coords
@property (readwrite) double userProgress;

// the font and numeric format for the value
@property (readwrite) NSFont *font;
@property (readwrite) NSString *format;

// font and string for the legend, if there is one
@property (readwrite) NSFont *legendFont;
@property (readwrite) NSString *legend;

// does the arc start at zero, or is it a dot?
@property (readwrite) BOOL isDot;

// signal callback
@property (readwrite, copy) MLGaugeCallbackBlock valueChangedBlock;

// set and get the current value of the 'progress' in user coords
- (void) setDoubleValue:(double) progress;
- (double) doubleValue;

// Event protocol OUT
@property (readwrite, nonatomic) id target;
@property (readwrite, nonatomic, assign) SEL action;

@end
