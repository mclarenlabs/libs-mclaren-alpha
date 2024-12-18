/** *-* mode; objc *-*
 *
 * Controller to hold MLPiano and switches
 *
 * McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "LabelWithValue.h"
#import "MLPiano.h"

@interface MLPianoController : NSView

@property MLPiano *piano;
@property NSButton *octaveUp;
@property NSButton *octaveDown;
@property LabelWithValue *octaveLabel;

@end



