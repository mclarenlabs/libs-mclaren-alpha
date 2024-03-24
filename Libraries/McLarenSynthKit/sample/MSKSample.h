/** -*- mode:objc -*-
 *
 * A Sample contains an in-memory sound buffer of FLOATs along with
 * certain metadata about the sound.
 *
 */

#import <Foundation/Foundation.h>

@interface MSKSample : NSObject {
  NSData *_data; // the raw data - float - mono or stereo
}

@property (readonly) int frames; // how many frames
@property (readonly) int channels; // how many channels (1 or 2 normally)
@property (readonly) int samplerate;

@property (readonly) NSString *path; // full path
@property (readonly) NSString *basename; // name without extension
@property (readonly) NSString *ext; // extension


- (float*) bytes;
- (float*) frame:(int)n;
- (NSUInteger) capacity;	// max frames capable
- (NSUInteger) length;		// of the NSData

- (id) initWithData:(NSData*)data channels:(int)channels ;
- (id) initWithCapacity:(NSUInteger)numFrames channels:(int)channels;
- (id) initWithFrames:(NSUInteger)numFrames channels:(int)channels;

// read files - using libsndfile
- (id) initWithFilePath:(NSString*)path error:(NSError**)error;

// write to file path - using libsndfile
- (BOOL) writeToFilePath:(NSString*)path error:(NSError**)error;

// resampling - using libresample
- (MSKSample*) resampleBy:(double)ratio;
- (MSKSample*) resampleTo:(double)rate;

// for use by the SampleRecorder only
- (void) recorderSetsFrames:(int)frames;
- (void) recorderSetsSamplerate:(int)samplerate;
- (void) recorderSetsChannels:(int)channels;


@end
