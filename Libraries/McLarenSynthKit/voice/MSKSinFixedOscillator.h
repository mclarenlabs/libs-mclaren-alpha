/** -*- mode: objc -*-
 *
 * A Voice renders a sound to its context
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/model/MSKOscillatorModel.h"

/*
 * an MSKSinFixedOscillator renders sound based on its attached models and its input buffers.
 */

@interface MSKSinFixedOscillator : MSKContextVoice {
  double _freq;
  double _phi;
  double _dphi;
}

// the frequency initial value
@property (readwrite) double iFreq;

// the envelope sample input
@property (nonatomic, readwrite) MSKContextVoice *sEnvelope;

- (id) initWithCtx:(MSKContext*)c;

@end

