/** -*- mode: objc -*-
 *
 * A top-level model that holds the models for Synth80
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

@interface Synth80Model : NSObject

@property (nonatomic, retain, strong) MSKEnvelopeModel *env1Model;
@property (nonatomic, retain, strong) MSKOscillatorModel *osc1Model;
@property (nonatomic, retain, strong) MSKDrawbarModel *drawbar1Model;
@property (nonatomic, retain, strong) MSKEnvelopeModel *env2Model;
@property (nonatomic, retain, strong) MSKOscillatorModel *osc2Model;

@property (nonatomic, retain, strong) MSKModulationModel *modulationModel;
@property (nonatomic, retain, strong) MSKAlgorithmModel *algorithmModel;

@property (nonatomic, retain, strong) MSKReverbModel *reverbModel;
@property (nonatomic, retain, strong) MSKFilterModel *filtModel;

@property (nonatomic, retain, strong) MSKSampleModel *sample1Model;

@end
