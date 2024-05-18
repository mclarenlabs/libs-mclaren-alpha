/**  -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * A Model for Filters
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "MSKFilterModel.h"

@implementation MSKFilterTypeValueTransformer : NSValueTransformer
+ (Class)transformedValueClass {
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
  // NSLog(@"Transforming:%@", value);
  msk_filter_type_enum typ = [value unsignedIntegerValue];
  switch (typ) {
  case MSK_FILTER_NONE:
    return @"none";
  case MSK_FILTER_BIQUAD_TYPE_LOWPASS:
    return @"low";
  case MSK_FILTER_BIQUAD_TYPE_HIGHPASS:
    return @"high";
  case MSK_FILTER_BIQUAD_TYPE_BANDPASS:
    return @"band";
  case MSK_FILTER_BIQUAD_TYPE_NOTCH:
    return @"notch";
  case MSK_FILTER_BIQUAD_TYPE_PEAK:
    return @"peak";
  case MSK_FILTER_BIQUAD_TYPE_LOWSHELF:
    return @"lowshelf";
  case MSK_FILTER_BIQUAD_TYPE_HIGHSHELF:
    return @"hishelf";
  case MSK_FILTER_MOOG:
    return @"moog";
  case MSK_FILTER_MOOG_TANH:
    return @"moog/tanh";
  default:
    return @"?";
  }
}
  
@end


@implementation MSKFilterModel

- (id) init {
  if (self = [super init]) {
    _fc = 10000; // FILTER_FC_DEFAULT
    _q = 1.0; // 1.0 .. 10.0
    _fcmod = 0.0; // realtime control
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
    _filtertype = [coder decodeIntegerForKey:@"filtertype"];
    _fc =  [coder decodeDoubleForKey:@"fc"];
    _q =  [coder decodeDoubleForKey:@"q"];
    _fcmod = [coder decodeDoubleForKey:@"fcmod"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder*)coder {
  [coder encodeInteger:_filtertype forKey:@"filtertype"];
  [coder encodeDouble:_fc forKey:@"fc"];
  [coder encodeDouble:_q forKey:@"q"];
  [coder encodeDouble:_fcmod forKey:@"fcmod"];
}
@end

