/**
 *
 */

#import <Cocoa/Cocoa.h>

@interface NSColor (ColorExtensions)

- (NSColor *)lightenColorByValue:(float)value;
- (NSColor *)darkenColorByValue:(float)value;
- (BOOL)isLightColor;

+ (NSColor *) mcBlueColor;
+ (NSColor *) mcOrangeColor;
+ (NSColor *) mcGreenColor;
+ (NSColor *) mcPurpleColor;
+ (NSColor *) mcYellowColor;

+ (NSColor *) twDefault; // white
+ (NSColor *) twPrimary; // blue
+ (NSColor *) twInfo; // blue-green
+ (NSColor *) twSuccess; // avocado green
+ (NSColor *) twWarning; // orange
+ (NSColor *) twDanger; // red
+ (NSColor *) twInverse; // black;

@end
