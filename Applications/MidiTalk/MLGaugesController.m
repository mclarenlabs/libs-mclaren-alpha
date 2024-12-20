/** *-* mode; objc *-*
 *
 * Controller to hold array of MLGauges
 *
 * McLaren Labs 2024
 *
 */

#import "MLGaugesController.h"
#import "GSTable-MLdecls.h"
#import "NSColor+ColorExtensions.h"

@implementation MLGaugesController

- (id) init {

  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) { // nsbox
    [self setTitle:@"Gauges"];
    [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    GSTable *tab = [[GSTable alloc] initWithNumberOfRows:1 numberOfColumns:6];

    [self  makeGauges];
    
    [tab putView: _gauge1
	   atRow: 0 column: 0 withMargins: 5];

    [tab putView: _gauge2
	   atRow: 0 column: 1 withMargins: 5];

    [tab putView: _gauge3
	   atRow: 0 column: 2 withMargins: 5];

    [tab putView: _gauge4
	   atRow: 0 column: 3 withMargins: 5];

    [tab putView: _gauge5
	   atRow: 0 column: 4 withMargins: 5];

    [tab putView: _gauge6
	   atRow: 0 column: 5 withMargins: 5];

    [tab setXResizingEnabled: YES forColumn: 0];
    [tab setXResizingEnabled: YES  forColumn: 1];
    [tab setXResizingEnabled: YES  forColumn: 2];
    [tab setXResizingEnabled: YES  forColumn: 3];
    
    [tab setYResizingEnabled: YES forRow: 0];

    [self setContentView: tab];
    [self sizeToFit];
  }
  return self;

}

- (MLGauge*) makeGaugeORIG:(NSRect)rect
{

  MLGauge *gauge = [[MLGauge alloc] initWithFrame:rect];

  gauge.centerx = 50;
  gauge.centery = 50;
  gauge.radius = 40;
  gauge.degStart = 225;
  gauge.degEnd = -45;
  gauge.arcWidth = 16;
  gauge.userStart = 0.0;
  gauge.userEnd = 1.0;
  gauge.userProgress = 0.0;
  gauge.coarseAdj = 0.1;
  gauge.fineAdj = 0.01;

  gauge.font = [NSFont userFixedPitchFontOfSize:20.0];
  gauge.format = @"%d";
  gauge.legendFont = [NSFont userFixedPitchFontOfSize:10.0];
  gauge.legend = @"title";

  return gauge;
}

- (MLGauge*) makeGauge:(NSRect)rect
{

  MLGauge *gauge = [[MLGauge alloc] initWithFrame:rect];

  gauge.centerx = 50;
  gauge.centery = 50;
  gauge.radius = 40;
  gauge.degStart = 225;
  gauge.degEnd = -45;
  gauge.arcWidth = 16;

  // default range is [0..127]
  gauge.userStart = 0;
  gauge.userEnd = 127;
  gauge.userProgress = 0.0;
  gauge.coarseAdj = 1;
  gauge.fineAdj = 1;

  gauge.font = [NSFont userFixedPitchFontOfSize:20.0];
  gauge.format = @"%g";
  gauge.legendFont = [NSFont userFixedPitchFontOfSize:10.0];
  gauge.legend = @"title";

  return gauge;
}

- (void) makeGauges
{

  NSRect rect = NSMakeRect(0, 0, 100, 100);

  _gauge1 = [self makeGauge:rect];
  _gauge1.color = [NSColor mcBlueColor];
  _gauge1.legend = @"gauge1";
  _gauge1.userStart = 0;
  _gauge1.userEnd = 127;

  _gauge2 = [self makeGauge:rect];
  _gauge2.color = [NSColor mcGreenColor];

  // make this a midi controller CC8 0..127
  _gauge2.legend = @"gauge2";
  _gauge2.format = @"%g";  
  _gauge2.userStart = 0;
  _gauge2.userEnd = 127;
  _gauge2.coarseAdj = 1;
  _gauge2.fineAdj = 1;
  
  _gauge3 = [self makeGauge: rect];
  _gauge3.color = [NSColor mcOrangeColor];

  _gauge4 = [self makeGauge: rect];
  _gauge4.color = [NSColor mcPurpleColor];

  _gauge5 = [self makeGauge: rect];
  _gauge5.color = [NSColor mcBlueColor];

  _gauge6 = [self makeGauge: rect];
  _gauge6.color = [NSColor mcGreenColor];

}
@end
