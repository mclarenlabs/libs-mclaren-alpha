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
#import "McLarenSynthKit/model/MSKSampleModel.h"

@implementation MSKSampleModel

//
// NSCoding
//

- (id) initWithCoder:(NSCoder*)coder {
  if (self = [super init]) {
    _sample = [coder decodeObjectForKey:@"sample"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder*)coder {
  [coder encodeObject: _sample forKey:@"sample"];
}



@end
