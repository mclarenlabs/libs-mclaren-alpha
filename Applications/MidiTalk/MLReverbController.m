/** -*- mode: objc -*-
 *
 * Controller for MSKEnvelopeModel
 *
 */

#import <AppKit/AppKit.h>
#import "MLReverbController.h"

@implementation MLReverbController

- (void) makeWidgets {

  NSRect textRect = NSMakeRect(0, 0, 100, 25);
  NSRect sliderRect = NSMakeRect(0, 0, 200, 25);

  // Dry
  _drySlider = [[NSScrollSlider alloc] initWithFrame:sliderRect];
  [_drySlider setAutoresizingMask: NSViewWidthSizable];
  [_drySlider setTitle:@"dry"];
  [_drySlider setMinValue: 0.0];
  [_drySlider setMaxValue: 100.0];
  [_drySlider setNumberOfTickMarks:101];
  [_drySlider setAllowsTickMarkValuesOnly:YES];
  
  _dryText = [[NSTextField alloc] initWithFrame:textRect];

  // Wet
  _wetSlider = [[NSScrollSlider alloc] initWithFrame:sliderRect];
  [_wetSlider setAutoresizingMask: NSViewWidthSizable];
  [_wetSlider setTitle:@"wet"];
  [_wetSlider setMinValue: 0.0];
  [_wetSlider setMaxValue: 100.0];
  [_wetSlider setNumberOfTickMarks:101];
  [_wetSlider setAllowsTickMarkValuesOnly:YES];
  
  _wetText = [[NSTextField alloc] initWithFrame:textRect];

  // Roomsize
  _roomsizeSlider = [[NSScrollSlider alloc] initWithFrame:sliderRect];
  [_roomsizeSlider setAutoresizingMask: NSViewWidthSizable];
  [_roomsizeSlider setTitle:@"roomsize"];
  [_roomsizeSlider setMinValue: 0.0];
  [_roomsizeSlider setMaxValue: 100.0];
  [_roomsizeSlider setNumberOfTickMarks:101];
  [_roomsizeSlider setAllowsTickMarkValuesOnly:YES];
  
  _roomsizeText = [[NSTextField alloc] initWithFrame:textRect];

  // Damp
  _dampSlider = [[NSScrollSlider alloc] initWithFrame:sliderRect];
  [_dampSlider setAutoresizingMask: NSViewWidthSizable];
  [_dampSlider setTitle:@"damp"];
  [_dampSlider setMinValue: 0.0];
  [_dampSlider setMaxValue: 100.0];
  [_dampSlider setNumberOfTickMarks:101];
  [_dampSlider setAllowsTickMarkValuesOnly:YES];
  
  _dampText = [[NSTextField alloc] initWithFrame:textRect];

}

- (id) init {
  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) {	// nsbox
    [self setTitle:@"Reverb"];

    [self setAutoresizingMask: NSViewWidthSizable];
    
    GSTable *tab = [[GSTable alloc] initWithNumberOfRows:4 numberOfColumns:2];
    // [tab setAutoresizingMask: NSViewWidthSizable];

    [self makeWidgets];

    // Arrange Views
    [tab putView:_drySlider atRow:3 column:0];
    [tab putView:_dryText atRow:3 column:1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView:_wetSlider atRow:2 column:0];
    [tab putView:_wetText atRow:2 column:1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView:_roomsizeSlider atRow:1 column:0];
    [tab putView:_roomsizeText atRow:1 column:1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView:_dampSlider atRow:0 column:0];
    [tab putView:_dampText atRow:0 column:1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab setXResizingEnabled: YES forColumn: 0];
    [tab setXResizingEnabled: NO  forColumn: 1];

    // [tab sizeToFit];

    [self setContentView: tab];
    [self sizeToFit];
  }
  return self;
}

- (void) bindToModel:(MSKReverbModel*) model {

  [_drySlider bind:@"value"
	  toObject:model
       withKeyPath:@"dry"
	   options:nil];

  [_dryText bind:@"value"
	toObject:model
     withKeyPath:@"dry"
	 options:nil];

  [_wetSlider bind:@"value"
	  toObject:model
       withKeyPath:@"wet"
	   options:nil];

  [_wetText bind:@"value"
	toObject:model
     withKeyPath:@"wet"
	 options:nil];

  [_roomsizeSlider bind:@"value"
	       toObject:model
	    withKeyPath:@"roomsize"
		options:nil];

  [_roomsizeText bind:@"value"
	     toObject:model
	  withKeyPath:@"roomsize"
	      options:nil];

  [_dampSlider bind:@"value"
	   toObject:model
	withKeyPath:@"damp"
	    options:nil];

  [_dampText bind:@"value"
	 toObject:model
      withKeyPath:@"damp"
	  options:nil];

  

}

@end

  
