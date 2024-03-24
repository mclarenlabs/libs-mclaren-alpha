/** -*- mode:objc -*-
 *
 * A Sample Recorder reads from the 'rbuf' of a recording context and writes
 * samples to a Sample object.
 *
 * The Recorder begins when recOn is called and stops when recOff is called,
 * or when the Sample runs out of capacity.  When recording is finished,
 * the Recorders _active flag is set to NO and it is released by the context
 * so that it can be reclaimed
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/sample/MSKSample.h"

@interface MSKSampleRecorder : MSKContextVoice {
  MSKSample *_sample;
  BOOL isRecording;
  BOOL stopRecording;
  int maxFrames;
}

- (id) initWithCtx:(MSKContext*)c;

@property (readwrite) MSKContextVoice *sInput;  // what input to read from 
@property (readwrite) MSKSample *sample; // where to store the sample data
@property (readwrite) int position;	 // how many frames recorded

- (BOOL) recOn;		      // begin recording
- (BOOL) recOff;	      // stop recording and exit this recorder

@end
