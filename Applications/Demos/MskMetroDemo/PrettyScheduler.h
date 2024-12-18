/**
 *
 * The Scheduler subclassed so that it redirects its logger output to
 * a textview with pretty formatting.
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "McLarenSynthKit/MSKPattern.h"

@interface PrettyScheduler : MSKScheduler

@property (readwrite) NSTextView *textView; // the textview to use

- (void) logger:(NSString*)fmtTime pat:(NSString*)patname msg:(NSString*)msg;

@end
