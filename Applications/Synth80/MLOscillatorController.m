/** -*- mode: objc -*-
 *
 * Controller for MSKOscillatorModel
 *
 */

#import <AppKit/AppKit.h>
#import "MLOscillatorController.h"

@implementation MLOscillatorController

- (void) makeWidgets {

  // Oscillator Type
  _oscCombo = [[MLCircularSliderWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_oscCombo.titleTextField setStringValue:@"Osc Type"];
  [_oscCombo.slider setMinValue:0];
  [_oscCombo.slider setMaxValue:6];
  [_oscCombo.slider setNumberOfTickMarks:6];
  [_oscCombo.slider setAllowsTickMarkValuesOnly:YES];

  // Octave
  _octaveCombo = [[MLStepperWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_octaveCombo.titleTextField setStringValue:@"Octave"];
  [_octaveCombo.stepper setMinValue:-4];
  [_octaveCombo.stepper setMaxValue:5];
  [_octaveCombo.stepper setIncrement:1.0];

  // Transpose
  _transposeCombo = [[MLStepperWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_transposeCombo.titleTextField setStringValue:@"Transpose"];
  [_transposeCombo.stepper setMinValue:-12];
  [_transposeCombo.stepper setMaxValue:12];
  [_transposeCombo.stepper setIncrement:1.0];

  // Cents
  _centsCombo = [[MLStepperWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_centsCombo.titleTextField setStringValue:@"Cents"];
  [_centsCombo.stepper setMinValue:-50];
  [_centsCombo.stepper setMaxValue:50];
  [_centsCombo.stepper setIncrement:1.0];

  // Pulsewidth
  _pwCombo = [[MLStepperWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_pwCombo.titleTextField setStringValue:@"Pulsewidth"];
  [_pwCombo.stepper setMinValue:5];
  [_pwCombo.stepper setMaxValue:95];
  [_pwCombo.stepper setIncrement:5];

  // Bendwidth
  _bendwidthCombo = [[MLStepperWithValue alloc] initWithSize:NSMakeSize(140, 50)];
  [_bendwidthCombo.titleTextField setStringValue:@"BendWidth"];
  [_bendwidthCombo.stepper setMinValue:1];
  [_bendwidthCombo.stepper setMaxValue:24];
  [_bendwidthCombo.stepper setIncrement:1];

  // Harmonic
  _harmCombo = [[MLStepperWithValue alloc] initWithSize:NSMakeSize(140, 50)];
  [_harmCombo.titleTextField setStringValue:@"Harmonic"];
  [_harmCombo.stepper setMinValue:1];
  [_harmCombo.stepper setMaxValue:50];
  [_harmCombo.stepper setIncrement:1.0];

  // Subharmonic
  _subharmCombo = [[MLStepperWithValue alloc] initWithSize:NSMakeSize(140, 50)];
  [_subharmCombo.titleTextField setStringValue:@"Subharmonic"];
  [_subharmCombo.stepper setMinValue:1];
  [_subharmCombo.stepper setMaxValue:50];
  [_subharmCombo.stepper setIncrement:1.0];

}

- (id) init {
  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) {	// nsbox
    NSLog(@"MLOSccCont init");
    [self setTitle:@"Oscillator"];

    [self setAutoresizingMask: NSViewWidthSizable];
    
    GSTable *tab = [[GSTable alloc] initWithNumberOfRows:2 numberOfColumns:5];
    // [tab setAutoresizingMask: NSViewWidthSizable];

    [self makeWidgets];

    NSLog(@"oscCombo:%@", _oscCombo);

    [tab putView: _oscCombo
	   atRow: 1 column: 0];

    [tab putView: _octaveCombo
	   atRow: 0 column: 1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView: _transposeCombo
	   atRow: 1 column: 1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];


    [tab putView: _centsCombo
	   atRow: 0 column: 2
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView: _pwCombo
	   atRow: 1 column: 2
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView: _bendwidthCombo
	   atRow: 0 column: 3
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView: _subharmCombo
	   atRow: 0 column: 4
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView: _harmCombo
	   atRow: 1 column: 4
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];


    [tab setXResizingEnabled: YES forColumn: 0];
    [tab setXResizingEnabled: YES  forColumn: 1];
    [tab setXResizingEnabled: YES  forColumn: 2];
    [tab setXResizingEnabled: YES  forColumn: 3];
    [tab setXResizingEnabled: YES  forColumn: 4];
    // [tab sizeToFit];

    [self setContentView: tab];
    [self sizeToFit];
  }
  return self;
}

- (void) bindToModel:(MSKOscillatorModel*) model {

  // bindings
  [_oscCombo.slider bind:@"value"
		toObject:model
	     withKeyPath:@"osctype"
		 options:nil];

  [_oscCombo.valueTextField bind:@"value"
			toObject:model
		     withKeyPath:@"osctype"
			 options: @{
    NSValueTransformerBindingOption: [MSKOscillatorTypeValueTransformer new]
	}];

  [_octaveCombo.stepper bind:@"value"
		   toObject:model
		 withKeyPath:@"octave"
		     options:nil];

  [_octaveCombo.valueTextField bind:@"value"
			   toObject:model
			withKeyPath:@"octave"
			    options:nil];

  [_transposeCombo.stepper bind:@"value"
		       toObject:model
		    withKeyPath:@"transpose"
			options:nil];

  [_transposeCombo.valueTextField bind:@"value"
			      toObject:model
			   withKeyPath:@"transpose"
			       options:nil];

  [_centsCombo.stepper bind:@"value"
		   toObject:model
		withKeyPath:@"cents"
		    options:nil];

  [_centsCombo.valueTextField bind:@"value"
			  toObject:model
		       withKeyPath:@"cents"
			   options:nil];

  [_pwCombo.stepper bind:@"value"
		   toObject:model
		withKeyPath:@"pw"
		    options:nil];

  [_pwCombo.valueTextField bind:@"value"
		       toObject:model
		    withKeyPath:@"pw"
			options:nil];

  [_bendwidthCombo.stepper bind:@"value"
		       toObject:model
		    withKeyPath:@"bendwidth"
		    options:nil];

  [_bendwidthCombo.valueTextField bind:@"value"
		       toObject:model
		    withKeyPath:@"bendwidth"
			options:nil];

  [_harmCombo.stepper bind:@"value"
		   toObject:model
		withKeyPath:@"harmonic"
		    options:nil];

  [_harmCombo.valueTextField bind:@"value"
			 toObject:model
		      withKeyPath:@"harmonic"
			  options:nil];

  [_subharmCombo.stepper bind:@"value"
		     toObject:model
		  withKeyPath:@"subharmonic"
		      options:nil];

  [_subharmCombo.valueTextField bind:@"value"
			    toObject:model
			 withKeyPath:@"subharmonic"
			     options:nil];

}

@end

  
