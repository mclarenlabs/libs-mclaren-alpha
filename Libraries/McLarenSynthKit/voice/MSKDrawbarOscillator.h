/** -*- mode:objc -*-
 *
 * Oscillator with overtones.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/model/MSKDrawbarOscillatorModel.h"

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

// override the model
@property (nonatomic, readwrite) MSKDrawbarOscillatorModel *model;

// the envelope
@property (nonatomic, readwrite, ) MSKContextEnvelope *sEnvelope;


- (id) initWithCtx:(MSKContext*)c;

@end

