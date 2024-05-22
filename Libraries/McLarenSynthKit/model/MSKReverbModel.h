/** -*- mode:objc -*-
 *
 * A model manages settings for reverb units.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>

@interface MSKReverbModel : NSObject < NSCoding > {
  @public
  int _on;			// reverb on/off
  double _dry;
  double _wet;
  double _roomsize;
  double _damp;
}

// the properties of the model
@property (nonatomic, readwrite) int on;
@property (nonatomic, readwrite) double dry;
@property (nonatomic, readwrite) double wet;
@property (nonatomic, readwrite) double roomsize;
@property (nonatomic, readwrite) double damp;

- (id) init;

@end
