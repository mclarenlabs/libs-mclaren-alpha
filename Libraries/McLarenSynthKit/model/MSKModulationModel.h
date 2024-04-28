/** -*- mode:objc -*-
 *
 * A model manages settings for oscillators.
 * This model will contain a superset of all possible oscillator parameters.
 *
 * Copyright (c) McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/model/MSKOscillatorModel.h"

@interface MSKModulatedOscillatorModel : MSKOscillatorModel {
  @public
  // for reading in the audio loop
  double _modulation;
}

@property (nonatomic, readwrite) double modulation;

@end
