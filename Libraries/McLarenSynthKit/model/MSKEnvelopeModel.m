/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * Model for Envelopes
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKEnvelopeModel.h"

@implementation MSKEnvelopeModel

- (id) initWithName:(NSString*)name {

  if (self = [super initWithName:name]) {
    _attack = 0.001;
    _decay = 0.01;
    _sustain = 0.9;
    _rel = 0.2;
    _sens = 1.0;
  }
  return self;

}

- (double) iGainForVel:(uint8_t) vel {
  double scaledVelocity = vel / 128.0;
  double velsens = (1.0 - _sens) + (scaledVelocity * _sens);
  return velsens;
}

@end
