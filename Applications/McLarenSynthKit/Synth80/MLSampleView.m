/** -*- mode:objc -*-
 *
 * Draw a sample buffer to the screen
 *  Influenced by https://manual.audacityteam.org/man/audacity_waveform.html
 *
 * McLaren Labs 2024
 */

#import "MLSampleView.h"
#import "NSColor+ColorExtensions.h"

@implementation MLSampleView {
  MSKSample *_sample;
  NSColor *_bgColor;
  NSColor *_dotColor;
  NSColor *_fillColor;
}

/*
 * Make our 'sample' property bindable.
 */

+ (void) initialize {
  [self exposeBinding:@"sample"];
}

- (id) initWithFrame:(NSRect)frame {
  if (self = [super initWithFrame:frame]) {

    // piano key whitish color
    _bgColor = [NSColor colorWithDeviceRed:0.9
				     green:0.9
				      blue:1.0
				     alpha:1.0];

    _dotColor = [NSColor mcBlueColor];
    _fillColor = [NSColor mcPurpleColor];
  }
  return self;
}

/*
 * Set/Get sample - with auto-redraw for setting new sample
 */

- (MSKSample*) sample {
  return _sample;
}

- (void) setSample:(MSKSample*)samp {
  _sample = samp;

  [self performSelectorOnMainThread: @selector(setNeedsDisplay:)
			 withObject: @YES
		      waitUntilDone: NO];
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

- (void) drawBasename:(NSRect)rect {

  NSString *str = _sample.basename;
  NSColor *color = [NSColor blackColor];
  NSDictionary *attrs = @{
  NSForegroundColorAttributeName: color
  };

  double ypos = (_bounds.size.height / 2.0) - 6.0;
  [str drawAtPoint:NSMakePoint(10, ypos) withAttributes: attrs];

}


/*
 * Draw samples to each x-pixel position and draw vertical lines.
 *
 * For each position, draw the max and min and rms values of the samples in that region.
 */

- (void) drawSamples:(float*)samples num:(int)num cap:(int)cap stride:(int)stride offset:(int)offset rect:(NSRect)rect {

  double x = rect.origin.x;
  double y = rect.origin.y;
  double width = rect.size.width;
  double height = rect.size.height;

  // samples per pixel
  int spp = num / width; // one pixel

  // Get the graphics context that we are currently executing under
  NSGraphicsContext* ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];

  [_dotColor setFill];
  [_fillColor setStroke];

  int cnt = 0;
  double squaredsum = 0.0;
  double ymax = -1000.0;
  double ymin = 1000.0;

  for (int i = 0; i < num; i+= 1) {
    float fi = i;
    float samp = samples[i*stride + offset];
    double xval=  x + (width * (fi / cap));
    double yval = y + ((samp + 1.0) * (height / 2.0));

    if (cnt == spp) {

      double rms = sqrt(squaredsum / cnt);

      // draw the outline
      {
	[_dotColor setStroke];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(xval, ymin)];
	[path lineToPoint:NSMakePoint(xval, ymax)];
	[path stroke];
      }

      // draw the rms fill
      {
	[_fillColor setStroke];
	NSBezierPath *path = [NSBezierPath bezierPath];
	double ypos = y + ((rms + 1.0) * (height / 2.00));
	double ymin = y + ((-rms + 1.0) * (height / 2.00));
	[path moveToPoint:NSMakePoint(xval, ypos)];
	[path lineToPoint:NSMakePoint(xval, ymin)];
	[path stroke];
      }

      cnt = 0;
      squaredsum = 0.0;
      ymax = -1000.0;
      ymin = 1000.0;
    }

    squaredsum += samp * samp;
    ymin = (yval < ymin) ? yval : ymin;
    ymax = (yval > ymax) ? yval : ymax;
    cnt++;

  }

  [ctx restoreGraphicsState];
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
  if (_sample) {

    int stride = _sample.channels;

    [self drawSamples:[_sample frame:0] num:[_sample frames] cap:[_sample capacity] stride:stride offset:0 rect:top];

    if (stride > 1) {
      [self drawSamples:[_sample frame:0] num:[_sample frames] cap:[_sample capacity] stride:stride offset:1 rect:bot];
    }

    [self drawBasename:_bounds];
  }


}
 

@end
