/** -*- mode:objc -*-
 *
 * An extension to GeneralOscillator: a phase distortion input is added
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/voice/MSKGeneralOscillator.h"
#import "McLarenSynthKit/model/MSKOscillatorModel.h"
#import "McLarenSynthKit/model/MSKModulationModel.h"

@interface MSKPhaseDistortionOscillator : MSKContextVoice

// the initial Note
@property (nonatomic, readwrite) unsigned iNote;

// the oscillator model
@property (nonatomic, readwrite) MSKOscillatorModel *model;

// the envelope
@property (nonatomic, readwrite) MSKContextEnvelope *sEnvelope;

// the modulation model
@property (nonatomic, readwrite) MSKModulationModel *modulationModel;

// the phasedistortion input
@property (nonatomic, readwrite) MSKContextVoice *sPhasedistortion;

@end
