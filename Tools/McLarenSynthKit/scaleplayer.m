/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A small example demonstrating opening the default audio device and playing
 * a scale.
 *
 */

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"
#import "McLarenSynthKit/McLarenSynthKit.h"

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

  MSKOscillatorModel *oscmodel1 = [[MSKOscillatorModel alloc] init];
  oscmodel1.osctype = MSK_OSCILLATOR_TYPE_TRIANGLE;

  MSKEnvelopeModel *envmodel1 = [[MSKEnvelopeModel alloc] init];
  envmodel1.attack = 0.01;
  envmodel1.decay = 0.05;
  envmodel1.sustain = 0.9;
  envmodel1.rel = 2.0;

  NSArray *midiScale = @[ @60, @62, @64, @65, @67, @69, @71, @72 ];

  int i = 0;
  for (NSNumber *note in midiScale) {
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, (0.4 + i*0.2)*NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_main_queue(), ^{
        MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:ctx];
        env.oneshot = YES;
        env.shottime = 0.05;
        env.model = envmodel1;
        [env compile];

        MSKGeneralOscillator *osc = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
        osc.iNote = [note unsignedIntegerValue];
        osc.sEnvelope = env;
        osc.model = oscmodel1;
        [osc compile];

        [ctx addVoice:osc];
      });
    i++;
  }

  // Close the context after two seconds
  dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 3.0*NSEC_PER_SEC);
  dispatch_after(after, dispatch_get_main_queue(), ^{
      [ctx close];
    });

  // Exit after four seconds
  dispatch_time_t after4 = dispatch_time(DISPATCH_TIME_NOW, 5.0*NSEC_PER_SEC);
  dispatch_after(after4, dispatch_get_main_queue(), ^{
      exit(0);
    });

  // Run forever
  [[NSRunLoop mainRunLoop] run];

}
 
