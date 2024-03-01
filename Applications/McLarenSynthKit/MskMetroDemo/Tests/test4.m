/*
 * Test4:
 *  - all beats
 *  - do an intro
 *  - call a sub-pat with repeat 2
 *  - loop until empty
 */

#import <Foundation/Foundation.h>
#import "../Pattern.h"

#import "Testing.h" // Simplified report message

int main(int argc, char *argv[]) {

  NSArray *expectedValues =
    @[
      @"one",
       @"two",
       @"subone", @"subtwo",
       @"three"
      ];
  
  NSMutableArray *actualValues = [[NSMutableArray alloc] init];


  Pattern *pat = [[Pattern alloc] initWithName:@"pat1"];
  Pattern *subpat = [[Pattern alloc] initWithName:@"pat2"];

  [subpat thunk:^{
      NSLog(@"SUB INTRO ONE");
    }];

  [subpat sync:@"beat"];
  [subpat thunk:^{
      NSLog(@"SUB BEAT ONE");
      [actualValues addObject:@"subone"];
    }];

  [subpat sync:@"beat"];
  [subpat thunk:^{
      NSLog(@"SUB BEAT TWO");
      [actualValues addObject:@"subtwo"];
    }];

  // [subpat repeat:2];
  /****************/

  [pat thunk:^{
      NSLog(@"INTRO ONE");
      [actualValues addObject:@"one"];
    }];
  
  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"INTRO TWO");
      [actualValues addObject:@"two"];
    }];

  [pat pat:subpat];

  [pat thunk:^{
      NSLog(@"EXIT");
      [actualValues addObject:@"three"];
    }];
  NSLog(@"pat:%@", pat);

  /****************/


  Scheduler *sched = [[Scheduler alloc] init];

  Thread *t = [[Thread alloc] initWithThreadId:45];
  [t push:pat];

  NSLog(@"thread:%@", t);

  [t interpret:sched ticktime:00]; // launch the thread and run until it waits

  NSLog(@"sched:%@", sched);

  for (int i = 0; i < 10; i++) {
    [sched wakeFor:@"beat" ticktime:i*100+1];
    NSLog(@"sched:%@", sched);
  }

  NSLog(@"%@", actualValues);
  pass([actualValues isEqualTo:expectedValues], "trace of values matches");
}
