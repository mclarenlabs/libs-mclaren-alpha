/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * This demonstration is an extension of scaleplayer.m.  It adds
 * Reverb to the FX path, and the sound graph constructed for each
 * note includes two oscillators: one that modulates the phase of
 * the output oscillator.
 *
 */

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"
#import "McLarenSynthKit/McLarenSynthKit.h"

#import "NSObject+MLBlocks.h"

int main(int argc, char *argv[]) {

  MSKError_linker_function(); // cause NSError category to be linked
  ASKError_linker_function(); // cause NSError category to be linked

  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;
  request.persize = 1024;
  request.periods = 2;

  NSString *devName = @"default";

  NSError *error;
  BOOL ok;

  MSKContext *ctx = [[MSKContext alloc] initWithName:devName
                                           andStream:SND_PCM_STREAM_PLAYBACK
                                               error:&error];

  if (error != nil) {
    NSLog(@"MSKContext init error:%@", error);
    exit(1);
  }

  ok = [ctx configureForRequest:request error:&error];
  if (ok == NO) {
    NSLog(@"MSKContext configure error:%@", error);
    exit(1);
  }

  ok = [ctx startWithError:&error];
  if (ok == NO) {
    NSLog(@"MSKContext starting error:%@", error);
    exit(1);
  }

  //
  // Build an Effects path consisting of a reverb unit and a low-pass filter.
  //
  
  MSKReverbModel *modreverb = [[MSKReverbModel alloc] init];
  modreverb.on = YES;
  modreverb.dry = 70;
  modreverb.wet = 50;
  modreverb.roomsize = 30;

  MSKFreeverbReverb *rb = [[MSKFreeverbReverb alloc] initWithCtx:ctx];
  rb.model = modreverb;
  rb.sInput = ctx.pbuf;
  [rb compile];

  MSKGeneralFilter *lpf = [MSKGeneralFilter filterWithLowpass:ctx];
  lpf.sInput = rb;
  [lpf compile];

  [ctx addFx:lpf];  // install the FX chain

  //
  // Create the fixed models that will be shared by all notes
  //

  MSKOscillatorModel *oscmodel1 = [[MSKOscillatorModel alloc] init];
  oscmodel1.osctype = MSK_OSCILLATOR_TYPE_TRIANGLE;

  MSKOscillatorModel *oscmodel2 = [[MSKOscillatorModel alloc] init];
  oscmodel2.osctype = MSK_OSCILLATOR_TYPE_TRIANGLE;

  MSKModulationModel *modmodel2 = [[MSKModulationModel alloc] init];
  modmodel2.modulation = 0.2;

  MSKEnvelopeModel *envmodel1 = [[MSKEnvelopeModel alloc] init];
  envmodel1.attack = 0.2; // slow attack
  envmodel1.decay = 0.2;
  envmodel1.sustain = 0.9;
  envmodel1.rel = 2.0;

  MSKEnvelopeModel *envmodel2 = [[MSKEnvelopeModel alloc] init];
  envmodel2.attack = 0.01;
  envmodel2.decay = 0.05;
  envmodel2.sustain = 0.9;
  envmodel2.rel = 2.0;

  NSArray *midiScale = @[ @60, @62, @64, @65, @67, @69, @71, @72,
			     @60, @62, @64, @65, @67, @69, @71, @72,
			     @60, @62, @64, @65, @67, @69, @71, @72
			  ];

  int i = 0;

  NSObject *self = [NSNull null];

  for (NSNumber *note in midiScale) {
    //    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, (0.5 + i*0.5)*NSEC_PER_SEC);
    // dispatch_after(after, dispatch_get_main_queue(), ^{
    [self afterDelay:(0.5 + i*0.4) performBlockOnMainThread:^{

        MSKLinEnvelope *env = [[MSKLinEnvelope alloc] initWithCtx:ctx];
        env.oneshot = YES;
        env.shottime = 0.6;
        env.model = envmodel1;
        [env compile];

        MSKGeneralOscillator *osc1 = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
        osc1.iNote = [note unsignedIntegerValue];
        osc1.sEnvelope = env;
        osc1.model = oscmodel1;
        [osc1 compile];

        MSKExpEnvelope *env2 = [[MSKExpEnvelope alloc] initWithCtx:ctx];
        env2.oneshot = YES;
        env2.shottime = 0.2;
        env2.model = envmodel2;
        [env2 compile];

	MSKPhaseDistortionOscillator *osc2 = [[MSKPhaseDistortionOscillator alloc] initWithCtx:ctx];
	osc2.iNote = [note unsignedIntegerValue];
	osc2.sEnvelope = env2;
	osc2.model = oscmodel2;
  osc2.modulationModel = modmodel2;


	osc2.sPhasedistortion = osc1;
	[osc2 compile];
	

        [ctx addVoice:osc2];
      }];
    i++;
  }

  // Close the context after two seconds
#if 0
  dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 15.0*NSEC_PER_SEC);
  dispatch_after(after, dispatch_get_main_queue(), ^{
      [ctx close];
    });
#else
  [self afterDelay:15.0 performBlockOnMainThread:^{
      [ctx close];
	}];
#endif

  // Exit after four seconds
#if 0
  dispatch_time_t after10 = dispatch_time(DISPATCH_TIME_NOW, 17.0*NSEC_PER_SEC);
  dispatch_after(after10, dispatch_get_main_queue(), ^{
      exit(0);
    });
#else
  [self afterDelay:17.0 performBlockOnMainThread:^{
      exit(0);
    }];
#endif

  // Run forever
  [[NSRunLoop mainRunLoop] run];
  // dispatch_main();

}
 
