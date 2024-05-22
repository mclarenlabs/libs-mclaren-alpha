/**  -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * An Audio Context and its friends:
 *  MSKContextBuffer
 *  MSKContextVoice
 *  MSKContextEnvelope protocol
 *  MSKContextRequest
 *  MSKContext
 *
 * Copyright (c) McLaren Labs 2024
 */

// #include "config.h"
#include "math.h"
#include "msk_rmscalc.h"

#import "AlsaSoundKit/ASKError.h"
#import "McLarenSynthKit/MSKError.h"
#import "AlsaSoundKit/ASKPcmSystem.h"
#import "AlsaSoundKit/ASKPcm.h"
#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/voice/MSKSinFixedOscillator.h"
#import "McLarenSynthKit/env/MSKLinEnvelope.h"
#import "McLarenSynthKit/filt/MSKGeneralFilter.h"
#import "McLarenSynthKit/fifo/MSKOFifo.h"

static int CTXDEBUG = 1;
static BOOL playsChime = YES;    // Context plays tones when it starts

#define MAXVOICES 32            // static array for voice reservation

/*
 * A Context Buffer allocates a buffer sized for the Context.
 */

@implementation MSKContextBuffer

- (id) initWithCtx:(MSKContext*)ctx {

  if (self = [super init]) {
    _ctx = ctx;
    [self allocateBuffer];
  }
  return self;
}

- (BOOL) allocateBuffer {
  _persize = _ctx.persize;
  _length = _persize * _ctx.channels * sizeof(MSKSAMPTYPE);
  _data = [NSMutableData dataWithLength:_length];
  _frames = (MSKSAMPTYPE*) [_data bytes];

  return 1;
}

void CFMSKContextBufferClear(__unsafe_unretained MSKContextBuffer *v) {
  memset(v->_frames, 0, v->_length);
}
  
@end

/*
 * The base MSKContextVoice allocates a buffer and has a default SING function.
 */

@implementation MSKContextVoice

- (id) initWithCtx:(MSKContext*)ctx {

  if (self = [super initWithCtx:ctx]) {
    _active = YES;
    _reclaim = NO;

    _isInitialized = NO;
    _when = 0;
  }
  return self;
}

- (BOOL) auEval:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {

  // initialize this voice the first time it is called
  if (_isInitialized == NO) {
    BOOL result = [self auInit:now nframes:nframes];
    (void) result;
    _isInitialized = YES;
    _when = now;
  }
  else {
    // if we have already been evaluated in this time step then return
    if (now > _when) {
      _when = now;
    }
    else {
      return NO;
    }
  }

  // call render
  return [self auRender:now nframes:nframes];
}

- (BOOL) compile {
  NSLog(@"Compile method must be implemented");
  exit(1);
}

- (BOOL) auInit:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {
  return YES;
}

- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes {
  return YES;
}

- (void) dealloc {
#if LOGDEALLOC
  NSLog(@"MSKContextVoice dealloc");
#endif
}

@end

/*
 * MSKContextEnvelope is a Voice with additional state and methods
 */
@implementation MSKContextEnvelope {
  __unsafe_unretained MSKOFifo *_ofifo; // for exporting status messages
}

- (id) initWithCtx:(MSKContext*)ctx {
  if (self = [super initWithCtx:ctx]) {
    _gate = 1;
    _abort = 0;
    _reset = 0;
    _ofifo = ctx.ofifo;
  }
  return self;
}

- (BOOL) noteOff {
  _gate = 0;
  return YES;
}

- (BOOL) noteAbort {
  _abort = 1;
  return YES;
}

- (BOOL) noteReset:(int)idx {
  if (idx == -1 || idx == _audioIdx) {
    _reset = 1;
  }
  return YES;
}

BOOL CFMSKContextEnvelopeExport(__unsafe_unretained MSKContextEnvelope *v, double t, double maxval) {

  msk_ofifo_message_t msg;

  if (CFMSKOFifo_avail(v->_ofifo) == YES) {

    msg.tag = MSK_OFIFO_TAG_ENVELOPE;
    msg.idx = v->_audioIdx;
    msg.data.envelope.gate = v->_gate;
    msg.data.envelope.active = v->_active;
    msg.data.envelope.t = t;
    msg.data.envelope.val = maxval;

    BOOL ok = CFMSKOFifo_write_message(v->_ofifo, msg);
    (void) ok;
  }
  return YES;
}

@end

/*
 * MSKContextVoiceRetainer manages reference transfers from dispatch-land to
 * audio-thread land.
 */

@implementation MSKContextVoiceRetainer  {

  // to be modified in the dispatch thread
  MSKContextVoice *_rvoices[MAXVOICES];

  // to be read in the audio thread
@public
  __unsafe_unretained MSKContextVoice *_uvoices[MAXVOICES]; // unretained
}


- (id) init {
  if (self = [super init]) {
    for (int i = 0; i < MAXVOICES; i++) {
      _rvoices[i] = nil;
      _uvoices[i] = NULL;
    }
  }
  return self;
}

- (BOOL) onContextRetainVoice:(MSKContextVoice*)v {

  BOOL result = NO;
  for (int i = 0; i < MAXVOICES; i++) {
    if (_rvoices[i] == nil) {
      _rvoices[i] = v;
      _uvoices[i] = v;
      // NSLog(@"retained _rvoices[%d]", i);
      result = YES;
      break;
    }
  }

  // opportunistically clean up 
  for (int i = 0; i < MAXVOICES; i++) {
    if ((_uvoices[i] == NULL) && (_rvoices[i] != nil)) {
      _rvoices[i] = nil;
      // NSLog(@"reclaimed _uvoices[%d]", i);
    }
  }

  return result;
}

- (void) onContextReleaseDeadVoices {

  // opportunistically clean up 
  for (int i = 0; i < MAXVOICES; i++) {
    if ((_uvoices[i] == NULL) && (_rvoices[i] != nil)) {
      _rvoices[i] = nil;
      // NSLog(@"reclaimed _uvoices[%d]", i);
    }
  }

}

MSKContextVoice *CFMSKContextVoiceRetainerGetVoice(__unsafe_unretained MSKContextVoiceRetainer *r, int i) {
  assert (i >= 0);
  assert (i < MAXVOICES);
  return r->_uvoices[i];
}

void CFMSKContextVoiceRetainerReleaseVoice(__unsafe_unretained MSKContextVoiceRetainer *r, int i) {
  assert (i >= 0);
  assert (i < MAXVOICES);
  r->_uvoices[i] = NULL;
}

void CFMSKContextVoiceRetainerReleaseInactiveVoices(__unsafe_unretained MSKContextVoiceRetainer *r) {
  for (int i = 0; i < MAXVOICES; i++) {
    if (r->_uvoices[i] != NULL) {
      __unsafe_unretained MSKContextVoice *voice = r->_uvoices[i];
          if (voice->_active == NO) {
            r->_uvoices[i] = NULL;
          }
    }
  }
}

void CFMSKContextVoiceRetainerReleaseReclaimedFx(__unsafe_unretained MSKContextVoiceRetainer *r) {
  for (int i = 0; i < MAXVOICES; i++) {
    if (r->_uvoices[i] != NULL) {
      __unsafe_unretained MSKContextVoice *voice = r->_uvoices[i];
          if (voice->_reclaim == YES) {
            r->_uvoices[i] = NULL;
          }
    }
  }
}

@end

/*
 * MSKContextRequest is simple object with rate, persize and periods fields.
 * It current has no methods.
 */

@implementation MSKContextRequest

- (id) init {
  if (self = [super init]) {
    self.isExact = NO; // to be back-compatible, a request is not an exact demand
  }
  return self;
}

@end

/*
 * MSKContext Private Category
 *
 * This category defines private variables used internally by the Context.
 * The defined ivars are carefully designed as only C types and are used
 * to communicate from the outside world into the audio thread, or from the
 * audio thread to the dispatch timer block.
 *
 * Voices transferred from the Dispatch world into the Audio Thread
 * use a two-phase commit/release procedure.  To commit a voice to the
 * Audio Thread, a reference to the voice is written to _varray - this
 * holds a reference, and an unretained pointer is written to _vptr[i],
 * which the Audio Thread plays from.
 *
 * When the Audio Thread is done with the voice, it clears the _vptr[i]
 * entry.  This does not release the voice.
 *
 * The next time a voice is added, the _vptr[] entries are examined, and
 * if any are cleared but their corresponding _varray[] is not, then the
 * _varray entry can be released in the dispatch world.
 *
 */

@interface MSKContext()

// Properties related to retaining voices and fx
@property (readonly) MSKContextVoiceRetainer *vretainer;
@property (readonly) MSKContextVoiceRetainer *xretainer;
@property (readonly) MSKContextVoice *oldfx; // the former active FX if there is one

// Properties relating to the audio buffer
@property (readonly)  int pcmBufferLength;
@property (readonly) NSData *pcmBufferData;
@property (readonly) void *pcmBufferFrames;

@property (readonly)  double oldgain; // for gain interpolation
@property (readwrite) dispatch_queue_t aqueue;
@property (readwrite) dispatch_source_t timer;
@end

/*
 * An ALSA Audio Context
 *
 * It creates an audio context with the parameter request it receives.
 */

@implementation MSKContext

+ (void) setPlaysChime:(BOOL)doesPlayChime {
  playsChime = doesPlayChime;
}


- (id) initWithName:(NSString*)pcmname andStream:(snd_pcm_stream_t)stream error:(NSError**)error {
  if (self = [super init]) {

    _name = pcmname;
    _stream = stream;
    _aqueue = [MSKContext sharedQueue];

    _pcm = [[ASKPcm alloc] initWithName:pcmname stream:stream error:error];

    if (CTXDEBUG)
      NSLog(@"MSKContext %@ _pcm %@", pcmname, _pcm);

    // 2020-06-17 self.polyphony = -1;
    // 2020-06-17 self.voices = [[NSMutableArray alloc] init];

    _vretainer = [[MSKContextVoiceRetainer alloc] init];
    _xretainer = [[MSKContextVoiceRetainer alloc] init];

    _f = 0;
    _t = 0;
    // _deltat = (1.0 / self.rate); // rate is not known yet
    _gain = 0.5;
    _oldgain = _gain;

    _ofifo = [[MSKOFifo alloc] init];

  }
  return self;
}

- (BOOL) configureForRequest:(MSKContextRequest*)request error:(NSError**)error {

  if (CTXDEBUG)
    NSLog(@"MSKContext configureForRequest: name:%@ stream:%u", _name, _stream);

  BOOL hwok = [self setHardwareParams:request error:error];
  if (hwok == YES) {
    BOOL swok = [self setSoftwareParams:error];
    if (swok == YES) {
      BOOL bufok = [self allocatePcmBuffer:error];
      if (bufok == YES) {
      }
      else {
        NSLog(@"MSKContext could not allocate buffer");
        return NO;
      }
    }
    else {
      NSLog(@"MSKContext could not set software parameters");
      return NO;
    }
  }
  else {
    NSLog(@"MSKContext could not set hardware parameters");
    return NO;
  }
  if (CTXDEBUG)
    NSLog(@"MSKContext name:%@ persize:%lu rate:%d", _name, _persize, _rate);
  return YES;
}

- (BOOL) configureLikeContext:(MSKContext*)other error:(NSError**)error {
  unsigned rate = other.rate;
  snd_pcm_uframes_t persize = other.persize;
  unsigned periods = other.periods;

  if (CTXDEBUG)
    NSLog(@"MSKContext configureLikeContext: name:%@ stream:%u", _name, _stream);

  MSKContextRequest *exact = [[MSKContextRequest alloc] init];
  exact.isExact = YES;
  exact.rate = rate;
  exact.persize = persize;
  exact.periods = periods;

  BOOL ok = [self configureForRequest:exact error:error];
  return ok;
}

- (BOOL) startWithError:(NSError**)error {
  _deltat = (1.0 / self.rate);  // rate is known after configuration
  [self launchTimer];           // launch our Audio Thread dispatch listener
  BOOL ok = [_pcm startThreadWithError:error];  // launch the Audio Thread
  return ok;
}

- (id) initWithName:(NSString*)pcmname andStream:(snd_pcm_stream_t)stream andRequest:(MSKContextRequest*)request error:(NSError**)error {
  if (self = [super init]) {

    _name = pcmname;
    _stream = stream;
    _aqueue = [MSKContext sharedQueue];

    _pcm = [[ASKPcm alloc] initWithName:pcmname stream:stream error:error];

    if (*error != nil) {
      return self;
    }

    // 2020-06-17 _polyphony = -1;
    // 2020-06-17 _voices = [[NSMutableArray alloc] init];

    _vretainer = [[MSKContextVoiceRetainer alloc] init];
    _xretainer = [[MSKContextVoiceRetainer alloc] init];

    _ofifo = [[MSKOFifo alloc] init]; // must be before sw params because it uses an envelope

    BOOL hwok = [self setHardwareParams:request error:error];
    if (hwok == YES) {
      BOOL swok = [self setSoftwareParams:error];
      if (swok == YES) {
        BOOL bufok = [self allocatePcmBuffer:error];
        if (bufok == YES) {
        }
        else {
          NSLog(@"MSKContext could not allocate buffer");
          return self;
        }
      }
      else {
        NSLog(@"MSKContext could not set software parameters");
        return self;
      }
    }
    else {
      NSLog(@"MSKContext could not set hardware parameters");
      return self;
    }

    _f = 0;
    _t = 0;
    _deltat = (1.0 / self.rate);
    _gain = 0.5;
    _oldgain = _gain;

    [self launchTimer];         // launch our Audio Thread dispatch listener

    BOOL ok = [_pcm startThreadWithError:error]; // launch the Audio Thread
    if (ok == YES) {
    }
    else {
      NSLog(@"MSKContext could not launch audio thread");
    }

    if (CTXDEBUG)
      NSLog(@"MSKContext name:%@ persize:%lu rate:%d", _name, _persize, _rate);
  }
  return self;
}

/*
 * Allocate the Buffer in the format of the sound card
 */

- (BOOL) allocatePcmBuffer:(NSError**)error {

  _pcmBufferLength = _persize * _channels * _formatsize;

  if (_pcmBufferLength <= 0) {
    *error = [NSError errorWithMSKContextError:kMSKContextErrorIllegalValue
                                         str:[NSString stringWithFormat:@"Illegal length:%d", _pcmBufferLength]];
    return NO;
  }

  _pcmBufferData = [NSMutableData dataWithLength:_pcmBufferLength];
  _pcmBufferFrames = (void*) [_pcmBufferData bytes];
  return YES;
}

/*
 * Set the Hardware Parameters from the desired period size and count.
 * Set _persize and _periods.  Get _bufsize
 */

- (BOOL) setBufferParams:(ASKPcmHwParams*)params fromPeriods:(unsigned)periods andPersize:(snd_pcm_uframes_t)persize isExact:(BOOL)isExact error:(NSError**)error {

  BOOL ok;
  NSError *under = nil;

  _periods = periods;

  if (isExact == YES) {
    goto EXACT;
  }

  // NEAR algorithm

  ok = [self.pcm setPeriodsNear:params val:&_periods error:&under];
  
  if (ok == NO) {

    // could not set periods first, try setting persize first
    _persize = persize;
    ok = [self.pcm setPeriodSizeNear:params val:&_persize error:&under];
    if (ok == NO) {
      // NSLog(@"cannot set period size %lu (%@)", _persize, under);
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot set period size %lu", _persize]
                                         under:under];
      return NO;
    }

    // now set periods
    _periods = periods;
    ok = [self.pcm setPeriodsNear:params val:&_periods error:&under];
    if (ok == NO) {
      // NSLog(@"cannot set periods near %i (%@)", _periods, under);
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot set periods near %i", _periods]
                                         under:under];
      return NO;
    }
  }

  else {
    // periods is set, now set persize

    _persize = persize;
    ok = [self.pcm setPeriodSizeNear:params val:&_persize error:&under];
    if (ok == NO) {
      // NSLog(@"cannot set period size %lu (%@)", _persize, under);
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot set periods size %lu", _persize]
                                         under:under];
      return NO;
    }
  }

  // finally get bufsize and return YES
  ok = [params getBufferSize:&_bufsize error:&under];
  if (ok == NO) {
    // NSLog(@"cannot get buffer size (%@)", under)
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot get buffer size"]
                                       under:under];
    return NO;
  }
  return YES;

 EXACT:

  // Use the EXACT params algorithm
  
  ok = [self.pcm setPeriods:params val:_periods error:&under];
  
  if (ok == NO) {

    // could not set periods first, try setting persize first
    _persize = persize;
    ok = [self.pcm setPeriodSize:params val:_persize error:&under];
    if (ok == NO) {
      // NSLog(@"cannot set period size %lu (%@)", _persize, under);
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot set period size %lu", _persize]
                                         under:under];
      return NO;
    }

    // now set periods
    _periods = periods;
    ok = [self.pcm setPeriods:params val:_periods error:&under];
    if (ok == NO) {
      // NSLog(@"cannot set periods near %i (%@)", _periods, under);
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot set periods near %i", _periods]
                                         under:under];
      return NO;
    }
  }

  else {
    // periods is set, now set persize

    _persize = persize;
    ok = [self.pcm setPeriodSize:params val:_persize error:&under];
    if (ok == NO) {
      // NSLog(@"cannot set period size %lu (%s)", _persize, snd_strerror(err));
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot set period size %lu", _persize]
                                         under:under];
      return NO;
    }
  }

  // finally get bufsize and return YES
  ok = [params getBufferSize:&_bufsize error:&under];
  if (ok == NO) {
    // NSLog(@"cannot get buffer size (%@)", under);
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot get buffer size"]
                                       under:under];
    return NO;
  }
  return YES;
}


- (BOOL) setHardwareParams:(MSKContextRequest*)request error:(NSError**)error {

  BOOL ok;
  NSError *under = nil;

  _hwparams = [_pcm getHwParams:error]; // get an initial set of HW parameters
  if (_hwparams == nil) {
    return NO;
  }

  if (CTXDEBUG) {
    NSLog(@"MSKContext setHardwareParams Initial:%@", self.hwparams);
  }

  _rate = request.rate;
  _channels = 2;
  
  if (request.isExact == YES) {
    ok = [self.pcm setRate:self.hwparams val:_rate error:&under];
    if (ok == NO) {
      // NSLog(@"cannot set rate exact %u (%@)", _rate, under);
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot set rate exact %u", _rate]
                                         under:under];
      return NO;
    }
  }
  else {
    ok = [self.pcm setRateNear:self.hwparams val:&_rate error:&under];
    if (ok == NO) {
      if (CTXDEBUG) {
        NSLog(@"MSKContext cannot set rate near %u (%@) - returning NSError", _rate, under);
      }
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot set rate near %u", _rate]
                                         under:under];
      return NO;
    }
  }

  ok = [self.pcm setChannels:self.hwparams val:_channels error:&under];
  if (ok == NO) {
    // NSLog(@"cannot set channels %u (%@)", _channels, under);
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot set channels %u", _channels]
                                       under:under];
    return NO;
  }

  ok = [self.pcm setAccess:self.hwparams val:SND_PCM_ACCESS_RW_INTERLEAVED error:&under];
  if (ok == NO) {
    if (CTXDEBUG) {
      NSLog(@"MSKContext cannot set access INTERLEAVED (%@) - returning NSError", under);
    }
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot set access INTERLEAVED"]
                                       under:under];
    return NO;
  }

  // SND_PCM_FORMAT_FLOAT_LE
  _format = SND_PCM_FORMAT_FLOAT_LE;
  _formatsize = sizeof(float_t);
  _formatgain = (1.0 / 16.0);
  ok = [self.pcm setFormat:self.hwparams val:_format error:&under];
  if (ok == YES)
    goto FORMATOK;

  // Try S32 and S16 formats
  _format = SND_PCM_FORMAT_S32_LE;
  _formatsize = sizeof(int32_t);
  _formatgain = (0x1 << 28) * 1.0;
  ok = [self.pcm setFormat:self.hwparams val:_format error:&under];
  if (ok == YES)
    goto FORMATOK;
  
  // TOM: note - RPi3 internal is 22050 and S16.  it crackles.
  _format = SND_PCM_FORMAT_S16_LE;
  _formatsize = sizeof(int16_t);
  _formatgain = (0x1 << 12) * 1.0;
  ok = [self.pcm setFormat:self.hwparams val:_format error:&under];
  if (ok == YES)
    goto FORMATOK;
  
  if (CTXDEBUG) {
    NSLog(@"MSKContext cannot set format FLOAT_LE, S16_LE or S32_LE (%@) - returning NSError", under);
      }
  *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot set format S16_LE or S32_LE"]
                                       under:under];
  _format = SND_PCM_FORMAT_UNKNOWN;
  _formatsize = 0;
  return NO;

 FORMATOK:

  ok = [self setBufferParams:self.hwparams fromPeriods:request.periods andPersize:
request.persize isExact:request.isExact error:error];
  if (!ok) {
    if (CTXDEBUG) {
      NSLog(@"MSKContext cannot set buffer params: period and period size - returning NSError");
    }
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot buffer params: period and period size"]
                                       under:*error];
    return NO;
  }

  ok = [_pcm setHwParams:_hwparams error:error];
  if (ok != YES) {
    if (CTXDEBUG) {
      NSLog(@"MSKContext cannot set HW PARAMS (%@)", *error);
    }
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot set hw params"]
                                       under:*error];
    return NO;
  }

  // NOW, print the hw params to see how they are now
  if (CTXDEBUG) {
    NSLog(@"MSKContext setHardwareParams Final:%@", _hwparams);
  }

  return YES;
}

/*
 * Set up the `rbuf` and add the appropriate callbacks for capture
 */

- (BOOL) addCaptureCallbacks {

  // TOM: 2019-07-01
  _rbuf = [[MSKContextVoice alloc] initWithCtx:self];
  if (CTXDEBUG) {
    NSLog(@"MSKContext allocating rbuf:%@", _rbuf);
  }

  [self.pcm onCaptureBuffer:^{
      // 2020-07-29 
      CFMSKContextVoiceRetainerReleaseInactiveVoices(_vretainer);
      return _pcmBufferFrames;
    }];

  [self.pcm onCaptureThreadError:^(int err) {
      // this is called from the audio thread, so it must send a message
      if (CFMSKOFifo_avail(_ofifo) == YES) {
        msk_ofifo_message_t msg;
        msg.tag = MSK_OFIFO_TAG_THREADERROR;
        msg.idx = MSK_OFIFO_SOURCE_IDX_MAIN;
        msg.data.threaderror.alsaerr = err;
        BOOL ok = CFMSKOFifo_write_message(_ofifo, msg);
        (void) ok;
      }
    }];
  

  [self.pcm onCapture:^(snd_pcm_sframes_t nframes) {
      // copy _frames to rbuf, reformatting and calculating RMS

      CFMSKContextBufferClear(_rbuf);
      MSKSAMPTYPE *rframes = _rbuf->_frames;

      // compute audio levels
      msk_rmscalc_t rms;
      msk_rmscalc_clear(&rms);

      // interpolate the gain across the period
      double gainincr = (_gain - _oldgain) / nframes;

      if (_format == SND_PCM_FORMAT_S16_LE) {
        int16_t* buf = (int16_t*) _pcmBufferFrames;

        for (int i = 0; i < nframes; i++) {
          _oldgain += gainincr;

          double left = buf[i*2] * _oldgain / _formatgain;
          double right = buf[i*2 + 1] * _oldgain / _formatgain;

          msk_rmscalc_accum(&rms, left, right);

          rframes[i*2] = left;
          rframes[i*2 + 1] = right;
        }
      }
      
      // transfer output of filter into output frames and adjust format
      if (_format == SND_PCM_FORMAT_S32_LE) {
        int32_t* buf = (int32_t*) _pcmBufferFrames;

        for (int i = 0; i < nframes; i++) {
          _oldgain += gainincr;

          double left = buf[i*2] * _oldgain / _formatgain;
          double right = buf[i*2 + 1] * _oldgain / _formatgain;

          msk_rmscalc_accum(&rms, left, right);

          rframes[i*2] = left;
          rframes[i*2 + 1] = right;
        }
      }

      // transfer output of filter into output frames and adjust format
      if (_format == SND_PCM_FORMAT_FLOAT_LE) {
        float* buf = (float*) _pcmBufferFrames;

        for (int i = 0; i < nframes; i++) {
          _oldgain += gainincr;

          double left = buf[i*2] * _oldgain / _formatgain;
          double right = buf[i*2 + 1] * _oldgain / _formatgain;

          msk_rmscalc_accum(&rms, left, right);

          rframes[i*2] = left;
          rframes[i*2 + 1] = right;
        }
      }

      // save last value of gain
      _oldgain = _gain;

      {
        // compute RMS values
        msk_rmscalc_total(&rms, nframes);

        if (CFMSKOFifo_avail(_ofifo) == YES) {
          msk_ofifo_message_t msg;
          msg.tag = MSK_OFIFO_TAG_AUDIOLEVELS;
          msg.idx = MSK_OFIFO_SOURCE_IDX_MAIN;
          msg.data.audiolevel.rmsL = rms.rmsL;
          msg.data.audiolevel.rmsR = rms.rmsR;
          msg.data.audiolevel.absPeakL = rms.absPeakL;
          msg.data.audiolevel.absPeakR = rms.absPeakR;
          BOOL ok = CFMSKOFifo_write_message(_ofifo, msg);
          (void) ok;
        }
      }

      // update context time
      _f += nframes;
      _t = ((_f * 1.0) / _rate);

      // render rbuf into each voice that has been registered
      for (int i = 0; i < MAXVOICES; i++) {

        __unsafe_unretained MSKContextVoice *voice;
        voice = CFMSKContextVoiceRetainerGetVoice(_vretainer, i);
        
        if (voice == NULL) {
          continue;
        }

        // Render the voice (and its inputs recursively)
        // voice->_sing(voice, nframes);
        // CFMSKContextVoiceEval(voice, _f, nframes);
        BOOL result = [voice auEval:_f nframes:nframes];
        (void) result;
      }
        
    }];
  return YES;
}

- (BOOL) addPlaybackCallbacks {

  // start-up notes to hear PCM device is working
  __block MSKLinEnvelope *e1 = [[MSKLinEnvelope alloc] initWithCtx:self];
  __block MSKLinEnvelope *e2 = [[MSKLinEnvelope alloc] initWithCtx:self];

  if (playsChime == YES) {
    MSKSinFixedOscillator *v1 = [[MSKSinFixedOscillator alloc] initWithCtx:self];
    v1.iFreq = 440.0;
    v1.sEnvelope = e1;

    MSKSinFixedOscillator *v2 = [[MSKSinFixedOscillator alloc] initWithCtx:self];
    v2.iFreq = 490.0;
    v2.sEnvelope = e2;

    [self addVoice:v1];
    [self addVoice:v2];
  }

  // visible internal buffer
  _pbuf = [[MSKContextVoice alloc] initWithCtx:self];

  // default FX is a low-pass filter
  MSKGeneralFilter *bq = [MSKGeneralFilter filterWithLowpass:self];
  bq.sInput = self.pbuf;
  [self addFx:bq];

  // schedule our callback
  [self.pcm onPlayback:^(snd_pcm_sframes_t nframes) {

      if (nframes < _persize) {
        return (void*) NULL;
      }

      // this should never happen
      if (nframes > _bufsize) {
        NSLog(@"Error: NFrames:%ld Bufsize:%ld", nframes, self.bufsize);
        exit(1);
      }

      // 2020-08-24 removed
      // nframes = _persize;       // play no more than _persize

      if (e1 && _t > 2.0) {
        [e1 noteOff];
        e1 =  nil;
      }

      if (e2 && _t > 3.0) {
        [e2 noteOff];
        e2 = nil;
      }

      // TOM: 2018-02-16 serial reduction
      CFMSKContextBufferClear(_pbuf);
      MSKSAMPTYPE *cframes = _pbuf->_frames;

      // render each voice that has been registered into pbuf
      for (int i = 0; i < MAXVOICES; i++) {

        __unsafe_unretained MSKContextVoice *voice;
        voice = CFMSKContextVoiceRetainerGetVoice(_vretainer, i);

        if (voice == NULL) {
          continue;
        }

        // Render the voice (and its inputs recursively)
        // voice->_sing(voice, _f, nframes);
        // CFMSKContextVoiceEval(voice, _f, nframes);
        BOOL result = [voice auEval:_f nframes:nframes];
        (void) result;

        MSKSAMPTYPE *frames = voice->_frames;
        for (int i = 0; i < nframes; i++) {
          cframes[i*2] += frames[i*2];
          cframes[i*2 + 1] += frames[i*2 + 1];
        }
      }
        
      // render the FIRST fx that has been registered
      MSKSAMPTYPE *fxframes;
      for (int i = 0; i < MAXVOICES; i++) {
        __unsafe_unretained MSKContextVoice *fx;
        fx = CFMSKContextVoiceRetainerGetVoice(_xretainer, i);

        if (fx == NULL) {
          continue;
        }

        if (fx->_active == NO) {
          continue;
        }

        // Render the voice (and its inputs recursively)
        // fx->_sing(fx, nframes);
        // CFMSKContextVoiceEval(fx, _f, nframes);
        BOOL result = [fx auEval:_f nframes:nframes];
        (void) result;
        
        // set the raw mem for the translation
        fxframes = fx->_frames;
        break;
      }

      // Send out the FXFRAMES as a WAVE
      if (CFMSKOFifo_avail_varlength(_ofifo, _pbuf->_length) == YES) {
        msk_ofifo_message_t msg;
        msg.tag = MSK_OFIFO_TAG_VAR;
        msg.idx = MSK_OFIFO_SOURCE_IDX_MAIN;
        msg.data.var.length = _pbuf->_length;
        msg.data.var.bytes = fxframes;
        BOOL ok = CFMSKOFifo_write_message(_ofifo, msg);
        (void) ok;
      }
        
      // compute audio levels
      msk_rmscalc_t rms;
      msk_rmscalc_clear(&rms);

      // interpolate the gain across the period
      double gainincr = (_gain - _oldgain) / nframes;

      // transfer output of filter into output frames and adjust format
      if (_format == SND_PCM_FORMAT_S16_LE) {
        int16_t* buf = (int16_t*) _pcmBufferFrames;
        memset(buf, 0, _pcmBufferLength);

        for (int i = 0; i < nframes; i++) {
          _oldgain += gainincr;
          double left = _oldgain * fxframes[i*2];
          double right = _oldgain * fxframes[i*2 + 1];

          msk_rmscalc_accum(&rms, left, right);

          buf[i*2] = left * _formatgain;
          buf[i*2 + 1] = right *_formatgain;
        }
      }

      // transfer output of filter into output frames and adjust format
      if (_format == SND_PCM_FORMAT_S32_LE) {
        int32_t* buf = (int32_t*) _pcmBufferFrames;
        memset(buf, 0, _pcmBufferLength);

        for (int i = 0; i < nframes; i++) {
          _oldgain += gainincr;
          double left = _oldgain * fxframes[i*2];
          double right = _oldgain * fxframes[i*2 + 1];

          msk_rmscalc_accum(&rms, left, right);

          buf[i*2] = left * _formatgain;
          buf[i*2 + 1] = right *_formatgain;
        }
      }

      // transfer output of filter into output frames and adjust format
      if (_format == SND_PCM_FORMAT_FLOAT_LE) {
        float* buf = (float*) _pcmBufferFrames;
        memset(buf, 0, _pcmBufferLength);

        for (int i = 0; i < nframes; i++) {
          _oldgain += gainincr;
          double left = _oldgain * fxframes[i*2];
          double right = _oldgain * fxframes[i*2 + 1];

          msk_rmscalc_accum(&rms, left, right);

          buf[i*2] = left * _formatgain;
          buf[i*2 + 1] = right *_formatgain;
        }
      }

      // save last value of gain
      _oldgain = _gain;

      {
        // compute RMS values
        msk_rmscalc_total(&rms, nframes);

        if (CFMSKOFifo_avail(_ofifo) == YES) {
          msk_ofifo_message_t msg;
          msg.tag = MSK_OFIFO_TAG_AUDIOLEVELS;
          msg.idx = MSK_OFIFO_SOURCE_IDX_MAIN;
          msg.data.audiolevel.rmsL = rms.rmsL;
          msg.data.audiolevel.rmsR = rms.rmsR;
          msg.data.audiolevel.absPeakL = rms.absPeakL;
          msg.data.audiolevel.absPeakR = rms.absPeakR;
          BOOL ok = CFMSKOFifo_write_message(_ofifo, msg);
          (void) ok;
        }
      }

      // update context time
      _f += nframes;
      _t = ((_f * 1.0) / _rate);

      // submit the data to PCM
      return (void*) _pcmBufferFrames;
    }];

  // in the Audio Thread, cleanup after playing by releasing inactive voices
  [self.pcm onPlaybackCleanup:^{
      CFMSKContextVoiceRetainerReleaseInactiveVoices(_vretainer);
      CFMSKContextVoiceRetainerReleaseReclaimedFx(_xretainer);    
    }];

  [self.pcm onPlaybackThreadError:^(int err) {
      // this is called from the audio thread, so it must send a message
      if (CFMSKOFifo_avail(_ofifo) == YES) {
        msk_ofifo_message_t msg;
        msg.tag = MSK_OFIFO_TAG_THREADERROR;
        msg.idx = MSK_OFIFO_SOURCE_IDX_MAIN;
        msg.data.threaderror.alsaerr = err;
        BOOL ok = CFMSKOFifo_write_message(_ofifo, msg);
        (void) ok;
      }
    }];

  return YES;
}


- (BOOL) setSoftwareParams:(NSError**)error {

  // TOM: 2019-07-01
  if (CTXDEBUG)
    NSLog(@"MSKContext setSoftwareParams:%@ stream:%u", _name, _stream);

  _swparams = [self.pcm getSwParams];

  if (CTXDEBUG)
    NSLog(@"MSKContext setSoftwareParams Initial: %@", _swparams);

  // install the callbacks before we start the PCM
  if (_stream == SND_PCM_STREAM_CAPTURE) {
    BOOL ok = [self addCaptureCallbacks];
    if (ok == NO) {
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot install capture callbacks"]];
      return NO;
    }
  }
  else {
    BOOL ok = [self addPlaybackCallbacks];
    if (ok == NO) {
      *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                           str:[NSString stringWithFormat:@"cannot install playback callbacks"]];
      return NO;
    }
  }

  BOOL ok;
  NSError *under = nil;

  ok = [_pcm setAvailMin:_swparams val:_persize error:&under];
  if (ok == NO) {
    // NSLog(@"cannot set avail min %lu (%@)", _persize, under);
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot set avail min %lu", _persize]
                                       under:under];
    return NO;
  }

  ok = [_pcm setStartThreshold:_swparams val:0 error:&under];
  if (ok == NO) {
    if (CTXDEBUG) {
      NSLog(@"MSKContext cannot set start threshold (%@) - returning NSError", under);
    }
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot set start threshold"]
                                       under:under];
    return NO;
  }

  ok = [_pcm setSwParams:_swparams error:&under];
  if (ok == NO) {
    if (CTXDEBUG) {
      NSLog(@"MSKContext - cannot set sw params (%@) - returning NSError", under);
    }
    *error = [NSError errorWithMSKContextError:kMSKContextErrorCannotConfigureDevice
                                         str:[NSString stringWithFormat:@"cannot set sw params"]
                                       under:under];
    return NO;
  }

  if (CTXDEBUG)
    NSLog(@"MSKContext setSoftwareParams Final: %@", _swparams);

  return YES;
}

- (void) onRms:(MSKContextRMSBlock)block {
  _rmsblock = block;
}

- (void) onEnvelope:(MSKContextEnvelopeBlock)block {
  _envelopeblock = block;
}

- (void) onWave:(MSKContextWaveBlock)block {
  _waveblock = block;
}

- (void) onError:(MSKContextErrorBlock)block {
  _errorblock = block;
}

- (void) onCapture:(MSKContextCaptureBlock)block {
  _captureblock = block;
}

// translate vol [0..100] to an exponential value (0..1.0]
+ (double) vol2gain:(double)vol {
  // double gain = exp10((vol / 20.0) - 5.0);
  // exp10(x) = exp(M_LN10 * x)
  // double gain = exp(M_LN10 * ((vol / 20.0) - 5.0));
  // 2024-05-15
  double gain = exp(M_LN10 * ((vol / 20.0) - 3.0));
  return gain;
}

// translate gain (0..1.0] to a logarithmic value [0..100]
+ (double) gain2vol:(double)gain {
  // double vol = (gain<=0.00001) ? -10 : 20*(log10(gain) + 5.0);
  double vol = (gain<=0.00001) ? 0 : 20*(log10(gain) + 3.0);
  return vol;
}



/*
 * Add a voice to be played.  This method is called from a dispatch
 * queue that is generating voices.
 *
 * A two-phase commit is used: the voice is retained in the _varray[i] slot, and
 * a plain pointer is copied into the _vptr[i] slot.  The audio thread plays voices
 * using the plain pointers.
 *
 */

- (BOOL) addVoice:(MSKContextVoice*) voice {

  assert(voice->_ctx == self);

  BOOL res = [_vretainer onContextRetainVoice:voice];
  return res;
}

- (BOOL) addFx:(MSKContextVoice*)fx {

  assert(fx->_ctx == self);

  BOOL res = [_xretainer onContextRetainVoice:fx];

  if (_oldfx != nil) {
    _oldfx->_reclaim = YES;       // instruct the audio loop to remove the old FX
  }
  _oldfx = fx;                  // store the new one

  return res;
}

- (BOOL) allVoicesOff {
#if 0
  dispatch_async(_aqueue, ^{
      [self.voices removeAllObjects];
    });
#endif
  return YES;
}

/*
 * Set/Get the value of the gain.
 */

- (void) setGain:(double)gain {
  _gain = gain;
}

- (double) getGain {
  return _gain;
}

- (void) setVolume:(double)vol {
  [self setGain:[MSKContext vol2gain:vol]];
}

- (double) getVolume {
  return [MSKContext gain2vol:[self getGain]];
}
 


////////////////////////////////////////////////////////////////
//
// DISPATCH

+ (dispatch_queue_t) sharedQueue {
  static dispatch_queue_t dqueue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      dqueue = dispatch_queue_create("pcm", NULL);
      // TOM: 2018-07-10 - always dispatch to high-priority queue
      dispatch_set_target_queue(dqueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    });
  return dqueue;
}


/*
 * The AudioTimer has a special roll translating from the audio thread
 * to dispatch queues.
 *
 * It READS from the OUTFIFO being written by the audio thread.  It's
 * job will be to handle messages from the audio thread and turn them
 * into dispatch queue messages.
 */

- (void) launchTimer {
  double period = (_persize * 1.0) / (_rate * 1.0);
  double leeway = period / 100.0;

  if (CTXDEBUG)
    NSLog(@"MSKContext launchTimer %g/%g\n", period, leeway);

  // launch a timer
  _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                  0, 0, _aqueue);

  if (_timer) {
    dispatch_source_set_timer(_timer,
                              dispatch_walltime(NULL, 0),
                              period*NSEC_PER_SEC,
                              leeway*NSEC_PER_SEC);

    // for moving average
    double alpha = pow(0.9, (double)_persize / (double)_bufsize);
    __block double avgRmsL = 0.0;
    __block double avgRmsR = 0.0;

    dispatch_source_set_event_handler(_timer, ^{
        msk_ofifo_message_t msg;
        void *varbytes;
        if (_pbuf != nil) {
          varbytes = alloca(_pbuf->_length);
        }
        else {
          varbytes = alloca(_rbuf->_length);
        }

        while (CFMSKOFifo_read_message(_ofifo, &msg, varbytes) != NO) {
          if (msg.tag == MSK_OFIFO_TAG_AUDIOLEVELS) {
            double dbRmsL = 20.0f * log10f(msg.data.audiolevel.rmsL);
            if (isnan(dbRmsL)) {
              dbRmsL = 0.0;
            }

            double dbRmsR = 20.0f * log10(msg.data.audiolevel.rmsR);
            if (isnan(dbRmsR)) {
              dbRmsR = 0.0;
            }

            // compute moving average
            avgRmsL = (alpha * avgRmsL) + ((1.0 - alpha) * dbRmsL);
            avgRmsR = (alpha * avgRmsR) + ((1.0 - alpha) * dbRmsR);

            double dbAbsPeakL = 20.0f * log10f(msg.data.audiolevel.absPeakL);
            double dbAbsPeakR = 20.0f * log10f(msg.data.audiolevel.absPeakR);

            // fprintf(stdout, "RMS %5.3f/%5.3f  %5.3f/%5.3f\n", dbRmsL, dbRmsR, dbAbsPeakL, dbAbsPeakR); fflush(stdout);

            if (_rmsblock) {
              _rmsblock(MSK_OFIFO_SOURCE_IDX_MAIN, dbRmsL, dbRmsR, dbAbsPeakL, dbAbsPeakR);
            }
          }
          else if (msg.tag == MSK_OFIFO_TAG_ENVELOPE) {
            if (_envelopeblock) {
              _envelopeblock(msg.idx, msg.data.envelope.gate, msg.data.envelope.t, msg.data.envelope.val);
            }

          }
          else if (msg.tag == MSK_OFIFO_TAG_THREADERROR) {
            int alsaerr = msg.data.threaderror.alsaerr;
            NSError *nserr = [NSError errorWithMSKContextError:kMSKContextErrorThreadStoppedUnexpectedly
                                                         str:@"Thread Stopped Unexpectedly"
                                                       under:[NSError errorWithASKAlsaError:alsaerr]];
            if (_errorblock) {
              _errorblock(nserr);
            }
          }
          else if (msg.tag == MSK_OFIFO_TAG_VAR) {
            if (_waveblock) {
              MSKContextBuffer *buf = [[MSKContextBuffer alloc] initWithCtx:self];
              memcpy(buf->_frames, varbytes, buf->_length);
              _waveblock(msg.idx, buf);
            }
          }

        }
      });
          
    dispatch_source_set_cancel_handler(_timer, ^{
        if (CTXDEBUG)
          NSLog(@"MSKContext timer was cancelled");
        dispatch_source_set_event_handler(_timer, nil);
      });

    dispatch_resume(_timer);
  }
}

- (BOOL) close {

  dispatch_async(_aqueue, ^{

      // unregister callback and close
      [_pcm stopAndClose];
      [_pcm onPlayback:nil];
      // 2022-09-13
      [_pcm onPlaybackCleanup:nil];
      [_pcm onPlaybackThreadError:nil];
      _pcm = nil;

      // release the internal buffers
      _pbuf = nil;
      _rbuf = nil;
      _vretainer = nil;
      _oldfx = nil;
      _xretainer = nil;

      // release the blocks
      _rmsblock = nil;
      _envelopeblock = nil;
      _waveblock = nil;
      _captureblock = nil;
      _errorblock = nil;
      
    });

  if (_timer) {
    dispatch_source_cancel(_timer);
  }
  
  return YES;
}

- (void) dealloc {
#if LOGDEALLOC
  NSLog(@"MSKContext dealloc: %@", _name);
#endif
}


@end
