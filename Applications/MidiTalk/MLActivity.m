/** -*- mode: objc -*-
 *
 * A colored activity indicator light.
 *
 * McLaren Labs 2024.
 *
 */

#import "MLActivity.h"
#import "NSColor+ColorExtensions.h"

@implementation MLActivity {
  NSBezierPath *path1;
  NSBezierPath *path2;

  int _count; // probably needs to be atomic
  int _state;

}

- (id) initWithFrame:(NSRect)frame {
  if (self = [super initWithFrame:frame]) {

    _color = [NSColor mcBlueColor];
    _count = 0;

    double roundedRadius = 3.0;

    path1 = [NSBezierPath bezierPathWithRoundedRect:_bounds
					    xRadius:roundedRadius
					    yRadius:roundedRadius];
    
    path2 = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(_bounds, 1.0f, 1.0f)
					    xRadius:roundedRadius
					    yRadius:roundedRadius];

    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 0.1
						  target: self
						selector: @selector(timeout)
						userInfo: nil
						 repeats: YES];

    // allow timer to fire while slider dragging is happening
    [[NSRunLoop mainRunLoop] addTimer:t forMode:NSRunLoopCommonModes];
    [[NSRunLoop mainRunLoop] addTimer:t forMode:NSEventTrackingRunLoopMode];
  }
  return self;
}

- (void) tickle {
  _count++;
}

- (void) timeout {
  int newstate;

  if (_count == 0) {
    newstate = 0;
  }
  else {
    newstate = 1;
  }

  // reset the tickler
  _count = 0;

  if (_state != newstate) {
    _state = newstate;
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
