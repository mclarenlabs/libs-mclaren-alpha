# Libs McLaren

This project contains libraries and programs for using MIDI and Sound devices on Linux with GNUstep.  The base of the project is the ASK ("Alsa Sound Kit") library for interfacing with ALSA (Advanced Linux Sound Architecture) via ObjectiveC.  This library makes it easy to enumerate MIDI and Sound devices, to open and close them, and to send and receive MIDI events and Sound buffers.

The second layer of the project is the MSK ("McLaren Synth Kit") library.  It builds on top of the device-level ASK library by providing an object-oriented approach to sound generation.  An MSKContext provides a substrate for rendering sound graphs that are described by envelopes, oscillators, filters and effects generators.

Currently, there are the following demonstration programs.

* askpcmlist (tool) - list the PCM (sound) devices in the system
* askseqlist (tool) - list the MIDI Sequencer devices in the system
* askseqdump (tool) - dump MIDI events from a specific sequencer
* miniosc1 (tool) - make an oscillator on a PCM (sound) device
* minisynth1 (tool) - generate tones on a PCM (sound) device from MIDI input events

There are also a few GUI applications that use GNUstep AppKit.

* MidiMon (app) - watch the MIDI system and dump events from multiple clients
* MidiScriptDemo (app) - a scriptable app using StepTalk that can do many things with MIDI and PCM (audio) devices by accessing the ASK library
* MskFilterDemo - use sliders to vary the properties of a filter
* MskOrganDemo - a drawbar organ with reverb and a filter


## Building

The components of the project use GNUstep makefiles in a standard way.  Simply "cd" to the directory of the library or program and type

``` console
$ make
$ make install
```
### Developing Locally

You can choose whether to `make install` the library (ASK) or not.  Installing the ASK and MSK libraries will place their headers and objects in a standard location (~/GNUstep/Local/Library or /usr/GNUstep/Local/Library, etc.).  But for developing and repeated compiling it can be more convenient to leave them in place, and to also leave the tools and applications in place.

To facilitate working with the ASK and MSK libraries "in-place", the applications' and tools' GNUmakefiles have been given a flag called "localdev" that adds the compilation and linker flags so that it can find the two libraries.

In the example below, the ASK library is compiled but not installed.  The MidiMon application is compiled with the "localdev" flag so that it finds the library in the project and not in a global location.  There's nothing special about the "localdev" flag, we have simply used it in a consistent way so that each sub-program finds the ASK library using relative paths.

``` console
$ cd Libraries/AlsaSoundKit
$ make
$ cd ../../Applications/MidiMon
$ make localdev=yes
$ openapp ./MidiMon.app
```

## StepTalk

StepTalk is a scripting language with SmallTalk syntax that runs on top of the Objective-C runtime.  StepTalk scripts can create ObjectiveC objects and send messages using selectors.  The entire AppKit and Foundation libraries can be accessed through StepTalk.

This project includes "MidiScriptDemo" to demonstrate some of the capabilities of StepTalk.  Using StepTalk scripts can send and receive MIDI events, and play notes on a PCM (sound) device.

Before building "MidiScriptDemo" you must make sure "libs-steptalk" is installed on your system.  If you need to build it, the instructions are simple.

``` console
$ git clone https://github.com/gnustep/libs-steptalk
$ cd libs-steptalk
$ cd Frameworks/StepTalk
$ make
$ make install
```
