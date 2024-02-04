/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A tiny example demonstrating playing a single sound with all defaults.
 *
 */

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"
#import "McLarenSynthKit/McLarenSynthKit.h"

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
  __block MSKContext *ctx = [[MSKContext alloc] initWithName:devName
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


  // Create and sound a Voice after 1 second
  dispatch_time_t attackt = dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC);
  dispatch_after(attackt, dispatch_get_main_queue(), ^{
    
    MSKOscillatorModel *oscmodel1 = [[MSKOscillatorModel alloc] initWithName:@"osc1"];
    oscmodel1.osctype = MSK_OSCILLATOR_TYPE_TRIANGLE;

    MSKEnvelopeModel *envmodel1 = [[MSKEnvelopeModel alloc] initWithName:@"env1"];
    envmodel1.sustain = 1.0;
    envmodel1.rel = 1.5;

    MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:ctx];
    env.oneshot = YES;
    env.shottime = 0.05;
    env.model = envmodel1;
    [env compile];

    MSKGeneralOscillator *osc = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
    osc.iNote = 60;
    osc.sEnvelope = env;
    osc.model = oscmodel1;
    [osc compile];

    // Hand the oscillator over to the context for rendering
    [ctx addVoice:osc];
    });

  // Close the context after two seconds
  dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC);
  dispatch_after(after, dispatch_get_main_queue(), ^{
      [ctx close];
      ctx = nil;
    });

  // Exit after four seconds
  dispatch_time_t after4 = dispatch_time(DISPATCH_TIME_NOW, 4.0*NSEC_PER_SEC);
  dispatch_after(after4, dispatch_get_main_queue(), ^{
      exit(0);
    });

  // Run forever
  [[NSRunLoop mainRunLoop] run];

}
 
