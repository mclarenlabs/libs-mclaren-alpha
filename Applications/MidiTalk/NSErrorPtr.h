/*
 * This class holds an NSError* and when asked to be cast to a pointer
 * via the #pointerValue method, it returns a reference to its NSError*.
 *
 * There is actually only one use-case for this class, and that is to
 * create a value that can be passed to an ObjC method that declares
 *     NSError** err
 * as an "out" value.  An instance of this class can be used in the StepTalk
 * interpreter.
 *
 * McLaren Labs 2023
 */

#include <Foundation/Foundation.h>

@interface NSErrorPtr : NSObject
@property NSError *err;

- (BOOL) hasValue; // is err!=nil
- (void) clear;    // set err=nil

- (void*) pointerValue; // returns &err

@end

