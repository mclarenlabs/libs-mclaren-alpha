/** -*- mode: objc -*-
 *
 * Controller for MSKEnvelopeModel
 *
 */

#import <AppKit/AppKit.h>
#import "McLarenSynthKit/model/MSKEnvelopeModel.h"
#import "MLCircularSliderWithValue.h"

@interface MLEnvelopeController : NSBox

@property MLCircularSliderWithValue *attackCombo;
@property MLCircularSliderWithValue *decayCombo;
@property MLCircularSliderWithValue *sustainCombo;
@property MLCircularSliderWithValue *releaseCombo;

- (void) bindToModel:(MSKEnvelopeModel*)model;

@end
