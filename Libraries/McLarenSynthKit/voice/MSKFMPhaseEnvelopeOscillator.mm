/** -*- mode: c++ -*-
 *
 * Phase-Distortion adds an extra input and control to an oscillator
 *
 * Copyright (c) McLaren Labs 2024
 */

extern "C" {

#include "math.h"
#import "McLarenSynthKit/MSKContext.h"
// #import "MclarenSynthKit/env/MSKLinEnvelope.h"
#import "McLarenSynthKit/voice/MSKGeneralOscillator.h"
#import "McLarenSynthKit/voice/MSKFMPhaseEnvelopeOscillator.h"

}

#include "synthpp_voice.h"

typedef enum {
  FORM_A2__C2_C2,		// a2 output, c2 envelope, c2 pe
  FORM_A2__C2_A2,		// a2 output, c2 envelope, a2 pe
  FORM_A2__A2_C2,		// a2 output, a2 envelope, c2 pe
  FORM_A2__A2_A2,		// a2 output, a2 envelope, a2 pe
} form_t;

@implementation MSKFMPhaseEnvelopeOscillator {
  fmpeosc *fmpeosc;
  form_t form;
}

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {

    fmpeosc = new struct fmpeosc(c.rate, c.persize);

    // realtime control
    // _modulation = 3.5;

  }
  return self;
}


- (BOOL) compile {
  fmpeosc->note = self.iNote;

  if (_model != nil) {
    fmpeosc->osctype.setRef(_model->_osctype);
    fmpeosc->octave.setRef(_model->_octave);
    fmpeosc->transpose.setRef(_model->_transpose);
    fmpeosc->cents.setRef(_model->_cents);
    fmpeosc->bendwidth.setRef(_model->_bendwidth);

    fmpeosc->harmonic.setRef(_model->_harmonic);
    fmpeosc->subharmonic.setRef(_model->_subharmonic);
  }

  if (_modulationModel != nil) {
    fmpeosc->modulation.setRef(_modulationModel->_modulation);
    fmpeosc->bend.setRef(_modulationModel->_pitchbend);
  }

  // 
  // determine form at compile time
  //

  if (_sEnvelope == nil) {
    if (_sPhaseenvelope == nil) {
      form = FORM_A2__C2_C2;
    }
    else {
      form = FORM_A2__C2_A2;
    }
  }
  else {
    if (_sPhaseenvelope == nil) {
      form = FORM_A2__A2_C2;
    }
    else {
      form = FORM_A2__A2_A2;
    }
  }
    
  return [super compile];
}
  
- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  a2Rate<MSKSAMPTYPE> out(0.0, 0.0, _frames);

  switch (form) {
  case FORM_A2__C2_C2:
    {
      c2Rate<MSKSAMPTYPE> env(1.0, 1.0); // ENV defaults to 1
      c2Rate<MSKSAMPTYPE> pe(1.0, 1.0); // PE defaults to 1.0
      fmpeosc->render(out, env, pe);
    }
    break;

  case FORM_A2__C2_A2:
    {
      BOOL res = [_sPhaseenvelope auEval:now nframes:nframes];
      (void) res;

      c2Rate<MSKSAMPTYPE> env(1.0, 1.0);
      a2Rate<MSKSAMPTYPE> pe(0.0, 0.0, _sPhaseenvelope->_frames);
      fmpeosc->render(out, env, pe);
      _active = self.sPhaseenvelope->_active;
    }
    break;

  case FORM_A2__A2_C2:
    {
      BOOL res = [_sEnvelope auEval:now nframes:nframes];
      (void) res;
    
      a2Rate<MSKSAMPTYPE> env(0.0, 0.0, _sEnvelope->_frames);
      c2Rate<float> pe(1.0, 1.0); // PE defaults to 1.0
      fmpeosc->render(out, env, pe);
      _active = self.sEnvelope->_active;
    }
    break;

  case FORM_A2__A2_A2:
    {
      BOOL res1 = [_sEnvelope auEval:now nframes:nframes];
      (void) res1;
      BOOL res2 = [_sPhaseenvelope auEval:now nframes:nframes];
      (void) res2;
    
      a2Rate<MSKSAMPTYPE> env(0.0, 0.0, _sEnvelope->_frames);
      a2Rate<MSKSAMPTYPE> pe(0.0, 0.0, _sPhaseenvelope->_frames);
      fmpeosc->render(out, env, pe);
      _active = self.sEnvelope->_active && _sPhaseenvelope->_active;
    }
    break;

  }
  
  return YES;
}


#if LOGDEALLOC
- (void) dealloc {
  NSLog(@"MSKPhaseEnvelopeOscillator dealloc");
}
#endif

@end
