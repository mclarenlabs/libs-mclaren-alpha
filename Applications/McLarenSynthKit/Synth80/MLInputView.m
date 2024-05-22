/** -*- mode: objc -*-
 *
 * This class provides its derived classes a cleaned-up keyboard
 * input handling suitable for our controls.
 *
 * - first responder managed and flag _isFirstResponder set for children
 * - key input is de-repeatized
 *
 */

#include "MLInputView.h"

@implementation MLInputView {

  // de-repeat handling
  NSEvent *lastKeyUp; // the pending key up
  NSEvent *lastLastKeyUp; // the prior pending key up
  NSTimer *timer;
}

- (id) initWithFrame:(NSRect)frame {
  if (self = [super initWithFrame:frame]) {

    // event handling
    _isFirstResponder = NO;

    // de-repeat handling
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05
					     target:self
					   selector:@selector(timer)
					   userInfo:nil
					    repeats:YES];
  }
  return self;
}

//
// KEY handling
//

- (BOOL) becomeFirstResponder {
  _isFirstResponder = YES;
  [self setNeedsDisplay:YES];
  return YES;
}

- (BOOL) resignFirstResponder {
  _isFirstResponder = NO;
  [self setNeedsDisplay:YES];
  return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
  return YES;
}

// allow keypress events
- (BOOL) acceptsFirstResponder {
  return YES;
}

- (BOOL)canBecomeKeyView {
  return YES;
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
  BOOL handled = YES;
  
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
    handled = [self performKeyDown:theEvent];
  }

  if (handled == NO) {
    // This is a little strange: we assume it is handled, and ignore return values
    // for repeated keys.  By checking the last one and putting this here, we
    // respond correctly for NSTabCharacter.
    [super keyDown:theEvent];
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

- (BOOL) performKeyDown:(NSEvent*)ev
{
  NSLog(@"subclass must implement performKeyDown");
  return NO;
}

- (BOOL) performKeyUp:(NSEvent*)ev
{
  NSLog(@"subclass must implement performKeyUp");
  return NO;
}


@end


