/*
 * Make a seq, a metronome and a scheduler and run some patterns.
 *
 * This test demonstrates the progress of the pattern by printing
 * a sequence of numbers to the screen at one-second intervals.
 *
 * Try running with and without the "[metro stop]" call in the pattern
 * and observe the difference.
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"
#import "../Pattern.h"

@interface Test : NSObject
@property (readwrite) ASKSeq *seq;
@property (readwrite) MSKMetronome *metro;
@property (readwrite) Scheduler *sched;
@end

@implementation Test

- (void) makeSeq {

  ASKSeqOptions *options = [[ASKSeqOptions alloc] init];
  options->_sequencer_name = "metronome";

  NSError *error;
  _seq = [[ASKSeq alloc] initWithOptions:options error:&error];
  if (error != nil) {
    NSLog(@"Could not create sequencer.  Error:%@", error);
    exit(1);
  }
}

- (void) makeMetronome {

  NSError *error;
  _metro = [[MSKMetronome alloc] initWithSeq:_seq error:&error];

  // set tempo
  NSError *err;
  [_seq setTempo:60 error:&err];

  if (error != nil) {
    NSLog(@"Could not create metronome. Error:%@", error);
    exit(1);
  }
  
}

- (void) makeScheduler {

  _sched = [[Scheduler alloc] init];
  [_sched registerMetronome:_metro];

}

- (void) run {

  NSLog(@"start test");
  [self makeSeq];
  [self makeMetronome];
  [self makeScheduler];

  NSLog(@"creating pattern");

  Pattern *pat = [[Pattern alloc] initWithName:@"pat1"];
  [pat thunk:^{
      NSLog(@"INTRO ONE");
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"ONE");
    }];

  NSLog(@"here");
  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"TWO");
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"THREE");
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"FOUR");
      [_metro stop];
    }];
  [pat repeat:2];

  [_sched addLaunch:pat];

  NSLog(@"sched:%@", _sched);

  [_metro start];

  sleep(10);


}

@end

int main(int argc, char *argv[]) {

  Test *test = [[Test alloc] init];
  [test run];


}
