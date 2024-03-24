/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A tiny example demonstrating playing a single sound with all defaults.
 *
 */

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"
#import "McLarenSynthKit/McLarenSynthKit.h"

void usage() {
  fprintf(stderr, "playsample [-d device] file.ext");
  exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {

  MSKError_linker_function(); // cause NSError category to be linked
  ASKError_linker_function(); // cause NSError category to be linked

  // arguments
  NSString *devName = @"default";
  NSString *filePath;

  int opt;
  while ((opt = getopt(argc, argv, "d:f:")) != -1) {
    switch (opt) {
    case 'd':
      devName = [NSString stringWithCString:optarg];
      break;
    case '?':
      usage();
      break;
    }
  }

  filePath = [NSString stringWithFormat:@"%s", argv[optind]];
    
  NSLog(@"playing file:%@ to:%@", filePath, devName);

  // Desired audio context parameters
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44100;
  request.persize = 1024;
  request.periods = 2;

  NSError *error;
  BOOL ok;

  // turn off the 'chime' that signals the context is working
  [MSKContext setPlaysChime:NO];

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

  // Load a sample from a file
  NSError *err;
  MSKSample *samp = [[MSKSample alloc] initWithFilePath:filePath error:&err];
  if (err != nil) {
    NSLog(@"Error: %@", err);
    exit(1);
  }

  // print info of the samp
  NSLog(@"sample:%@", samp);

  // Create a player for the sample
  MSKSamplePlayer *player = [[MSKSamplePlayer alloc] initWithCtx:ctx];
  [player setSample:samp];
  [player compile];

  // Ask the context to play it
  [ctx setGain:1.0];
  [ctx addVoice:player];

  // Exit after the sample's duration
  // Sample is played at the context's samplerate, not the sample's!
  float duration = (1.0 * samp.frames) / ctx.rate;
  duration += 1.0; // add a second
  dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, duration*NSEC_PER_SEC);
  dispatch_after(after, dispatch_get_main_queue(), ^{
      exit(0);
    });

  // Run forever
  [[NSRunLoop mainRunLoop] run];

}
 
