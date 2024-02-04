# Models

Models define the state of synthesizer elements in the McLaren Synth Kit.

Most models have the following structure:

    @interface ExampleModel {
      @public
      double _myprop;
    }

    @property (readwrite, nonatomic) double myprop;
    @end

The ivars are marked `@public` so that they can be read in the audio thread.  They are not intended to be written or read anywhere else.  The values should be read and written through the property.  GUI elements access properties and can make use of bindings and observers.

You can see some uses of bindings in action in the example programs.

## Explanation

Objective-C does not have a "friend" designation for class members that would help us hide these ivars from everything except the audio thread operations.  Instead, we'll rely on convention and this documentation.

## Future Work

In the future, models should be able to archive and unarchive themselves.  This will be the first step toward implementing save and restore for synthesizer configurations.
