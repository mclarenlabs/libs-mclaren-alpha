/** -*- mode:objc -*-
 *
 * Draw a sample buffer to the screen
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

@interface MLContextBufferView : NSView

@property (readwrite) MSKContextBuffer *sample;

@end
  
