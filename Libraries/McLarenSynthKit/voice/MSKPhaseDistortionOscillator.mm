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
#import "McLarenSynthKit/voice/MSKPhaseDistortionOscillator.h"

}

#include "synthpp_voice.h"

typedef enum {
  FORM_A2__C2_C2,		// a2 output, c2 envelope, c2 pd
  FORM_A2__C2_A2,		// a2 output, c2 envelope, a2 pd
  FORM_A2__A2_C2,		// a2 output, a2 envelope, c2 pd
  FORM_A2__A2_A2,		// a2 output, a2 envelope, a2 pd
} form_t;

@implementation MSKPhaseDistortionOscillator {
  pdosc *pdosc;
  form_t form;
}

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {

    pdosc = new struct pdosc(c.rate, c.persize);

    // realtime control
    // _modulation = 3.5;

  }
  return self;
}


- (BOOL) compile {
  pdosc->note = self.iNote;

  if (_model != nil) {
    pdosc->osctype.setRef(_model->_osctype);
    pdosc->octave.setRef(_model->_octave);
    pdosc->transpose.setRef(_model->_transpose);
    pdosc->cents.setRef(_model->_cents);
    pdosc->bendwidth.setRef(_model->_bendwidth);
  }

  if (_modulationModel != nil) {
    pdosc->modulation.setRef(_modulationModel->_modulation);
    pdosc->bend.setRef(_modulationModel->_pitchbend);
  }

  // 
  // determine form at compile time
  //

  if (_sEnvelope == nil) {
    if (_sPhasedistortion == nil) {
      form = FORM_A2__C2_C2;
    }
    else {
      form = FORM_A2__C2_A2;
    }
  }
  else {
    if (_sPhasedistortion == nil) {
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

#if 0 // OLD CODE
  MSKSAMPTYPE *buf = _frames;

  MSKSAMPTYPE *pdbuf = _sPhasedistortion->_frames;
  a2Rate<float> out; out.addr = buf;
  a2Rate<float> pd; pd.l = 0; pd.r = 0; pd.addr = pdbuf;
#endif

  switch (form) {
  case FORM_A2__C2_C2:
    {
      c2Rate<MSKSAMPTYPE> env(1.0, 1.0); // ENV defaults to 1
      c2Rate<MSKSAMPTYPE> pd(0.0, 0.0); // PD defaults to 0
      pdosc->render(out, env, pd);
    }
    break;

  case FORM_A2__C2_A2:
    {
      BOOL res = [_sPhasedistortion auEval:now nframes:nframes];
      (void) res;

      c2Rate<MSKSAMPTYPE> env(1.0, 1.0);
      a2Rate<MSKSAMPTYPE> pd(0.0, 0.0, _sPhasedistortion->_frames);
      pdosc->render(out, env, pd);
      _active = self.sPhasedistortion->_active;
    }
    break;

  case FORM_A2__A2_C2:
    {
      BOOL res = [_sEnvelope auEval:now nframes:nframes];
      (void) res;
    
      a2Rate<MSKSAMPTYPE> env(0.0, 0.0, _sEnvelope->_frames);
      c2Rate<float> pd(0.0, 0.0); // PD defaults to 0
      pdosc->render(out, env, pd);
      _active = self.sEnvelope->_active;
    }
    break;

  case FORM_A2__A2_A2:
    {
      BOOL res1 = [_sEnvelope auEval:now nframes:nframes];
      (void) res1;
      BOOL res2 = [_sPhasedistortion auEval:now nframes:nframes];
      (void) res2;
    
      a2Rate<MSKSAMPTYPE> env(0.0, 0.0, _sEnvelope->_frames);
      a2Rate<MSKSAMPTYPE> pd(0.0, 0.0, _sPhasedistortion->_frames);
      pdosc->render(out, env, pd);
      _active = self.sEnvelope->_active && _sPhasedistortion->_active;
    }
    break;

  }
  
  return YES;
}


#if LOGDEALLOC
- (void) dealloc {
  NSLog(@"MSKPhaseDistortionOscillator dealloc");
}
#endif

@end
