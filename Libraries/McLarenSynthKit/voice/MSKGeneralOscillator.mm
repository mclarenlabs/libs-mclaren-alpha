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

// define the FORM of the outputs/inputs
typedef enum {
  FORM_A2__C2,			// a2 output, c2 envelope
  FORM_A2__A2,			// a2 output, a2 envelope
} form_t;

@implementation MSKGeneralOscillator {
  gosc *gosc;
  form_t form;
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

  // 
  // determine form at compile time
  //
  
  if (_sEnvelope == nil) {
    form = FORM_A2__C2;
  }
  else {
    form = FORM_A2__A2;
  }

  return [super compile];
}

//
// Context Voice implementation
//

- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  a2Rate<MSKSAMPTYPE> out(0.0, 0.0, _frames);

  switch (form) {
  case FORM_A2__C2 :
    {
      c2Rate<float> env(1.0, 1.0);
      gosc->render(out, env);
    };
    break;

  case FORM_A2__A2 :
    {
      BOOL res = [_sEnvelope auEval:now nframes:nframes];
      (void) res;
      a2Rate<MSKSAMPTYPE> env(0.0, 0.0, _sEnvelope->_frames);
      gosc->render(out, env);
      _active = _sEnvelope->_active;
    };
    break;
  }

  return YES;
}

@end


