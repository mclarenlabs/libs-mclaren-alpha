/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A tiny example demonstrating recording a single sound for four
 * seconds and writing to a file.  File extension dictates format.
 *
 * The gain of a system microphone may need to be adjusted by
 * the appropriate program.
 */

#include <unistd.h>

extern char *optarg;
extern int optind, opterr, optopt;

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"
#import "McLarenSynthKit/McLarenSynthKit.h"

void usage() {
  fprintf(stderr, "capturesample [-c cutoff] [-d device] [-f lowpass|lowshelf|peak] file.ext");
  exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {

  MSKError_linker_function(); // cause NSError category to be linked
  ASKError_linker_function(); // cause NSError category to be linked

  // arguments
  NSString *devName = @"default";
  char *filtertype = "none";
  int fcutoff = 2000; // devault cutuff
  NSString *filePath;

  int opt;
  while ((opt = getopt(argc, argv, "d:f:")) != -1) {
    switch (opt) {
    case 'c':
      fcutoff = atoi(optarg);
      break;
    case 'd':
      devName = [NSString stringWithCString:optarg];
      break;
    case 'f':
      filtertype = optarg;
      break;
    case '?':
      usage();
      break;
    }
  }

  filePath = [NSString stringWithFormat:@"%s", argv[optind]];

  NSLog(@"capturing file:%@ from:%@", filePath, devName);
    

  // Desired audio context parameters
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44100;
  request.persize = 1024;
  request.periods = 2;

  NSError *error;
  BOOL ok;

  // Create an audio context on the 'default' device for recording
  __block MSKContext *rec = [[MSKContext alloc] initWithName: devName
                                                   andStream: SND_PCM_STREAM_CAPTURE
                                                       error: &error];

  if (error != nil) {
    NSLog(@"MSKContext init error:%@", error);
    exit(EXIT_FAILURE);
  }

  // Configure the context with the request
  ok = [rec configureForRequest:request error:&error];
  if (ok == NO) {
    NSLog(@"MSKContext configure error:%@", error);
    exit(EXIT_FAILURE);
  }

  // Start the context
  ok = [rec startWithError:&error];
  if (ok == NO) {
    NSLog(@"MSKContext starting error:%@", error);
    exit(EXIT_FAILURE);
  }

  // Create an empty sample to hold four seconds
  MSKSample *samp = [[MSKSample alloc] initWithCapacity:(44100*4) channels:2];

  // print the elements of the samp
  NSLog(@"sample:%@", samp);

  // create a filter
  MSKFilterModel *fmodel = [[MSKFilterModel alloc] init];
  fmodel.filtertype = MSK_FILTER_NONE;
  fmodel.fc = fcutoff;
  fmodel.q = 2.0;

  if (strcmp(filtertype, "lowpass") == 0) {
    NSLog(@"setting filter type to LOWPASS");
    fmodel.filtertype = MSK_FILTER_BIQUAD_TYPE_LOWPASS;
  }
  else if (strcmp(filtertype, "lowshelf") == 0) {
    NSLog(@"setting filter type to LOWSHELF");
    fmodel.filtertype = MSK_FILTER_BIQUAD_TYPE_LOWSHELF;
  } 
  else if (strcmp(filtertype, "peak") == 0) {
    NSLog(@"setting filter type to PEAK");
    fmodel.filtertype = MSK_FILTER_BIQUAD_TYPE_PEAK;
  }
  
  MSKGeneralFilter *lowpass = [[MSKGeneralFilter alloc] initWithCtx:rec];
  lowpass.model = fmodel;
  lowpass.sInput = rec.rbuf; // read from the recording bus
  [lowpass compile];

  // Create a recorder for the sample
  __block MSKSampleRecorder *recorder = [[MSKSampleRecorder alloc] initWithCtx:rec];
  recorder.sample = samp;
  // recorder.sInput = rec.rbuf;
  recorder.sInput = lowpass;
  [recorder compile];

  // Ask the context to record it
  [rec setGain:1.0];
  [rec addVoice:recorder];

  dispatch_time_t after1 = dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC);
  dispatch_after(after1, dispatch_get_main_queue(), ^{
      [recorder recOn];
    });

  dispatch_time_t after2 = dispatch_time(DISPATCH_TIME_NOW, 3.0*NSEC_PER_SEC);
  dispatch_after(after2, dispatch_get_main_queue(), ^{
      [recorder recOff];
      recorder = nil;
    });

  dispatch_time_t after3 = dispatch_time(DISPATCH_TIME_NOW, 4.0*NSEC_PER_SEC);
  dispatch_after(after3, dispatch_get_main_queue(), ^{
      NSError *err;
      NSLog(@"samp:%@", samp);
      [samp writeToFilePath:filePath error:&err];
      if (err != nil) {
        NSLog(@"error writing file:%@", err);
      }
    });

  // Exit after four seconds
  dispatch_time_t after4 = dispatch_time(DISPATCH_TIME_NOW, 5.0*NSEC_PER_SEC);
  dispatch_after(after4, dispatch_get_main_queue(), ^{
      exit(EXIT_SUCCESS);
    });

  // Run forever
  // [[NSRunLoop mainRunLoop] run];
  dispatch_main();

}
 
