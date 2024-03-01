# McLaren Synth Kit - Metronome

The MSK Metronome provides a high-precision timing source that is linked to the ALSA MIDI clock.  With it, you can produce tick-accurate timing of MIDI events.

## Time Types

The Linux ALSA Sequencer interface provides many complex functions.  In addition to sending and receiving MIDI events, the SEQ interface provides functions for manipulating how MIDI events are handled in a timing queue.

There are two distinct time types in the MIDI system

* tick time
* realtime

Ticks are related to the beats of music.  By default, a SEQ is set up with 120 PPQ (parts-per-quarter) note.  When playing back events in a queue, the tempo of the queue determines the rate at which ticks are replayed.

Realtime maps events to absolute times (in seconds and nanoseconds) that are independent of the current tempo of the music.

## MIDI Clock

There is another time base in the system: the [MIDI clock](https://en.wikipedia.org/wiki/MIDI_beat_clock).  By definition, there are 24 MIDI clocks per quarter note.

With our default system set up, a MIDI clock occurs every 5 ticks, and a quarter note occurs every 24 clocks.

## The MSK Metronome

The MSK Metronome uses the timing of MIDI ticks to produce a beat-based timebase that can be used in any way you see fit.  Furthermore, the Metronome also has the notion of a time signature (4/4, 3/4, etc) to help map ticks to beats and measures.

The beat callback of the Metronome looks like this when used.

``` objc
metro.setTimesig:4 den:4;  // set 4/4 time

[metro onBeat:^(unsigned tick, int beat, int measure) {
   if (beat == 0)
     NSLog(@"down beat");
   else
     NSLog(@"beat: %d", beat)
  }]
```

When run, the metronome will start counting from beat 0 at tick 0 and will increment the measure every four beats.  The tick value returned is the running tick time with 120 PPQ.

The Metronome can also produce a MIDI clock callback.

``` objc
[metro onClock:^(unsigned tick, int clock, int beat, int measure) {
   ...
   }];
```

The clock will run from 0..23 for each beat.

## The Metronome Dispatch Queue

Events from the Metronome are dispatched from the dispatch queue of the underlying `ASKSeq`.  By default, this is a dedicated queue called "midi" for events handled by the ASK system.

It is important to be aware of the fact that callbacks from the Metronome are run on this queue.


## Controlling the Metronome

The Metronome has the following methods to control its operation.

* start
* stop
* kontinue

Each of these maps to operations on the underlying ALSA queue attached to the SEQ of the Metronome.  A side-effect of this design is that if your code is using the same queue for other things, starting and stopping the metronome will start and stop those events.  This is normally a good thing when the Metronome is the driving timebase for your system.

## Instantiating a Metronome

The `MSKMetronome` does not create an ALSA Seq on its own.  It needs to have one provided for it.

The following two methods illustrate a typical way a Seq and a Metronome would be created using the McLarenSynthKit.  The `makeSeq` method creates a Seq, whose only customizatin is that it is named "metronome."  This Seq is available for regular event sending and receiving, etc.

The `makeMetronome` method is initialized with the Seq previously created.  Callbacks can then be attached to the Metronome, and the start/stop/kontinue methods can be used to control its play position.

``` objc
- (void) makeSeq {

  ASKSeqOptions *options = [[ASKSeqOptions alloc] init];
  options->_sequencer_name = "metronome";

  NSError *error;
  _seq = [[ASKSeq alloc] initWithOptions:options error:&error];
  if (error != nil) {
    NSLog(@"Could not create sequencer.  Error:%@", error);
    exit(1);
  }
}

- (void) makeMetronome {

  NSError *error;
  _metro = [[MSKMetronome alloc] initWithSeq:_seq error:&error];

  // set tempo
  NSError *err;
  [_seq setTempo:90 error:&err];

  if (error != nil) {
    NSLog(@"Could not create metronome. Error:%@", error);
    exit(1);
  }
}
```

