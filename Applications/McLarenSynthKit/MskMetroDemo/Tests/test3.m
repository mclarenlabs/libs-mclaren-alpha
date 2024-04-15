/*
 * Begin testing the pattern framework.
 * Test a repeat count of 2.
 * Now wait on a sleep
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/MSKPattern.h"

#import "Testing.h" // Simplified report message

int main(int argc, char *argv[]) {

  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat1"];
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

  [pat ticks:20];
  [pat thunk:^{
      NSLog(@"SLEPT 20");
    }];

  [pat ticks:40];
  [pat thunk:^{
      NSLog(@"SLEPT 40");
    }];

  [pat repeat:2];  // REPEAT TWICE
  NSLog(@"pat:%@", pat);

  /****************/


  MSKScheduler *sched = [[MSKScheduler alloc] init];

  MSKThread *t = [[MSKThread alloc] initWithThreadId:45];
  [t push:pat];

  NSLog(@"thread:%@", t);

  [t interpret:sched ticktime:-1]; // launch the thread and run until it waits

  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 1, "the thread is waiting");

  [sched wakeFor:@"beat" ticktime:1201];

  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 1, "the thread is waiting");

  [sched wakeFor:@"beat" ticktime:1501];

  NSLog(@"sched:%@", sched);
  pass([sched.sleepers count] == 1, "the thread is sleeping");

  [sched wakeFor:@"beat" ticktime:1701];

  NSLog(@"sched:%@", sched);
  pass([sched.sleepers count] == 1, "the thread is still sleeping even though a beat passed");

  [sched wakeSleeper:0 ticktime:1901];

  NSLog(@"sched:%@", sched);
  pass([sched.sleepers count] == 1, "the thread is sleeping");

  [sched wakeSleeper:1 ticktime:2101];

  NSLog(@"sched:%@", sched);
  pass([sched.waiters count] == 1, "the thread is waiting");

}
