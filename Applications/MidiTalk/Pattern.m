/** -*- mode: objc -*-
 *
 * Extend MSKPattern for StepTalk
 *   - implement play: operator
 *   - allow sync: to work with selectors
 *
 * McLaren Labs 2024
 */

#import "Pattern.h"

#import "StepTalk/STSelector.h"

#import "AppKit/NSApplication.h"

/*
 * Allow sync: to work on selectors in StepTalk
 */

@implementation Pattern

- (void) sync:(id)waitchan {

  if ([waitchan isKindOfClass:[NSString class]]) {
    [super sync:waitchan];
  }
  else if ([waitchan isKindOfClass:[STSelector class]]) {
    // use the selector name as the wait channel
    [super sync:[waitchan selectorName]];
  }
  else {
    // else try to get a string value
    [super sync:[waitchan stringValue]];
  }
}

/*
 * Implement play: for StepTalk.
 *    play: [ block ... ]
 * Map STBlock to a thunk.
 */

- (void) play:(id)block {

  NSArray *modes = @[ NSDefaultRunLoopMode,
					  NSRunLoopCommonModes,
					  NSEventTrackingRunLoopMode,
					  NSModalPanelRunLoopMode
		      ];
      
  [self thunk:^{

      [block performSelectorOnMainThread:@selector(value)
			      withObject:@(0)
			   waitUntilDone:NO
				   modes:modes

       ];
      
    }];
}

@end
