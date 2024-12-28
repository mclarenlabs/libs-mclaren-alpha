/** -*- mode:objc -*-
 *
 * Oscillator with overtones.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/model/MSKOscillatorModel.h"
#import "McLarenSynthKit/model/MSKDrawbarModel.h"
#import "McLarenSynthKit/model/MSKModulationModel.h"

@interface MSKDrawbarOscillator : MSKContextVoice {

  unsigned _rate;

  // primary configuration parameters
  int _osctype;

  // note properties
  double _freq;
  int _note;
  int _octave;
  int _transpose;
  int _cents;
  double _bend;
  unsigned int _bendwidth;
  double _pw;
  double _modulation;
}

// the Note
@property (nonatomic, readwrite) unsigned iNote;

// the oscillator model
@property (nonatomic, readwrite) MSKOscillatorModel *model;

// the modulation model
@property (nonatomic, readwrite) MSKModulationModel *modulationModel;

// the drawbar model
@property (nonatomic, readwrite) MSKDrawbarModel *drawbarModel;

// the envelope
@property (nonatomic, readwrite, ) MSKContextVoice *sEnvelope;


- (id) initWithCtx:(MSKContext*)c;

@end

