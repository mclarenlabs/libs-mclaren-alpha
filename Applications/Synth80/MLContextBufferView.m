/** -*- mode:objc -*-
 *
 * Draw a sample buffer to the screen
 *  Influenced by https://manual.audacityteam.org/man/audacity_waveform.html
 *
 * McLaren Labs 2024
 */

#import "MLContextBufferView.h"
#import "NSColor+ColorExtensions.h"

@implementation MLContextBufferView {
  NSColor *_bgColor;
  NSColor *_dotColor;
  NSColor *_fillColor;
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

- (void) drawSamples:(float*)samples num:(int)num cap:(int)cap stride:(int)stride rect:(NSRect)rect {

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
    float samp = samples[i*2 + stride];
    if (fabs(samp) < 1e-9)
      samp = 0;
    double xval=  x + (width * (fi / cap));
    double yval = y + ((samp + 1.0) * (height / 2.0));

    if (cnt == spp) {

#define DRAW_RMS_FILL 0

      double rms = sqrt(squaredsum / cnt);
#if !DRAW_RMS_FILL
      (void) rms;		// tell compiler to ignore it
#endif

      // draw the outline
      {
	[_dotColor setStroke];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(xval, ymin)];
	[path lineToPoint:NSMakePoint(xval, ymax)];
	[path stroke];
      }

#if DRAW_RMS_FILL
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
#endif

      cnt = 0;
      squaredsum = 0.0;
      ymax = -1000.0;
      ymin = 1000.0;
    }

    squaredsum += samp * samp;
    if (cnt == 0) {
      ymin = y + ((-fabs(samp) + 1.0) * (height / 2.0));
      ymax = y + ((fabs(samp) + 1.0) * (height / 2.0));
    }
    else {
      ymin = (yval < ymin) ? yval : ymin;
      ymax = (yval > ymax) ? yval : ymax;
    }
    cnt++;

  }

  [ctx restoreGraphicsState];
}

- (void) drawRect:(NSRect)rect {

  float midy = NSMidY(rect);
  float newheight = NSHeight(rect) / 2.0;

  // split the rect into top/bot regions for the left/right channels
  NSRect bot = NSMakeRect(rect.origin.x, rect.origin.y,
   			  rect.size.width, newheight);
  
  NSRect top = NSMakeRect(rect.origin.x, midy,
			  rect.size.width, newheight);
  

  [self drawBackground:rect];

  if (_sample) {

    MSKSAMPTYPE *frames = _sample->_frames;
    unsigned framenum = [_sample persize];
    

    [self drawSamples:frames num:framenum cap:framenum stride:2 rect:top];

    [self drawSamples:(frames+1) num:framenum cap:framenum stride:2 rect:bot];

  }

}
  

@end
