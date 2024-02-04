/** -*- mode:objc -*-
 *
 * Model for OScillators
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKOscillatorModel.h"

@implementation MSKOscillatorTypeValueTransformer
+ (Class)transformedValueClass {
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
  // NSLog(@"Transforming:%@", value);
  msk_oscillator_type_enum typ = [value unsignedIntegerValue];
  switch (typ) {
  case MSK_OSCILLATOR_TYPE_SIN:
    return @"sin";
  case MSK_OSCILLATOR_TYPE_SAW:
    return @"saw";
  case MSK_OSCILLATOR_TYPE_SQUARE:
    return @"square";
  case MSK_OSCILLATOR_TYPE_TRIANGLE:
    return @"triangle";
  case MSK_OSCILLATOR_TYPE_REVSAW:
    return @"revsaw";
  case MSK_OSCILLATOR_TYPE_NONE:
    return @"none";
  default:
    return @"?";
  }
}
  
@end


@implementation MSKOscillatorModel

- (id) initWithName:(NSString*)name {

  if (self = [super initWithName:name]) {
    self.modified = NO;

    _osctype = MSK_OSCILLATOR_TYPE_SIN;
    _octave = 0;
    _transpose = 0;
    _cents = 0;
    _bendwidth = 12;
    _pitchbend = 0.0;
    _pw = 50;			// pulse-width or duty-cycle
    _noise = 0;
    _cutoff = 20000;

    // midi-enabled
    // _pitchbendsw = 1;

    // FM synth
    _harmonic = 7.0;
    _subharmonic = 9.0;

  }
  return self;

}

@end
