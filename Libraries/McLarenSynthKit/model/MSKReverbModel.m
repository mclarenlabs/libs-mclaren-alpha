/*
 * Model for Reverbs
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKReverbModel.h"

@implementation MSKReverbModel

- (id) init {

  if (self = [super init]) {

    // init values
    _on = NO;
    _dry = 50;
    _wet = 79;
    _roomsize = 90;
    _damp = 40;
  }
  return self;
}

// KVC: disallow nil values
- (void) setNilValueForKey:(NSString*)key {
  NSLog(@"setNilValueForKey:%@", key);
}

//
// NSCoding
//

- (id) initWithCoder:(NSCoder*)coder {
  if (self = [super init]) {
    _on = [coder decodeIntegerForKey:@"on"];
    _dry =  [coder decodeDoubleForKey:@"dry"];
    _wet =  [coder decodeDoubleForKey:@"wet"];
    _roomsize =  [coder decodeDoubleForKey:@"roomsize"];
    _damp = [coder decodeDoubleForKey:@"damp"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder*)coder {
  [coder encodeInteger:_on forKey:@"on"];
  [coder encodeDouble:_dry forKey:@"dry"];
  [coder encodeDouble:_wet forKey:@"wet"];
  [coder encodeDouble:_roomsize forKey:@"roomsize"];
  [coder encodeDouble:_damp forKey:@"damp"];
}
@end
