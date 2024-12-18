/*
 * a circular slider with a title field and a value field
 *
 */

#import <AppKit/AppKit.h>
#import "GSTable-MLdecls.h"

@interface MLStepperWithValue : GSHbox

- (id) initWithSize:(NSSize)size;

@property (readwrite) NSTextField *titleTextField;
@property (readwrite) NSTextField *valueTextField;
@property (readwrite) NSStepper *stepper;


@end
