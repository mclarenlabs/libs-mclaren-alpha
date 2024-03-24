/** -*- mode:objc -*-
 *
 * A Sample contains an in-memory sound buffer of FLOATs along with
 * certain metadata about the sound.
 *
 */

#import "McLarenSynthKit/sample/MSKSample.h"

#include <sndfile.h>
#include <libresample.h>

NSString *SNDFILEErrorDomain = @"SNDFILEErrorDomain";

/*
 * Utility to emit sndfile errors as NSError
 */

static
NSError *errorFromSndFile(int code) {
  return [NSError errorWithDomain: SNDFILEErrorDomain
			     code: code
			 userInfo: @{
    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%s",
					 sf_error_number(code)]
	}];
}


@implementation MSKSample

- (float*) bytes {
  return (float*) [_data bytes];
}

- (float*) frame:(int)n {
  float *start = (float*)[_data bytes];
  return (start + (n * _channels));
}

- (NSUInteger) length {
  return [_data length];
}

- (NSUInteger) capacity {
  return [_data length] / (sizeof(float) * _channels);
}

- (id) initWithData:(NSData*)data channels:(int)channels {
  if (self = [super init]) {
    _data = data;
    _channels = channels;
    int length = [data length];
    _frames = length / (sizeof(float) * channels);
  }
  return self;
}

- (id) initWithCapacity:(NSUInteger)numFrames channels:(int)channels {
  if (self = [super init]) {
    NSUInteger numBytes = numFrames * sizeof(float) * channels;
    _data = [NSMutableData dataWithLength:numBytes];
    _channels = channels;
    _frames = 0;
  }
  return self;
}

- (id) initWithFrames:(NSUInteger)numFrames channels:(int)channels {
  if (self = [super init]) {
    _frames = numFrames;
    _channels = channels;
    NSUInteger numBytes = numFrames * (sizeof(float) * channels);
    _data = [NSMutableData dataWithLength:numBytes];
  }
  return self;
}

- (id) initWithFilePath:(NSString*)path error:(NSError**)error {
  if (self = [super init]) {

    const char *cpath = [path cString];
    SNDFILE *srcfile;
    SF_INFO srcinfo;

    srcfile = sf_open(cpath, SFM_READ, &srcinfo);

    if (!srcfile) {
      int code = sf_error(NULL);
      *error = errorFromSndFile(code);
    }
    else {
      _frames = srcinfo.frames;
      _channels = srcinfo.channels;
      _samplerate = srcinfo.samplerate;

      _path = path;
      _basename = [[path lastPathComponent] stringByDeletingPathExtension];
      _ext = [path pathExtension];

      NSUInteger numBytes = (srcinfo.frames * srcinfo.channels * sizeof(float));

      _data = [NSMutableData dataWithLength:numBytes];
      sf_readf_float(srcfile, (float*)[_data bytes], _frames);
      sf_close(srcfile);
    }
  }
  return self;
}

/*
 * Write to path.  Use extension to decide what format.
 *  https://github.com/minorninth/libresample/blob/master/tests/resample-sndfile.c
 */

- (BOOL) writeToFilePath:(NSString*)path error:(NSError**)error {

  NSString *ext = [path pathExtension];

  SNDFILE *dstfile;
  SF_INFO dstinfo;
  SF_FORMAT_INFO formatinfo;
  int numformats;


  if (ext == nil) {
    // default to WAV if no extension given (type/subtype)
    dstinfo.format = SF_FORMAT_WAV | SF_FORMAT_FLOAT;
  }
  else {
    // figure out format of destination file
    sf_command(NULL, SFC_GET_FORMAT_MAJOR_COUNT,
	       &numformats, sizeof(numformats));
    for (int i = 0; i < numformats; i++) {
      memset(&formatinfo, 0, sizeof(formatinfo));
      formatinfo.format = i;
      sf_command(NULL, SFC_GET_FORMAT_MAJOR,
		 &formatinfo, sizeof(formatinfo));
      // NSLog(@"examining format:%s", formatinfo.extension);
      if (!strcmp(formatinfo.extension, [ext cString])) {
	  NSLog(@"Using %s for output format.", formatinfo.name);
	  dstinfo.format = formatinfo.format;
	  break;
      }
    }
  }

  dstinfo.format |= SF_FORMAT_FLOAT; // choose float subformat
  dstinfo.samplerate = (int)(_samplerate + 0.5);
  dstinfo.channels = _channels;

  dstfile = sf_open([path cString], SFM_WRITE, &dstinfo);
  if (!dstfile) {
    int code = sf_error(NULL);
    *error = errorFromSndFile(code);
    return NO;
  }
  else {
    sf_writef_float(dstfile, (float*)[_data bytes], _frames);
    sf_close(dstfile);
  }

  return YES;
}

/*
 * Extract the data of chan into a new NSData.
 */

- (NSData*) extractChannel:(int)chan {

  NSData *out = [NSMutableData dataWithLength: _frames * sizeof(float)];
  float *inbuf = (float*)[_data bytes];
  float *outbuf = (float*)[out bytes];

  for (int i = 0; i < _frames; i++) {
    outbuf[i] = inbuf[i*_channels + chan];
  }

  return out;
}

/*
 * Overwrite chan with data from NSData.  Source must have enough floats.
 */

- (void) insertChannel:(int)c withData:(NSData*)data {

  float *inbuf = (float*)[data bytes];
  float *outbuf = (float*)[_data bytes];

  for (int i = 0; i < _frames; i++) {
    outbuf[i*_channels + c] = inbuf[i];
  }
}

/*
 * Produce the output frames for resampling a single channel by
 * a factor of 'ratio'.  The number of output samples is written
 * in value 'out'.
 */

- (NSData*) resampleChannel:(int)c ratio:(double)ratio out:(int*)out {

  // maxframes formula given in Usage Notes in repository:
  //   https://github.com/minorninth/libresample/tree/master
  int maxframes = ceill(_frames * ratio + ratio);
  int maxbytes = maxframes * sizeof(float);

  NSData *chan = [self extractChannel:c];
  float *inbuf = (float*) [chan bytes];

  NSData *outdata = [NSMutableData dataWithLength:maxbytes];
  float *outbuf = (float*) [outdata bytes];

  void *handle = resample_open(1, ratio, ratio);

  int inUsed;
  *out = resample_process(handle, ratio, inbuf, _frames, 1,
			  &inUsed, outbuf, maxbytes);
  assert(inUsed != 0);
  resample_close(handle);
  
  return outdata;
}

/*
 * Produce a new sample from resampling this one.
 */

- (MSKSample*) resampleBy:(double)ratio {

  // resample channel 0 to figure out num output frames
  int out0;
  NSData *chan0 = [self resampleChannel:0 ratio:ratio out:&out0];

  MSKSample *samp = [[MSKSample alloc] initWithFrames:out0 channels:_channels];
  [samp insertChannel:0 withData:chan0];

  // do it for the other channels
  for (int i = 1; i < _channels; i++) {
    int out;
    NSData *chan = [self resampleChannel:i ratio:ratio out:&out];
    [samp insertChannel:i withData:chan];
  }

  // fix up sample metadata (member access allowed because we are this class)
  samp->_samplerate = _samplerate;
  samp->_path = _path;
  samp->_basename = _basename;
  samp->_ext = _ext;

  // return result
  return samp;
}

- (MSKSample*) resampleTo:(double)rate {

  double ratio = rate / _samplerate;

  MSKSample *samp = [self resampleBy:ratio];

  // fix up metadata
  samp->_samplerate = rate;

  // return result
  return samp;
}

- (void) recorderSetsFrames:(int)frames {
  _frames = frames;
}

- (void) recorderSetsSamplerate:(int)samplerate {
  _samplerate = samplerate;
}

- (void) recorderSetsChannels:(int)channels {
  _channels = channels;
}

- (NSString*) description {
  return [NSString stringWithFormat:@"Sample<frames:%d base:%@ ext:%@ samp:%d>",
		   _frames, _basename, _ext, _samplerate];
}
    


@end
