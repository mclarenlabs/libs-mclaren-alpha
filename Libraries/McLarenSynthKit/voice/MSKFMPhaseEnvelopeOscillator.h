/** -*- mode:objc -*-
 *
 * An FM Oscillator with an additional envelope input that controls the magnitude
 * of the modulation.
 *
 * out[i] = SIN(\phi + 3.5 * M * pi[i] * SIN(\psi))
 *  where \psi = \phi * (HARMONIC/SUBHARMONIC)
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/model/MSKModulatedOscillatorModel.h"

@interface MSKFMPhaseEnvelopeOscillator : MSKContextVoice

// the Note
@property (nonatomic, readwrite) unsigned iNote;

// the model
@property (nonatomic, readwrite) MSKModulatedOscillatorModel *model;

// the envelope
@property (nonatomic, readwrite) MSKContextEnvelope *sEnvelope;

// the phase envelope
@property (nonatomic, readwrite) MSKContextEnvelope *sPhaseenvelope;

- (id) initWithCtx:(MSKContext*)c;

@end
