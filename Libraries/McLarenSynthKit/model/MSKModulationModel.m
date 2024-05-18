/** -*- mode:objc -*-
 *
 * Model for Oscillators with a modulated input
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/model/MSKModulationModel.h"

@implementation MSKModulationModel {
  int modulationOutstanding;
  int pitchbendOutstanding;
}

- (id) init {

  if (self = [super init]) {
    _modulation = 0.0;
    _pitchbend = 0.0;

    modulationOutstanding = 0;
    pitchbendOutstanding = 0;
  }
  return self;
}

- (void) setModulationAndDecrement:(NSNumber*)modulationNumber {
  modulationOutstanding--;
  [self setModulation:[modulationNumber doubleValue]];
}

- (void) setPitchbendAndDecrement:(NSNumber*)pitchbendNumber {
  pitchbendOutstanding--;
  [self setPitchbend:[pitchbendNumber doubleValue]];
}


- (void) setModulationRealtime:(double)modulation {
  _modulation = modulation;
  if (modulationOutstanding < 2 || modulation == 0.00) {
    modulationOutstanding++;
    [self performSelectorOnMainThread:@selector(setModulationAndDecrement:)
			   withObject:@(modulation)
			waitUntilDone:NO];
  }
}
  
- (void) setPitchbendRealtime:(double)pitchbend {
  _pitchbend = pitchbend;
  if (pitchbendOutstanding < 2 || pitchbend == 0.00) {
    pitchbendOutstanding++;
    [self performSelectorOnMainThread:@selector(setPitchbendAndDecrement:)
			   withObject:@(pitchbend)
			waitUntilDone:NO];
  }
}

//
// NSCoding
//

- (id) initWithCoder:(NSCoder*)coder {
  if (self = [super init]) {
    _modulation = [coder decodeDoubleForKey:@"modulation"];
    _pitchbend =  [coder decodeDoubleForKey:@"pitchbend"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder*)coder {
  [coder encodeDouble:_modulation forKey:@"modulation"];
  [coder encodeDouble:_pitchbend forKey:@"pitchbend"];
}


@end
