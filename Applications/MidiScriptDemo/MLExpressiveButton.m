#import "MLExpressiveButton.h"
#import "NSColor+ColorExtensions.h"

@implementation MLExpressiveButton {
  NSPoint mouseDownPoint;
  NSEvent *lastKeyUp; // the pending key up
  NSEvent *lastLastKeyUp; // the prior pending key up
  NSTimer *timer;
}

+ (Class) cellClass {
  return [MLExpressiveButtonCell class];
}

- (MLExpressiveButtonCell*) cell {
  return _cell;
}

- (id) initWithFrame:(NSRect)frame {
  if (self = [super initWithFrame:frame]) {

    // note On/Off protocol
    _midiNote = 0;
    _velocity = 127;
    _noteOnSelector = @selector(butNoteOn:vel:);
    _noteOffSelector = @selector(butNoteOff:vel:);
    _keyPressureSelector = @selector(butKeyPressure:vel:);
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05
					     target:self
					   selector:@selector(timer)
					   userInfo:nil
					    repeats:YES];

  }
  return self;
}

/*
 * TOM: 2023-09-05 added the following three events to capture
 * mouse and drags. What I notice is that this holds onto the mouse
 * and the button stays highlighted until done dragging.  Without it,
 * the button un-hilights as the mouse leaves the button.
 */
- (void) mouseDown:(NSEvent*)event
{
  mouseDownPoint = [event locationInWindow];
  [self highlight:YES]; // set on mouseDown, will be released on performClick:
  [self sendNoteOn:_midiNote vel:_velocity];
  [self setNeedsDisplay:YES];

}

/*
 * Translate mouse drag events into Aftertouch (Key Pressure) events.
 */

- (void) mouseDragged:(NSEvent*)event
{
  // NSLog(@"mouseDragged:%@", event);
  NSPoint loc = [event locationInWindow];

  double distx = loc.x - mouseDownPoint.x;
  double disty = loc.y - mouseDownPoint.y;
  double distance = sqrt((distx * distx) + (disty * disty));

  if (distance > 127)
    distance = 127;

  unsigned udistance = distance;

  [self sendKeyPressure:_midiNote vel:udistance];
  
}

- (void) mouseUp:(NSEvent*)event
{
  // [self performClick:self]; // this is default Cocoa behavior
  [self highlight:NO];
  [self sendNoteOff:_midiNote vel:0];
  [self setNeedsDisplay:YES];
}

/*
 * These are the de-repeated keyDown and keyUp methods
 */

- (void) performKeyDown: (NSEvent*)theEvent
{
  // NSLog(@"%@", theEvent);
  if ([self isEnabled])
    {
      NSString *characters = [theEvent characters];

      /* Handle SPACE to perform a click */
      if ([characters isEqualToString: @" "])
        {
	  [self highlight:YES];
	  [self sendNoteOn:_midiNote vel:_velocity];
	  [self setNeedsDisplay:YES];
          return;
        }
    }

  [super keyDown: theEvent];
}

- (void) performKeyUp: (NSEvent*)theEvent
{

    if ([self isEnabled])
    {
      NSString *characters = [theEvent characters];

      /* Handle SPACE to perform a click */
      if ([characters isEqualToString: @" "])
        {
	  [self highlight:NO];
	  [self sendNoteOff:_midiNote vel:0];
	  [self setNeedsDisplay:YES];
          return;
        }
    }

  [super keyUp: theEvent];
}

/*
 * De-Repeatizing the key events:
 *
 * The keyDown: and keyUp: methods are used with the timer: method
 * to recognize repeated keypress events.  When the XServer begins a key
 * repeat sequence, the keyUp following the keyDown have the same timestamp.
 * We can recognize a generated keyUp/keyDown sequence by this fact.
 *
 * Recognizing the last keyUp event requires the timer.  We keep track
 * of the previous keyUp event at each tick in the timer.  If two ticks
 * see the same keyUp (without it being erased by an intervening keyDown)
 * then the timer considers it the end of the repeating sequence and 
 * emits the final keyUp.
 *
 * The un-repeated keyDown and keyUp evens are dispatched through performKeyDown:
 * and performKeyUp:.
 */

- (void) keyDown: (NSEvent*)theEvent
{
  // NSLog(@"keyDown:%@", theEvent);

  // if there is a queued keyUp event
  if (lastKeyUp != nil) {
    // see if it is cancelled by this event because it is a repeat
    if (([lastKeyUp keyCode] == [theEvent keyCode]) &&
	([lastKeyUp timestamp] == [theEvent timestamp])) {
      // NSLog(@"cancelling");
      lastKeyUp = nil; // cancel the keyUp, do nothing with this keyDown
      // return;
    }
    else {
      // this is not a repeat, so perform the queued event and this one
      // NSLog(@"%@", lastKeyUp);
      [self performKeyUp:lastKeyUp];
      lastKeyUp = nil;

      // and perform this one
      [self performKeyDown:theEvent];
    }
  }
  else {
    // just perform the keyDown event
    // NSLog(@"%@", theEvent);
    [self performKeyDown:theEvent];
  }

}

- (void) keyUp: (NSEvent*)theEvent
{
  // NSLog(@"%@", theEvent);

  // if there is a pending keyUp, then perform it
  if (lastKeyUp != nil) {
    // then perform a key up and make this one pending
    // NSLog(@"%@", lastKeyUp);
    [self performKeyUp:lastKeyUp];
    // return;
  }

  // always queue this one, regardless
  lastKeyUp = theEvent;

}

- (void) timer {

  // if there is a queued keyUp event
  if (lastKeyUp != nil) {
    // if there are two queued keyUp events and they are the same
    if (lastKeyUp == lastLastKeyUp) {
      // NSLog(@"%@", lastKeyUp);
      [self performKeyUp:lastKeyUp];
      lastKeyUp = nil;
      lastLastKeyUp = nil;
    }
  }

  lastLastKeyUp = lastKeyUp;


}

//
// Event IN methods
//

- (void) butNoteOn:(unsigned)midiNote vel:(unsigned)vel
{
  (void) vel; // ignored for now

  if (midiNote != _midiNote)
    return;

  [self highlight:YES];
  [self setNeedsDisplay:YES];
}

- (void) butNoteOff:(unsigned)midiNote vel:(unsigned)vel
{
  (void) vel; // ignored for now

  if (midiNote != _midiNote)
    return;

  [self highlight:NO];
  [self setNeedsDisplay:YES];
}

//
// Event OUT methods
//   Note: we know that performSelector can cause a leak and turn off those warnings
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void) sendNoteOn:(unsigned)midiNote vel:(unsigned)vel
{
  if (_target != nil) {
    if ([_target respondsToSelector:_noteOnSelector] == YES) {
      [_target performSelector:_noteOnSelector withObject:@(midiNote) withObject:@(vel)];
    }
  }
}

- (void) sendNoteOff:(unsigned)midiNote vel:(unsigned)vel
{
  if (_target != nil) {
    if ([_target respondsToSelector:_noteOffSelector] == YES) {
      [_target performSelector:_noteOffSelector withObject:@(midiNote) withObject:@(vel)];
    }
  }
}

- (void) sendKeyPressure:(unsigned)midiNote vel:(unsigned)vel
{
  // NS_DURING
  if (_target != nil) {
    if ([_target respondsToSelector:_keyPressureSelector] == YES) {
      [_target performSelector:_keyPressureSelector withObject:@(midiNote) withObject:@(vel)];
    }
  }
  // NS_HANDLER
  //   NSLog(@"Exc:%@", localException);
  // NS_ENDHANDLER
}

#pragma clang diagnostic pop

@end



@implementation MLExpressiveButtonCell

- (id) init {
  self = [super init];
  
  if (self) {
    [self setContinuous:NO];
    self.color = [NSColor mcBlueColor];
  }
  return self;
}  

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    
  float roundedRadius = 3.0;
    
  // Get the graphics context that we are currently executing under
  NSGraphicsContext* gc = [NSGraphicsContext currentContext];

  // Draw darker overlay out to corner of button
  [gc saveGraphicsState];
  [[NSBezierPath bezierPathWithRoundedRect:frame
				   xRadius:roundedRadius
				   yRadius:roundedRadius] setClip];
  [[_color darkenColorByValue:0.12f] setFill];
  NSRectFillUsingOperation(frame, NSCompositeSourceOver);
  [gc restoreGraphicsState];

  // If we are highlighted, then done
  if([self isHighlighted]) {
    return;
  }
    
  // Draw a lighter rounded rect inside
  [gc saveGraphicsState];
        
  // Make a rounded rect
  NSBezierPath* path = [NSBezierPath bezierPath];
  [path appendBezierPathWithRoundedRect:NSInsetRect(frame, 1.0, 1.0)
				xRadius:roundedRadius
				yRadius:roundedRadius];
    
  // Make a gradient
  NSColor *light = [self.color lightenColorByValue:0.2f];
  NSGradient* grad = [[NSGradient alloc] initWithColorsAndLocations:
					   light, 0.0f,
					 self.color, 1.0f,
					 nil];

  // Draw the gradient from bottom to top inside the circle
  @try {
    [grad drawInBezierPath:path angle:90.0];
  }
  @catch (NSException *e) {
    // workaround for ART backend
    [light setFill];
    [path fill];
  }    

  // Restore the context to what it was before we messed with it
  [gc restoreGraphicsState];

}

- (NSRect) drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSGraphicsContext* ctx = [NSGraphicsContext currentContext];
    
    // Save the graphics state
    [ctx saveGraphicsState];
    NSMutableAttributedString *attrString = [title mutableCopy];
    [attrString beginEditing];
    NSColor *titleColor;
    if ([self.color isLightColor]) {
        titleColor = [NSColor blackColor];
    } else {
        titleColor = [NSColor whiteColor];
    }
    
    [attrString addAttribute:NSForegroundColorAttributeName value:titleColor range:NSMakeRange(0, [[self title] length])];
    [attrString endEditing];
    NSRect r = [super drawTitle:attrString withFrame:frame inView:controlView];

    // Restore the graphics state
    [ctx restoreGraphicsState];
    
    return r;
}

@end
