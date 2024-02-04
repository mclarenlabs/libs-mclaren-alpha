/**
 * Add an interface for running a block on the main thread.
 *
 * Workaround for dispatch_async(dispatch_get_main_queue()) not
 * quite working right with GNUstep.  Have observed 100% CPU use.
 *
 * mclaren 2023
 */

#import <Foundation/Foundation.h>

typedef void(^MLVoidBlock)(void);

@interface NSObject (MLBlocks)

- (void) performBlockOnMainThread:(MLVoidBlock)block;

@end
