/** -*- mode:objc -*-
 *
 * Misc extensions
 *
 * McLaren Labs 2023
 */

#include "NSObject+additions.h"

@implementation NSObject (additions)

// Borrowed heavily from implementation of NSObject.m

- (id) performSelector: (SEL)aSelector
	    withObject: (id) object1
	    withObject: (id) object2
  	    withObject: (id) object3
{

  if (aSelector == 0)
    [NSException raise: NSInvalidArgumentException
		format: @"%@ null selector given", NSStringFromSelector(_cmd)];

  IMP msg = [self methodForSelector:aSelector];
  if (!msg)
    {
      [NSException raise: NSGenericException
		   format: @"invalid selector '%s' passed to %s",
                   sel_getName(aSelector), sel_getName(_cmd)];
      return nil;
    }

  return (*msg)(self, aSelector, object1, object2, object3);
}

@end
