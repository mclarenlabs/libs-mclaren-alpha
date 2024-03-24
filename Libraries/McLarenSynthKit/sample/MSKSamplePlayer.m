/** -*- mode:objc -*-
 *
 * A SamplePlayer reads data from an in-memory sample and plays it
 * in a context.
 *
 * McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/sample/MSKSample.h"
#import "McLarenSynthKit/sample/MSKSamplePlayer.h"

@implementation MSKSamplePlayer

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {

  }
  return self;
}

- (void) setSample:(MSKSample*)sample {
  _sample = sample;
  _position = 0;
}

- (MSKSample*) sample {
  return _sample;
}

/*
 * The following method must be implemented for MSKContext
 */

- (BOOL) compile {
  return YES;
}
 

/*
 * The following two methods are called from the audio thread
 */

- (BOOL) auInit:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {
  return YES;
}


- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  MSKSAMPTYPE *buf = _frames;  // our frame storage
  unsigned persize = _persize; // the period size - should be same as nframes

  unsigned sampleframes = _sample.frames;

  // count is persize unless position+persize>=sampleframes
  int count;
  if (_position + persize >= sampleframes) {
    count = sampleframes - _position;
  }
  else {
    count = persize;
  }

  if (_sample.channels == 1) {
    // duplicate samples to stereo
    for (int i = 0; i < count; i++) {
      float *s = [_sample frame: _position + i];
      buf[i * 2] = s[0];
      buf[i * 2 + 1] = s[0];
    }
  }
  else if (_sample.channels == 2) {

    float *s = [_sample frame: _position]; // start of frame[position]
    for (int i = 0; i < count; i++) {
      buf[i * 2] = s[i * 2];
      buf[i * 2 + 1] = s[i * 2 + 1];
    }
      
  }
  else {
    // only copy first two channels
    for (int i = 0; i < count; i++) {
      float *s = [_sample frame: _position + i];
      buf[i * 2] = s[0];
      buf[i * 2 + 1] = s[1];
    }
  }

  // fill the rest with zeros if there is any
  for (int i = count; i < persize; i++) {
    buf[i * 2] = 0;
    buf[i * 2 + 1] = 0;
  }
    
  // increment position, determine if we are done
  if (_position + persize >= sampleframes) {
    _active = NO;
    _position = sampleframes;
  }
  else {
    _position += persize;
  }

  return YES;
}
@end

