# Synth80

Synth80 is a two-oscillator software synthesizer with a built-in sampler.  It is presented as an example of the use of the McLaren Synth Kit and an exploration in the use of Cocoa bindings and a single-page document-based application applied to a synth.

Features:

* document-based app with save/restore of settings as .synth80 documents
* Undo/Redo (Alt-z, Alt-Z)
* a variety algorithms
* sample used as envelope or oscillator voice
* capture, save and load samples

![figures/Synth80-20240518.png](figures/Synth80-20240522.png)

## Document Model

The settings in the Synth80 application can be saved as `.synth80` document.

The overall Synth80Model is a data structure that contains all of the models used by the audio path.  Saving and restoring the models consists of saving and restoring the state of the singleton Synth80Model.

The Cocoa/GNUstep document-based application machinery handles most of the save/restore and undo/redo with minimal specific code in this application.

## Single-page application

For an application like a synthesizer, where there is only one audio output, it does not make much sense to open a new window for each document.  In this application there is a single `sharedWindowController`.  When a new document is opened, the previous is closed.  The model of the newly open document is used to set the values of the singleton Synth80Model.  The `sharedWindowController` then sees the values of the newly opened document.

## Controllers and Models

Models are fundamental to the McLaren Synth Kit.  Each defines the attributes of the voices that are added to the audio graph.  The McLaren Synth Kit has no GUI elements.

For each model used from the McLaren Synth Kit, this application defines a controller. A controller instantiates the views (widgets) used to manipulate the model and binds the views to the properties of the model.

| Controller                 | Model            |
| ---------------------------|------------------|
| MLEnvelopeController       | MSKEnvelopeModel |
| MLOscillatorController     | MSKOscillatorModel |
| MLDrawbarController        | MSKDrawbarModel |
| MLSampleController         | MSKSampleModel |
| MLFilterController         | MSKFilterModel |
| MLReverbController         | MSKReverbModel |
| MLModulationController     | MSKModulationModel |
| Synth80AlgorithmController | Synth80AlgorithmModel |


(Note: Controllers and other GUI-related widgets with the "ML" prefix will one day be placed in a shared framework.)

Users of this application should feel free to create new ways of interacting with models by creating new controllers.  The controllers shown here are functional, but more expressive ways of interaction may be possible.  Have fun, and be creative!

## Samples

The application has support for samples.  There is a "capture" button the records sounds from the default audio input into an in-memory sample.

Samples also be saved and restored from .wav files and other formats supported by the `sndfile` library.  To access the save/load feature, right-click over the waveform to see the context menu.

When saving a .synth80 document, the sample may be included or excluded.  Samples add quite a lot to the size of the saved document.  For this reason, the saving of the sample is optional and is selected with the `[ ] Save Sample` checkbox in the Sample View.

## Play with built-in keyboard or attached MIDI keyboard

The Synth80 application includes a graphical keyboard that can be played with a mouse or with keyboard shortcuts: a, s, d, f, g, h, etc.

An attached MIDI keyboard can also be used.  By default, the Synth80 application finds all attached MIDI keyboard devices.  This feature is implemented by the `makeGreedyListener` method in the AppDelegate.

## Mouse-scroller sensitivity

Most of the Cocoa controls have been augmented with mouse scroll-wheel behavior.  This makes it nicer to vary the controls.

## Pre-defined sounds

ToDo: include some example .synth80 documents in the project

## Playing and Sampling other Devices

The application uses the "default" playing and recording audio devices.  There is currently no provision to set this as a default or configure it from the application.

However, it is easy to change the values in the code.

