/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * An envelope produces a buffer of values in [0 .. 1.0]
 *
 * Copyright (c) McLaren Labs 2024
 */

extern "C" {
#include "math.h"
#import "McLarenSynthKit/env/MSKLinEnvelope.h"
#import "McLarenSynthKit/fifo/MSKOFifo.h"
}

#include "synthpp_env.h"

@implementation MSKLinEnvelope {

  linEnv *_linEnv;
  MSKOFifo *_ofifo; // the ofifo of the ctx
}

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {
    _linEnv = new struct linEnv(c.rate, c.persize);
    _ofifo = _ctx.ofifo;         // the output fifo to write to

    _oneshot = NO;
    _shottime = 0.1;
    _iGain = 1.0;
  }
  return self;
}

- (BOOL) compile {

  if (_model != nil) {
    _linEnv->attack.setRef(_model->_attack);
    _linEnv->decay.setRef(_model->_decay);
    _linEnv->sustain.setRef(_model->_sustain);
    _linEnv->rel.setRef(_model->_rel);
  }

  if (_oneshot == YES) {
    _linEnv->oneshot = 1;
    _linEnv->shottime = _shottime;
  }

  _linEnv->gain = _iGain;

  return [super compile];
}
  

- (BOOL) noteOff {
  _linEnv->noteOff();
  return YES;
}

- (BOOL) noteAbort {
  _linEnv->noteAbort();
  return YES;
}

- (BOOL) noteReset:(int)idx {
  if (idx == -1 || idx == _audioIdx) {
    _linEnv->noteReset();
  }
  return YES;
}

-(BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  MSKSAMPTYPE *buf = _frames;

  a2Rate<float> out; out.addr = buf;
  _linEnv->render(out);

  CFMSKContextEnvelopeExport(self, _linEnv->getT(), _linEnv->getEnvMax());
  _active = (_linEnv->isDone() == false);
   
  return YES;
}

#if LOGDEALLOC
- (void) dealloc {
  NSLog(@"MSKLinEnvelope dealloc");
}
#endif 



@end
