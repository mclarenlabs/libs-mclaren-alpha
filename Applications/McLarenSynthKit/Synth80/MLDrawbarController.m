/** -*- mode: objc -*-
 *
 * Controller for MSKEnvelopeModel
 *
 */

#import <AppKit/AppKit.h>
#import "MLDrawbarController.h"

@implementation MLDrawbarController

- (void) makeWidgets {

  NSSize sliderSize = NSMakeSize(20, 50);
  NSSize textSize = NSMakeSize(45, 20);
  
  _v0 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v1 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v2 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v3 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v4 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v5 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v6 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v7 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v8 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];

  [_v0.titleTextField setStringValue:@"16"];
  [_v1.titleTextField setStringValue:@"5 1/3"];
  [_v2.titleTextField setStringValue:@"8"];
  [_v3.titleTextField setStringValue:@"4"];
  [_v4.titleTextField setStringValue:@"2 2/3"];
  [_v5.titleTextField setStringValue:@"2"];
  [_v6.titleTextField setStringValue:@"1 3/5"];
  [_v7.titleTextField setStringValue:@"1 1/3"];
  [_v8.titleTextField setStringValue:@"1"];
}

- (id) init {
  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) {	// nsbox
    [self setTitle:@"Drawbar"];

    [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    GSHbox *hbox = [[GSHbox alloc] init];
    // [tab setAutoresizingMask: NSViewWidthSizable];

    [self makeWidgets];

    [hbox addView: _v0 enablingXResizing: YES withMinXMargin:10.0];
    [hbox addView: _v1 enablingXResizing: YES withMinXMargin:10.0];
    [hbox addView: _v2 enablingXResizing: YES withMinXMargin:10.0];
    [hbox addView: _v3 enablingXResizing: YES withMinXMargin:10.0];
    [hbox addView: _v4 enablingXResizing: YES withMinXMargin:10.0];
    [hbox addView: _v5 enablingXResizing: YES withMinXMargin:10.0];
    [hbox addView: _v6 enablingXResizing: YES withMinXMargin:10.0];
    [hbox addView: _v7 enablingXResizing: YES withMinXMargin:10.0];
    [hbox addView: _v8 enablingXResizing: YES withMinXMargin:10.0];

    [self setContentView: hbox];
    [self sizeToFit];
  }
  return self;
}

- (void)configureDrawbar:(MLVerticalSliderWithValue*)v
		    path:(NSString*)path
		   model:(MSKDrawbarModel*)model
{
  NSSlider *slider = v.slider;
  NSTextField *valueTextField = v.valueTextField;

  [slider setMinValue:0];
  [slider setMaxValue:8];
  [slider setNumberOfTickMarks:9];
  [slider setAllowsTickMarkValuesOnly:YES];

  [slider bind:@"value"
      toObject:model
	  withKeyPath:path
       options:nil];

  [valueTextField bind:@"value"
	      toObject:model
	   withKeyPath:path
	       options:nil];
}

- (void) bindToModel:(MSKDrawbarModel*) model {

  [self configureDrawbar:_v0 path:@"amp0" model:model];
  [self configureDrawbar:_v1 path:@"amp1" model:model];
  [self configureDrawbar:_v2 path:@"amp2" model:model];
  [self configureDrawbar:_v3 path:@"amp3" model:model];
  [self configureDrawbar:_v4 path:@"amp4" model:model];
  [self configureDrawbar:_v5 path:@"amp5" model:model];
  [self configureDrawbar:_v6 path:@"amp6" model:model];
  [self configureDrawbar:_v7 path:@"amp7" model:model];
  [self configureDrawbar:_v8 path:@"amp8" model:model];

}

@end

  
