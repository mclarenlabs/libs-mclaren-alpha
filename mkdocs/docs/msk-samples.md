# McLaren Synth Kit - Samples

An `MSKSample` is the class that can read, write and manipulate audio samples.  It has an array of PCM values of type `float`.  It can contain one, two or more channels.

An `MSKSample` has a `capacity` property that is the maximum number of frames it can hold.  It also has an integer property called `frames` that is a count of the number of frames that actually hold data.  It also stores the `samplerate` of the audio data.

With the McLaren Synth Kit, it is possible to capture samples from a Capture Context, or to play samples on an Playback Context.   This section will demonstrate some of these capabilities.

## Capturing a Sample

An `MSKContext` is used to interact with an ALSA PCM device.  So far, we have shown how to use a Playback context.  But it is also possible to create a Capture context.

A capture context grabs audio from an input source, and the voices of its graph process the captured audio.

In the example below, we show how to open a Context with stream `SND_PCM_STREAM_CAPTURE`.  The steps followed are exactly the same as for a Playback context except for the stream direction.

``` objc
// Desired audio context parameters
MSKContextRequest *request = [[MSKContextRequest alloc] init];
request.rate = 44100;
request.persize = 1024;
request.periods = 2;

NSString *devName = @"default";

NSError *error;
BOOL ok;

// Create an audio context on the 'default' device for recording
MSKContext *rec = [[MSKContext alloc] initWithName: devName
                                         andStream: SND_PCM_STREAM_CAPTURE
                                             error: &error];

if (error != nil) {
  NSLog(@"MSKContext init error:%@", error);
  exit(EXIT_FAILURE);
}

// Configure the context with the request
ok = [rec configureForRequest:request error:&error];
if (ok == NO) {
  NSLog(@"MSKContext configure error:%@", error);
  exit(EXIT_FAILURE);
}

// Start the context
ok = [rec startWithError:&error];
if (ok == NO) {
  NSLog(@"MSKContext starting error:%@", error);
  exit(EXIT_FAILURE);
}

```

Next, we want to allocate a Sample to hold recorded audio.  The following allocates a Sample with a capaccity to hold up to four seconds of 44100 rate stereo audio.

``` objc
// Create an empty sample to hold four seconds
MSKSample *samp = [[MSKSample alloc] initWithCapacity:(44100*4) channels:2];
```

An `MSKSampleRecorder` is a voice that can be used in a Capture Context to record audio to a sample.  Allocate one and connect it to the Context and the Sample.  The following shows how.  The recorder has two properties that must be connected.

* sample: the sample to record into
* sInput: the signal input.  A Capture Context exposes its recording buffer "voice" as property `rbuf`.

``` objc
MSKSampleRecorder *recorder = [[MSKSampleRecorder alloc] initWithCtx:rec];
recorder.sample = samp;
recorder.sInput = rec.rbuf;
[recorder compile];
```

Next, add the recorder "voice" to the context.  This adds the recorder to the audio thread of the Capture Context in a safe way.

``` objc
[rec addVoice:recorder];
```

Now, start the recorder.

``` objc
[recorder recOn];
```

And after some amount of time, stop the recording.

``` objc
[recorder recOff];
```

The recorder will stop when `recOff` is invoked, or when the Sample runs out of capacity: whichever comes first.  At this point, `samp` contains audio with the number of captured frames given by `samp.frames`.


## Playing a Sample

A sample can be passed to a Playback Context for playing.  Recall that the voices and operators of a Playback Context work on small chunks of audio data at a time: a single period of PCM data.  Generally, these are 1024 or 2048 sized chunks.  An `MSKSample` can hold many more frames than this.

For playing a sample, the McLaren Synth Kit provides an `MSKSamplePlayer` for handing out the samples in chunks in the audio thread of a Playback Context.

Assuming we have created a Playback Context called `ctx` and we have the Sample `samp` created above, we can play it back using the code below.

```
// Create a player for the sample
MSKSamplePlayer *player = [[MSKSamplePlayer alloc] initWithCtx:ctx];
[player setSample:samp];
[player compile];

// Ask the context to play it
[ctx addVoice:player];
```

This is pretty straightforward.  After the "player" is done playing the sample, it will exit and be reclaimed by ARC reference counting when there are no more references to it.

> Note:  As the player progresses through the sample contents, the player's `position` property will be incremented.  An observer timer loop could watch this value to advance an on-screen display of the current position in the sample.

### Sample Rate

It is worth noting that in the above example there was no attempt to determine if the sample rate of the Playback Context matched that of the Capture Context.  The Contexts themselves do not adjust sample rate, and if they are different you will hear that.  If you want to preserve the pitch, then you may need to resample.

## Resampling

An `MSKSample` can produce a copy of itself resampled by a ratio, or to a new sample rate.  The McLaren Synth Kit makes use of `libresample` to perform this function.  The github repo for this library is at the link below.

* [https://github.com/minorninth/libresample](https://github.com/minorninth/libresample)

If we wanted to ensure that the recorded sample was resampled appropriately for playback the following code would do it.

``` objc
// Resample for playback context
MSKSample *playsamp = [samp resampleTo:ctx.rate];

// Create a player for the sample
MSKSamplePlayer *player = [[MSKSamplePlayer alloc] initWithCtx:ctx];
[player setSample:playsamp];
[player compile];

// Ask the context to play it
[ctx addVoice:player];
```


## Reading a Sample

Reading and writing of samples is provided by `libsndfile` which is included in most Linux distributions.  There is a good overview of the library maintained at the link below.

* [https://libsndfile.github.io/libsndfile/](https://libsndfile.github.io/libsndfile/)

Given the pathname of the file, an `MSKSample` can be initialized with its contents.  The `libsndfile` library recognizes .au, .wav, .ogg, .aiff and more.

``` objc
NError *err;
MSKSample *samp = [[MSKSample alloc] initWithFilePath:filepath error:&err];
```

If there is a problem opening the file or reading its contents, the `err` value will hold an `NSError`.

## Finding a Sample - the Sample Manager

To make it easier to bundle samples with programs, or to maintain a collection of samples, the `MSKSampleManager` looks in common places with common filename suffixes.



``` objc
MSKSampleManager *mgr = [MSKSampleManager defaultManager];
NSString *path = [mgr sampleWithName:@"beep"];
MSKSample *samp = [MSKSample alloc] initWithFilePath:path error:&err];
```

The sample  manager would look for files named "beep.wav", "beep.au", "beep.aiff", etc in a set of standard places.  Currently, these are the following.

* <gnustep-library-paths>/McLarenSynthKit/Samples/
* <gnustep-library-paths>/Samples/
* paths to Resource/Samples in all loaded bundles including the main bundle.


## Writing a Sample

There is one method to write a Sample to a file.

``` objc
MSKSample *samp = ...
NSError *err;
[samp writeToFilePath:path error:&err];
```

This method looks at the suffix of the filename to deduce the format.  For instance, if the path ends in ".wav" it will be written in WAV format.

If there is a problem writing the file, and `NSError` describing the condition will be placed in `err`.

Currently, the suffix determines the file container format and the sample format is set to single-precision float.  In the future there may be an option to specify the sample format to be used for saving.




