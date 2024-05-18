/** -*- mode: objc -*-
 *
 * A top-level model that holds the models for Synth80
 *
 * McLaren Labs 2024
 */

#import "Synth80Model.h"

@implementation Synth80Model

- (id) init {
  if (self = [super init]) {

    NSLog(@"Synth80Model init");

  self.env1Model = [[MSKEnvelopeModel alloc] init];
  self.env1Model.attack = 0.05;
  self.env1Model.decay = 0.1;
  self.env1Model.sustain = 0.8;
  self.env1Model.rel = 0.2;

  self.osc1Model = [[MSKOscillatorModel alloc] init];
  self.osc1Model.osctype = MSK_OSCILLATOR_TYPE_SQUARE;

  self.drawbar1Model = [[MSKDrawbarModel alloc] init];

  self.env2Model = [[MSKEnvelopeModel alloc] init];
  self.env2Model.attack = 0.05;
  self.env2Model.decay = 0.1;
  self.env2Model.sustain = 0.8;
  self.env2Model.rel = 0.2;

  self.osc2Model = [[MSKOscillatorModel alloc] init];
  self.osc2Model.osctype = MSK_OSCILLATOR_TYPE_SIN;

  self.modulationModel = [[MSKModulationModel alloc] init];

  self.algorithmModel = [[MSKAlgorithmModel alloc] init];

  self.filtModel = [[MSKFilterModel alloc] init];
  self.filtModel.filtertype = MSK_FILTER_MOOG;
  self.filtModel.fc = 2500;
  self.filtModel.q = 2.0;

  self.reverbModel = [[MSKReverbModel alloc] init];
  self.reverbModel.on = YES; // ToDo: make a GUI switch

  self.sample1Model = [[MSKSampleModel alloc] init];
  }
  return self;
}

//
// NSCoding
//

#if 1

- (id) initWithCoder:(NSCoder*)coder {
  NSLog(@"Synth80Model initWithCoder");
  if (self = [super init]) {
    _env1Model = [coder decodeObjectForKey:@"env1"];
    _osc1Model = [coder decodeObjectForKey:@"osc1"];
    _drawbar1Model = [coder decodeObjectForKey:@"drawbar1"];

    _env2Model = [coder decodeObjectForKey:@"env2"];
    _osc2Model = [coder decodeObjectForKey:@"osc2"];

    _modulationModel = [coder decodeObjectForKey:@"modulation"];
    _algorithmModel = [coder decodeObjectForKey:@"algorithm"];
    
    _reverbModel = [coder decodeObjectForKey:@"reverb"];
    _filtModel = [coder decodeObjectForKey:@"filt"];

    _sample1Model = [coder decodeObjectForKey:@"sample1"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder*)coder {
  NSLog(@"Synth80Model: encodeWithCoder");
  [coder encodeObject: _env1Model forKey:@"env1"];
  [coder encodeObject: _osc1Model forKey:@"osc1"];
  [coder encodeObject: _drawbar1Model forKey:@"drawbar1"];

  [coder encodeObject: _env2Model forKey:@"env2"];
  [coder encodeObject: _osc2Model forKey:@"osc2"];

  [coder encodeObject: _modulationModel forKey:@"modulation"];
  [coder encodeObject: _algorithmModel forKey:@"algorithm"];

  [coder encodeObject: _reverbModel forKey:@"reverb"];
  [coder encodeObject: _filtModel forKey:@"filt"];

  [coder encodeObject: _sample1Model forKey:@"sample1"];
}

#endif


@end
