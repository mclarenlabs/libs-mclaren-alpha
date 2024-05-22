/** -*- mode: objc -*-
 *
 * Controller for MSKFilterModel
 *
 */

#import <AppKit/AppKit.h>
#import "McLarenSynthKit/model/MSKFilterModel.h"
#import "MLCircularSliderWithValue.h"
#import "NSScrollSlider.h"

@interface MLFilterController : NSBox

@property (nonatomic, retain, strong) NSSlider *filtertypeSlider;
@property (nonatomic, retain, strong) NSSlider *fcSlider;
@property (nonatomic, retain, strong) NSSlider *fcmodSlider;
@property (nonatomic, retain, strong) NSTextField *filtertypeText;
@property (nonatomic, retain, strong) NSTextField *fcText;
@property (nonatomic, retain, strong) NSTextField *fcmodText;

- (void) bindToModel:(MSKFilterModel*)model;

@end
