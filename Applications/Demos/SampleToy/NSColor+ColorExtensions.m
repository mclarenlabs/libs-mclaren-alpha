/**
 *
 */

#import "NSColor+ColorExtensions.h"

@implementation NSColor (ColorExtensions)

- (NSColor *)lightenColorByValue:(float)value {
    float red = [self redComponent];
    red += value;
    
    float green = [self greenComponent];
    green += value;
    
    float blue = [self blueComponent];
    blue += value;
    
    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0f];
}

- (NSColor *)darkenColorByValue:(float)value {
    float red = [self redComponent];
    red -= value;
    
    float green = [self greenComponent];
    green -= value;
    
    float blue = [self blueComponent];
    blue -= value;
    
    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0f];
}

- (BOOL)isLightColor {
    NSInteger   totalComponents = [self numberOfComponents];
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat sum;
    
    if (isGreyscale) {
        sum = [self redComponent];
    } else {
        sum = ([self redComponent]+[self greenComponent]+[self blueComponent])/3.0;
    }

    // TOM:
    // return (sum > 0.8);
    return (sum > 0.6);
}

+ (NSColor *) mcBlueColor {
  return [NSColor colorWithCalibratedRed:60.0/255 green:181.0/255
				    blue:223.0/255 alpha:1.00f];
}

+ (NSColor *) mcOrangeColor {
  return [NSColor colorWithCalibratedRed:253.0/255 green:93.0/255
				    blue:61.0/255 alpha:1.00f];
}

+ (NSColor *) mcGreenColor {
  return [NSColor colorWithCalibratedRed:159.0/255 green:210.0/255
				    blue:70.0/255 alpha:1.00f];
}

+ (NSColor *) mcPurpleColor {
  return [NSColor colorWithCalibratedRed:213.0/255 green:58.0/255
				    blue:172.0/255 alpha:1.00f];
}

+ (NSColor *) mcYellowColor {
  return [NSColor colorWithCalibratedRed:248.0/255 green:254.0/255
				    blue:67.0/255 alpha:1.00f];
}

+ (NSColor *) twDefault {
  return [NSColor colorWithCalibratedRed:0.85f green:0.85f blue:0.85f alpha:1.00f];
}

+ (NSColor *) twPrimary {
  return [NSColor colorWithCalibratedRed:0.00f green:0.33f blue:0.80f alpha:1.00f];
}

+ (NSColor *) twInfo {
  return [NSColor colorWithCalibratedRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
}

+ (NSColor *) twSuccess {
  return [NSColor colorWithCalibratedRed:0.32f green:0.64f blue:0.32f alpha:1.00f];
}

+ (NSColor *) twWarning {
  return [NSColor colorWithCalibratedRed:0.97f green:0.58f blue:0.02f alpha:1.00f];
}

+ (NSColor *) twDanger {
  return [NSColor colorWithCalibratedRed:0.74f green:0.21f blue:0.18f alpha:1.00f];
}

+ (NSColor*) twInverse {
  return [NSColor colorWithCalibratedRed:0.13f green:0.13f blue:0.13f alpha:1.00f];
}


@end
