/** -*- mode:objc -*-
 *
 * Render stereo VU meters for a context.
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

@interface MLVUMeterView : NSView

- (void) rmsL:(double)rmsL rmsR:(double)rmsR peakL:(double)peakL peakR:(double)peakR;

@end
  
