# Introduction to McLaren Synth Kit

The McLaren Synth Kit aims to bring audio programming to GNUstep Objective-C on Linux.  It consists of a number of parts.

1. Alsa Sound Kit (ASK) - Obj-C wrappers around Alsa sound and MIDI devices
2. McLaren Synth Kit (MSK) - a more abstract sound "context" and synthesizer construction operators like oscillators, envelopes and effects.
3. Demonstration programs and applications.

## Project Home

The documentation you are reading here is from the `/mkdocs` directory of the McLaren Synth Kit repository on github.

* [https://github.com/mclarenlabs/libs-mclaren-alpha](https://github.com/mclarenlabs/libs-mclaren-alpha)

## Background

This project is partially inspired by experiences with audio systems on IOS, OSX and Webkit and a NeXT project called [MusicKit](https://github.com/leighsmith/MusicKit).  We had in mind building a networked synthesizer using RTP-MIDI in an embedded Raspberry Pi application.  We really liked the features of modern Objective-C and thought it could provide a nice experience for audio programming.

We purposely chose to focus on Linux and its ALSA interface.  We wanted to avoid the layers of abstraction provided by the PortAudio project or JUCE. We also wanted to avoid dependence on a sound server like Pulse or JACK simply to reduce dependencies.  We wanted to keep the toolkit lean and easy to set up.

These decisions helped make the toolkit simple to use for simple things.  Along the way we learned a lot and discovered some interesting capabilities.  Hopefully this project will help share the things we learned.


## Concurrency

One of the things that makes audio programming difficult is the management of concurrency.  In an audio application like a synthesizer, there is usually a thread dedicated to rendering the audio, a thread dedicated to MIDI, a thread managing the GUI, and possibly other threads performing background tasks.

Apple's GCD (Grand Central Dispatch) aka "dispatch queues" help simplify concurrency, and they are a first-class part of GNUstep's Objective-C environment.  Instead of writing code that manages threads and locks, your code is organized into blocks that execute sequentially in a dispatch queue concurrency domain.  The syntactic sugar of "blocks" in C lets you write code that executes in one concurrency domain and launches an operation in another.  This replaces a cross-thread operation with something simpler.

One of the design goals of the McLaren Synth Kit it to elevate audio programming to the realm of dispatch events, and to hide threads and locks as much as possible.  We think we have succeeded.

 
## Memory Management

The McLaren Synth Kit is designed to take full advantage of ARC (Automatic Reference Counting) for memory reclamation.  A synthesizer with polyphony is usually rendering many different sounds at once.  Each sound has a starting event (its "attack") and eventually its "decay" and "release."  It's convenient to think of sounds as being allocated and deallocated.  While they are allocated, they are rendered to produce a sound.
 
With the Synth Kit, a sound unit (called a "Voice") is dynamically allocated and configured, and then is handed to the audio thread for rendering.  After the Voice is done playing, the audio thread marks it a reclaimable.  A different background thread periodically checks for reclaimable Voices and gives them back to ARC.  This puts the memory of the Voice back in the allocation pool.

These details are handled by the Synth Kit.  When you're writing an audio program using the kit, you only need to allocate and configure voices.  Once you're done with a sound, Synth Kit takes care of cleaning up.


## Objective-C is C

Objective-C is strictly a superset of C.  This means that C structs and functions can be used directly in Objective-C programs.  ALSA makes use of opaque C pointers as well as C structs for defining events and messages.  These things are the "language" of ALSA.  The McLaren Synth Kit exposes many of these details where it adds no value to abstract them.

Objective-C objects can be referenced as C structs.  This capability can lead to dangerous programming territory, but when used carefully it is very powerful.  In the McLaren Synth Kit, we take advantage of the memory management and property capabilities of Objective-C objects, but we can (safely) pass references to these structs to low-level C functions.  C functions can access Objective-C instance variables directly, because the memory layout is known by both C and Objective-C.

## Error Handling

We tried to normalize errors that arise in a number of contexts.  Wherever possible, errors exposed as `NSError` objects.  Initializers that may encounter an error have an extra `error:(NSError**)` argument in which to describe the problem.

## StepTalk

It's interesting to think about how an interpreted language could be used to build audio interfaces and stitch together audio units to create user-defined synthesize instruments.  StepTalk is a GNUstep project that implements a Smalltalk-like interpreted language on top of the Objective-C runtime environment.

We have only just begun to build demonstration programs with StepTalk, but you can see an example of how this could work in the application `MidiScriptDemo` in the `Applications/` directory.


## A Brief Tour of the Components

The tool kit is divided into two layers.  The Alsa Sound Kit (ASK) provides minimal Objective-C wrappers around ALSA sound and MIDI sequencer devices.  It also encapsulates standard algorithms on these things, so that instead of writing code to play a sound or enumerate the sequencers in your system, you call a method or set up a block. 

The major components of the Alsa Sound Kit are described below.

* ASKPcm - open an ALSA audio device and play or capture sounds
* ASKPcmList - list the ALSA audio devices in your system
* ASKSeq - open an ALSA MIDI Sequencer device and play or capture MIDI events
* ASKSeqList - list the ALSA MIDI devices in your system

The McLaren Synth Kit (MSK) further abstracts audio devices into an object called a "Audio Context."  An Audio Context can render audio pipelines that are described as a connected graph of audio elements, each of which is called a "Voice".  A Voice can be a simple oscillator, an oscillator controlled by an envelope, or a more complex graph of multiple oscillators, envelopes and filters.  A Voice can play for ever, it can stop after a specified time or it can be sent a `noteOff` message.

Once created, a Voice is handed over to a Context for rendering.  The Context manages the rendering and mixing of multiple Voices.  In a typical use, a Voice is allocated for each MIDI note sounding.  When a Voice is done playing, the Context removes the Voice and arranges for the reclamation of its memory.

The major components of the McLaren Synth Kit are described below.

* MSKContext - an audio context for rendering Voices or capturing sounds into a Voice
* MSKLinEnvelope, MSKExpEnvelope - linear and exponential envelope generators
* MSKSinFixedOscillator - a simple sinusoidal oscillator
* MSKGeneralOscillator - Sin, Squarewave, Triangle, Saw oscillator
* MSKPhaseDistortionOscillator - an oscillator who phase is controlled by another Voice

The parameters of the various kinds of voices are continuously variable.  To allow multiple voices to share configuration parameters (for example, all of the notes playing in a MIDI channel to have the same "transpose" or "pitchbend" setting) the continously variable parameters of voices are separated into objects called Models. The models in the system are listed below.

* MSKEnvelopeModel
* MSKOscillatorModel
* MSKReverbModel

> Aside: Models have a special role in the system: they provide read-only "C" variables that the Voices read from the audio thread.   And for each "C" variable, they expose an Objective-C "property" for reading and writing that variable.  To the outside-world, their properties can be freely used with Cocoa controls and Cocoa bindings.  The audio thread reads the primitive "C" values behind the models to respond to value changes.

## A Complete Example

Shown below is a complete example of a program that opens a device and plays a sound using a `MSKContext`.

The top of the program opens a new Audio Context, configures it and starts it running.  Dispatch queue calls are used to schedule events.  At time t=1 second, a block is launched that creates a new sound and adds it to the context.  This starts the sound playing until its release time has passed.  At time t=2 seconds, a block is launched that closes the context.  Lastly at time t=4 seconds a block is launched to exit the program.

This program is available in the `msk-examples` directory and is named `tiny.m`.  You can compile it yourself and try it out.

``` objc
int main(int argc, char *argv[]) {

  // Desired audio context parameters
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;
  request.persize = 1024;
  request.periods = 2;

  NSString *devName = @"default";

  NSError *error;
  BOOL ok;

  // Create an audio context on the 'default' device for playback
  MSKContext *ctx = [[MSKContext alloc] initWithName:devName
                                           andStream:SND_PCM_STREAM_PLAYBACK
                                               error:&error];

  if (error != nil) {
    NSLog(@"MSKContext init error:%@", error);
    exit(1);
  }

  // Configure the context with the request
  ok = [ctx configureForRequest:request error:&error];
  if (ok == NO) {
    NSLog(@"MSKContext configure error:%@", error);
    exit(1);
  }

  // Start the context
  ok = [ctx startWithError:&error];
  if (ok == NO) {
    NSLog(@"MSKContext starting error:%@", error);
    exit(1);
  }


  // Create and sound a Voice after 1 second
  dispatch_time_t attackt = dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC);
  dispatch_after(attackt, dispatch_get_main_queue(), ^{
    
    MSKOscillatorModel *oscmodel1 = [[MSKOscillatorModel alloc] initWithName:@"osc1"];
    oscmodel1.osctype = @MSK_OSCILLATOR_TYPE_TRIANGLE;

    MSKEnvelopeModel *envmodel1 = [[MSKEnvelopeModel alloc] initWithName:@"env1"];
    envmodel1.sustain = 1.0;
    envmodel1.rel = 1.5;

    MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:ctx];
    env.oneshot = YES;
    env.shottime = 0.05;
    env.model = envmodel1;
	[env compile];

    MSKGeneralOscillator *osc = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
    osc.iNote = 60;
    osc.sEnvelope = env;
    osc.model = oscmodel1;
	[osc compile];

    // Hand the oscillator over to the context for rendering
    [ctx addVoice:osc];
    });

  // Close the context after two seconds
  dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC);
  dispatch_after(after, dispatch_get_main_queue(), ^{
      [ctx close];
    });

  // Exit after four seconds
  dispatch_time_t after4 = dispatch_time(DISPATCH_TIME_NOW, 4.0*NSEC_PER_SEC);
  dispatch_after(after4, dispatch_get_main_queue(), ^{
      exit(0);
    });

  // Run forever
  [[NSRunLoop currentRunLoop] run];

}

```


## Summary

This chapter gives a brief introduction to the design goals of the McLaren Synth Kit.  The kit uses the concurrency and memory management features of modern Objective-C to provide a comfortable environment for audio programming on Linux.  An example program showed how to play a synthesized sound consisting of an envelope generator and an oscillator playing a middle-C.  Hopefully this was intriguing enough that you want to find out more.

We didn't explain the details of how audio objects are defined and configured using the McLaren Synth Kit, and we didn't explain the rules for how "Voices" (the audio objects of the MSK) can be combined to create more complex sounds.  We also didn't cover how to find audio devices on your computer (i.e. - external USB sound cards) and how to use them.  All of these will be covered in later chapters.




