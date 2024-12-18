/** -*- mode: objc -*-
 *
 * This class provides its derived classes a cleaned-up keyboard
 * input handling suitable for our controls.
 *
 * - first responder managed and flag _isFirstResponder set for children
 * - key input is de-repeatized
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MLInputView : NSView {
  @public
    BOOL _isFirstResponder;
}

@property (readwrite) BOOL isFirstResponder;

// Subclass MUST implement these to receive de-repeatized keyboard events
// and MUST return whether the event was handled
- (BOOL) performKeyDown:(NSEvent*)ev;
- (BOOL) performKeyUp:(NSEvent*)ev;

@end


