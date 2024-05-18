/** -*- mode: objc -*-
 *
 * Controller for MSKReverbModel
 *
 */

#import <AppKit/AppKit.h>
#import "McLarenSynthKit/model/MSKReverbModel.h"
#import "MLCircularSliderWithValue.h"

@interface MLReverbController : NSBox

@property (nonatomic, retain, strong) NSSlider *drySlider;
@property (nonatomic, retain, strong) NSSlider *wetSlider;
@property (nonatomic, retain, strong) NSSlider *roomsizeSlider;
@property (nonatomic, retain, strong) NSSlider *dampSlider;
@property (nonatomic, retain, strong) NSTextField *dryText;
@property (nonatomic, retain, strong) NSTextField *wetText;
@property (nonatomic, retain, strong) NSTextField *roomsizeText;
@property (nonatomic, retain, strong) NSTextField *dampText;

- (void) bindToModel:(MSKReverbModel*)model;

@end
