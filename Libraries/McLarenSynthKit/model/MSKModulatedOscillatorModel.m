/** -*- mode:objc -*-
 *
 * Model for Oscillators with a modulated input
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKModulatedOscillatorModel.h"

@implementation MSKModulatedOscillatorModel

- (id) initWithName:(NSString*)name {

  if (self = [super initWithName:name]) {
    _modulation = 0.0;
  }
  return self;

}

@end
