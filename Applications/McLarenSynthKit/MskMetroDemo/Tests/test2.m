/*
 * Begin testing the pattern framework.
 * Test a repeat count of 2.
 *
 * This test creates a pattern and uses the low-level methods
 * of the schedulers to execute the Thread of the Pattern and
 * check the state of the scheduler.
 */

#import <Foundation/Foundation.h>
#import "../Pattern.h"

#import "Testing.h" // Simplified report message

int main(int argc, char *argv[]) {

  Pattern *pat = [[Pattern alloc] initWithName:@"pat1"];
  [pat thunk:^{
      NSLog(@"ZERO");
    }];
  
  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"ONE");
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"TWO");
    }];

  [pat repeat:2];  // REPEAT TWICE
  NSLog(@"pat:%@", pat);

  /****************/


  Scheduler *sched = [[Scheduler alloc] init];

  Thread *t = [[Thread alloc] initWithThreadId:45];
  [t push:pat];

  NSLog(@"thread:%@", t);

  [t interpret:sched ticktime:-1]; // launch the thread and run until it waits

  NSLog(@"sched:%@", sched);

  [sched wakeFor:@"beat" ticktime:1201];

  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 1, "the thread is waiting");

  [sched wakeFor:@"beat" ticktime:1501];

  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 1, "the thread is waiting");

  [sched wakeFor:@"beat" ticktime:1701];

  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 1, "the thread is waiting");

  [sched wakeFor:@"beat" ticktime:1901];

  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 0, "no threads are waiting");

}
