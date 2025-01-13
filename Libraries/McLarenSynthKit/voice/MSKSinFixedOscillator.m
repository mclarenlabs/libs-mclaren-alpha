/** -*- mode: objc -*-
 *
 * A Voice adds a sound to the context
 *
 * Copyright (c) McLaren Labs 2024
 */

#include "math.h"

#import "McLarenSynthKit/voice/MSKSinFixedOscillator.h"

typedef enum {
  FORM_A2__C2,			// a2 output, c2 envelope
  FORM_A2__A2,			// a2 output, a2 envelope
} form_t;

static double GAIN = 1.0; // TOM: when velocity enabled: 50 * 128

@implementation MSKSinFixedOscillator {
  form_t form;
}

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {

    _iFreq = 220.0;
    _freq = 220.0;
    _phi = 0;
    _dphi = (2 * M_PI) * _freq / _ctx.rate;
    _active = YES;

  }
  return self;
}

- (BOOL) compile {

  if (_sEnvelope == Nil) {
    form = FORM_A2__C2;
  }
  else {
    form = FORM_A2__A2;
  }
    

  return [super compile];
}

static void calcDPhi(__unsafe_unretained MSKSinFixedOscillator *v) {
  v->_dphi = (2 * M_PI) * v->_freq / v->_ctx.rate;
}

- (BOOL) auInit:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {
  _freq = _iFreq;
  calcDPhi(self);
  return YES;
}


- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  MSKSAMPTYPE *buf = _frames;

  switch (form) {
    
  case FORM_A2__C2:
    {
      for (int i = 0; i < nframes; i++) {
	double sound = GAIN * SINFN(_phi);
	_phi += _dphi;
	buf[i * 2] = sound;
	buf[i * 2 + 1] = sound;
      }
    }
    break;

  case FORM_A2__A2:
    {
      BOOL result = [_sEnvelope auEval:now nframes:nframes];
      (void) result;
    
      MSKSAMPTYPE *gain = _sEnvelope->_frames;
      for (int i = 0; i < nframes; i++) {
	double sound = GAIN * SINFN(_phi);
	_phi += _dphi;
	buf[i*2] = gain[i*2] * sound;
	buf[i*2 + 1] = gain[i*2 + 1] * sound;
      }
      _active = _sEnvelope->_active;
    }
    break;
  }

  return YES;
}

#if LOGDEALLOC
- (void) dealloc {
  NSLog(@"MSKSinFixedOscillator dealloc");
}
#endif


@end


