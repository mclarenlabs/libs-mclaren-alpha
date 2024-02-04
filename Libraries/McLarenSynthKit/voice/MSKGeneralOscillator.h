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

@interface MSKGeneralOscillator : MSKContextVoice {

  // allow access to these for MSKPhaseDistortionOscillator
  @protected
  MSKContextEnvelope *_sEnvelope;
  MSKOscillatorModel *_model;

}

// the initial Note
@property (nonatomic, readwrite) unsigned iNote;

// the model
@property (nonatomic, readwrite) MSKOscillatorModel *model;

// the envelope
@property (nonatomic, readwrite) MSKContextEnvelope *sEnvelope;

- (id) initWithCtx:(MSKContext*)c;

@end

