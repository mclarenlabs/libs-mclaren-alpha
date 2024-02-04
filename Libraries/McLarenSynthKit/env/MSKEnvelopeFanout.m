/** -*- mode:objc -*-
 *
 * An Envelope Fanout re-sends the envelope protocol methods (noteOff,
 * notAbort and noteReset) to a collection of envelopes.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/env/MSKEnvelopeFanout.h"

@implementation MSKEnvelopeFanout

- (id) initWithCtx:(MSKContext*)c {
  if (self = [super initWithCtx:c]) {
  }
  return self;
}

- (BOOL) noteOff {

  if (_env1 != nil)
    [_env1 noteOff];
  
  if (_env2 != nil)
    [_env2 noteOff];
  
  if (_env3 != nil)
    [_env3 noteOff];
  
  if (_env4 != nil)
    [_env4 noteOff];
  
  return YES;
}

- (BOOL) noteAbort {

  if (_env1 != nil)
    [_env1 noteAbort];

  if (_env2 != nil)
    [_env2 noteAbort];

  if (_env3 != nil)
    [_env3 noteAbort];

  if (_env4 != nil)
    [_env4 noteAbort];

  return YES;
}


- (BOOL) noteReset:(int)idx {

  if (_env1 != nil)
    [_env1 noteReset:idx];

  if (_env2 != nil)
    [_env2 noteReset:idx];

  if (_env3 != nil)
    [_env3 noteReset:idx];

  if (_env4 != nil)
    [_env4 noteReset:idx];

  return YES;
}

- (BOOL) compile {
  return YES;
}

- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {
  return YES;
}

#if LOGDEALLOC
- (void) dealloc {
  NSLog(@"MSKEnvelopeFanout dealloc");
}
#endif 



@end
