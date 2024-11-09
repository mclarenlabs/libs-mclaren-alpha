/** -*- mode: objc -*-
 *
 * A colored indicator light.
 *
 * McLaren Labs 2024.
 *
 */

#import "MLLamp.h"
#import "NSColor+ColorExtensions.h"

@implementation MLLamp {
  NSBezierPath *path1;
  NSBezierPath *path2;

  int _state;

}

- (id) initWithFrame:(NSRect)frame {
  if (self = [super initWithFrame:frame]) {

    _color = [NSColor mcBlueColor];
    _state = 0;

    double roundedRadius = 3.0;

    path1 = [NSBezierPath bezierPathWithRoundedRect:_bounds
					    xRadius:roundedRadius
					    yRadius:roundedRadius];
    
    path2 = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(_bounds, 1.0f, 1.0f)
					    xRadius:roundedRadius
					    yRadius:roundedRadius];
  }
  return self;
}

- (void) on {
  if (_state != 1) {
    _state = 1;
    [self setNeedsDisplay:YES];
  }
}

- (void) off {
  if (_state != 0) {
    _state = 0;
    [self setNeedsDisplay:YES];
  }
}

- (void) drawRect:(NSRect)rect {

  // Get the graphics context that we are currently executing under
  NSGraphicsContext* ctx = [NSGraphicsContext currentContext];

  // Draw background - use inset to allow view of focus ring
  [ctx saveGraphicsState];

  [[NSColor darkGrayColor] setFill];
  [path1 fill];

  if (_state > 0) {
    [_color setFill];
    [path2 fill];
  }

  [ctx restoreGraphicsState];
}

@end
