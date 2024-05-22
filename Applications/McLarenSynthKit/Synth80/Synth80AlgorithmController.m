/** -*- mode: objc -*-
 *
 * Controller for MSKAlgorithmModel
 *
 */

#import <AppKit/AppKit.h>
#import "MLAlgorithmController.h"

@implementation MLAlgorithmController

- (void) makeWidgets {

  // NSSize sliderSize = NSMakeSize(25, 50);
  // NSSize textSize = NSMakeSize(50, 25);

  NSSize circSize = NSMakeSize(100, 50);

  // _algorithmCombo = [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
  // textSize:textSize];

  _algorithmCombo = [[MLCircularSliderWithValue alloc] initWithSize:circSize];
  [_algorithmCombo.titleTextField setStringValue:@"Algo"];
  [_algorithmCombo.slider setMinValue:0];
  [_algorithmCombo.slider setMaxValue:6];
  [_algorithmCombo.slider setNumberOfTickMarks:6];
  [_algorithmCombo.slider setAllowsTickMarkValuesOnly:YES];
  
}

- (id) init {
  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) {	// nsbox
    [self setTitle:@"Algorithm"];

    [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    [self makeWidgets];

    [self setContentView: _algorithmCombo];
    [self sizeToFit];
  }
  return self;
}

- (void) bindToModel:(Synth80AlgorithmModel*) model {

  // bindings
  [_algorithmCombo.slider bind:@"value"
		toObject:model
	     withKeyPath:@"algorithm"
		 options:nil];

  [_algorithmCombo.valueTextField bind:@"value"
			      toObject:model
			   withKeyPath:@"algorithm"
			 options: @{
    NSValueTransformerBindingOption: [Synth80AlgorithmTypeValueTransformer new]
	}];

}

@end

  
