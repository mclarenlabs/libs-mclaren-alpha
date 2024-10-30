#import "MSKSample+additions.h"

@implementation MSKSample(MidiTalk)

+ (MSKSample*) sampleWithName:(NSString*)name {

  MSKSampleManager *mgr = [MSKSampleManager defaultManager];
  NSString *filePath = [mgr sampleWithName:name];
  if (filePath == nil) {
    NSLog(@"MSKSample: could not find sample named:%@", name);
    return nil;
  }

  NSError *err;
  MSKSample *sample = [[MSKSample alloc] initWithFilePath:filePath error:&err];

  if (err != nil) {
    NSLog(@"MSKSample: %@", err);
    return nil;
  }

  return sample;
}


@end
