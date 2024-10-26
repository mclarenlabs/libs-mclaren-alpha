/** -*- mode:objc -*-
 *
 * Draw stereo VU meters.
 *
 * McLaren Labs 2024
 */

#import "MLVUMeterView.h"
#import "NSColor+ColorExtensions.h"

@implementation MLVUMeterView {
  double _min;
  double _max;
  double _rmsL;
  double _rmsR;
  double _peakL;
  double _peakR;

  NSColor *_bgColor;
  NSColor *_bluegreen;
  NSColor *_brightgreen;
  NSColor *_black;
}

- (id) initWithFrame:(NSRect)frame {
  if (self = [super initWithFrame:frame]) {

    _min = -40;
    _max = 3;

    // piano key whitish color
    _bgColor = [NSColor colorWithDeviceRed:0.9
				     green:0.9
				      blue:1.0
				     alpha:1.0];

    _bluegreen = [NSColor mcBlueColor];
    _brightgreen = [NSColor mcPurpleColor];
    _black = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0];
  }
  return self;
}

- (void) drawBackground:(NSRect)rect {

  double roundedRadius = 3.0;

  // Get the graphics context that we are currently executing under
  NSGraphicsContext* ctx = [NSGraphicsContext currentContext];

  // Draw background - use inset to allow view of focus ring
  [ctx saveGraphicsState];

  NSBezierPath *path;
  path = [NSBezierPath bezierPathWithRoundedRect:_bounds
					 xRadius:roundedRadius
					 yRadius:roundedRadius];
  [[NSColor darkGrayColor] setFill];
  [path fill];

  path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 1.0f, 1.0f)
					 xRadius:roundedRadius
					 yRadius:roundedRadius];
  [_bgColor setFill];
  [path fill];

  [ctx restoreGraphicsState];
}

/*
 * Draw samples to each x-pixel position and draw vertical lines.
 *
 * For each position, draw the max and min and rms values of the samples in that region.
 */

- (void) drawRms:(double)rms peak:(double)peak rect:(NSRect)rect {

  double ox = rect.origin.x + 2;
  double oy = rect.origin.y + 2;
  
  double width = rect.size.width - 4;
  double height = rect.size.height - 4;

  double x;
  if (rms < _min) {
    x = _min;
  }
  else if (rms > _max) {
    x = _max;
  }
  else {
    x = rms;
  }

  double y;
  if (peak < _min) {
    y = _min;
  }
  else if (peak > _max) {
    y = _max;
  }
  else {
    y = peak;
  }

  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];

  // draw tick bar

  // draw meter bar from the origin
  double bar = ((x - _min) / (_max - _min)) * width;

  NSBezierPath *path;
  NSRect frame = NSMakeRect(ox, oy, bar, height);
  path = [NSBezierPath bezierPathWithRoundedRect:frame
					 xRadius:1
					 yRadius:1];
  [_bluegreen setFill];
  [_black setStroke];

  [path fill];

  // draw peak box
  double box = ((y - _min) / (_max - _min)) * width;
  NSRect peakFrame = NSMakeRect(box-2, oy, 4, height); // x,y,wid,ht
  path = [NSBezierPath bezierPathWithRoundedRect:peakFrame
					 xRadius:1
					 yRadius:1];

  [_brightgreen setFill];
  [path fill];
  

  [ctx restoreGraphicsState];

}

- (void) rmsL:(double)rmsL rmsR:(double)rmsR peakL:(double)peakL peakR:(double)peakR {
  _rmsL = rmsL;
  _rmsR = rmsR;
  _peakL = peakL;
  _peakR = peakR;

  [self performSelectorOnMainThread: @selector(setNeedsDisplay:)
			 withObject: @YES
		      waitUntilDone: NO];
}


- (void) drawRect:(NSRect)rect {

  float midy = NSMidY(_bounds);
  float newheight = NSHeight(_bounds) / 2.0;

  // split the rect into top/bot regions for the left/right channels
  NSRect bot = NSMakeRect(_bounds.origin.x, _bounds.origin.y,
   			  _bounds.size.width, newheight);
  
  NSRect top = NSMakeRect(_bounds.origin.x, midy,
			  _bounds.size.width, newheight);
  

  [self drawBackground:_bounds];

  [self drawRms:_rmsL peak:_peakL rect:bot];
  [self drawRms:_rmsR peak:_peakR rect:top];
}

 

@end
