/** -*- mode: objc -*-
 *
 * Controller for MSKModulationModel
 *
 */

#import <AppKit/AppKit.h>
#import "McLarenSynthKit/model/MSKModulationModel.h"
#import "MLVerticalSliderWithValue.h"

@interface MLModulationController : NSBox

@property MLVerticalSliderWithValue *modulationCombo;
@property MLVerticalSliderWithValue *pitchbendCombo;

- (void) bindToModel:(MSKModulationModel*)model;

@end
