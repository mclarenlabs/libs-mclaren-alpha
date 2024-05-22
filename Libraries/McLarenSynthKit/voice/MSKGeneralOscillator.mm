/** -*- mode: c++ -*-
 *
 * A Voice adds a sound to the context
 *
 * Copyright (c) McLaren Labs 2024
 */

extern "C" {

#include "math.h"
#import "McLarenSynthKit/voice/MSKGeneralOscillator.h"

}

#include "synthpp_voice.h"

@implementation MSKGeneralOscillator {
  gosc *gosc;
}

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {
    gosc = new struct gosc(c.rate, c.persize);

    // ContextVoice protocol
    _active = YES;
  }
  return self;
}

- (BOOL) compile {
  
  // handle iNote
  gosc->note = _iNote;

  //
  // from the oscillator model - unconditional, because they have values
  //

  if (_model != nil) {
    // capture references to control values
    gosc->osctype.setRef(_model->_osctype);
    gosc->octave.setRef(_model->_octave);
    gosc->transpose.setRef(_model->_transpose);
    gosc->cents.setRef(_model->_cents);
    gosc->bendwidth.setRef(_model->_bendwidth);
    gosc->pw.setRef(_model->_pw);
  }

  if (_modulationModel != nil) {
    gosc->bend.setRef(_modulationModel->_pitchbend);
  }

  return YES;
}

//
// Context Voice implementation
//

- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  a2Rate<MSKSAMPTYPE> out(0.0, 0.0, _frames);
  
  if (_sEnvelope == nil) {
    float one = 1.0;
    k1Rate<float> env(0.0); env.setRef(one);  // alt: c1Rate() could have been used
    gosc->render(out, env);
  }
  else {
    BOOL res = [_sEnvelope auEval:now nframes:nframes];
    (void) res;
    a2Rate<MSKSAMPTYPE> env(0.0, 0.0, _sEnvelope->_frames);
    gosc->render(out, env);
    _active = _sEnvelope->_active;
  }
  
  return YES;
}

@end


