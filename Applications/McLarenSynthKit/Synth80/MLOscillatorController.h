/** -*- mode: objc -*-
 *
 * Controller for MSKOscillatorModel
 *
 */

#import <AppKit/AppKit.h>
#import "McLarenSynthKit/model/MSKOscillatorModel.h"
#import "MLCircularSliderWithValue.h"
#import "MLStepperWithValue.h"

@interface MLOscillatorController : NSBox

@property MLCircularSliderWithValue *oscCombo;
@property MLStepperWithValue *octaveCombo;
@property MLStepperWithValue *pwCombo;
@property MLStepperWithValue *transposeCombo;
@property MLStepperWithValue *centsCombo;

@property MLStepperWithValue *bendwidthCombo;

@property MLStepperWithValue *harmCombo;
@property MLStepperWithValue *subharmCombo;

- (void) bindToModel:(MSKOscillatorModel*)model;

@end
