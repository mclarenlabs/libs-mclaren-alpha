/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * An audio context keeps the total sample count, current time, and
 * parameters related to the sample size.
 *
 * Copyright (c) McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/ASKPcm.h"

// @class FVRevmodel;

/*
 * These flags affect computation and performance of the library.
 * They cannot be modified.
 */

#define MSKSAMPTYPE float // either set to 'float' or 'double'
#define COSFN(x) cosf(x) // cos(double), cosf(float)
#define SINFN(x) sinf(x) // sin(double), sinf(float)
#define LOGDEALLOC 0    // turn on/off dealloc-related messages

/*
 * A Context Buffer can be allocated after a Context is configured.
 * It is sized to the period size of the Context in samples.
 */

@class MSKContext;                // forward ref

@interface MSKContextBuffer : NSObject {

  /*
   * These ivars of a MSKContextBuffer are marked public but are
   * intended to be read from SING function and the MSKContext rendering
   * callback.
   */

  @public
  MSKContext *_ctx;

  // params describing the buffer and its memory allocation
  unsigned _persize;
  unsigned _length;
  MSKSAMPTYPE *_frames;

}

@property (readonly) NSData *data;
@property (readonly) unsigned persize; // from ctx
@property (readonly) unsigned length;  // number bytes

- (id) init __attribute__((unavailable("This method is not available.  Please use initWithCtx:")));
- (id) initWithCtx:(MSKContext*)ctx;

void CFMSKContextBufferClear(__unsafe_unretained MSKContextBuffer *v);

@end

/*
 * The base type of something that renders a Voice in a Context.  It
 * knows how to allocate a buffer sized for the period size of its
 * context, and it has a SING handler function.  The SING function is
 * called by the audio thread each period.
 *
 * Its implementation is @public so that its implementation can
 * be read from the Audio Thread.
 */

@class MSKContextVoice;
@class MSKOFifo;

@interface MSKContextVoice : MSKContextBuffer {

  BOOL _isCompiled;

  @public

  // the rendering callback handler
  BOOL _isInitialized;
  uint64_t _when;

  // params for tracking when a voice is done
  BOOL _active;
  BOOL _reclaim; // used in FX path

  // backing store for property
  unsigned int _audioIdx;
}
@property (readwrite) unsigned int audioIdx; // for reporting back levels

- (id) initWithCtx:(MSKContext*)ctx;

// called after connections are attached
- (BOOL) compile;

// called on the audio thread
- (BOOL) auEval:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes;
- (BOOL) auInit:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes;
- (BOOL) auRender:(uint64_t)now nframes:(snd_pcm_sframes_t)nframes;

@end

/*
 * A Voice starts singing when it is allocated, and it sings forever,
 * or until it is no longer active.
 *
 * An Envelope is a protocol extension to a Voice which can be sent
 * the noteOff, noteAbort and noteReset methods.
 */

@interface MSKContextEnvelope : MSKContextVoice {

  // PRIVATE: params describing key sounding and control
  BOOL _gate;
  BOOL _abort;
  BOOL _reset;
}

// PUBLIC
- (BOOL) noteOff;
- (BOOL) noteAbort;
- (BOOL) noteReset:(int)idx;

// PRIVATE: for envelope to send its state
BOOL CFMSKContextEnvelopeExport(__unsafe_unretained MSKContextEnvelope *v, double t, double maxval);


@end

/*
 * A Voice Retainer manages reference transfers from dispatch-land to audiothread-land.
 */

@interface MSKContextVoiceRetainer : NSObject

// methods to be called in the dispatch Context
- (BOOL) onContextRetainVoice:(MSKContextVoice*)v;
- (void) onContextReleaseDeadVoices;

@end

/*
 * An Audio Context reports ongoing information with block callbacks.
 * Their types are defined here.
 */

typedef void (^MSKContextRMSBlock)(unsigned idx, double rmsleft, double rmsright, double absleft, double absright);
typedef void (^MSKContextEnvelopeBlock)(unsigned idx, BOOL gate, double t, double val);
typedef void (^MSKContextWaveBlock)(unsigned idx, MSKContextBuffer *buf);
typedef void (^MSKContextCaptureBlock)(MSKContextVoice *rbuf);
typedef void (^MSKContextErrorBlock)(NSError *error);

/*
 * A Context Request represents the parameters requested of the audio
 * device.  The Audio Context does its best to satisfy the request.
 */

@interface MSKContextRequest : NSObject
@property (readwrite) BOOL isExact;  // exact params required
@property (readwrite) unsigned rate; // requested sample rate
@property (readwrite) snd_pcm_uframes_t persize; // requested period size
@property (readwrite) unsigned periods; // requested number of periods
@end


/*
 * The Audio Context manages an audio device.
 * It renders voices and reports status.
 */

@interface MSKContext : NSObject

@property (readonly) NSString *name;
@property (readonly) snd_pcm_stream_t stream;
@property (readonly) ASKPcm *pcm;
@property (readonly) ASKPcmHwParams *hwparams;
@property (readonly) ASKPcmSwParams *swparams;

@property (readonly)  snd_pcm_uframes_t bufsize; // e.g. 4096
@property (readonly)  snd_pcm_uframes_t persize; // e.g. 1024
@property (readonly)  unsigned int periods; // 2,3,4 usually
@property (readonly)  snd_pcm_access_t access; // e.g. SND_PCM_ACCESS_RW_INTERLEAVED
@property (readonly)  snd_pcm_format_t format; // e.g. SND_PCM_FORMAT_S16_LE
@property (readonly)  size_t formatsize; // e.g. sizeof(int16_t) or sizeof(int32_t)
@property (readonly)  double formatgain;
@property (readonly)  double gain;
@property (readonly)  unsigned rate; // 44100, 48000
@property (readonly)  unsigned channels; // 2

@property (readonly) MSKContextVoice *pbuf; // accumulator for voices playback
@property (readonly) MSKContextVoice *rbuf; // recording buffer for capture

@property (readonly)  MSKOFifo *ofifo; // message channel out of audio thread - for VOICE FRIENDS

@property (readonly, copy) MSKContextRMSBlock rmsblock;
@property (readonly, copy) MSKContextEnvelopeBlock envelopeblock;
@property (readonly, copy) MSKContextWaveBlock waveblock;
@property (readonly, copy) MSKContextCaptureBlock captureblock;
@property (readonly, copy) MSKContextErrorBlock errorblock;

@property (readonly) uint64_t f; // count of frames since time0
@property (readonly) double t; // (frames / rate)
@property (readonly) double deltat; // (1.0 / rate)

@property (readwrite) int polyphony;
// 2020-06-17 @property (readwrite) NSMutableArray* voices;

+ (void) setPlaysChime:(BOOL)doesPlayChime;

// To be deprecated
- (id) initWithName:(NSString*)pcmname andStream:(snd_pcm_stream_t)stream andRequest:(MSKContextRequest*)request error:(NSError**)error;

- (id) initWithName:(NSString*)pcmname andStream:(snd_pcm_stream_t)stream error:(NSError**)error;
- (BOOL) configureForRequest:(MSKContextRequest*)request error:(NSError**)error;
- (BOOL) configureLikeContext:(MSKContext*)other error:(NSError**)error;
- (BOOL) startWithError:(NSError**)error;

+ (dispatch_queue_t) sharedQueue;

+ (double) vol2gain:(double)gain;
+ (double) gain2vol:(double)vol;

- (BOOL) addVoice:(MSKContextVoice*)voice;
- (BOOL) addFx:(MSKContextVoice*)fx;
- (BOOL) allVoicesOff;
- (void) onRms:(MSKContextRMSBlock)block;
- (void) onEnvelope:(MSKContextEnvelopeBlock)block;
- (void) onWave:(MSKContextWaveBlock)block;
- (void) onError:(MSKContextErrorBlock)block;
- (void) setGain:(double)gain;
- (double) getGain;
- (void) setVolume:(double)vol;
- (double) getVolume;
- (BOOL) close;

@end
