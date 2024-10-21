/** -*-  mode: c++ -*-
 *
 * A biquad or moog filter
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/filt/MSKGeneralFilter.h"

#include "synthpp_biquad.h"
#include "synthpp_moog.h"

@implementation MSKGeneralFilter {
  msk_filter_type_enum oldtype;
  synthpp_biquad *biquad;
  synthpp_moog *moog;
}

- (id) initWithCtx:(MSKContext*)c {

  if (self = [super initWithCtx:c]) {
    oldtype = MSK_FILTER_NONE;
    biquad = new class synthpp_biquad(c.rate, c.persize);
    moog = new class synthpp_moog(c.rate, c.persize);
  }
  return self;
}

- (BOOL) compile {

  if (_model != nil) {
    biquad->fc.setRef(_model->_fc);
    biquad->q.setRef(_model->_q);
    biquad->fcmod.setRef(_model->_fcmod);

    moog->fc.setRef(_model->_fc);
    moog->q.setRef(_model->_q);    
    moog->fcmod.setRef(_model->_fcmod);
  }

  return [super compile];
}

- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  // v.sInput->_sing(v.sInput, nframes);
  // CFMSKContextVoiceEval(v.sInput, now, nframes);
  BOOL res = [_sInput auEval:now nframes:nframes];
  (void) res;

  // FSAMPTYPE *in = _sInput->_frames;
  // FSAMPTYPE *out = _frames;

  a2Rate<float> out; out.addr = _frames;
  a2Rate<float> in; in.addr = _sInput->_frames;

  bool isNone = 0;
  bool isBiquad = 0;
  bool isMoog = 0;

  if (_model != nil) {
    msk_filter_type_enum newtype = _model->_filtertype;

    if (newtype != oldtype) {
      if (newtype == MSK_FILTER_NONE) {
	isNone = 1;
      }
      else if (newtype == MSK_FILTER_BIQUAD_TYPE_LOWPASS) {
	biquad->setType(bq_type_lowpass);
      }
      else if (newtype == MSK_FILTER_BIQUAD_TYPE_HIGHPASS) {
	biquad->setType(bq_type_highpass);
      }
      else if (newtype == MSK_FILTER_BIQUAD_TYPE_BANDPASS) {
	biquad->setType(bq_type_bandpass);
      }
      else if (newtype == MSK_FILTER_BIQUAD_TYPE_NOTCH) {
	biquad->setType(bq_type_notch);
      }
      else if (newtype == MSK_FILTER_BIQUAD_TYPE_PEAK) {
	biquad->setType(bq_type_peak);
      }
      else if (newtype == MSK_FILTER_BIQUAD_TYPE_LOWSHELF) {
	biquad->setType(bq_type_lowshelf);
      }
      else if (newtype == MSK_FILTER_BIQUAD_TYPE_HIGHSHELF) {
	biquad->setType(bq_type_highshelf);
      }
      else if (newtype == MSK_FILTER_MOOG) {
	moog->setTanh(0);
	isMoog = 1;
      }
      else if (newtype == MSK_FILTER_MOOG_TANH) {
	moog->setTanh(1);
	isMoog = 1;
      }
      oldtype = newtype;
    }
  }

  switch (oldtype) {
  case MSK_FILTER_NONE:
    isNone = 1;
    break;
  case MSK_FILTER_BIQUAD_TYPE_LOWPASS:
  case MSK_FILTER_BIQUAD_TYPE_HIGHPASS:
  case MSK_FILTER_BIQUAD_TYPE_BANDPASS:
  case MSK_FILTER_BIQUAD_TYPE_NOTCH:
  case MSK_FILTER_BIQUAD_TYPE_PEAK:
  case MSK_FILTER_BIQUAD_TYPE_LOWSHELF:
  case MSK_FILTER_BIQUAD_TYPE_HIGHSHELF:
    isBiquad = 1;
    break;
  case MSK_FILTER_MOOG:
  case MSK_FILTER_MOOG_TANH:
    isMoog = 1;
    break;
  }

  if (isNone) {
    memcpy(_frames, _sInput->_frames, _length);
  }
  else if (isBiquad) {
    biquad->render(out, in);
  }
  else if (isMoog) {
    moog->render(out, in);
  }

  _active = _sInput->_active;
  return YES;
}

+ (MSKGeneralFilter*) filterWithLowpass:(MSKContext*)ctx {

  MSKGeneralFilter *lpf = [[MSKGeneralFilter alloc] initWithCtx:ctx];
  lpf->biquad->makeLowpass();
  return lpf;

}

@end
