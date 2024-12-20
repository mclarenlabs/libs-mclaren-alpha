/**
 * Context controller adjusts volume and visualizes RMS
 *
 */

#import "MLContextController.h"
#import "GSTable-MLdecls.h"

@implementation MLContextController

- (void) makeWidgets {

  NSRect textRect = NSMakeRect(0, 0, 50, 25);
  NSRect sampleRect = NSMakeRect(0, 0, 100, 40);
  
  _volumeValue = [[NSTextField alloc] initWithFrame:textRect];
  [_volumeValue setEditable: YES];
  [_volumeValue setBezeled: YES];
  [_volumeValue setDrawsBackground: YES];

  _volumeSlider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, 20, 50)];
  [_volumeSlider setMinValue:0];
  [_volumeSlider setMaxValue:100];
  // [_volumeSlider setNumberOfTickMarks:101];
  [_volumeSlider setContinuous:YES];
  [_volumeSlider setAutoresizingMask: NSViewHeightSizable];

  _vuMeterView = [[MLVUMeterView alloc] initWithFrame: sampleRect];
  [_vuMeterView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

}

- (id) initWithTitle:(NSString*)title {

  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) { // nsbox
    [self setTitle:title];
    [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable ];

    [self makeWidgets];

    GSHbox *hbox = [GSHbox new];
    GSVbox *vbox = [GSVbox new];

    [vbox addView: _volumeSlider enablingYResizing: YES withMinYMargin:5];
    [vbox addView: _volumeValue enablingYResizing: NO withMinYMargin: 5];
    [vbox setAutoresizingMask: NSViewHeightSizable];

    [hbox addView: vbox enablingXResizing: NO withMinXMargin: 5];
    [hbox addView: _vuMeterView enablingXResizing: YES withMinXMargin: 5];
    [hbox setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    [self setContentView: hbox];
    [self sizeToFit];
  }
  return self;
}

- (void) bindToContext:(MSKContext*)ctx {

    [_volumeSlider bind:@"value"
	       toObject: ctx
	    withKeyPath: @"volume"
		options: nil];

    [_volumeValue bind:@"value"
	      toObject: ctx
	    withKeyPath: @"volume"
		options: nil];

}


@end
