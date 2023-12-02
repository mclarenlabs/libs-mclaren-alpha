/*
 * ButtonSynth has three buttons that play sounds
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include "./GSTable-MLdecls.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *win;
@property (nonatomic, retain, strong) NSTextView *textview;

@end
