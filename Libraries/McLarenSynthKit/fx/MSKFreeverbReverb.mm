/** -*- mode: c++ -*-
 *
 * Transcription of Freeverb for ObjC
 *
 */

extern "C" {
#import "McLarenSynthKit/fx/MSKFreeverbReverb.h"
}

#include "synthpp_freeverb.h"

@implementation MSKFreeverbReverb {
  // freeverb *freeverb;
  synthpp_freeverb *sppfreeverb;
}


- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {

    // freeverb = new class freeverb(c.rate, c.persize);
    sppfreeverb = new class synthpp_freeverb(c.rate, c.persize);

  }

  return self;
}


//
// ContextVoice Section
//

- (BOOL) compile {

  if (_model != nil) {
    sppfreeverb->dry.setRef(_model->_dry);
    sppfreeverb->wet.setRef(_model->_wet);
    sppfreeverb->roomsize.setRef(_model->_roomsize);
    sppfreeverb->damp.setRef(_model->_damp);
  }

  return YES;
}


- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  __unsafe_unretained MSKReverbModel *model = _model;

  // eval our predecessor
  BOOL res = [_sInput auEval:now nframes:nframes];
  (void) res;

  if (model && model->_on) {

    a2Rate<float> out; out.addr = _frames;
    a2Rate<float> in; in.addr = _sInput->_frames;

    sppfreeverb->render(out, in);
    
  }
  else {
    memcpy(_frames, _sInput->_frames, _length);
  }
  _active = _sInput->_active;
  return YES;
}


//
// Reverberator Section
//

- (void) mute {
  sppfreeverb->mute();
}


@end

