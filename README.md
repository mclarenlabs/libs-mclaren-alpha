# Libs McLaren

This project contains libraries and programs for using MIDI and Sound devices on Linux with GNUstep.  The base of the project is the ASK ("Alsa Sound Kit") library for interfacing with ALSA (Advanced Linux Sound Architecture) via ObjectiveC.  This library makes it easy to enumerate MIDI and Sound devices, to open and close them, and to send and receive MIDI events and Sound buffers.

The second layer of the project is the MSK ("McLaren Synth Kit") library.  It builds on top of the device-level ASK library by providing an object-oriented approach to sound generation.  Sounds can be described as graphs consisting of envelopes, oscillators, filters and effects, and rendered by an MSKContext managing an audio device.  Classes also exist for capturing and manipulating samples.

There are a number of full-featured applications.

* MidiTalk - a scriptable app using StepTalk interpreted scripting language for managing McLaren Synth Kit objects.
* Synth80 - a two-oscillator and sampling synth with full save/restore of patches.
* MidiMon - watch MIDI system and dump events.

There is a collection GUI demonstrations that show off aspects of the McLarenSynthKit.

* MskFilterDemo (app) - use sliders to vary the properties of a filter
* MskOrganDemo (app) - a drawbar organ with reverb and a filter
* MskMetroDemo (app) - a simple Metronome using oscillators for tones
* MskPatternDemo (app) - a Musical Pattern demonstration with adjustable tempo and waveform
* SampleToy (app) - capture a sample and play it with a keyboard
Currently, there are the following ASK demonstration programs.

And then there are two collections of command-line tools.  The list below require only the ALSA Sound Kit Library.

* askpcmlist (tool) - list the PCM (sound) devices in the system
* askseqlist (tool) - list the MIDI Sequencer devices in the system
* askseqdump (tool) - dump MIDI events from a specific sequencer
* miniosc1 (tool) - make an oscillator on a PCM (sound) device
* minisynth1 (tool) - generate tones on a PCM (sound) device from MIDI input events

The second collection of command-line tools below illustrates some of the features of the McLaren Synth Kit.

* scaleplayer (tool)- play a scale using a simple oscillator
* pdscaleplayer (tool) - play a scale with a complex oscillator and reverb
* playsample (tool) - play an audio sample from a file (wav, au, etc)
* capturesample (tool) - capture an audio sample to a file


## Organization of the Project

The two Libraries "AlsaSoundKit" and "McLarenSynthKit" are the core of the project.

The "Applications" directory is organized with full-featured programs at the top, and a collection of demonstration programs in the "Demos" directory.

The "Tools" directory is divided into two directory.  Tools using only the "AlsaSoundKit" library are in the "Tools/AlsaSoundKit" directory.  Tools requiring both the "McLarenSynthKit" library and the "AlsaSoundKit" library and are in the "Tools/McLarenSynthKit" directory

``` console

├── Applications
│   ├── MidiTalk
│   ├── Synth80
│   ├── MidiMon
│   └── Demos
│       ├── LiveloopToy
│       ├── MskFilterDemo
│       ├── MskMetroDemo
│       ├── MskOrganDemo
│       └── SampleToy
├── Libraries
│   ├── AlsaSoundKit
│   └── McLarenSynthKit
├── Tools
│   ├── AlsaSoundKit
│   │   └── askpcmlist, askseqdump, miniosc1, minisynth1
│   └── McLarenSynthKit
│   │   └── capturesample, pdscaleplayer, playsample, scaleplayer, tiny
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

$ cd Applications/Synth80
$ make
$ sudo -E make install

$ cd Applications/MidiTalk
$ make
$ sudo -E make install

$ cd Applications/Demos
$ make
$ sudo -E make install

```

### Support for Library Developers

If you find yourself working on the library code itself (files in `Libraries/AlsaSoundKit` or `Libraries/McLarenSynthKit`) it can be painful to perform a `make install` after changing a line or two.

We have provided help for working with this project "locally."  That is, with all files remaining in the `libs-mclaren-alpha` project directory.  This way you can re-compile a library file and all of the Applications and Tools can find the libraries in the project directtory itself.

When using `make install` with the ASK and MSK libraries, their headers and objects are placed in a standard location (~/GNUstep/Local/Library or /usr/GNUstep/Local/Library, etc.).  But for developing the libraries themselves with repeated compiling it can be more convenient to leave them in place, and to also leave the tools and applications in place too.

To facilitate working with the ASK and MSK libraries "in-place", the applications' and tools' GNUmakefiles have been given a flag called "localdev" that adds the compilation and linker flags so that it can find the two libraries.

To work this way, first build the libraries but do not install.

``` console
## build the libraries but do not install
$ cd Libraries/AlsaSoundKit
$ make
$ cd Libraries/McLarenSynthKit
$ make
```

Then for each application or tool, build it with the "localdev" flag and the Makefile will set up the library paths appropriately.

``` console
$ cd Tools/AlsaSoundKit
$ make localdev=yes

$ cd Tools/McLarenSynthKit
$ make localdev=yes

$ cd Applications/MidiMon
$ make localdev=yes

$ cd Applications/Synth80
$ make localdev=yes

$ cd Applications/MidiTalk
$ make localdev=yes

$ cd Applications/Demos
$ make localdev=yes
```

## StepTalk

StepTalk is a scripting language with SmallTalk syntax that runs on top of the Objective-C runtime.  StepTalk scripts can create ObjectiveC objects and send messages using selectors.  The entire AppKit and Foundation libraries can be accessed through StepTalk.

Before building "MidiTalk" you must make sure "libs-steptalk" is installed on your system.  If you need to build it, the instructions are simple.

``` console
$ git clone https://github.com/gnustep/libs-steptalk
$ cd libs-steptalk
$ make
$ sudo -E make install
```
