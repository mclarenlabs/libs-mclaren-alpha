/** -*- mode: objc -*-
 *
 * A widget that displays a label value pair.
 *
 */

#import <AppKit/AppKit.h>

@interface LabelWithValue : NSTextField

@property (readonly) NSString *label;
@property (readonly) NSString *value;

@property (readonly) NSFont *font;

@property (readonly) NSColor *labelColor;
@property (readonly) NSColor *valueColor;

- (void) setFont:(NSFont*)font;
- (void) setLabel:(NSString*)label;
- (void) setValue:(NSString*)value;

@end
