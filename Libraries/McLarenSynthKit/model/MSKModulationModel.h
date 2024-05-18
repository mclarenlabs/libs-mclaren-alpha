/** -*- mode:objc -*-
 *
 * A model manages settings for oscillators.
 * This model will contain a superset of all possible oscillator parameters.
 *
 * Copyright (c) McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/model/MSKOscillatorModel.h"

@interface MSKModulationModel : NSObject< NSCoding > {
  @public

  // for reading in the audio loop
  double _modulation;
  double _pitchbend;
}

@property (nonatomic, readwrite) double modulation;
@property (nonatomic, readwrite) double pitchbend;

- (void) setModulationRealtime:(double)modulation;
- (void) setPitchbendRealtime:(double)pitchbend;

@end
