/** -*- mode:objc -*-
 *
 * An extension to GeneralOscillator: a phase distortion input is added
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/voice/MSKGeneralOscillator.h"
#import "McLarenSynthKit/model/MSKModulatedOscillatorModel.h"

@interface MSKPhaseDistortionOscillator : MSKGeneralOscillator {
}

// override the model type
@property (nonatomic, readwrite) MSKModulatedOscillatorModel *model;


// the phasedistortion
@property (nonatomic, readwrite) MSKContextVoice *sPhasedistortion;

@end
