/** -*- mode:objc -*-
 *
 * A SamplePlayer reads data from an in-memory sample and plays it
 * in a context.
 *
 * McLaren Labs 2024
 *
 */


#import <Foundation/Foundation.h>
#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/sample/MSKSample.h"

@interface MSKSamplePlayer : MSKContextVoice {
  MSKSample *_sample;
}

- (id) initWithCtx:(MSKContext*)c;

@property (readwrite) MSKSample *sample; // the sample data
@property (readonly) int position;	 // which frame is played next

@end
