## MSK Context Buffer

In the Mclaren Synth Kit, all sample buffers are an array of single-precision FLOATs in INTERLEAVED access pattern.  An `MSKContextBuffer` holds an `NSData` sized to the period size of a configured `MSKContext`.

An `MSKContextBuffer` is always initialized with a specific Context, and it holds a reference to that Context.

``` objc
ASKContextBuffer *buf = [[ASKContextBuffer alloc] initWithCtx:ctx]
```

If you are writing your own Voices, you will need to access the underlying frames in the `_frames` instance variable.


## MSK Context Voice

In the Mclaren Synth Kit, an `MSKContextVoice` is a buffer that has been augmented with callback functions for producing various kinds of sounds or envelopes.  The callback functions are called once each period and fill the underlying `MSKContextBuffer` with samples.

The base class `MSKContextVoice` has a predefined callback that fills the buffer with zeros every time it is updated.  In other words, the base `MSKContextVoice` is a silence generator.

## Playing a Voice

Voices are designed to be played by a Context.  To play a Voice, add it to the Context.  The following code creates a Voice that plays silence.

``` objc
ASKContextVoice *silence = [[ASKcontextVoice alloc] initWithCtx:ctx]
[ctx addVoice:silence]
```

Once added to a Context, a Voice plays until its `_active` instance variable is set to `NO`.  We could stop our silence voice from playing like this.

``` objc
  silence->_active = NO;
  silence = nil;
```

Part of the logic implemented by the Context is the release of inactive voices ... **safely**.  At some point after the `silence` voice is marked inactive, the Context will release its reference to the voice.  When all of the references to the Voice are released, the memory for the VOice is reclaimed by Objective-C's ARC.

## The Voice Protocol

The example above demonstrates the basis for transferring Voices *into* and *out-of* the audio thread.  To add a voice to a Context, use the `addVoice:` method with a Voice.  To stop a voice from playing and arrange to have it removed from the Context, cause its `_active` instance variable to be set to `NO`.

That's it!  That is the informal protocol for transferring voices to and from the audio thread.  We'll see later that manipulating the `_active` instance variable is rarely done directly.  More usually it is handled by a pre-defined audio unit like an Envelope.

> Aside: Why is it safe to set the `_active` instance variable from a thread outside of the audio thread?
>
> In the chapter on PCMs, we said that care must be taken to not perform an operation that would block.
> Reading and writing variables across threads is allowed however.  The setting of the `_active` instance
> variable to `NO` from outside the audio thread is allowed.  In the callback block of the Context running
> inside the audio thread, the `_active` flag is read at the end of each period.  Inactive Voices are safely
> released.

## MSK Context Envelope

There is a formal protocol for Voices that generate an Envelope.  Envelopes in the Mclaren Synth Kit implement the standard attack, decay, sustain, release segments.  An `MSKContextEnvelope` implements the following methods.

``` objc
@protocol MSKContextEnvelope

- (BOOL) noteOff;
- (BOOL) noteAbort;
- (BOOL) noteReset:(int)idx;

@end
```

Invoking the `noteOff` method of an Envelope causes it to begin its release.  After the release time, the Envelope is marked inactive.

Invoking the `noteAbort` method causes an Envelope to drop to 0.0 by the end of the period.  The Envelope is then marked inactive.

Invoking `noteReset` causes an Envelope to start all over.

As stated, `MSKContextEnvelope` is a formal protocol, and not an implementation.  The McLaren Synth Kit provides two standard Envelope generators.

* `MSKExpEnvelope` - an exponential envelope
* `MSKLinEnvelope` - a linear envelope