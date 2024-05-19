/** -*- mode:objc -*-
 *
 * This model has enums for different algorithms that Synth80 will implement.
 *
 * Copyright (c) McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/model/MSKOscillatorModel.h"

typedef enum synth80_algorithm_type {
  SYNTH80_ALGORITHM_TYPE_OSC1,
  SYNTH80_ALGORITHM_TYPE_DRBR1,
  SYNTH80_ALGORITHM_TYPE_RING,
  SYNTH80_ALGORITHM_TYPE_PHASE,
  SYNTH80_ALGORITHM_TYPE_FMPHASE
} synth80_algorithm_type_enum;

@interface Synth80AlgorithmTypeValueTransformer : NSValueTransformer
// translates from ENUM to STRING for GUI elements
@end

@interface Synth80AlgorithmModel : NSObject< NSCoding > {
  @public
  // for reading in the audio loop
}

@property (nonatomic, readwrite) synth80_algorithm_type_enum algorithm;

@end
