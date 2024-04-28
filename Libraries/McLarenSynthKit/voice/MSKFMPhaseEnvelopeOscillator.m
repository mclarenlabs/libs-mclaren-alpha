/*
 * Phase Distortion Oscillator
 *
 * Copyright (c) McLaren Labs 2024
 */

#include "math.h"
#import "McLarenSynthKit/voice/MSKFMPhaseEnvelopeOscillator.h"

static double GAIN = 4.0;

@implementation MSKFMPhaseEnvelopeOscillator {

  unsigned _rate;

  // primary configuration parameters
  int _osctype;

  // note properties from the model
  int _note;
  int _octave;
  int _transpose;
  int _cents;
  double _bend;
  unsigned int _bendwidth;

  // oscillator properties from the model
  double _modulation;
  double _harmonic;
  double _subharmonic;

  // internal oscillator state
  double _freq;
  double _phi;
  double _phimod;

  double _incr;
  double _dphi;
  double _dphimod;
}

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {

    _rate = _ctx.rate;

    _active = YES;

    _freq = 220;
    _phi = 0;
    _phimod = 0;
  }
  return self;
}

// do nothing? 2023-01-02
- (BOOL) compile {
  return YES;
}

void CFMSKFMPhaseEnvelopeOscillatorCalcFreq(__unsafe_unretained MSKFMPhaseEnvelopeOscillator *v) {
  double bend = v->_bend * v->_bendwidth;
  v->_freq = 440.0 * exp2((((v->_note+v->_transpose+bend+(v->_cents/100.0)) - 69) / 12.0)  + v->_octave);
}  

void CFMSKFMPhaseEnvelopeOscillatorCalcDelta(__unsafe_unretained MSKFMPhaseEnvelopeOscillator *v) {
  v->_incr = v->_freq / v->_rate; // modulo incr
  v->_dphi = (2 * M_PI) * v->_incr; // radians incr
  v->_dphimod = v->_dphi * (v->_harmonic / v->_subharmonic);
}

- (BOOL) auInit:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {
  // handle iNote
  _note = _iNote;
  return YES;
}

BOOL CFMSKFMPhaseEnvelopeOscillatorControls(__unsafe_unretained MSKFMPhaseEnvelopeOscillator *v, uint64_t now, snd_pcm_sframes_t nframes) {

  __unsafe_unretained MSKOscillatorModel *model = v->_model;
  __unsafe_unretained MSKModulationModel *modModel = v->_modulationModel;
 
  if (model) {
    v->_osctype = model->_osctype;
    v->_octave = model->_octave;
    v->_transpose = model->_transpose;
    v->_cents = model->_cents;
    v->_bendwidth = model->_bendwidth;
    v->_bend = model->_pitchbend;

    // FM controls in Osc model
    v->_harmonic = model->_harmonic;
    v->_subharmonic = model->_subharmonic;
  }

  if (modModel) {
    v->_modulation = modModel->_modulation;
  }
  
  CFMSKFMPhaseEnvelopeOscillatorCalcFreq(v);
  CFMSKFMPhaseEnvelopeOscillatorCalcDelta(v);
  return YES;
}

- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  CFMSKFMPhaseEnvelopeOscillatorControls(self, now, nframes);

  MSKSAMPTYPE *buf = _frames;

  double dphi = _dphi;
  double dphimod = _dphimod;

  if (_sEnvelope == nil) {
    for (int i = 0; i < nframes; i++) {
      // modulation is a command-line parameter, but varied by controller too
      double sound = GAIN * SINFN(_phi + _modulation * SINFN(_phimod));
      _phi += dphi;
      _phimod += dphimod;
      buf[i * 2] = sound;
      buf[i * 2 + 1] = sound;
    }
  }
  else {
    if (_sPhaseenvelope == nil) {
      // v->_sEnvelope->_sing(v->_sEnvelope, nframes);
      // CFMSKContextVoiceEval(v->_sEnvelope, now, nframes);
      BOOL res = [_sPhaseenvelope auEval:now nframes:nframes];
      (void) res;
      
      MSKSAMPTYPE *gain = _sEnvelope->_frames;
      for (int i = 0; i < nframes; i++) {
	// modulation is a command-line parameter, but varied by controller too
	double sound = GAIN * SINFN(_phi + _modulation * SINFN(_phimod));
	_phi += dphi;
	_phimod += dphimod;
	buf[i*2] = gain[i*2] * sound;
	buf[i*2 + 1] = gain[i*2 + 1] * sound;
      }
      _active = _sEnvelope->_active;
    }
    else {
      // v->_sEnvelope->_sing(v->_sEnvelope, nframes);
      // v->_sPhaseenvelope->_sing(v->_sPhaseenvelope, nframes);
      // CFMSKContextVoiceEval(v->_sEnvelope, now, nframes);
      // CFMSKContextVoiceEval(v->_sPhaseenvelope, now, nframes);
      BOOL res1 = [_sEnvelope auEval:now nframes:nframes];
      (void) res1;
      BOOL res2 = [_sPhaseenvelope auEval:now nframes:nframes];
      (void) res2;
      
      MSKSAMPTYPE *gain = _sEnvelope->_frames;
      MSKSAMPTYPE *mod = _sPhaseenvelope->_frames;
      for (int i = 0; i < nframes; i++) {
	// modulation is a command-line parameter, but varied by controller too
	double sound = GAIN * SINFN(_phi + _modulation * mod[i*2] * SINFN(_phimod));
	_phi += dphi;
	_phimod += dphimod;
	buf[i*2] = gain[i*2] * sound;
	buf[i*2 + 1] = gain[i*2 + 1] * sound;
      }
      _active = _sEnvelope->_active;
    }
  }
  return YES;
}


@end
