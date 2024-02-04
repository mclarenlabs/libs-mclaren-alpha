/** -*- mode:objc -*-
 *
 * Model for Drawbar Oscillators
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKDrawbarOscillatorModel.h"

@implementation MSKDrawbarOscillatorModel

- (id) initWithName:(NSString*)name {

  if (self = [super initWithName:name]) {
    self.modified = NO;

    // Organ Harmonics
    _overtones = 9;
    _numerators[0] = 1;
    _numerators[1] = 3;
    _numerators[2] = 2;
    _numerators[3] = 4;
    _numerators[4] = 6;
    _numerators[5] = 8;
    _numerators[6] = 10;
    _numerators[7] = 12;
    _numerators[8] = 16;

    _denominators[0] = 1;
    _denominators[1] = 1;
    _denominators[2] = 1;
    _denominators[3] = 1;
    _denominators[4] = 1;
    _denominators[5] = 1;
    _denominators[6] = 1;
    _denominators[7] = 1;
    _denominators[8] = 1;

    _amplitudes[0] = 0.5;
    _amplitudes[1] = 0.5;
    _amplitudes[2] = 0.8;
    _amplitudes[3] = 0.5;
    _amplitudes[4] = 0.0;
    _amplitudes[5] = 0.0;
    _amplitudes[6] = 0.0;
    _amplitudes[7] = 0.0;
    _amplitudes[8] = 0.0;
  }
  return self;

}

/*
 * Drawbars - scaled by factor of 1/8
 */

static double scale = 8.0;

- (void) setAmp0:(double)val {
  _amplitudes[0] = val / scale;
  self.modified = YES;
}

- (double) getAmp0 {
  return _amplitudes[0] * scale;
}

- (void) setAmp1:(double)val {
  _amplitudes[1] = val / scale;
  self.modified = YES;
}

- (double) getAmp1 {
  return _amplitudes[1] * scale;
}

- (void) setAmp2:(double)val {
  _amplitudes[2] = val / scale;
  self.modified = YES;
}

- (double) getAmp2 {
  return _amplitudes[2] * scale;
}

- (void) setAmp3:(double)val {
  _amplitudes[3] = val / scale;
  self.modified = YES;
}

- (double) getAmp3 {
  return _amplitudes[3] * scale;
}

- (void) setAmp4:(double)val {
  _amplitudes[4] = val / scale;
  self.modified = YES;
}

- (double) getAmp4 {
  return _amplitudes[4] * scale;
}

- (void) setAmp5:(double)val {
  _amplitudes[5] = val / scale;
  self.modified = YES;
}

- (double) getAmp5 {
  return _amplitudes[5] * scale;
}

- (void) setAmp6:(double)val {
  _amplitudes[6] = val / scale;
  self.modified = YES;
}

- (double) getAmp6 {
  return _amplitudes[6] * scale;
}

- (void) setAmp7:(double)val {
  _amplitudes[7] = val / scale;
  self.modified = YES;
}

- (double) getAmp7 {
  return _amplitudes[7] * scale;
}

- (void) setAmp8:(double)val {
  _amplitudes[8] = val / scale;
  self.modified = YES;
}

- (double) getAmp8 {
  return _amplitudes[8] * scale;
}


@end
