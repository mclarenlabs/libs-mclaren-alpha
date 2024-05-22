/*
 * a stepper with a title field and a value field
 *
 */

#import "MLStepperWithValue.h"

@implementation MLStepperWithValue

- (id) initWithSize:(NSSize)size {

  if (self = [super init]) { // super is GSHbox

    double hmarg = 5.0;
    double wid = size.width;
    double ht = size.height;
    double txtwd = wid-ht-hmarg;
    double txtht = ht / 2.0;

    NSRect blankRect = NSMakeRect(0, 0, txtwd, 5);
    NSRect titleRect = NSMakeRect(0, 0, txtwd, txtht-5);
    NSRect textRect = NSMakeRect(0, 0, txtwd-20, txtht);
    NSRect stepRect = NSMakeRect(0, 0, 20, txtht);

    [self setAutoresizingMask: NSViewWidthSizable];

    GSVbox *vbox = [GSVbox new];

    _titleTextField = [[NSTextField alloc] initWithFrame:titleRect];
    [_titleTextField setEditable: NO];
    [_titleTextField setBezeled: NO];
    [_titleTextField setDrawsBackground: NO];

    GSHbox *hbox = [GSHbox new];
    
    _stepper = [[NSStepper alloc] initWithFrame:stepRect];
    _valueTextField = [[NSTextField alloc] initWithFrame:textRect];

    [hbox addView: _stepper];
    [hbox addView: _valueTextField];

    // stack value and title fields
    [vbox addView: hbox];
    [vbox addView: _titleTextField];

    NSView *blank = [[NSView alloc] initWithFrame:blankRect];
    [vbox addView: blank];

    // [self addView: vbox enablingXResizing: NO withMinXMargin:hmarg];
    [self addView: vbox enablingXResizing: NO];
  }
  return self;
}
  
@end

