/*
 * Implementation of Gauge
 *
 * McLaren Labs 2019, 2023
 */

#import "MLGauge.h"
#import "NSColor+ColorExtensions.h"

@implementation MLGauge {
  @protected
  double _buttondown_progress;
  BOOL _button_pressed;
  float _button_x;
  float _button_y;
  BOOL _isFirstResponder;

}

- (id) initWithFrame:(NSRect)frame {
  if (self = [super initWithFrame:frame]) {
    _button_pressed = NO;
    _button_x = 0;
    _button_y = 0;
    _isFirstResponder = NO;

    _color = [[NSColor mcOrangeColor] darkenColorByValue:0.12];

    _userProgress = 0.0;

    _ticks = 5;
    _tick_ylo = 0;
    _tick_yhi = 3;

    _font = [NSFont userFontOfSize:20.0];
    _format = @"%g";
    _legendFont = [NSFont userFontOfSize:10.0];
    _legend = nil;
    _isDot = NO;

    // [self enableMotion];
    // [self enableButton];
    // [self enableScroll];
    // [self enableKey];

  }
  return self;
}

- (void) drawArc:(NSRect)rect {
  
  // float width = rect.size.width;
  // float height = rect.size.height;

  NSColor *color = _color;

  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];

  NSBezierPath *path = [NSBezierPath bezierPath];
  [path appendBezierPathWithArcWithCenter:NSMakePoint(_centerx, _centery)
				   radius:_radius
			       startAngle:_degStart
				 endAngle:_degEnd
				clockwise:YES];

  if (_button_pressed) {
    [[color darkenColorByValue:0.12f] set];
  }
  else {
    [[color darkenColorByValue:0.24f] set];
  }
  
  [path setLineWidth: _arcWidth];
  [path setLineCapStyle: NSLineCapStyleRound];
  [path stroke];

  [ctx restoreGraphicsState];
}

/*
 * Utility: convert user coordinate to degrees.
 * User value is between userStart, userEnd.
 */

- (double) user2deg:(double)user {

  double ratio = (user - _userStart) / (_userEnd - _userStart);
  double rad = _degStart + ratio * (_degEnd - _degStart);
  return rad;
}
    

- (void) drawProgressArc:(NSRect)rect progress:(double)progress {
  //float width = rect.size.width;
  //float height = rect.size.height;

  NSColor *color = _color;

  double degprogress = [self user2deg:progress];

  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];

  NSBezierPath *path = [NSBezierPath bezierPath];
  if (_isDot == YES) {
    [path appendBezierPathWithArcWithCenter:NSMakePoint(_centerx, _centery)
				     radius:_radius
				 startAngle:degprogress+1
				   endAngle:degprogress
				  clockwise:YES];
  }
  else {
    [path appendBezierPathWithArcWithCenter:NSMakePoint(_centerx, _centery)
				     radius:_radius
				 startAngle:_degStart+0.5 // TOM: tiny amount
				   endAngle:degprogress
				  clockwise:YES];
  }


  if (_button_pressed) {
    [[color lightenColorByValue:0.12f] set];
  }
  else {
    [[color lightenColorByValue:0.0f] set];
  }

  [path setLineWidth: _arcWidth-4];
  [path setLineCapStyle: NSLineCapStyleRound];
  [path stroke];

  [ctx restoreGraphicsState];

}

- (void) atUser:(double)user {

  double deg = [self user2deg:user];
  double rad = (deg / 180.0) * M_PI;
  NSAffineTransform *translate = [NSAffineTransform transform];

  [translate translateXBy:_centerx yBy:_centery];

  [translate translateXBy:cos(rad)*_radius yBy:sin(rad)*_radius];

  [translate rotateByDegrees:90+deg];

  [translate concat];

}

- (void) littleOrigin {


  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];

  NSBezierPath *path = [NSBezierPath bezierPath];
  
  [path moveToPoint:NSMakePoint(0, -5)];
  [path lineToPoint:NSMakePoint(0, 5)];

  [path moveToPoint:NSMakePoint(-10, 0)];
  [path lineToPoint:NSMakePoint(10, 0)];

  [path stroke];

  [ctx restoreGraphicsState];
}

- (void) insideTick {

  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];

  NSAffineTransform *translate = [NSAffineTransform transform];
  [translate translateXBy:0 yBy:_arcWidth/2.0];
  [translate concat];

  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint:NSMakePoint(0, 5)];
  [path lineToPoint:NSMakePoint(0, 3)];
  [path stroke];

  [ctx restoreGraphicsState];
}

- (void) insideTickYLo:(double)ylo yhi:(double)yhi {

  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];

  NSAffineTransform *translate = [NSAffineTransform transform];
  [translate translateXBy:0 yBy:_arcWidth/2.0];
  [translate concat];

  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint:NSMakePoint(0, ylo)];
  [path lineToPoint:NSMakePoint(0, yhi)];
  [path stroke];

  [ctx restoreGraphicsState];
}

- (void) drawTicks {

  if (_ticks == 0)
    return;
  
  double user = _userStart;
  double incr = (_userEnd - _userStart) / _ticks;
  
  for (int i = 0; i < _ticks+1; i++) {
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    [ctx saveGraphicsState];
    
    [self atUser:user];
    [self insideTickYLo:_tick_ylo yhi:_tick_yhi];

    [ctx restoreGraphicsState];

    user += incr;				      // move to next spot
  }

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

- (void) drawRect:(NSRect)rect {

  // float width = rect.size.width;
  // float height = rect.size.height;

  NSColor *color = [NSColor blueColor];
  [color set];

  [self drawArc:rect];
  [self drawProgressArc:rect progress:_userProgress];
  [self drawTicks];

  if (_isFirstResponder == YES) {
    NSDottedFrameRect(rect);
  }

  NSDictionary *attributes = @{
  NSFontAttributeName: _font,
  };

  NSString *txt = [NSString stringWithFormat:_format, _userProgress];
  [self drawText:txt
	centeredAtPoint:NSMakePoint(_centerx, _centery)
	withAttributes:attributes];

  NSDictionary *legendAttributes = @{
  NSFontAttributeName: _legendFont
  };

  if (_legend != nil) {
    [self drawText:_legend 
	  horizontallyCenteredAtPoint:NSMakePoint(_centerx, _centery-_radius)
	  withAttributes:legendAttributes];
  }

}

- (void) mouseDown:(NSEvent*)event
{
  NSPoint point = [self convertPoint:[event locationInWindow]
			    fromView:nil];
  double x = point.x;
  double y = point.y;
  
  _buttondown_progress = _userProgress;
  _button_pressed = YES;
  _button_x = x;
  _button_y = y;

  [self setNeedsDisplay:YES];
}

- (void) mouseUp:(NSEvent*)event
{
  _button_pressed = NO;
  [self setNeedsDisplay:YES];
  [self notify];
}

- (void) mouseDragged:(NSEvent*)event
{
  NSPoint point = [self convertPoint:[event locationInWindow]
			    fromView:nil];

  // double x = point.x;
  double y = point.y;
  
  if (_button_pressed) {
    double amount = (y - _button_y) * (_userStart - _userEnd) / 100.0;

    _userProgress = _buttondown_progress - amount;

    // TOM: 2019-11-01 - snap to nearest _findadj
    _userProgress = round(_userProgress / _fineAdj) * _fineAdj;

    if (_userProgress < _userStart)
      _userProgress = _userStart;

    if (_userProgress > _userEnd)
      _userProgress = _userEnd;

    [self setNeedsDisplay:YES];
    [self notify];
  }
}

- (void) scrollWheel:(NSEvent*)event {

  if (event.type == NSScrollWheel) {
    // NSLog(@"scrollWheel:%@ %ld %g", event, event.buttonNumber, event.deltaY);

    if (event.buttonNumber == 5) {
      _userProgress += _fineAdj;
 
      // TOM: 2019-11-01
      _userProgress = round(_userProgress / _fineAdj) * _fineAdj;

      if (_userProgress > _userEnd)
	_userProgress = _userEnd;
     }

    if (event.buttonNumber == 4) {
      _userProgress -= _fineAdj;

      // TOM: 2019-11-01
      _userProgress = round(_userProgress / _fineAdj) * _fineAdj;

      if (_userProgress < _userStart)
	_userProgress = _userStart;
    }
    
    [self setNeedsDisplay:YES];
    [self notify];
  }
}

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



- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent { return YES; }

// allow keypress events

- (BOOL) acceptsFirstResponder {  return YES; }
- (BOOL)canBecomeKeyView { return YES; }

- (void) keyDown: (NSEvent *)ev
{
  NSString *characters = [ev characters];
  int i, length = [characters length];
  double value = _userProgress;
  double min = _userStart;
  double max = _userEnd;
  NSUInteger alt_down = ([ev modifierFlags] & NSAlternateKeyMask); // RIGHT-OPT
  BOOL valueChanged = NO;
  double diff;

  if (alt_down)
    {
      diff = _coarseAdj;
    }
  else
    {
      diff = _fineAdj;
    }
  
  for (i = 0; i < length; i++)
    {
      switch ([characters characterAtIndex: i])
        {
	   case NSLeftArrowFunctionKey:
	   case NSDownArrowFunctionKey:
		value -= diff;
		valueChanged = YES;
	     break;
	   case NSUpArrowFunctionKey:
	   case NSRightArrowFunctionKey:
	        value += diff;
		valueChanged = YES;
	     break;
	   case NSPageDownFunctionKey:
		value -= diff * 2;
		valueChanged = YES;
	     break;
	   case NSPageUpFunctionKey:
		value += diff * 2;
		valueChanged = YES;
	     break;
	   case NSHomeFunctionKey:
		value = min;
		valueChanged = YES;
	     break;
	   case NSEndFunctionKey:
		value = max;
		valueChanged = YES;
	     break;
        }
    }
  
  if (valueChanged)
    {
      if (value < min)
	{ 
	  value = min;
	}
      else if (value > max)
	{
	  value = max;
	}
      
      [self setValue: value];
      return;
    }

  [super keyDown: ev];
}

- (void) setValue:(double) value {
  
  _userProgress = value;

  if (_userProgress > _userEnd)
    _userProgress = _userEnd;

  if (_userProgress < _userStart)
    _userProgress = _userStart;

  [self setNeedsDisplay:YES];
}

- (double) value {
  return _userProgress;
}

/*
 * To be used internally to notify the onValueChanged handler
 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void) notify
{
  if (_target != nil) {
    if ([_target respondsToSelector:_action] == YES) {
      [_target performSelector:_action withObject:self];
    }
  }
}

//
// USER: Register Callbacks
//

- (void) onChange:(SEL)sel target:(id)target {
  _target = target;
  _action = sel;
}

- (void) onChange:(id)block {
  [self onChange:@selector(value:) target:block];
}
  

#pragma clang diagnostic pop

- (void) dealloc {
}

@end
