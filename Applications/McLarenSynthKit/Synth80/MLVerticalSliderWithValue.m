/*
 * a vertical slider with a title field and a value field
 *
 */

#import "MLVerticalSliderWithValue.h"

@implementation MLVerticalSliderWithValue

- (id) initWithSliderSize:(NSSize)sliderSize textSize:(NSSize)textSize {


  if (self = [super initWithNumberOfRows:3 numberOfColumns:1]) { // super is GSTable

    double vmarg = 5.0;

    NSRect textRect = NSMakeRect(0, 0, textSize.width, textSize.height);
    NSRect sliderRect = NSMakeRect(0, 0, sliderSize.width, sliderSize.height);

    double sliderMargin;
    if (sliderSize.width < textSize.width) {
      // to center the slider under the text boxes
      sliderMargin = (textSize.width - sliderSize.width) / 2.0;
    }
    else {
      sliderMargin = 0.0;
    }
      

    [self setAutoresizingMask: NSViewHeightSizable];

    _titleTextField = [[NSTextField alloc] initWithFrame:textRect];
    [_titleTextField setEditable: NO];
    [_titleTextField setBezeled: YES];
    [_titleTextField setDrawsBackground: NO];

    _valueTextField = [[NSTextField alloc] initWithFrame:textRect];

    _slider = [[NSScrollSlider alloc] initWithFrame:sliderRect];

    // stack value and title fields
    // [self addView: _titleTextField enablingYResizing: NO];
    // [self addView: _slider enablingYResizing: YES withMinYMargin:vmarg];
    // [self addView: _valueTextField enablingYResizing: NO withMinYMargin:vmarg];
    [self putView: _titleTextField
	    atRow: 0 column:0];
    [self putView: _slider
	    atRow: 1 column:0
	  withXMargins: sliderMargin
	 yMargins: vmarg];
    [self putView: _valueTextField
	    atRow: 2 column:0];

    [self setYResizingEnabled: NO  forRow:0];
    [self setYResizingEnabled: YES forRow:1];
    [self setYResizingEnabled: NO  forRow:2];
      

  }
  return self;
}
  
@end

