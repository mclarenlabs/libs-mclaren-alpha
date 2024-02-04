/*
 * a circular slider with a title field and a value field
 *
 */

#import "MLCircularSliderWithValue.h"

@implementation MLCircularSliderWithValue

- (id) initWithSize:(NSSize)size {

  if (self = [super init]) { // super is GSHbox

    double hmarg = 5.0;
    double wid = size.width;
    double ht = size.height;
    double txtwd = wid-ht-hmarg;
    double txtht = ht / 2.0;

    NSRect textRect = NSMakeRect(0, 0, txtwd, txtht);

    [self setAutoresizingMask: NSViewWidthSizable];

    GSVbox *vbox = [GSVbox new];

    _titleTextField = [[NSTextField alloc] initWithFrame:textRect];
    [_titleTextField setEditable: NO];
    [_titleTextField setBezeled: NO];
    [_titleTextField setDrawsBackground: NO];

    _valueTextField = [[NSTextField alloc] initWithFrame:textRect];

    // stack value and title fields
    [vbox addView: _valueTextField];
    [vbox addView: _titleTextField];

    _slider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, ht, ht)];
    [_slider.cell setSliderType:NSCircularSlider];

    [self addView: _slider enablingXResizing: NO withMinXMargin:0.0];
    [self addView: vbox enablingXResizing: NO withMinXMargin:hmarg];
  }
  return self;
}
  
@end

