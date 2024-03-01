/*
 * Begin testing the pattern framework
 *
 * This test creates a pattern and uses the low-level methods
 * of the schedulers to execute the Thread of the Pattern and
 * check the state of the scheduler.
 */

#import <Foundation/Foundation.h>
#import "../Pattern.h"

#import "Testing.h" // Simplified report message

int main(int argc, char *argv[]) {

  NSArray *expectedValues = @[ @0, @1, @2 ];
  NSMutableArray *actualValues = [[NSMutableArray alloc] init];

  Pattern *pat = [[Pattern alloc] initWithName:@"pat1"];
  [pat thunk:^{
      NSLog(@"ZERO");
      [actualValues addObject:@0];
    }];
  
  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"ONE");
      [actualValues addObject:@1];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"TWO");
      [actualValues addObject:@2];
    }];

  NSLog(@"pat:%@", pat);

  Scheduler *sched = [[Scheduler alloc] init];

  Thread *t = [[Thread alloc] initWithThreadId:45];
  [t push:pat];

  NSLog(@"thread:%@", t);

  [t interpret:sched ticktime:-1]; // launch the thread and run until it waits

  // there should be one item in the waiters now
  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 1, "the thread is waiting");

  [sched wakeFor:@"beat" ticktime:1201];

  // there should be one item in the waiters now
  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 1, "the thread is waiting");

  [sched wakeFor:@"beat" ticktime:1501];

  // the waiters list should be empty
  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 0, "no threads are waiting");

  // the traces should match the expectation
  pass([actualValues isEqualTo:expectedValues], "Test1 traces");
}
