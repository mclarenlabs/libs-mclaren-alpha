#import <AppKit/AppKit.h>
#import "SampleToy_AppDelegate.h"
#include <dispatch/dispatch.h>

int main(int argc, char *argv[])
{

  @autoreleasepool
    {
      [NSApplication sharedApplication];

      AppDelegate *delegate = [AppDelegate new];
      [NSApp setDelegate:delegate];

      [NSApp run];
    }

  return 0;
}
