# Libs McLaren

This project contains libraries and programs for using MIDI and Sound devices on Linux with GNUstep.  The base of the project is the ASK ("Alsa Sound Kit") library for interfacing with ALSA (Advanced Linux Sound Architecture) via ObjectiveC.  This library makes it easy to enumerate MIDI and Sound devices, to open and close them, and to send and receive MIDI events and Sound buffers.

The second layer of the project is the MSK ("McLaren Synth Kit") library.  It builds on top of the device-level ASK library by providing an object-oriented approach to sound generation.  An MSKContext provides a substrate for rendering sound graphs that are described by envelopes, oscillators, filters and effects generators.

Currently, there are the following ASK demonstration programs.

* askpcmlist (tool) - list the PCM (sound) devices in the system
* askseqlist (tool) - list the MIDI Sequencer devices in the system
* askseqdump (tool) - dump MIDI events from a specific sequencer
* miniosc1 (tool) - make an oscillator on a PCM (sound) device
* minisynth1 (tool) - generate tones on a PCM (sound) device from MIDI input events

And a few MSK demonstration programs.

* scaleplayer (tool)- play a scale using a simple oscillator
* pdscaleplayer (tool) - play a scale with a complex oscillator and reverb
* playsample (tool) - play an audio sample from a file (wav, au, etc)
* capturesample (tool) - capture an audio sample to a file


There are also a few GUI applications that use GNUstep AppKit with only the AlsaSoundKit part of the project.

* MidiMon (app) - watch the MIDI system and dump events from multiple clients
* MidiScriptDemo (app) - a scriptable app using StepTalk that can do many things with MIDI and PCM (audio) devices by accessing the ASK library

And then there are GUI applications which build on the McLarenSynthKit part of the project.

* MskFilterDemo (app) - use sliders to vary the properties of a filter
* MskOrganDemo (app) - a drawbar organ with reverb and a filter
* MskMetroDemo (app) - a simple Metronome using oscillators for tones
* MskPatternDemo (app) - a Musical Pattern demonstration with adjustable tempo and waveform
* SampleToy (app) - capture a sample and play it with a keyboard


## Organization of the Project

The Libraries, Tools and Applications generally follow the same structure.  The AlsaSoundKit depends only on the Linux ALSA Library.  The McLarenSynthKit Library depends on the AlsaSoundKit Library as well as libsndfile and libresample.

Tools are sub-divided into two categories.  The tools in `Tools/AlsaSoundKit` depend only on the AlsaSoundKit library.  Tools in `Tools/McLarenSynthKit` depend on the McLarenSynthKit library (which also depends on the AlsaSoundKit library).

Applications are slightly different.  `Applications/MidiMon` depends only on the AlsaSoundKit.  `Applications/MidiScriptDemo` depends on the AlsaSoundKit and also the StepTalk project.  Applications in `Applications/McLarenSynthKit` require the McLarenSynthKit library (which also depends on the AlsaSoundKit library).

``` console

├── Libraries
│   ├── AlsaSoundKit
│   └── McLarenSynthKit
├── Tools
│   ├── AlsaSoundKit
│   │   └── askpcmlist, askseqdump, miniosc1, minisynth1
│   └── McLarenSynthKit
│   │   └── capturesample, pdscaleplayer, playsample, scaleplayer, tiny
├── Applications
│   ├── McLarenSynthKit
│   │   ├── LiveloopToy
│   │   ├── MskFilterDemo
│   │   ├── MskMetroDemo
│   │   ├── MskOrganDemo
│   │   ├── SampleToy
│   │   └── Synth80
│   ├── MidiMon
│   └── MidiScriptDemo
├── README.md
```


## Building

To build both ASK and MSK, install the following dependencies.

* libasound2-dev
* libsndfile1-dev
* libresample1-dev

The components of the project use GNUstep makefiles in a standard way.  The libraries must be built and installed first, and then the applications.

You can build pieces of the project in stages yourself.  Make sure the libraries are built and installed first.

``` console
$ cd Libraries/AlsaSoundKit
$ make
$ sudo -E make install

$ cd Libraries/McLarenSynthKit
$ make
$ sudo -E make install
```

Then build and install the various demonstration programs.

``` console
$ cd Tools/AlsaSoundKit
$ make
$ sudo -E make install

$ cd Tools/McLarenSynthKit
$ make
$ sudo -E make install

$ cd Applications/MidiMon
$ make
$ sudo -E make install

$ cd Applications/MidiScriptDemo
$ make
$ sudo -E make install

$ cd Applications/McLarenSynthKit/MskOrganDemo
$ make
$ sudo -E make install

$ cd Applications/McLarenSynthKit/MskFilterDemo
$ make
$ sudo -E make install

$ cd Applications/McLarenSynthKit/MskMetroDemo
$ make
$ sudo -E make install

```

### Developing Locally

We have provided help for working with this project "locally."  That is, with all files remaining in the project directory.

When using `make install` with the ASK and MSK libraries, their headers and objects are placed in a standard location (~/GNUstep/Local/Library or /usr/GNUstep/Local/Library, etc.).  But for developing the libraries themselves with repeated compiling it can be more convenient to leave them in place, and to also leave the tools and applications in place too.

To facilitate working with the ASK and MSK libraries "in-place", the applications' and tools' GNUmakefiles have been given a flag called "localdev" that adds the compilation and linker flags so that it can find the two libraries.

In the example below, the ASK library is compiled but not installed.  The MidiMon application is compiled with the "localdev" flag so that it finds the library in the project and not in a global location.  There's nothing special about the "localdev" flag, we have simply used it in a consistent way so that each sub-program finds the ASK and MSK libraries using relative paths.

``` console
## build the libraries but do not install
$ cd Libraries/AlsaSoundKit
$ make
$ cd Libraries/McLarenSynthKit
$ make

## build programs that to references the libraries where they reside
$ cd Applications/MidiMon
$ make localdev=yes
$ openapp ./MidiMon.app

## etc.
$ cd Applications/McLarenSynthKit/MskOrganDemo
$ make localdev=yes
$ openapp ./MskOrganDemo

$ cd Applications/McLarenSynthKit/MskMetroDemo
$ make localdev=yes
$ openapp ./MskMetroDemo &
$ openapp ./MskPatternDemo &
```

## StepTalk

StepTalk is a scripting language with SmallTalk syntax that runs on top of the Objective-C runtime.  StepTalk scripts can create ObjectiveC objects and send messages using selectors.  The entire AppKit and Foundation libraries can be accessed through StepTalk.

This project includes "MidiScriptDemo" to demonstrate some of the capabilities of StepTalk.  Using StepTalk scripts can send and receive MIDI events, and play notes on a PCM (sound) device.

Before building "MidiScriptDemo" you must make sure "libs-steptalk" is installed on your system.  If you need to build it, the instructions are simple.

``` console
$ git clone https://github.com/gnustep/libs-steptalk
$ cd libs-steptalk
$ make
$ sudo -E make install
```
