/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * Model for Envelopes
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKEnvelopeModel.h"

@implementation MSKEnvelopeModel

- (id) init {

  if (self = [super init]) {
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

//
// NSCoding
//

- (id) initWithCoder:(NSCoder*)coder {
  if (self = [super init]) {
    _attack = [coder decodeDoubleForKey:@"attack"];
    _decay =  [coder decodeDoubleForKey:@"decay"];
    _sustain =  [coder decodeDoubleForKey:@"sustain"];
    _rel = [coder decodeDoubleForKey:@"release"];
    _sens =  [coder decodeDoubleForKey:@"sensitivity"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder*)coder {
  [coder encodeDouble:_attack forKey:@"attack"];
  [coder encodeDouble:_decay forKey:@"decay"];
  [coder encodeDouble:_sustain forKey:@"sustain"];
  [coder encodeDouble:_rel forKey:@"release"];
  [coder encodeDouble:_sens forKey:@"sensitivity"];
}

@end
