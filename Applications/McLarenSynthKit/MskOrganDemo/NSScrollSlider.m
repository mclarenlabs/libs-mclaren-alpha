#import "NSScrollSlider.h"

@implementation NSScrollSlider

- (void) scrollWheel:(NSEvent*) e {
  double val = self.doubleValue;
  double delta;
  BOOL only_ticks = [self.cell allowsTickMarkValuesOnly];

  if (only_ticks) {
    double tick0 = [_cell tickMarkValueAtIndex: 0];
    double tick1 = [_cell tickMarkValueAtIndex: 1];
    delta = tick1 - tick0;
  }
  else {
    delta = (self.maxValue - self.minValue) / 25.0;
  }

  if (e.buttonNumber == 5) {
    val -= delta;

    if ([self.cell sliderType] == NSCircularSlider) {
      if (val < self.minValue)
	val = self.maxValue - delta;
    }

    if (only_ticks) {
      val = [_cell closestTickMarkValueToValue: val];
    }
    else {
      if (val < self.minValue) {
	val = self.minValue;
      }
    }
  }

  if (e.buttonNumber == 4) {
    val +=  delta;

    if ([self.cell sliderType] == NSCircularSlider) {
      if (val > self.maxValue)
	val = self.minValue + delta;
    }

    if (only_ticks) {
      val = [_cell closestTickMarkValueToValue: val];
    }
    else {
      if (val > self.maxValue) {
	val = self.maxValue;
      }
    }
  }

  [self setDoubleValue:val];
  [self sendAction: self.action to:self.target];
}

@end
