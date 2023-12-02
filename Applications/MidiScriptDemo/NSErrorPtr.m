/** -*- mode:objc -*-
 *
 * Give the interpreter an object that can be passed to an arg of type
 *   NSError **ptr
 *
 * (c) McLarenLabs 2023
 */

#include "NSErrorPtr.h"

@implementation NSErrorPtr

- (id) init {
  if (self = [super init]) {
    _err = nil;
  }
  return self;
}

- (BOOL) hasValue {
  return (_err != nil);
}

- (void) clear {
  _err = nil;
}

// When the interpreter finds a method signature that needs a pointer from
// an instance of this class, it finds this method.

- (void*) pointerValue {
  return &_err;
}

@end
