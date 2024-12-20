/** -*- mode:objc -*-
 *
 * Misc extensions
 *
 * McLaren Labs 2023
 */

#include <Foundation/Foundation.h>

@interface NSObject (additions)

// The standard provides up to two arguments, this provides three

- (id) performSelector: (SEL)aSelector
	    withObject: (id) object1
	    withObject: (id) object2
  	    withObject: (id) object3;

@end
