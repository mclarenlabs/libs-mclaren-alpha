/**
 * Generate Tones on a PCM device
 *
 * McLaren Labs 2023
 */

#include <math.h>

#import <Foundation/Foundation.h>
#import "ToneGenerator.h"

/*
 * A Note manages the state of an envelope and the generation of an oscillator
 * sound corresponding to a midiNote.
 *
 * The Note renders its waveform into a buffer with the render: method.  It adds
 * the sample values into the buffer so that multiple Notes could be supported.
 */

@implementation Note {
  double freq;
  double nrg; // how much energy in the envelope system
  double env; // the current envelope value
  double target; // how much above 1.0 to start
  double factor; // rate of envelope
  double phi;
  double dphi;
}

- (id) init {
  if (self = [super init]) {
    freq = 440.0;
    nrg = 0;
    env = 0;
    phi = 0;
    _state = NOTE_OFF;
    target = 0.1; // rate control
  }
  return self;
}

- (void) freqForMidiNote:(int)midiNote
{
  // a formula for mapping midiNotes to frequency
  freq = 440.0 * exp2((midiNote - 69) / 12.0);
}

- (void) calcDphi {
  // set the frequency from midiNote and compute phi increment
  [self freqForMidiNote:_midiNote];
  dphi = (2 * M_PI) * (freq / _sampleRate);
}



- (void) attack {

  [self calcDphi];

  _state = NOTE_ATTACK;
  nrg = 1 + target - env; // continue upward from current env
  if (_attackSamples == 0)
    _attackSamples = 1.0;
  factor = exp(log(target / 1.0 + target) / _attackSamples);
}

- (void) decay {
  _state = NOTE_DECAY;
  nrg = env; // continue downward from current env
  if (_attackSamples == 0)
    _attackSamples = 1.0;
  factor = exp(log(target / 1.0 + target) / _attackSamples);
}

- (void) sustain {
  _state = NOTE_SUSTAIN;
}

- (void) releaseIt {
  _state = NOTE_RELEASE;
  nrg = env; // continue downward from current env
  if (_releaseSamples == 0)
    _releaseSamples = 1.0;
  factor = exp(log(target / 1.0 + target) / _releaseSamples);
}

- (void) off {
  _state = NOTE_OFF;
}

#define INCR_PHI \
  do {		 \
  phi += dphi;	    \
  if (phi > 2*M_PI)  \
    phi -= 2 * M_PI; \
  } while (0)


static inline double sound(double phi)
{
  // return sin(phi);
  return sin(phi) * sin(2*phi);
}

#if TONEGEN_USE_FLOAT_LE
- (void) render:(float*)wav n:(int)n
#else
- (void) render:(int32_t*)wav n:(int)n
#endif
{
  double val;

  for (int i = 0; i < n; i++) {
    switch (_state) {
    case NOTE_ATTACK:
      env = (1.0 + target) - nrg;
      nrg *= factor;
      val = env * sound(phi);
      INCR_PHI;
      if (env >= 1.0) {
	[self decay];
      }
      break;

    case NOTE_DECAY:
      env = nrg;
      nrg *= factor;
      val = env * sound(phi);
      INCR_PHI;
      if (env <= _sustainLevel)
	[self sustain];
      break;

    case NOTE_SUSTAIN:
      env = nrg;
      val = env * sound(phi);
      INCR_PHI;
      break;

    case NOTE_RELEASE:
      env = nrg;
      nrg *= factor;
      val = env * sound(phi);
      INCR_PHI;
      if (env <= 0.000001)
	[self off];
      break;

    case NOTE_OFF:
      val = 0.0;
      break;
    }

    // generate stereo output sized for FORMAT_S32_LE
#if TONEGEN_USE_FLOAT_LE
    wav[2*i] += 0.25 * val;
    wav[2*i+1] += 0.25 * val;
#else
    wav[2*i] += (1<<26) * val;
    wav[2*i+1] += (1<<26) * val;
#endif
  }

}

- (BOOL) noteIsOff
{
  return _state == NOTE_OFF;
}

@end

@implementation ToneGenerator {
  ASKPcm *pcm;
  unsigned int rate;
  NSData *data;
  Note *note;
}

- (void) openPcm:(NSString*)pcmname {

  ASKError_linker_function(); // cause NSError category to be linked

  rate = 44100; // 22050, 44100, 48000
  unsigned int channels = 2;
  snd_pcm_stream_t stream = SND_PCM_STREAM_PLAYBACK;
#if TONEGEN_USE_FLOAT_LE
  snd_pcm_format_t format = SND_PCM_FORMAT_FLOAT_LE;
#else
   snd_pcm_format_t format = SND_PCM_FORMAT_S32_LE; // SND_PCM_FORMAT_S16_LE
#endif
  snd_pcm_access_t access = SND_PCM_ACCESS_RW_INTERLEAVED;
  unsigned int periods = 2;
  snd_pcm_uframes_t persize = 1024;
  

  BOOL ok;
  NSError *error = nil;         // to hold an error

  // Open the sound device for playback
  pcm = [[ASKPcm alloc] initWithName:pcmname
			      stream:stream
			       error:&error];

  if (error != nil) {
    NSLog(@"Error Opening PCM:%@", error);
    exit(1);
  }

  // Configure the hardware parameters
  ASKPcmHwParams *hwparams = [pcm getHwParams:&error];
  if (error != nil) {
    NSLog(@"Could not get HW Params:%@", error);
    exit(1);
  }

  ok = [pcm setRate:hwparams val:rate error:&error];
  if (ok == NO) {
    NSLog(@"Error setting rate:%@", error);
    exit(1);
  }

  ok = [pcm setChannels:hwparams val:channels error:&error];
  if (ok == NO) {
    NSLog(@"Error setting channels:%@", error);
    exit(1);
  }

  ok = [pcm setAccess:hwparams val:access error:&error];
  if (ok == NO) {
    NSLog(@"Error setting access to interleaved:%@", error);
    exit(1);
  }
  
  ok = [pcm setFormat:hwparams val:format error:&error];
  if (ok == NO) {
    NSLog(@"Error setting format:%@", error);
    exit(1);
  }

  ok = [pcm setPeriodsNear:hwparams val:&periods error:&error];
  if (ok == NO) {
    NSLog(@"Error setting periods:%@", error);
    exit(1);
  }

  NSLog(@"Got periods:%u", periods);

  ok = [pcm setPeriodSizeNear:hwparams val:&persize error:&error];
  if (ok == NO) {
    NSLog(@"Error setting period size:%@", error);
    exit(1);
  }

  NSLog(@"Got period size:%lu", persize);

  // Now set the HW params
  ok = [pcm setHwParams:hwparams error:&error];
  if (ok == NO) {
    NSLog(@"Could not set hw params:%@", error);
    exit(1);
  }

  // Set Software Parameters
  ASKPcmSwParams *swparams = [pcm getSwParams];

  ok = [pcm setAvailMin:swparams val:persize error:&error];
  if (ok == NO) {
    NSLog(@"Error setting avail min:%@", error);
    exit(1);
  }
  
  ok = [pcm setStartThreshold:swparams val:0 error:&error];
  if (ok == NO) {
    NSLog(@"Error getting sw params:%@", error);
    exit(1);
  }

  ok = [pcm setSwParams:swparams error:&error];
  if (ok == NO) {
    NSLog(@"Could not set sw params:%@", error);
    exit(1);
  }

  // Allocate a buffer for the waveform data
#if TONEGEN_USE_FLOAT_LE
  data = [NSMutableData dataWithLength:(2 * persize * sizeof(float))];
  float *wav = (float*) [data bytes];
#else
  data = [NSMutableData dataWithLength:(2 * persize * sizeof(int32_t))];
  int32_t *wav = (int32_t*) [data bytes];
#endif

  // Create the Note
  note = [[Note alloc] init];
  note.sampleRate = rate;
  note.attackSamples = 1000;
  note.sustainLevel = 0.9;
  note.releaseSamples = 10000;

  // Install callbacks
  [pcm onPlayback:^(snd_pcm_sframes_t nframes) {
#if TONEGEN_USE_FLOAT_LE
      bzero(wav, 2 * persize * sizeof(float));
#else
      bzero(wav, 2 * persize * sizeof(int32_t));
#endif
      [note render:wav n:nframes];
      return (void*) wav;
    }];

  [pcm onPlaybackThreadError:^(int err) {
      NSLog(@"Got Thread Error:%d", err);
      exit(1);
    }];

}

- (void) start {
  // Launch the PCM Thread
  NSError *error = nil;
  BOOL ok = [pcm startThreadWithError:&error];
  if (ok == NO) {
    NSLog(@"Could not start PCM thread:%@", error);
    exit(1);
  }
}

- (void) stop {
  [pcm stopAndClose];
}

- (void) noteOn:(unsigned)midiNote vel:(unsigned)vel {
  (void) vel; // unsigned for now

  note.midiNote = midiNote;
  [note attack];
}

- (void) noteOff:(unsigned)midiNote vel:(unsigned)vel {
  (void) vel; // unsigned for now

  [note releaseIt];
}

- (double) attackTime {
  return note.attackSamples / rate;
}

- (void) setAttackTime:(double)val {
  if (val == 0)
    note.attackSamples = 1.0;
  else
    note.attackSamples = val * rate;
}

- (double) sustainLevel {
  return note.sustainLevel;
}

- (void) setSustainLevel:(double)val {
  note.sustainLevel = val;
}

- (double) releaseTime {
  return note.releaseSamples / rate;
}

- (void) setReleaseTime:(double)val {
  if (val == 0)
    note.releaseSamples = 1.0;
  else
    note.releaseSamples = val * rate;
}

@end
