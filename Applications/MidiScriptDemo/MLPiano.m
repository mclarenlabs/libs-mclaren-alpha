/**  -*- mode: objc -*-
 *
 * Implementation of Piano keyboard
 *
 * Mclaren Labs 2023
 */

#import "MLPiano.h"
#import "NSColor+ColorExtensions.h"

// MIDI num for C0, C1, C2, C3, C4(middleC)=60
static int cnoteForOctave[] = {12, 24, 36, 48, 60, 72, 84, 96, 108, 120 };


#define MIDIMAX 128

@implementation MLPiano {
  BOOL _midiState[MIDIMAX];

  // tracking mouse down/up
  NSEvent *_lastMouseDownEvent;
  int _lastMidiNote;
}


- (id) initWithFrame:(NSRect)frame
{
  if (self = [super initWithFrame:frame]) {

    for (int i = 0; i < MIDIMAX; i++) {
      _midiState[i] = NO;
    }

    _accel = @"awsedftgyhujkolp;'";
    _accelFont = [NSFont userFontOfSize:11];

    // down/drag/up tracking
    _lastMidiNote = -1;

    _isFirstResponder = NO;

    // properties
    _bgColor = [NSColor darkGrayColor];

    _ww = 40;
    _wh = 100;
    _wc = [NSColor colorWithDeviceRed:0.9
				green:0.9
				 blue:1.0
				alpha:1.0];
    _bw = 35;
    _bh = 60;
    _bc = [NSColor colorWithDeviceRed:0.4
				green:0.4
				 blue:0.4
				alpha:1.0];

    // one and a half octaves
    _totalWholeNotes = 10;

    // default MIDI mapping
    _octave = 4; // middle C

    // fixed velocity for ow
    _velocity = 127;

    [self littleMidiTest];

    // default OUT protocol
    _noteOnSelector = @selector(pianoNoteOn:vel:);
    _noteOffSelector = @selector(pianoNoteOff:vel:);
  }
  return self;
}

// State Management (highlighted=DOWN)

- (BOOL) isWhiteHighlighted:(int)idx
{
  int midiNote = [self midiNoteForIndex:idx isBlack:NO];
  return _midiState[midiNote];
}

- (void) setWhiteHighlighted:(int)idx val:(BOOL)val
{
  int midiNote = [self midiNoteForIndex:idx isBlack:NO];
  _midiState[midiNote] = val;
}


- (BOOL) isBlackHighlighted:(int)idx
{
  int midiNote = [self midiNoteForIndex:idx isBlack:YES];
  return _midiState[midiNote];
}

- (void) setBlackHighlighted:(int)idx val:(BOOL)val
{
  int midiNote = [self midiNoteForIndex:idx isBlack:YES];
  _midiState[midiNote] = val;
}

// Drawing Coordinates

- (NSRect) whiteCoords:(int)i
{
  return NSMakeRect(_ww * i, 0, _ww, _wh);
}

- (NSRect) blackCoords:(int)i
{
  return NSMakeRect((_ww * (i +1)) - (_bw / 2.0),
		    _wh - _bh,
		    _bw, _bh);
}

// given relative mouse coords, is this a Black key?
- (BOOL) isBlackKey:(int)x y:(int)y index:(int*)index
{
  if ((y < 0) || (y > _wh))
    return NO;
  
  BOOL yIsInBlackRange = ((y >= (_wh-_bh)) && (y <= _wh));
  if (yIsInBlackRange == NO)
    return NO;

  // determine key index
  int i = trunc((x - (_bw/2.0)) / _ww);

  BOOL xIsInBlackRange = ((x <= ((_ww * (i+1)) + (_bw/2.0))) &&
			  (x >= ((_ww * (i+1)) - (_bw/2.0))));

  if ((xIsInBlackRange == YES) &&
      ((i != 2) && (i != 6) &&
       (i != 9) && (i != 13) &&
       (i != 16) && (i != 20) &&
       (i != 23) && (i != 27) &&
       (i != 30) && (i != 34) &&
       (i != 37) && (i != 41) &&
       (i != 44) && (i != 48)
       ))
      
    {
      *index = i;
      return YES;
    }
  else
    return NO;
}

// given relative mouse coords, is this a White key?
- (BOOL) isWhiteKey:(int)x y:(int)y index:(int*)index
{
  if ((y < 0) || (y > _wh))
    return NO;
  
  // determine key index
  int i = trunc(x / _ww);
  *index = i;
  return YES;
}

- (void) drawAccelerators:(NSRect)rect
{
  int baseNote = cnoteForOctave[_octave];
  int accelLength = [_accel length];
  for (int a = 0; a < accelLength; a++) {
    NSString *accel = [_accel substringWithRange:NSMakeRange(a, 1)];
    int midiNote = baseNote + a;
    int isBlack;
    int index = [self indexForMidiNote:midiNote isBlack:&isBlack];

    // NSDictionary *attributes = nil;
    NSDictionary *whiteKeyAttributes = @{
    NSFontAttributeName: _accelFont, 
    NSForegroundColorAttributeName : [NSColor darkGrayColor]
    };

    NSDictionary *blackKeyAttributes = @{
    NSFontAttributeName : _accelFont,
    NSForegroundColorAttributeName : [NSColor whiteColor]
    };

    if (isBlack == NO) {
      NSRect coords = [self whiteCoords:index];
      NSPoint where = NSMakePoint(coords.origin.x + 3,
				  coords.origin.y + 3);
      [accel drawAtPoint:where withAttributes:whiteKeyAttributes];
      
    }
    else {
      NSRect coords = [self blackCoords:index];
      
      NSPoint where = NSMakePoint(coords.origin.x + 3,
				  coords.origin.y + 3);
      [accel drawAtPoint:where withAttributes:blackKeyAttributes];
      
    }
  }
}
		    

- (void) drawRect:(NSRect)rect {

  double roundedRadius = 3.0;

  // Get the graphics context that we are currently executing under
  NSGraphicsContext* ctx = [NSGraphicsContext currentContext];

  // Draw background - use inset to allow view of focus ring
  [ctx saveGraphicsState];

  // TOM: 202309-16 was rect, change to self.bounds to avoid artifact
  [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 1.0f, 1.0f)
				   xRadius:roundedRadius
				   yRadius:roundedRadius] setClip];
  [_bgColor setFill];
  NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
  [ctx restoreGraphicsState];

  // Draw the white keys
  for (int i = 0; i < _totalWholeNotes; i++) {
    NSRect frame = [self whiteCoords:i];

    [ctx saveGraphicsState];
    [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.0f, 2.0f)
				   xRadius:roundedRadius
				   yRadius:roundedRadius] setClip];

    if ([self isWhiteHighlighted:i] == YES) {
      [[_wc darkenColorByValue:0.12f]  setFill];
    }
    else {
      [_wc setFill];
    }

    NSRectFillUsingOperation(frame, NSCompositeSourceOver);
    [ctx restoreGraphicsState];
  }

  // Draw the black keys
  for (int i = 0; i < (_totalWholeNotes-1); i++) {
    if ((i == 2) || (i == 6) ||
	(i == 9) || (i == 13) ||
	(i == 16) || (i == 20) ||
	(i == 23) || (i == 27) ||
	(i == 30) || (i == 34) ||
	(i == 37) || (i == 41))
      continue;

    NSRect rect = [self blackCoords:i];
    [ctx saveGraphicsState];
    [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rect, 1.0f, 1.0f)
				   xRadius:roundedRadius
				   yRadius:roundedRadius] setClip];

    if ([self isBlackHighlighted:i] == YES) {
      [[_bc darkenColorByValue:0.12f] setFill];
    }
    else {
      [_bc setFill];
    }
    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
    [ctx restoreGraphicsState];
  }
  
  // Draw the focus ring
  if (_isFirstResponder == YES) {
    [ctx saveGraphicsState];
    NSDottedFrameRect(NSInsetRect(self.bounds, 4.0f, 4.0f));
    [ctx restoreGraphicsState];
  }

  [self drawAccelerators:rect];

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

  int idx = 0; // which key position
  int midiNote = -1;

  if ([self isBlackKey:x y:y index:&idx] == YES) {
    midiNote = [self midiNoteForIndex:idx isBlack:YES];
  }
  else if ([self isWhiteKey:x y:y index:&idx] == YES) {
    midiNote = [self midiNoteForIndex:idx isBlack:NO];
  }

  // drag tracking
  _lastMidiNote = midiNote;

  // state update and notifications
  _midiState[midiNote] = YES;
  [self sendNoteOn:midiNote vel:_velocity];
  [self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent*)event
{
  NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];

  float x = point.x;
  float y = point.y;

  int idx = 0; // which key position
  int midiNote = -1;

  if ([self isBlackKey:x y:y index:&idx] == YES) {
    midiNote = [self midiNoteForIndex:idx isBlack:YES];
  }
  else if ([self isWhiteKey:x y:y index:&idx] == YES) {
    midiNote = [self midiNoteForIndex:idx isBlack:NO];
  }

  if (_lastMidiNote != -1) {
    if (midiNote == -1) {
      _midiState[_lastMidiNote] = NO;
      [self sendNoteOff:_lastMidiNote vel:0];

      _lastMidiNote = -1;
    }
    else if (midiNote != _lastMidiNote) {
      _midiState[_lastMidiNote] = NO;
      [self sendNoteOff:_lastMidiNote vel:0];
      
      _midiState[midiNote] = YES;
      [self sendNoteOn:midiNote vel:_velocity];
      _lastMidiNote = midiNote;
    }
  }
  else {
    // see if we got dragged back in
    if (midiNote != -1) {
      _midiState[midiNote] = YES;
      [self sendNoteOn:midiNote vel:_velocity];
      _lastMidiNote = midiNote;
    }
  }
      
  [self setNeedsDisplay:YES];
}
  
- (void) mouseUp:(NSEvent*)event
{
  if (_lastMidiNote != -1) {
    _midiState[_lastMidiNote] = NO;
    [self sendNoteOff:_lastMidiNote vel:0];
    _lastMidiNote = -1;
  }

  [self setNeedsDisplay:YES];
  return;
}

//
// KEYBOARD Handling
//  Map character to note and from "accel" array
//

- (BOOL) performKeyDown:(NSEvent*)ev
{
  NSString *characters = [ev characters];
  int i, length = [characters length];
  BOOL handled = NO;

  for (i = 0; i < length; i++)
    {
      char keychar = [characters characterAtIndex: i];

      // consider everything except navigation handled to silence NSBeep
      if (keychar != NSTabCharacter && keychar != NSBackTabCharacter)
	handled = YES;

      int accelLength = [_accel length];
      for (int a = 0; a < accelLength; a++) {
	char accel = [_accel characterAtIndex:a];
	
	if (accel == keychar) {
	  int midiNote = cnoteForOctave[_octave];
	  midiNote += a;
	  _midiState[midiNote] = YES;
	  [self sendNoteOn:midiNote vel:_velocity];
	  [self setNeedsDisplay:YES];
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

  for (i = 0; i < length; i++)
    {
      char keychar = [characters characterAtIndex: i];

      // consider everything except navigation handled to silence NSBeep
      if (keychar != NSTabCharacter && keychar != NSBackTabCharacter)
	handled = YES;

      int accelLength = [_accel length];
      for (int a = 0; a < accelLength; a++) {
	char accel = [_accel characterAtIndex:a];
	
	if (accel == keychar) {
	  int midiNote = cnoteForOctave[_octave];
	  midiNote += a;
	  _midiState[midiNote] = NO;
	  [self sendNoteOff:midiNote vel:0];
	  [self setNeedsDisplay:YES];
	}
      }
    }

  return handled;
}


//
// MIDI Translation from MIDI note to index/isBlack
//   Our visible keyboard starts at "C" with octave given by _octave.
//   Visible keys are numbered by "index" position an black/white status.
//

- (int) midiNoteForIndex:(int)index isBlack:(BOOL)isBlack
{
  int midiNote = cnoteForOctave[_octave];

  while (index >= 7) {
    index -= 7;
    midiNote += 12;
  }

  // now, index is in [0..7)
  static int blackOffsets[] = {1, 3, -1, 6, 8, 10, -1 };
  static int whiteOffsets[] = {0, 2, 4, 5, 7, 9, 11 };

  if (isBlack)
    midiNote += blackOffsets[index];
  else
    midiNote += whiteOffsets[index];

  return midiNote;

}
  
- (int) indexForMidiNote:(int)midiNote isBlack:(int*)isBlack
{
  int octaveNote = cnoteForOctave[_octave];

  int totalSemis = midiNote - octaveNote;
  int index = 0;

  while (totalSemis >= 12) {
    totalSemis -= 12;
    index += 7;
  }

  // Now determine if in first or second half of octave
  if (totalSemis >= 5) {
    // is top 7 semitones
    index += 3; // is at least two whole notes above
    totalSemis -= 5;

    index += trunc(totalSemis / 2.0);
    *isBlack = (totalSemis & 0x1); // is Odd
    return index;
  }
  else {
    // is in bottom 5 semitones
    index += trunc(totalSemis / 2.0);
    *isBlack = (totalSemis & 0x1); // is Odd
    return index;
  }

}

- (void) littleMidiTest
{
  // our little test
  for (int midiNote = 60; midiNote < 75; midiNote++) {
    int isBlack;
    int index = [self indexForMidiNote:midiNote isBlack:&isBlack];
    NSLog(@"midiNote:%d index:%d isBlack:%u", midiNote, index, isBlack);
  }

  return;
}

//
// query method
//

- (int) getNoteState:(NSUInteger)midiNote
{
  return _midiState[midiNote];
}

//
// Event IN methods
//

- (void) pianoNoteOn:(unsigned)midiNote vel:(unsigned)vel
{
  (void) vel; // ignore for now

  if (midiNote < cnoteForOctave[_octave])
    return;

  _midiState[midiNote] = YES;
  [self setNeedsDisplay:YES];
}

- (void) pianoNoteOff:(unsigned)midiNote vel:(unsigned)vel
{
  (void) vel; // ignore for now

  if (midiNote < cnoteForOctave[_octave])
    return;

  _midiState[midiNote] = NO;
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

#pragma clang diagnostic pop
@end
