/** -*- mode:objc -*-
 *
 * A Sample Recorder reads from the 'rbuf' of a recording context (or any other
 * voice) and writes samples to a Sample object.
 *
 * The Recorder begins when recOn is called and stops when recOff is called,
 * or when the Sample runs out of capacity.  When recording is finished,
 * the Recorders _active flag is set to NO and it is released by the context
 * so that it can be reclaimed
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/sample/MSKSample.h"
#import "McLarenSynthKit/sample/MSKSampleRecorder.h"

@implementation MSKSampleRecorder

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {
    isRecording = NO;
    stopRecording = NO;
  }
  return self;
}

- (void) setSample:(MSKSample*)sample {
  _sample = sample;
  [_sample recorderSetsSamplerate:_ctx.rate];

  // max frames we can store in the data
  maxFrames = [_sample capacity];
  _position = 0;
}

- (MSKSample*) sample {
  return _sample;
}

- (BOOL) recOn {
  isRecording = YES;
  _position = 0;
  return YES;
}

- (BOOL) recOff {
  stopRecording = YES;
  return YES;
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

  // eval our predecessor
  BOOL res = [_sInput auEval:now nframes:nframes];
  (void) res;

  MSKSAMPTYPE *buf = _sInput->_frames;
  
  unsigned persize = _persize; // the period size - should be same as nframes

  float *sbuf = [_sample bytes];

  if (isRecording == YES) {

    // NSLog(@"recording:%d %d %d", _position, persize, maxFrames);

    int i = 0;
    while ((i < persize) & (_position < maxFrames)) {
      sbuf[2 * _position] = buf[2 * i];
      sbuf[2 * _position + 1] = buf[2 * i + 1];
      i++;
      _position++;
    }

    if (stopRecording == YES) {
      [_sample recorderSetsFrames: _position]; // actual frames recorded
      [_sample recorderSetsChannels: 2];
      _active = NO; // CTX to release this recorder now
    }
  }
  return YES;
}

@end


