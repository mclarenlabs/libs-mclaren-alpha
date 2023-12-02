# AlsaSoundKit Tools

These are a couple of command-line tools that illustrate how to use the Alsa Sound Kit to interact with MIDI SEQ devices and Audio PCM devices.

* askpcmlist - list the PCM devices in the system
* askseqlist - list active SEQ devices in the system
* askseqdump - dump the MIDI events from a client in the system
* miniosc1 - play an oscillator sound on a specified PCM device
* minisynth1 - a monophonic synthesizer controlled by a MIDI Device

## Build Instructions

1. Make sure you have built the AlsaSoundKit library in the `/Libraries` folder.  You may either leave the library in place for "local development", or can install it globally with `make install`.

2. Compile the tools.  If you have chosen to install the ASK library globally, then all you need to do is compile the tools.

        $ make

3. If you have chosen to work locally, without a globally installed ASK library, then there is built-in support for that.  Compile the tools with the `localdev` flag.  This will set include and LD paths that help the executables find the local copy of the ASK library.

        $ make localdev=yes

## Usage

1. askpcmlist - no arguments

        $ obj/askpcmlist


2. askseqlist - no arguments

        $ obj/askseqlist

3. askseqdump: this tool needs to be edited to select the name of the client to watch.  Find this line

        ASKSeqAddr *addr = [seq parseAddress:@"Launch:0" error:&error];
    and change "Launch:0" to the name of the client you want to watch.
	Then recompile the program.
	
	    $ obj/askseqdump

4. miniosc1 - give the name of a PCM device in your system.  For example, "default"

        $ obj/miniosc1 default

5. minisynth1 - give the name of a PCM devide and a MIDI keyboard controller.  For example, use the Linux `vkeybd` application to make an on-screen piano keyboard.

        $ vkeybd &
		$ obj/minisynth1 default Virtual
		
	Play the keyboard and hear a note at a time on the speaker.
	After 10 seconds, this application closes the PCM and exits.
