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

@end
