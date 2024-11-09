/** -*- mode: objc -*-
 *
 * A colored indicator light.
 *
 * McLaren Labs 2024.
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MLLamp : NSView

@property (readwrite) NSColor *color; // the color to draw

- (void) on;
- (void) off;

@end
