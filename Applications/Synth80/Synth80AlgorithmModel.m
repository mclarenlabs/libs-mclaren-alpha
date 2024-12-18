/** -*- mode:objc -*-
 *
 * Model for Algorithm
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "Synth80AlgorithmModel.h"

@implementation Synth80AlgorithmTypeValueTransformer
+ (Class)transformedValueClass {
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
  // NSLog(@"Transforming:%@", value);
  synth80_algorithm_type_enum typ = [value unsignedIntegerValue];
  switch (typ) {
  case SYNTH80_ALGORITHM_TYPE_OSC1:
    return @"osc1";
  case SYNTH80_ALGORITHM_TYPE_DRBR1:
    return @"drbr1";
  case SYNTH80_ALGORITHM_TYPE_RING:
    return @"ring";
  case SYNTH80_ALGORITHM_TYPE_PHASE:
    return @"phase";
  case SYNTH80_ALGORITHM_TYPE_FMPHASE:
    return @"fmphase";
  case SYNTH80_ALGORITHM_TYPE_SAMP1:
    return @"smp1";
  case SYNTH80_ALGORITHM_TYPE_SAMP2:
    return @"smp2";
  default:
    return @"?";
  }
}
@end
  
@implementation Synth80AlgorithmModel

- (id) init {
  if (self = [super init]) {
    _algorithm = SYNTH80_ALGORITHM_TYPE_OSC1;
  }
  return self;
}

//
// NSCoding
//

- (id) initWithCoder:(NSCoder*)coder {
  if (self = [super init]) {
    _algorithm = [coder decodeIntegerForKey:@"algorithm"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder*)coder {
  [coder encodeInteger:_algorithm forKey:@"algorithm"];
}


@end
