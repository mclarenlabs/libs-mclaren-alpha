#import <AppKit/AppKit.h>
#import "MskOrganDemo_AppDelegate.h"

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
