/** -*- mode: objc -*-
 *
 * A widget that displays a label value pair.
 *
 */

#import "AppKit/AppKit.h"
#import "LabelWithValue.h"

@implementation LabelWithValue

- (id) init {
  if (self = [super init]) {
    _font = [NSFont userFontOfSize:16.0];
    _labelColor = [NSColor darkGrayColor];
    _valueColor = [NSColor blackColor];

    _label = @"Label:";
    _value = @"50.0";

    // TextView
    [self setEditable: NO];
    [self setSelectable: NO];
    [self setBezeled: YES];
    [self setDrawsBackground: NO];

    // compute the result to display
    [self setDisplayString];

  }
  return self;
}

- (void) thing {
}

// create the display string from the components
- (void) setDisplayString {

  NSDictionary *labelAttributes = @{
  NSFontAttributeName : _font,
  NSForegroundColorAttributeName : _labelColor
  };

  NSMutableAttributedString *labelStr = [[NSMutableAttributedString alloc] initWithString:_label
								 attributes:labelAttributes];

  NSDictionary *valueAttributes = @{
  NSFontAttributeName: _font,
  NSForegroundColorAttributeName : _valueColor
  };

  NSMutableAttributedString *valueStr = [[NSMutableAttributedString alloc] initWithString:_value
								 attributes:valueAttributes];

  [labelStr appendAttributedString:valueStr];

  [self setStringValue: (NSString*) labelStr];
  
}

- (void) setFont:(NSFont*)font
{
  _font = font;
  [self setDisplayString];
}

- (void) setLabel:(NSString*)label
{
  _label = label;
  [self setDisplayString];
}

- (void) setValue:(NSString*)value
{
  _value = value;
  [self setDisplayString];
}


@end
