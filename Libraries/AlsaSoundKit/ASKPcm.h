/* -*- mode:objc -*-
 *
 * Manage an Alsa PCM device.
 *
 * (c) McLaren Labs 2022
 */

#include <alsa/asoundlib.h>

#import <Foundation/Foundation.h>
#import "ASKPcmSystem.h"

/*
 * Error Handling
 */

extern char *ASKPcmPthreadErrorExit;

/*
 * Wrap a SND PCM STATUS value
 */

@interface ASKPcmStatus : NSObject

@property (readwrite) snd_pcm_status_t *pcm_status;

- (snd_pcm_state_t) getState;
- (NSString*) getStateName;
- (snd_pcm_sframes_t) getDelay;
- (snd_pcm_uframes_t) getAvail;
- (snd_pcm_uframes_t) getAvailMax;
- (snd_pcm_uframes_t) getOverrange;

@end

/*
 * Wrap a SND PCM Hw PARAMS value
 */

@interface ASKPcmHwParams : NSObject

@property (readwrite) snd_pcm_hw_params_t *hw_params;

- (BOOL) getAccess:(snd_pcm_access_t*)access error:(NSError**)error;
- (NSString*) getAccessDescription;
- (BOOL) getFormat:(snd_pcm_format_t*)format error:(NSError**)error;
- (NSString*) getFormatDescription;

- (BOOL) getChannels:(unsigned int*)channels error:(NSError**)error;
- (BOOL) getChannelsMin:(unsigned int*)channels error:(NSError**)error;
- (BOOL) getChannelsMax:(unsigned int*)channels error:(NSError**)error;

- (BOOL) getRate:(unsigned int*)rate error:(NSError**)error;
- (BOOL) getRateMin:(unsigned int*)rate error:(NSError**)error; 
- (BOOL) getRateMax:(unsigned int*)rate error:(NSError**)error;

- (BOOL) getPeriodTime:(unsigned int*)period error:(NSError**)error;
- (BOOL) getPeriodTimeMin:(unsigned int*)period error:(NSError**)error;
- (BOOL) getPeriodTimeMax:(unsigned int*)period error:(NSError**)error;

- (BOOL) getPeriodSize:(snd_pcm_uframes_t*) period error:(NSError**)error;
- (BOOL) getPeriodSizeMin:(snd_pcm_uframes_t*) period error:(NSError**)error;
- (BOOL) getPeriodSizeMax:(snd_pcm_uframes_t*) period error:(NSError**)error;

- (BOOL) getPeriods:(unsigned int*)periods error:(NSError**)error;
- (BOOL) getPeriodsMin:(unsigned int*)periods error:(NSError**)error;
- (BOOL) getPeriodsMax:(unsigned int*)periods error:(NSError**)error;

- (BOOL) getBufferTime:(unsigned int*)buffertime error:(NSError**)error;
- (BOOL) getBufferTimeMin:(unsigned int*)buffertime error:(NSError**)error;
- (BOOL) getBufferTimeMax:(unsigned int*)buffertime error:(NSError**)error;

- (BOOL) getBufferSize:(snd_pcm_uframes_t*)size error:(NSError**)error;
- (BOOL) getBufferSizeMin:(snd_pcm_uframes_t*)size error:(NSError**)error;
- (BOOL) getBufferSizeMax:(snd_pcm_uframes_t*)size error:(NSError**)error;

@end

/*
 * Wrap a SND PCM SW PARAMS value
 */

@interface ASKPcmSwParams : NSObject

@property (readwrite) snd_pcm_sw_params_t *sw_params;

- (BOOL) getTstampMode:(snd_pcm_tstamp_t*)mode error:(NSError**)error;
- (NSString*) getTstampModeDescription;
- (BOOL) getAvailMin:(snd_pcm_uframes_t*)avail error:(NSError**)error;
- (BOOL) getPeriodEvent:(int*)val error:(NSError**)error;
- (BOOL) getStartThreshold:(snd_pcm_uframes_t*)threshold error:(NSError**)error; 
- (BOOL) getStopThreshold:(snd_pcm_uframes_t*)threshold error:(NSError**)error; 
- (BOOL) getSilenceThreshold:(snd_pcm_uframes_t*)threshold error:(NSError**)error;
- (BOOL) getSilenceSize:(snd_pcm_uframes_t*)size error:(NSError**)error;

@end

/*
 * Manage a SND PCM object
 *  - open a pcm
 *  - query capabilities, set parameters
 *  - register callbacks
 *  - startThread, stopAndClose
 *
 */

@interface ASKPcm : NSObject

// this is the signature of callback for playing sounds
typedef void* (^ASKPcmPlaybackBlock)(snd_pcm_sframes_t nframes);
typedef void (^ASKPcmPlaybackCleanupBlock)();
typedef void (^ASKPcmPlaybackThreadErrorBlock)(int err); // ALSA err

// this is the signature of callback for capturing sounds
typedef void* (^ASKPcmCaptureBufferBlock)(); // return a buffer for capture
typedef void (^ASKPcmCaptureBlock)(snd_pcm_sframes_t nframes);
typedef void (^ASKPcmCaptureThreadErrorBlock)(int err); // ALSA err

// PThread properties used internally
@property (readonly) pthread_t pth;
@property (readonly) int running;
@property (readonly) int alive;
@property (readonly) int waiterror;
@property (readonly) int xruncnt;

// properties used internally
@property (readonly) NSString *name;
@property (readonly) NSString *threadname;
@property (readonly) snd_pcm_stream_t stream;
@property (readonly) snd_pcm_t *pcm_handle;

// these are set for fast access by pcm thread
@property (readonly) snd_pcm_access_t access;
@property (readonly) snd_pcm_format_t format;
@property (readonly) snd_pcm_uframes_t persize;
@property (readonly) int formatsize;

// private for holding the blocks: use the onFoo: methods
@property (readonly, copy) ASKPcmPlaybackBlock playblock;
@property (readonly, copy) ASKPcmPlaybackCleanupBlock playcleanupblock;
@property (readonly, copy) ASKPcmPlaybackThreadErrorBlock playthreaderrorblock;
@property (readonly, copy) ASKPcmCaptureBufferBlock capturebufferblock;
@property (readonly, copy) ASKPcmCaptureBlock captureblock;
@property (readonly, copy) ASKPcmCaptureThreadErrorBlock capturethreaderrorblock;

- (id) initWithName:(NSString*)name stream:(snd_pcm_stream_t)stream error:(NSError**)error;

- (ASKPcmInfo*) getInfo:(NSError**)error;
- (ASKPcmStatus*) getStatus:(NSError**)error;

- (ASKPcmHwParams*) getHwParams:(NSError**)error;
- (BOOL) setHwParams:(ASKPcmHwParams*)hwparams error:(NSError**)error;

- (ASKPcmSwParams*) getSwParams;
- (BOOL) setSwParams:(ASKPcmSwParams*)swparams error:(NSError**)error;


// Set HW Params, return BOOL
- (BOOL) setAccess:(ASKPcmHwParams*)params val:(snd_pcm_access_t)val error:(NSError**)error;
- (BOOL) setFormat:(ASKPcmHwParams*)params val:(snd_pcm_format_t)val error:(NSError**)error;
- (BOOL) setSubFormat:(ASKPcmHwParams*)params val:(snd_pcm_subformat_t)val error:(NSError**)error;
- (BOOL) setChannels:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error;
- (BOOL) setChannelsNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error;
- (BOOL) setRate:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error;
- (BOOL) setRateNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error;
- (BOOL) setPeriodTime:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error;
- (BOOL) setPeriodTimeNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error;
- (BOOL) setPeriodSize:(ASKPcmHwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error;
- (BOOL) setPeriodSizeNear:(ASKPcmHwParams*)params val:(snd_pcm_uframes_t*)val error:(NSError**)error;
- (BOOL) setPeriods:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error;
- (BOOL) setPeriodsNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error;
- (BOOL) setBufferTime:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error;
- (BOOL) setBufferTimeNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error;
- (BOOL) setBufferSize:(ASKPcmHwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error;
- (BOOL) setBufferSizeNear:(ASKPcmHwParams*)params val:(snd_pcm_uframes_t*)val error:(NSError**)error;


// Set SW Params, return BOOL
- (BOOL) setTstampMode:(ASKPcmSwParams*)params val:(snd_pcm_tstamp_t)val error:(NSError**)error;
- (BOOL) setAvailMin:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error;
- (BOOL) setPeriodEvent:(ASKPcmSwParams*)params val:(int)val error:(NSError**)error;
- (BOOL) setStartThreshold:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error;
- (BOOL) setStopThreshold:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error;
- (BOOL) setSilenceThreshold:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error;
- (BOOL) setSilenceSize:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error;

// Register Playback
- (void) onPlayback:(ASKPcmPlaybackBlock)block;
- (void) onPlaybackCleanup:(ASKPcmPlaybackCleanupBlock)block;
- (void) onPlaybackThreadError:(ASKPcmPlaybackThreadErrorBlock)block;

// Register Capture
- (void) onCaptureBuffer:(ASKPcmCaptureBufferBlock)block;
- (void) onCapture:(ASKPcmCaptureBlock)block;
- (void) onCaptureThreadError:(ASKPcmCaptureThreadErrorBlock)block;

// Start Running and Shut Down
- (BOOL) startThreadWithError:(NSError**)error;
- (BOOL) stopAndClose;

@end
