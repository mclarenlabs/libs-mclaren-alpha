/** -*- mode:objc -*-
 *
 * Model for Oscillators with a modulated input
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKModulationModel.h"

@implementation MSKModulationModel

- (id) init {

  if (self = [super init]) {
    _modulation = 0.0;
  }
  return self;
}

//
// NSCoding
//

- (id) initWithCoder:(NSCoder*)coder {
  if (self = [super init]) {
    _modulation = [coder decodeDoubleForKey:@"modulation"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder*)coder {
  [coder encodeDouble:_modulation forKey:@"modulation"];
}


@end
