/*
 * Model for Reverbs
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKReverbModel.h"

@implementation MSKReverbModel

- (id) initWithName:(NSString*)name {

  if (self = [super initWithName:name]) {

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

@end
