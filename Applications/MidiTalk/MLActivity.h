/** -*- mode: objc -*-
 *
 * A colored activity indicator light.
 *
 * McLaren Labs 2024.
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MLActivity : NSView

@property (readwrite) NSColor *color; // the color to draw

- (void) tickle;

@end
