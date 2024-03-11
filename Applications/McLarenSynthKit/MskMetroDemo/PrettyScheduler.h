/**
 *
 * The Scheduler subclassed so that it redirects its logger output to
 * a textview with pretty formatting.
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Pattern.h"

@interface PrettyScheduler : Scheduler

@property (readwrite) NSTextView *textView; // the textview to use

- (void) logger:(NSString*)fmtTime pat:(NSString*)patname msg:(NSString*)msg;

@end
