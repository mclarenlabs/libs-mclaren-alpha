/** -*- mode: objc -*-
 *
 * Controller for MSKModulationModel
 *
 */

#import <AppKit/AppKit.h>
#import "MLModulationController.h"

@implementation MLModulationController

- (void) makeWidgets {

  NSSize sliderSize = NSMakeSize(25, 50);
  NSSize textSize = NSMakeSize(50, 25);

  _modulationCombo = [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
								  textSize:textSize];
  [_modulationCombo.slider setAutoresizingMask: NSViewHeightSizable];
  [_modulationCombo.titleTextField setStringValue:@"mod"];

  _pitchbendCombo = [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
								  textSize:textSize];
  [_pitchbendCombo.slider setAutoresizingMask: NSViewHeightSizable];
  [_pitchbendCombo.titleTextField setStringValue:@"bend"];
  [_pitchbendCombo.slider setMinValue:-1];
}

- (id) init {
  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) {	// nsbox
    [self setTitle:@"Modulation"];

    [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    GSTable *tab = [[GSTable alloc] initWithNumberOfRows:1 numberOfColumns:2];
    // [tab setAutoresizingMask: NSViewWidthSizable];

    [self makeWidgets];

    [tab putView: _modulationCombo
	   atRow: 0 column: 0];
    [tab setXResizingEnabled: YES forColumn: 0];

    [tab putView: _pitchbendCombo
	   atRow: 0 column: 1];
    [tab setXResizingEnabled: YES forColumn: 0];

    [self setContentView: tab];
    [self sizeToFit];
  }
  return self;
}

- (void) bindToModel:(MSKModulationModel*) model {

  // bindings
  [_modulationCombo.slider bind:@"value"
		       toObject:model
		    withKeyPath:@"modulation"
			options:nil];

  [_modulationCombo.valueTextField bind:@"value"
			       toObject:model
			    withKeyPath:@"modulation"
				options: nil];
  // bindings
  [_pitchbendCombo.slider bind:@"value"
		      toObject:model
		   withKeyPath:@"pitchbend"
			options:nil];

  [_pitchbendCombo.valueTextField bind:@"value"
			      toObject:model
			   withKeyPath:@"pitchbend"
				options: nil];
}

@end

  
