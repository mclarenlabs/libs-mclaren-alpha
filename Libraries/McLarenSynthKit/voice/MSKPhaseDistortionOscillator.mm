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

@implementation MSKPhaseDistortionOscillator {
  pdosc *pdosc;
}

@dynamic model; // superclass will implement

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
    // help compiler understand _model holds a specialized model
    MSKModulatedOscillatorModel *m = (MSKModulatedOscillatorModel*) _model;
    pdosc->osctype.setRef(m->_osctype);
    pdosc->octave.setRef(m->_octave);
    pdosc->transpose.setRef(m->_transpose);
    pdosc->cents.setRef(m->_cents);
    pdosc->bendwidth.setRef(m->_bendwidth);
    pdosc->bend.setRef(m->_pitchbend);
    pdosc->modulation.setRef(m->_modulation);
  }

  return YES;
}
  
- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  MSKSAMPTYPE *buf = _frames;

  MSKSAMPTYPE *pdbuf = _sPhasedistortion->_frames;
  a2Rate<float> out; out.addr = buf;
  a2Rate<float> pd; pd.l = 0; pd.r = 0; pd.addr = pdbuf;
  
  if (self.sEnvelope == nil) {
    BOOL res = [_sPhasedistortion auEval:now nframes:nframes];
    (void) res;

    c2Rate<float> env(1.0, 1.0);
    pdosc->render(out, env, pd);
    _active = self.sEnvelope->_active;
  }
  else {
    BOOL res1 = [_sPhasedistortion auEval:now nframes:nframes];
    (void) res1;
    BOOL res2 = [_sEnvelope auEval:now nframes:nframes];
    (void) res2;
    
    MSKSAMPTYPE *envbuf = self.sEnvelope->_frames;
    a2Rate<float> env; env.l = 0; env.r = 0; env.addr = envbuf;
    pdosc->render(out, env, pd);
    _active = self.sEnvelope->_active && _sPhasedistortion->_active;
  }

  return YES;
}


#if LOGDEALLOC
- (void) dealloc {
  NSLog(@"MSKPhaseDistortionOscillator dealloc");
}
#endif

@end
