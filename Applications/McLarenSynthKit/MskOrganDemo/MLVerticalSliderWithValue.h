/*
 * a circular slider with a title field and a value field
 *
 */

#import <AppKit/AppKit.h>
#import "NSScrollSlider.h"
#import "GSTable-MLdecls.h"

@interface MLVerticalSliderWithValue : GSTable

- (id) initWithSliderSize:(NSSize)sliderSize textSize:(NSSize)textSize;

@property (readwrite) NSTextField *titleTextField;
@property (readwrite) NSTextField *valueTextField;
@property (readwrite) NSScrollSlider *slider;


@end
