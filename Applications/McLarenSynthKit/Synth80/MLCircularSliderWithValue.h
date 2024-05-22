/*
 * a circular slider with a title field and a value field
 *
 */

#import <AppKit/AppKit.h>
#import "NSScrollSlider.h"
#import "GSTable-MLdecls.h"

@interface MLCircularSliderWithValue : GSHbox

- (id) initWithSize:(NSSize)size;

@property (readwrite) NSTextField *titleTextField;
@property (readwrite) NSTextField *valueTextField;
@property (readwrite) NSScrollSlider *slider;


@end
