/**
 * The Base Class for Models.
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKModelBase.h"

@implementation MSKModelBase

- (id) initWithName:(NSString*)name {
  if (self = [super init]) {
    _name = name;
    _modified = NO;
  }
  return self;
}

@end

  
