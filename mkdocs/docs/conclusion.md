# Conclusion

This project describes the McLaren Synth Kit.  It consists of two parts: a lower-level library called the Alsa Sound Kit that provides a slim Objective-C wrapper around the MIDI and PCM components of the ALSA sound library.  THe Mclaren Synth Kit builds on the Alsa Sound Kit to provide a high-level abstraction of audio synthesis as the construction of an audio graph that is evaulated to produce sounds.

The Alsa Sound Kit does not attempt to hide the details of the ALSA sound library.  Rather, it aims to smooth the interface between the low-level C library and a slightly higher-level abstraction of Objective-C with dispatch queues.  For MIDI, we map an ALSA SEQ interface directly to a dispatch source operating with a high-priority queue.  This maps the MIDI system into the  dispatch queue interface used pervasively in Objective-C.

ALSA PCMs are mapped to a high-priority thread with Objective-C callback "blocks."  Blocks help to simplify some aspects of writing callback functions.

The most abstract interface are the Context and Voice classes of the Mclaren SYnth Kit.  In this level of abstraction, the callbacks of the PCM layer are completely hidden and audio synthesis is expressed as a series of operators Voices.

The libraries have been in use and are demonstrated by the softare projects released by [McLaren Labs](https://mclarenlabs.com).  Future installments of this project will describe further aspects of the libraries through examples and explations.  As always, the examples here are designed to be compiled and run and to form the basis of your own audio explorations.
