/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A small metronome example.
 *
 */

#import "AlsaSoundKit/AlsaSoundKit.h"
#import "McLarenSynthKit/McLarenSynthKit.h"
#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {

  MSKError_linker_function(); // cause NSError category to be linked
  ASKError_linker_function(); // cause NSError category to be linked

  // Desired audio context parameters
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;
  request.persize = 1024;
  request.periods = 2;

  NSString *devName = @"default";

  NSError *error;
  BOOL ok;

  // Create an audio context on the 'default' device for playback
  MSKContext *ctx = [[MSKContext alloc] initWithName:devName
                                           andStream:SND_PCM_STREAM_PLAYBACK
                                               error:&error];

  if (error != nil) {
    NSLog(@"MSKContext init error:%@", error);
    exit(1);
  }

  // Configure the context with the request
  ok = [ctx configureForRequest:request error:&error];
  if (ok == NO) {
    NSLog(@"MSKContext configure error:%@", error);
    exit(1);
  }

  // Start the context
  ok = [ctx startWithError:&error];
  if (ok == NO) {
    NSLog(@"MSKContext starting error:%@", error);
    exit(1);
  }

  MSKMetronomeModel *modmetro =
      [[MSKMetronomeModel alloc] initWithName:@"metro1"];
  modmetro.bpm = @(120);
  modmetro.timesig = [MSKMetronomeModelTimesig timesigWithNum:4 den:4];

  MSKOscillatorModel *oscmodel1 =
      [[MSKOscillatorModel alloc] initWithName:@"osc1"];
  oscmodel1.osctype = @(MSK_OSCILLATOR_TYPE_TRIANGLE);
  oscmodel1.modulation = @(3.0);
  oscmodel1.octave = @(0.0);

  MSKEnvelopeModel *envmodel1 = [[MSKEnvelopeModel alloc] initWithName:@"env1"];
  envmodel1.attack = @(0.02);
  envmodel1.decay = @(0.05);
  envmodel1.sustain = @(0.5);
  envmodel1.rel = @(0.1);

  MSKEnvelopeModel *phsenvmodel =
      [[MSKEnvelopeModel alloc] initWithName:@"phsenv"];
  phsenvmodel.attack = @(0.02);
  phsenvmodel.decay = @(0.05);
  phsenvmodel.sustain = @(0.9);
  phsenvmodel.rel = @(0.1);

  MSKReverbModel *modreverb = [[MSKReverbModel alloc] initWithName:@"reverb1"];
  modreverb.dry = @(1.0);
  modreverb.wet = @(0.5);
  modreverb.on = @(NO);

  MSKFreeverbReverb *rb = [[MSKFreeverbReverb alloc] initWithCtx:ctx];
  rb.model = modreverb;
  rb.sInput = ctx.cbuf;

  [ctx addFx:rb];

  MSKMetronome *metro = [[MSKMetronome alloc] initWithModel:modmetro
                                                      error:&error];
  if (error != nil) {
    NSLog(@"@MSKMetronome init error:%@", error);
    exit(1);
  }

  [metro onBeat:^(int beat, int measure) {
    double dgain = 0.0;
    int note = 60;

    if (beat == 0) { // downbeat
      dgain = 1.0;
      note = 60;
    } else {
      dgain = 0.25;
      note = 55;
    }

    MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:ctx];
    env.iGain = dgain;
    env.oneshot = YES;
    env.shottime = 0.1;
    env.model = envmodel1;
    [env compile];

    MSKExpEnvelope *phsdist = [[MSKExpEnvelope alloc] initWithCtx:ctx];
    env.iGain = 1.0;
    env.oneshot = YES;
    env.shottime = 0.1;
    env.model = phsenvmodel;
    [env compile];

    MSKPhaseDistortionOscillator *phs =
        [[MSKPhaseDistortionOscillator alloc] initWithCtx:ctx];
    phs.iNote = @(note);
    phs.sPhasedistortion = phsdist;
    phs.sEnvelope = env;
    phs.model = oscmodel1;
    [phs compile];

    // Hand the oscillator over to the context for rendering
    [ctx addVoice:phs];
  }];

  // start the metronome
  [metro start];

  // Stop the metronome after 10 seconds
  dispatch_time_t stopt = dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC);
  dispatch_after(stopt, dispatch_get_main_queue(), ^{
    [metro stop];
  });

  // Close the context after two seconds
  dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 12.0 * NSEC_PER_SEC);
  dispatch_after(after, dispatch_get_main_queue(), ^{
    [ctx close];
  });

  // Exit after four seconds
  dispatch_time_t after4 =
      dispatch_time(DISPATCH_TIME_NOW, 14.0 * NSEC_PER_SEC);
  dispatch_after(after4, dispatch_get_main_queue(), ^{
    exit(0);
  });

  // Run forever
  [[NSRunLoop mainRunLoop] run];
}
