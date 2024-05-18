/** -*- mode: objc -*-
 *
 * Controller for MSKModulationModel
 *
 */

#import <AppKit/AppKit.h>
#import "McLarenSynthKit/model/MSKAlgorithmModel.h"
#import "MLCircularSliderWithValue.h"

@interface MLAlgorithmController : NSBox

@property MLCircularSliderWithValue *algorithmCombo;

- (void) bindToModel:(MSKAlgorithmModel*)model;

@end
