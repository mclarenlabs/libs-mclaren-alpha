/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * An envelope produces a buffer of values in [0 .. 1.0]
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

extern "C" {
#include "math.h"
#import "McLarenSynthKit/env/MSKExpEnvelope.h"
#import "McLarenSynthKit/fifo/MSKOFifo.h"
}

#include "synthpp_env.h"

@implementation MSKExpEnvelope {

  expEnv *_expEnv;
  
}

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {

    _expEnv = new struct expEnv(c.rate, c.persize);

    _oneshot = NO;
    _shottime = 0.1;
    _iGain = 1.0;

  }
  return self;
}

- (BOOL) compile {

  if (_model != nil) {
    _expEnv->attack.setRef(_model->_attack);
    _expEnv->decay.setRef(_model->_decay);
    _expEnv->sustain.setRef(_model->_sustain);
    _expEnv->rel.setRef(_model->_rel);
  }

  if (_oneshot == YES) {
    _expEnv->oneshot = 1;
    _expEnv->shottime = _shottime;
  }

  _expEnv->gain = _iGain;

  return [super compile];
}

- (BOOL) noteOff {
  _expEnv->noteOff();
  return YES;
}

- (BOOL) noteAbort {
  _expEnv->noteAbort();
  return YES;
}

- (BOOL) noteReset:(int)idx {
  if (idx == -1 || idx == _audioIdx) {
    _expEnv->noteReset();
  }
  return YES;
}

- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  MSKSAMPTYPE *buf = _frames;

  a2Rate<float> out; out.addr = buf;
  _expEnv->render(out);

  CFMSKContextEnvelopeExport(self, _expEnv->getT(), _expEnv->getEnvMax());
  _active = (_expEnv->isDone() == false);

  return YES;
}

#if LOGDEALLOC
- (void) dealloc {
  NSLog(@"MSKExpEnvelope dealloc");
}
#endif



@end
