#import "NSObject+MLBlocks.h"

@implementation NSObject  (MLBlocks)

- (void) performBlock:(MLVoidBlock)block;
{
  block();
}


- (void) performBlockOnMainThread:(MLVoidBlock)block
{

  [self performSelectorOnMainThread:@selector(performBlock:)
			 withObject:[block copy]
		      waitUntilDone:NO];
}

- (void)  afterDelay:(NSTimeInterval)delay performBlockOnMainThread:(MLVoidBlock)block
{

  [self performBlockOnMainThread:^{
      [self performSelector:@selector(performBlock:)
		 withObject:[block copy]
		 afterDelay:delay];
    }];
}

@end
