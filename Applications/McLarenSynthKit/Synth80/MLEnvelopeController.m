/** -*- mode: objc -*-
 *
 * Controller for MSKEnvelopeModel
 *
 */

#import <AppKit/AppKit.h>
#import "MLEnvelopeController.h"

@implementation MLEnvelopeController

- (void) makeWidgets {

  // NSSize widgetSize = NSMakeSize(125, 50);
  NSSize widgetSize = NSMakeSize(110, 50);

  // Envelope - Attack
  _attackCombo = [[MLCircularSliderWithValue alloc] initWithSize:widgetSize];
  [_attackCombo.titleTextField setStringValue:@"Attack"];
  [_attackCombo.slider setMinValue:0];
  [_attackCombo.slider setMaxValue:0.5];
  [_attackCombo.slider setNumberOfTickMarks:50];
  [_attackCombo.slider setAllowsTickMarkValuesOnly:YES];

  // Envelope - Decay
  _decayCombo = [[MLCircularSliderWithValue alloc] initWithSize:widgetSize];
  [_decayCombo.titleTextField setStringValue:@"Decay"];
  [_decayCombo.slider setMinValue:0];
  [_decayCombo.slider setMaxValue:0.5];
  [_decayCombo.slider setNumberOfTickMarks:50];
  [_decayCombo.slider setAllowsTickMarkValuesOnly:YES];
  
  // Envelope - Sustain
  _sustainCombo = [[MLCircularSliderWithValue alloc] initWithSize:widgetSize];
  [_sustainCombo.titleTextField setStringValue:@"Sustain"];
  [_sustainCombo.slider setMinValue:0];
  [_sustainCombo.slider setMaxValue:1.0];
  [_sustainCombo.slider setNumberOfTickMarks:100];
  [_sustainCombo.slider setAllowsTickMarkValuesOnly:YES];
  
  // Envelope - Release
  _releaseCombo = [[MLCircularSliderWithValue alloc] initWithSize:widgetSize];
  [_releaseCombo.titleTextField setStringValue:@"Release"];
  [_releaseCombo.slider setMinValue:0];
  [_releaseCombo.slider setMaxValue:2.0];
  [_releaseCombo.slider setNumberOfTickMarks:100];
  [_releaseCombo.slider setAllowsTickMarkValuesOnly:YES];
  
}

- (id) init {
  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) {	// nsbox
    [self setTitle:@"Envelope"];

    [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    GSTable *tab = [[GSTable alloc] initWithNumberOfRows:1 numberOfColumns:4];
    // [tab setAutoresizingMask: NSViewWidthSizable];

    [self makeWidgets];

    [tab putView: _attackCombo
	   atRow: 0 column: 0];

    [tab putView: _decayCombo
	   atRow: 0 column: 1];

    [tab putView: _sustainCombo
	   atRow: 0 column: 2];

    [tab putView: _releaseCombo
	   atRow: 0 column: 3];


    [tab setXResizingEnabled: YES forColumn: 0];
    [tab setXResizingEnabled: YES  forColumn: 1];
    [tab setXResizingEnabled: YES  forColumn: 2];
    [tab setXResizingEnabled: YES  forColumn: 3];
    // [tab sizeToFit];

    [self setContentView: tab];
    [self sizeToFit];
  }
  return self;
}

- (void) bindToModel:(MSKEnvelopeModel*) model {

  // bindings
  [_attackCombo.slider bind:@"value"
		toObject:model
	     withKeyPath:@"attack"
		 options:nil];

  [_attackCombo.valueTextField bind:@"value"
			toObject:model
		     withKeyPath:@"attack"
			    options: nil];

  // bindings
  [_decayCombo.slider bind:@"value"
		toObject:model
	     withKeyPath:@"decay"
		 options:nil];

  [_decayCombo.valueTextField bind:@"value"
			toObject:model
		     withKeyPath:@"decay"
			    options: nil];

  // bindings
  [_sustainCombo.slider bind:@"value"
		toObject:model
	     withKeyPath:@"sustain"
		 options:nil];

  [_sustainCombo.valueTextField bind:@"value"
			toObject:model
		     withKeyPath:@"sustain"
			    options: nil];

  // bindings
  [_releaseCombo.slider bind:@"value"
		toObject:model
	     withKeyPath:@"rel"
		 options:nil];

  [_releaseCombo.valueTextField bind:@"value"
			toObject:model
		     withKeyPath:@"rel"
			    options: nil];


}

@end

  
