/** -*- mode: objc -*-
 *
 * The callbacks from MLPiano, MLExpressiveButton and ASKSeqDispatcher
 * all invoke a selector on a target with one, two or three integer arguments.
 *
 * In order to have a single place to put in error checking and verbosity,
 * the functions in this file have been created.
 *
 */

#import "apply.h"
#import "NSObject+additions.h" // withObject:withObject:withObject:

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

void applyWithOneInt(id target, SEL selector, int val) {
  if (target != nil) {
    if ([target respondsToSelector:selector] == YES) {
      [target performSelector:selector withObject:@(val)];
    }
  }
}

void applyWithTwoInts(id target, SEL selector, int val1, int val2) {
  if (target != nil) {
    if ([target respondsToSelector:selector] == YES) {
      [target performSelector:selector withObject:@(val1) withObject:@(val2)];
    }
  }
}

void applyWithThreeInts(id target, SEL selector, int val1, int val2, int val3) {
  if (target != nil) {
    if ([target respondsToSelector:selector] == YES) {
      [target performSelector:selector withObject:@(val1) withObject:@(val2) withObject:@(val3)];
    }
  }
}

#pragma clang diagnostic pop
