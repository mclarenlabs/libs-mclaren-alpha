# ALSA Sound Kit

The ALSA Sound Kit is a library that makes working with MIDI SEQ and Audio PCM devices easier in modern Objective-C.  ALSA handles (pointers) are encapsulated in Objects and many functions are mapped to methods of those objects.

The library also hides the low-level operation of the SEQ and PCM devices so that user-level code can focus on processing events, or preparing audio buffers.  For the SEQ devices, received MIDI events are wrapped in an object and received via a dispatch-queue.  For PCM devices, the library manages the necessary low-level thread and processes buffers of audio values through callbacks implemented as blocks.

Along with the ability to Open, Close, Start and Stop SEQ and PCM devices, the library provides utilities for listing the available SEQ and PCM devices in the system, and keeping the list of the available devices up to date.  These are useful for building GUIs.

A design goal of the library was to make working with ALSA more convenient in modern Objective-C, but not to completely hide ALSA.  Access to ALSA handles is unfettered, and because Objective-C *is* C, you can freely operate at the C level when necessary.  ALSA types describing audio formats and MIDI events are not hidden at all.  When working with this library a certain amount of knowledge of ALSA will help.

Another design goal was to make ASK objects pretty-print when sent to NSLog.  This can be helpful during development.


## Build Instructions

The library should build without problems in the normal way.

    $ make
	
If you choose to install the library globally, use the GNUstep install option.

    $ make install
	

## Working Locally

When working with the `libs-mclaren` project, you may choose not to install the library globally, but might prefer to work locally.  If that is the case, skip the "install" step.

The applications and tools of this project support a make option, "localdev=yes", that compiles the binaries to be able to find the ASK library in its build location.

## Description of the Library

1. ASKPcm: working with PCM devices.  Open, close, start thread, stop thread, receive and send audio buffers.  Configuring of audio devices by examining and setting their hardware and software properties.

2. ASKPcmSystem: find PCM devices in the system and examine their properties.

3. ASKPcmList: maintain a list of PCM devices in the system.

4. ASKSeq: working with MIDI SEQ devices.  Open, close, start and stop.  Receive MIDI events, send MIDI events.

5. ASKSeqEvent: a slim objecter wrapper around ALSA MIDI events.

6. ASKSeqSystem: find SEQ devices in the system and examine their properties.

7. ASKSeqList: maintain a "live" list of SEQ devices in the system.

8. ASKError: a category for creating NSError objects in the ASK.  Care must be taking to force this category to link by including a call to `ASKError_linker_function();` in the main program somewhere.


## Examples

See [../../Tools/AlsaSoundKit](../../Tools/AlsaSoundKit) for some examples that illustrate how to work with these objects.


## To Do

Eventually, it would be nice to have a simpler interface for creating and examininging SEQ events.  In the ALSA system, the SEQ event structure holds not only a MIDI event (noteOn, noteOff, etc.), but also information about the event's destination and timing.  We're still not sure the best way to abstract this to ObjC, so we haven't provided one.


