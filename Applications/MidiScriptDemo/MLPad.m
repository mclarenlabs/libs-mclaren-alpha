/** -*- mode: objc -*-
 *
 * Implementation of Pad
 *
 * McLaren Labs 2023
 */

#import "MLPad.h"
#import "NSColor+ColorExtensions.h"


@implementation MLPad {
  BOOL _state[16];

  // tracking mouse down/up
  NSEvent *_lastMouseDownEvent;
  int _lastIndex;

}
  

- (id) initWithFrame:(NSRect)frame {
  if (self = [super initWithFrame:frame]) {
    _bgColor = [NSColor darkGrayColor];
    _colors = @[ [NSColor mcBlueColor],
				      [NSColor mcGreenColor],
				      [NSColor mcOrangeColor],
				      [NSColor mcPurpleColor]
		 ];

    _xwid = 100;
    _ywid = 100;
    _margin = 5;

    for (int i = 0; i < 16; i++) { _state[i] = NO; }

    // accelerator characters
    _accel = @"m,./jkl;uiop7890";
    _accelFont = [NSFont userFontOfSize:11];
    _accelColor = [NSColor darkGrayColor];

    // labels
    _labels = [NSMutableArray arrayWithArray:
				@[@"0", @"1", @"2", @"3",
				   @"4", @"5", @"6", @"7",
				   @"8", @"9", @"A", @"B",
				   @"C", @"D", @"E", @"F"]];

    _labelFont = [NSFont userFontOfSize:32];
    _labelColor = [NSColor blackColor];

    // drag tracking
    _lastIndex = -1;

    // output protocol can modify midiMap
    _midiMap = [NSMutableArray arrayWithArray:@[ @0, @1, @2, @3,
							@4, @5, @6, @7,
							@8, @9, @10, @11,
							@12, @13, @14, @15]];
		    
    // fixed velocity for ow
    _velocity = 127;

    _noteOnSelector = @selector(padNoteOn:vel:);
    _noteOffSelector = @selector(padNoteOff:vel:);
    
    

  }
  return self;
}

- (BOOL) isHighlighted:(int)i j:(int)j
{
  int idx = [self indexForCell:i j:j];
  return _state[idx];
}

- (void) setHighlighted:(int)i j:(int)j val:(BOOL)val
{
  int idx = [self indexForCell:i j:j];
  _state[idx] = val;
}

- (NSRect) rectForCell:(int)i j:(int)j
{
  double originx = (i * _xwid) + _margin;
  double originy = (j * _ywid) + _margin;
  double width = _xwid - 2*_margin;
  double height = _ywid - 2*_margin;
  return NSMakeRect(originx, originy, width, height);
}

- (NSColor*) colorForCell:(int)i j:(int)j
{
  return _colors[i];
}

- (int) indexForCell:(int)i j:(int)j
{
  if (i < 0 || j < 0)
    return -1;
  if (i > 3 || j > 3)
    return -1;
  
  return j*4 + i;
}

- (void) drawCell:(int)i j:(int)j {

  NSColor *color = [self colorForCell:i j:j];

  double roundedRadius = 3.0;

  // Get the graphics context that we are currently executing under
  NSGraphicsContext* ctx = [NSGraphicsContext currentContext];

  // Get the rect for this cell
  NSRect frame = [self rectForCell:i j:j];

  // Draw darker overlay out to corner of button
  [ctx saveGraphicsState];
  [[NSBezierPath bezierPathWithRoundedRect:frame
				   xRadius:roundedRadius
				   yRadius:roundedRadius] setClip];
  [[color darkenColorByValue:0.12f] setFill];
  NSRectFillUsingOperation(frame, NSCompositeSourceOver);
  [ctx restoreGraphicsState];

  // If we are highlighted, then done
  if([self isHighlighted:i j:j]) {
    return;
  }
    
  // Draw a lighter rounded rect inside
  [ctx saveGraphicsState];
        
  // Make a rounded rect
  NSBezierPath* path = [NSBezierPath bezierPath];
  [path appendBezierPathWithRoundedRect:NSInsetRect(frame, 1.0, 1.0)
				xRadius:roundedRadius
				yRadius:roundedRadius];
    
  // Make a gradient
  NSColor *light = [color lightenColorByValue:0.2f];
  NSGradient* grad = [[NSGradient alloc] initWithColorsAndLocations:
					   light, 0.0f,
					 color, 1.0f,
					 nil];
  // Draw the gradient from bottom to top inside the circle
  [grad drawInBezierPath:path angle:90.0];

  // Restore the context to what it was before we messed with it
  [ctx restoreGraphicsState];

}

- (void) drawAccelerator:(int)i j:(int)j
{

  NSRect rect = [self rectForCell:i j:j];
  int idx = [self indexForCell:i j:j];
  NSString *accel = [_accel substringWithRange:NSMakeRange(idx, 1)];

  // NSDictionary *attributes = nil;
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:_accelFont,
					   NSFontAttributeName,
					   _accelColor,
					   NSForegroundColorAttributeName,
					   nil];

  NSSize size = [accel sizeWithAttributes:attributes];
  NSPoint where = NSMakePoint(rect.origin.x + 3,
			      rect.origin.y + rect.size.height - size.height);
  // [self drawText:accel centeredAtPoint:rect.origin withAttributes:nil];
  [accel drawAtPoint:where withAttributes:attributes];
}

- (void) drawLabel:(int)i j:(int)j
{

  NSRect rect = [self rectForCell:i j:j];
  int idx = [self indexForCell:i j:j];
  NSString *label = _labels[idx];

  if (label == nil)
    return;

  // NSDictionary *attributes = nil;
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:_labelFont,
					   NSFontAttributeName,
					   _labelColor,
					   NSForegroundColorAttributeName,
					   nil];

  // NSSize size = [label sizeWithAttributes:attributes];
  NSPoint where = NSMakePoint(NSMidX(rect), NSMidY(rect));
  [self drawText:label centeredAtPoint:where withAttributes:attributes];
}

- (void) drawRect:(NSRect)rect {

  // Get the graphics context that we are currently executing under
  NSGraphicsContext* ctx = [NSGraphicsContext currentContext];

  double roundedRadius = 3.0;

  // Draw background - use inset to allow view of focus ring
  [ctx saveGraphicsState];

  // TOM: 202309-16 was rect, change to self.bounds to avoid artifact
  [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 1.0f, 1.0f)
				   xRadius:roundedRadius
				   yRadius:roundedRadius] setClip];
  [_bgColor setFill];
  NSRectFillUsingOperation(rect, NSCompositeSourceOver);
  [ctx restoreGraphicsState];

  // Draw the rectangles
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
	[self drawCell:i j:j];
      }
  }

  // Draw the focus ring
  if (_isFirstResponder == YES) {
    NSDottedFrameRect(NSInsetRect(rect, 10.0f, 10.0f));
  }

  // Draw the accelerators
  [ctx saveGraphicsState];
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
	[self drawAccelerator:i j:j];
      }
  }
  [ctx restoreGraphicsState];

  // Draw the labels
  [ctx saveGraphicsState];
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
	[self drawLabel:i j:j];
      }
  }
  [ctx restoreGraphicsState];

}


- (void) drawText:(NSString*)txt centeredAtPoint:(NSPoint)point withAttributes:(NSDictionary*)attributes
{
  NSSize size = [txt sizeWithAttributes:attributes];
  [txt drawAtPoint:NSMakePoint(point.x - (size.width/2.0), point.y - (size.height/2.0))
    withAttributes:attributes];

}

- (void) drawText:(NSString*)txt horizontallyCenteredAtPoint:(NSPoint)point withAttributes:(NSDictionary*)attributes
{
  NSSize size = [txt sizeWithAttributes:attributes];
  [txt drawAtPoint:NSMakePoint(point.x - (size.width/2.0), point.y)
    withAttributes:attributes];

}

//
// MOUSE Handling
//

- (void) mouseDown:(NSEvent*)event
{
  NSPoint point = [self convertPoint:[event locationInWindow]
			    fromView:nil];
  _lastMouseDownEvent = event;
  
  float x = point.x;
  float y = point.y;

  int i = x / _xwid;
  int j = y / _ywid;

  int index = [self indexForCell:i j:j];

  // drag tracking
  _lastIndex = index;

  // state update and notifications
  _state[index] = YES;
  [self sendNoteOn:index vel:_velocity];
  [self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent*)event
{
  NSPoint point = [self convertPoint:[event locationInWindow]
			    fromView:nil];

  double x = point.x;
  double y = point.y;

  int i = x / _xwid;
  int j = y / _ywid;

  int index = [self indexForCell:i j:j];

  if (_lastIndex != -1) {
    if (index == -1) {
      _state[_lastIndex] = NO;
      [self sendNoteOff:_lastIndex vel:0];

      _lastIndex = -1;
    }
    else if (index != _lastIndex) {
      _state[_lastIndex] = NO;
      [self sendNoteOff:_lastIndex vel:0];
      
      _state[index] = YES;
      [self sendNoteOn:index vel:_velocity];
      _lastIndex = index;
    }
  }
  else {
    // see if we got dragged back in
    if (index != -1) {
      _state[index] = YES;
      [self sendNoteOn:index vel:_velocity];
      _lastIndex = index;
    }
  }

  [self setNeedsDisplay:YES];
}
  
- (void) mouseUp:(NSEvent*)event
{
  // this mouse up cancels the last mouse Down
  if (_lastIndex != -1) {
    _state[_lastIndex] = NO;
    [self sendNoteOff:_lastIndex vel:0];
    _lastIndex = -1;
  }
  [self setNeedsDisplay:YES];

}

- (BOOL) performKeyDown:(NSEvent*)ev
{
  NSString *characters = [ev characters];
  int i, length = [characters length];
  BOOL handled = NO;

  int celli, cellj;

  for (i = 0; i < length; i++)
    {
      char keychar = [characters characterAtIndex: i];

      // consider everything except navigation handled to silence NSBeep
      if (keychar != NSTabCharacter && keychar != NSBackTabCharacter)
	handled = YES;

      for (int a = 0; a < 16; a++) {
	char accel = [_accel characterAtIndex:a];
	if (accel == keychar) {
	  celli = a % 4;
	  cellj = a / 4;

	  [self setHighlighted:celli j:cellj val:YES];
	  [self setNeedsDisplay:YES];
	  int index = [self indexForCell:celli j:cellj];
	  if (index != -1) {
	    [self sendNoteOn:index vel:_velocity];
	  }
	}
      }
    }

  return handled;
}

- (BOOL) performKeyUp:(NSEvent*)ev
{
  NSString *characters = [ev characters];
  int i, length = [characters length];
  BOOL handled = NO;

  int celli, cellj;

  for (i = 0; i < length; i++)
    {
      char keychar = [characters characterAtIndex: i];

      // consider everything except navigation handled to silence NSBeep
      if (keychar != NSTabCharacter && keychar != NSBackTabCharacter)
	handled = YES;


      for (int a = 0; a < 16; a++) {
	char accel = [_accel characterAtIndex:a];
	if (accel == keychar) {
	  celli = a % 4;
	  cellj = a / 4;

	  [self setHighlighted:celli j:cellj val:NO];
	  [self setNeedsDisplay:YES];
	  int index = [self indexForCell:celli j:cellj];
	  if (index != -1) {
	    [self sendNoteOff:index vel:0];
	  }
	}
      }
    }

  return handled;
}

//
// Event IN methods
//

- (int) indexForMidiNote:(NSInteger)midiNote
{
  if (midiNote < 0)
    return -1;

  int length = [_midiMap count];
  int index = -1;
  for (int i = 0; i < length; i++)
    {
      NSNumber *mapNum = _midiMap[i];
      if (mapNum != nil) {
	int mapVal = [mapNum integerValue];
	if (mapVal == midiNote) {
	  index = i;
	  break;
	}
      }
    }
  NSLog(@"found midiNote:%ld in position:%d", midiNote, index);
  return index;
      
    
}

- (void) padNoteOn:(unsigned)midiNote vel:(unsigned)vel
{
  (void) vel; // ignored for now

  int index = [self indexForMidiNote:midiNote];
  
  if (index < 0 || index > 15)
    return;

  _state[index] = YES;
  [self setNeedsDisplay:YES];
}

- (void) padNoteOff:(unsigned)midiNote vel:(unsigned)vel
{
  (void) vel; // ignored for now

  int index = [self indexForMidiNote:midiNote];

  if (index < 0 || index > 15)
    return;

  _state[index] = NO;
  [self setNeedsDisplay:YES];
}

//
// Event OUT methods
//   Note: we know that performSelector can cause a leak and turn off those warnings
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void) sendNoteOn:(unsigned)index vel:(unsigned)vel
{
  NSNumber *midiNum = _midiMap[index];
  if (midiNum == nil)
    return;
  
  int midiNote = [midiNum integerValue];

  if (_target != nil) {
    if ([_target respondsToSelector:_noteOnSelector] == YES) {
      [_target performSelector:_noteOnSelector withObject:@(midiNote) withObject:@(vel)];
    }
  }
}

- (void) sendNoteOff:(unsigned)index vel:(unsigned)vel
{
  NSNumber *midiNum = _midiMap[index];
  if (midiNum == nil)
    return;
  
  int midiNote = [midiNum integerValue];

  if (_target != nil) {
    if ([_target respondsToSelector:_noteOffSelector] == YES) {
      [_target performSelector:_noteOffSelector withObject:@(midiNote) withObject:@(vel)];
    }
  }
}

#pragma clang diagnostic pop
- (void) dealloc {
}

@end
