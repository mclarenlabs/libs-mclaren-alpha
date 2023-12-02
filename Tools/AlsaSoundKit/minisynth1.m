/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A very tiny example of using the lower-level ASK PCM interface to open
 * the "default" Alsa Sound Dev and play a tone.
 *
 */

#include <math.h>

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"

int main(int argc, char *argv[])
{
  ASKError_linker_function(); // cause NSError category to be linked

  // NSString *pcmname = @"default"; // which sound device to open
  NSString *pcmname = [NSString stringWithFormat:@"%s", argv[1]];
  NSString *kbdname = [NSString stringWithFormat:@"%s", argv[2]];

  unsigned int rate = 44100; // 22050, 44100, 48000
  unsigned int channels = 2;
  snd_pcm_stream_t stream = SND_PCM_STREAM_PLAYBACK;
  snd_pcm_format_t format = SND_PCM_FORMAT_S32_LE; // SND_PCM_FORMAT_S16_LE
  snd_pcm_access_t access = SND_PCM_ACCESS_RW_INTERLEAVED;
  unsigned int periods = 2;
  snd_pcm_uframes_t persize = 1024;
  

  BOOL ok;
  NSError *error = nil;         // to hold an error

  // Open the sound device for playback
  ASKPcm *pcm = [[ASKPcm alloc] initWithName:pcmname
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

  // Create a sequencer
  error = nil;
  ASKSeq *seq = [[ASKSeq alloc] initWithError:&error];
  if (error != nil) {
    NSLog(@"Error creating sequencer:%@", error);
    exit(1);
  }

  // Create a waveform: A440
  static double phi = 0;
  static double dphi = 0;
  static int keycnt = 0;

  dphi = (2 * M_PI) * 440.0 / rate;

  // Get events from the keyboard
  ASKSeqAddr *kbdaddr = [seq parseAddress:kbdname error:&error];
  if (kbdaddr == nil) {
    NSLog(@"could not parse address '%@' error:%@", kbdname, error);
    exit(1);
  }
  
  ok = [seq connectFrom:kbdaddr.client port:kbdaddr.port error:&error];
  if (ok == NO) {
    NSLog(@"could not connect from keyboard client=%d:%@", kbdaddr.client, error);
    exit(1);
  }

  [seq addListener:^(NSArray *events) {
      for (ASKSeqEvent *e in events) {
        NSLog(@"%@", e);

        if (e->_ev.type == SND_SEQ_EVENT_NOTEON) {
          // uint8_t chan = e->_ev.data.note.channel;
          uint8_t note = e->_ev.data.note.note;
          // uint8_t vel = e->_ev.data.note.velocity;

          double freq = 8.176 * exp((double)(note)*log(2.0)/12.0);
          dphi = (2 * M_PI) * freq / rate;

          keycnt += 1;
          NSLog(@"freq:%g", freq);
        }

        if (e->_ev.type == SND_SEQ_EVENT_NOTEOFF) {
          // uint8_t chan = e->_ev.data.note.channel;
          // uint8_t note = e->_ev.data.note.note;
          // uint8_t vel = e->_ev.data.note.velocity;

          keycnt -= 1;
        }

        
      }
    }];

  NSData *data = [NSMutableData dataWithLength:(2 * persize * sizeof(int32_t))];
  int32_t *wav = (int32_t*) [data bytes];

  // Install callbacks
  [pcm onPlayback:^(snd_pcm_sframes_t nframes) {
      for (int i = 0; i < 1024; i++) {
        double sound = sin(phi) * (keycnt > 0 ? 1 : 0) * (1 << 26);
        wav[i*2] = sound;
        wav[i*2 + 1] = sound;
        phi += dphi;
        if (phi >= 2*M_PI) {
          phi -= 2*M_PI;
        }
      }
      return (void*) wav;
    }];

  [pcm onPlaybackThreadError:^(int err) {
      NSLog(@"Got Thread Error:%d", err);
      exit(1);
    }];

  
  // Launch the PCM Thread
  ok = [pcm startThreadWithError:&error];
  if (ok == NO) {
    NSLog(@"Could not start PCM thread:%@", error);
    exit(1);
  }

  // Stop it after 10 seconds
  dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 10.0*NSEC_PER_SEC);
  dispatch_after(after, dispatch_get_main_queue(), ^{
      [pcm stopAndClose];
      exit(0);
    });

  // Run forever
  [[NSRunLoop mainRunLoop] run];
  
}



