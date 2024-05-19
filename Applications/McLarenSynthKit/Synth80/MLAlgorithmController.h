/** -*- mode: objc -*-
 *
 * Controller for MSKModulationModel
 *
 */

#import <AppKit/AppKit.h>
#import "Synth80AlgorithmModel.h"
#import "MLCircularSliderWithValue.h"

@interface MLAlgorithmController : NSBox

@property MLCircularSliderWithValue *algorithmCombo;

- (void) bindToModel:(Synth80AlgorithmModel*)model;

@end
