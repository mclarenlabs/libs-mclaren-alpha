/** -*- mode:objc -*-
 *
 * Oscillator with harmonic overtones.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#include "math.h"
#import "McLarenSynthKit/voice/MSKDrawbarOscillator.h"

static double GAIN = 1.0;

@interface MSKDrawbarOscillator()
@end


@implementation MSKDrawbarOscillator { 
  // configuration
  int _overtones;
  int _numerators[MSK_DRAWBAR_OSCILLATOR_MAXTONES];
  int _denominators[MSK_DRAWBAR_OSCILLATOR_MAXTONES];

  // continuous updates
  double _amplitudes[MSK_DRAWBAR_OSCILLATOR_MAXTONES];

  // oscillator state
  double _phi[MSK_DRAWBAR_OSCILLATOR_MAXTONES];
  double _dphi[MSK_DRAWBAR_OSCILLATOR_MAXTONES];
  double _modulo[MSK_DRAWBAR_OSCILLATOR_MAXTONES];
  double _incr[MSK_DRAWBAR_OSCILLATOR_MAXTONES];
}

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {

    _rate = c.rate;
    
    // external properties
    _osctype = MSK_OSCILLATOR_TYPE_SIN;
    _overtones = 3;

    _numerators[0] = 1;
    _numerators[1] = 2;
    _numerators[2] = 3;

    _denominators[0] = 1;
    _denominators[1] = 1;
    _denominators[2] = 1;

    _amplitudes[0] = 0.5;
    _amplitudes[1] = 0.5;
    _amplitudes[2] = 0.8;

    _freq = 0;			// not set
    _note = 60; //middle-C
    _octave = 0;
    _transpose = 0;
    _cents = 0;
    _pw = 50.0;
    //    _modulation = 0.0;

    for (int i = 0; i < MSK_DRAWBAR_OSCILLATOR_MAXTONES; i++) {
      _phi[i] = 0.0;
      _dphi[i] = 0.0;
      _modulo[i] = 0.0;
      _incr[i] = 0.0;
    }

    _active = YES;

  }
  return self;
}

// Interface Properties
- (BOOL) compile {

  _note = _iNote;

  if (_model != nil) {

    _osctype = _model->_osctype;
    _octave = _model->_octave;
    _transpose = _model->_transpose;
    _cents = _model->_cents;
    _bendwidth = _model->_bendwidth;
    _pw = _model->_pw;
    // _modulation = _model->_modulation;

  }

  if (_modulationModel != nil) {
    _bend = _modulationModel->_pitchbend;
  }

  if (_drawbarModel != nil) {
    // Organ controls
    _overtones = _drawbarModel->_overtones;
    for (int i=0; i < MSK_DRAWBAR_OSCILLATOR_MAXTONES; i++) {
      _numerators[i] = _drawbarModel->_numerators[i];
      _denominators[i] = _drawbarModel->_denominators[i];
      _amplitudes[i] = _drawbarModel->_amplitudes[i];
    }
      
  }

  CFMSKDrawbarOscillatorCalcFreq(self);

  return YES;
}

BOOL CFMSKDrawbarOscillatorControls(__unsafe_unretained MSKDrawbarOscillator *v, uint64_t now, snd_pcm_sframes_t nframes) {
  __unsafe_unretained MSKOscillatorModel *model = v->_model;
  __unsafe_unretained MSKModulationModel *modulationModel = v->_modulationModel;
  BOOL recalc = NO;

  if (model) {

    int oct = model->_octave;
    if (oct != v->_octave) {
      v->_octave = oct;
      recalc = YES;
    }

    int transpose = model->_transpose;
    if (transpose != v->_transpose) {
      v->_transpose = transpose;
      recalc = YES;
    }

    int cent = model->_cents;
    if (cent != v->_cents) {
      v->_cents = cent;
      recalc = YES;
    }

    int bw = model->_bendwidth;
    if (bw != v->_bendwidth) {
      v->_bendwidth = bw;
      recalc = YES;
    }

    //    double mod = model->_modulation;
    //    if (mod != v->_modulation) {
    //      v->_modulation = mod;
    //    }
  }

  if (modulationModel) {
    double pb = modulationModel->_pitchbend;
    if (pb != v->_bend) {
      v->_bend = pb;
      recalc = YES;
    }
  }

  if (recalc) {
    CFMSKDrawbarOscillatorCalcFreq(v);
  }
  
  return YES;
}

void CFMSKDrawbarOscillatorCalcFreq(__unsafe_unretained MSKDrawbarOscillator *v) {
  // _freq = 8.176 * exp((double)(_note)*log(2.0)/12.0); // TODO: this should include octave and cents

  double bend = v->_bend * v->_bendwidth;


  for (int i = 0; i < v->_overtones; i++) {
    double freq;
    // freq = (i + 1) * (440.0 * exp2((((_note+(_cents/100.0)) - 69) / 12.0)  + _octave));
      
    int num = v->_numerators[i];
    int den = v->_denominators[i];
    
    freq = (440.0 * exp2((((v->_note+v->_transpose+bend+(v->_cents/100.0)) - 69) / 12.0)  + v->_octave)) * num / den;

    double incr = freq / v->_rate; // modulo incr
    double dphi = (2 * M_PI) * incr; // radians incr

    v->_dphi[i] = dphi;
    v->_incr[i] = incr;
  }
}

void CFMSKDrawbarOscillatorIncrModulo(__unsafe_unretained MSKDrawbarOscillator *v) {

  for (int i = 0; i < v->_overtones; i++) {
    double modulo = v->_modulo[i];
    double incr = v->_incr[i];
    double phi = v->_phi[i];
    double dphi = v->_dphi[i];

    modulo += incr;
    if (modulo >= 1.0) {
      modulo -= 1.0;
    }
    phi += dphi;
    if (phi >= 2*M_PI) {
      phi -= 2*M_PI;
    }

    v->_modulo[i] = modulo;
    v->_incr[i] = incr;
    v->_phi[i] = phi;
    v->_dphi[i] = dphi;
  }
}

static inline double compute_sound(double phi, double modulo, int osctype, double pw) {
  double sound;
  switch (osctype) {
  case MSK_OSCILLATOR_TYPE_SIN:
    sound = SINFN(phi);
    break;
  case MSK_OSCILLATOR_TYPE_SAW:
    sound = 2.0*modulo - 1.0;
    break;
  case MSK_OSCILLATOR_TYPE_SQUARE:
    sound = ((modulo*100.0) > pw) ? -1.0 : 1.0;
    break;
  case MSK_OSCILLATOR_TYPE_TRIANGLE:
    sound = 2.0*fabs(2*modulo-1.0) - 1.0;
    break;
  default:
    sound = 2*modulo -1.0;
    break;
  }

  return sound;
}

- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  CFMSKDrawbarOscillatorControls(self, now, nframes);

  MSKSAMPTYPE *buf = _frames;

  memset(buf, 0, 2 * nframes * sizeof(MSKSAMPTYPE));

  // smooth drawbar controls
  double amp[MSK_DRAWBAR_OSCILLATOR_MAXTONES];
  double aincr[MSK_DRAWBAR_OSCILLATOR_MAXTONES];

  if (_model == nil) {
    NSLog(@"no model");
    exit(1);
  }

  if (_drawbarModel != nil) {
    for (int o = 0; o < _overtones; o++) {
      amp[o] = _amplitudes[o];
      aincr[o] = (_drawbarModel->_amplitudes[o] - _amplitudes[o]) / nframes;
      _amplitudes[o] = _drawbarModel->_amplitudes[o];
    }
  }

  if (_sEnvelope == nil) {
    for (int i = 0; i < nframes; i++) {
      double sound = 0.0;
      for (int o = 0; o < _overtones; o++) {
	double amplitude = (amp[o] += aincr[o]);
	if (amplitude == 0.0) 
	  continue;
	double modulo = _modulo[o];
	double phi = _phi[o];
	sound += GAIN * amplitude * compute_sound(phi, modulo, _osctype, _pw);
      }
      CFMSKDrawbarOscillatorIncrModulo(self);
      buf[i * 2] += sound;
      buf[i * 2 + 1] += sound;
    }
  }

  // scale by gain
  else {
    BOOL res = [_sEnvelope auEval:now nframes:nframes];
    (void) res;

    MSKSAMPTYPE *gain = _sEnvelope->_frames;
    for (int i = 0; i < nframes; i++) {
      double sound = 0.0;
      for (int o = 0; o < _overtones; o++) {
	double amplitude = (amp[o] += aincr[o]);
	if (amplitude == 0.0) 
	  continue;
	double modulo = _modulo[o];
	double phi = _phi[o];
	sound += GAIN * amplitude * compute_sound(phi, modulo, _osctype, _pw);
      }
      CFMSKDrawbarOscillatorIncrModulo(self);
      buf[i*2] += gain[i*2] * sound;
      buf[i*2 + 1] += gain[i*2 + 1] * sound;
    }
    _active = _sEnvelope->_active;
  }
  return YES;
}


@end


