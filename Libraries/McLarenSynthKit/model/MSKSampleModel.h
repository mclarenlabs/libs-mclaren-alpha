/** -*- mode: objc -*-
 *
 * A Sample Model holds a sample.
 * This model exists to serve as an intermediary between
 *   - a sample controller - that may set the sample
 *   - an audio unit - that uses the sample to render a sound
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/sample/MSKSample.h"

@interface MSKSampleModel : NSObject < NSCoding >
@property (readwrite) MSKSample *sample;
@end

