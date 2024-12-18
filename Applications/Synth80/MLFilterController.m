/** -*- mode: objc -*-
 *
 * Controller for MSKEnvelopeModel
 *
 */

#import <AppKit/AppKit.h>
#import "GSTable-MLdecls.h"
#import "MLFilterController.h"

@implementation MLFilterController

- (void) makeWidgets {

  // make slider
  _filtertypeSlider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [_filtertypeSlider setTitle:@"filtertype"];

  [_filtertypeSlider setMinValue:0];
  [_filtertypeSlider setMaxValue:9];
  [_filtertypeSlider setNumberOfTickMarks:10];
  [_filtertypeSlider setAllowsTickMarkValuesOnly:YES];
  [_filtertypeSlider setContinuous:YES];
  [_filtertypeSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  _filtertypeText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  // FC
  _fcSlider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [_fcSlider setTitle:@"fc"];

  [_fcSlider setMinValue:100];
  [_fcSlider setMaxValue:5000];
  [_fcSlider setContinuous:YES];
  [_fcSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  _fcText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  // number formatter
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  NSMutableDictionary *attr = [NSMutableDictionary dictionary];

  [numberFormatter setFormat:@"#####.00"];
  [numberFormatter setMinimumFractionDigits:2];
  [numberFormatter setMaximumFractionDigits:2];
  [attr setObject:[NSColor redColor] forKey:@"NSColor"];
  [numberFormatter setTextAttributesForNegativeValues:attr];
  [_fcText setFormatter:numberFormatter];

  // FCMOD
  _fcmodSlider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [_fcmodSlider setTitle:@"fcmod"];
  
  [_fcmodSlider setMinValue:-12];
  [_fcmodSlider setMaxValue:12];
  [_fcmodSlider setContinuous:YES];
  [_fcmodSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  _fcmodText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  // number formatter
  NSNumberFormatter *numberFormatterRed = [[NSNumberFormatter alloc] init];
  NSMutableDictionary *attrRed = [NSMutableDictionary dictionary];

  [numberFormatterRed setFormat:@"###.0"];
  [numberFormatterRed setMinimumFractionDigits:1];
  [numberFormatterRed setMaximumFractionDigits:1];
  [attrRed setObject:[NSColor redColor] forKey:@"NSColor"];
  [numberFormatterRed setTextAttributesForNegativeValues:attrRed];
  [_fcmodText setFormatter:numberFormatterRed];


}

- (id) init {
  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) {	// nsbox
    [self setTitle:@"Filter"];

    [self setAutoresizingMask: NSViewWidthSizable];
    
    GSTable *tab = [[GSTable alloc] initWithNumberOfRows:3 numberOfColumns:2];
    // [tab setAutoresizingMask: NSViewWidthSizable];

    [self makeWidgets];

    // arrange in table
    [tab putView: _filtertypeSlider atRow:2 column:0];
    [tab putView: _filtertypeText atRow:2 column:1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView: _fcSlider atRow:1 column:0];
    [tab putView: _fcText atRow:1 column:1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab putView: _fcmodSlider atRow:0 column:0];
    [tab putView: _fcmodText atRow:0 column:1
	 withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

    [tab setXResizingEnabled: YES forColumn: 0];
    [tab setXResizingEnabled: NO  forColumn: 1];

    // [tab sizeToFit];

    [self setContentView: tab];
    [self sizeToFit];
  }
  return self;
}

- (void) bindToModel:(MSKFilterModel*) model {

  // use bindings
  [_filtertypeSlider bind:@"value"
	  toObject:model
       withKeyPath:@"filtertype"
	   options:nil];

  [_filtertypeText bind:@"value"
      toObject:model
	  withKeyPath:@"filtertype"
	options: @{
    NSValueTransformerBindingOption: [MSKFilterTypeValueTransformer new]
	}];

  // use bindings
  [_fcSlider bind:@"value"
	     toObject:model
	withKeyPath:@"fc"
	      options:nil];

  [_fcText bind:@"value"
      toObject:model
	  withKeyPath:@"fc"
       options:nil];

  [_fcmodText bind:@"value"
	  toObject:model
       withKeyPath:@"fcmod"
	   options:nil];

  // use bindings
  [_fcmodSlider bind:@"value"
		toObject:model
	     withKeyPath:@"fcmod"
		 options:nil];

}

@end

  
