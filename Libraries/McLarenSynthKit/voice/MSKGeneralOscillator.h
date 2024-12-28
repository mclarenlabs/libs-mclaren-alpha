/** -*- mode:objc -*-
 *
 * Oscillator waveform generalized to SIN, SAW, SQUARE, TRIANGLE, REVSAW
 *
 * This oscillator may be continuously updated through its model.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/model/MSKOscillatorModel.h"
#import "McLarenSynthKit/model/MSKModulationModel.h"

@interface MSKGeneralOscillator : MSKContextVoice

// the initial Note
@property (nonatomic, readwrite) unsigned iNote;

// the model
@property (nonatomic, readwrite) MSKOscillatorModel *model;

// the modulation model
@property (nonatomic, readwrite) MSKModulationModel *modulationModel;

// the envelope
@property (nonatomic, readwrite) MSKContextVoice *sEnvelope;

- (id) initWithCtx:(MSKContext*)c;

@end

