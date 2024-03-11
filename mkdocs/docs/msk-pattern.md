# McLaren Synth Kit - Patterns

Using the Metronome directly is appropriate for obtaining tick-accurate timing and scheduling simple repeating sequences.  With the Metronome "beat" callback it is easy to construct a program that plays beats.

For more complex repeating patterns, the `Pattern` facility can be helpful, and can make creating repeating musical motifs more fun.

## What is a Pattern?

A Pattern is a repeating sequence of instructions, some of which specify the passage of time, others execute code.  Patterns are built up by calling methods on a Pattern object.

In the snippet below, assume that there is Synthesizer object named `synth` that has a method `playNote:`.  The following defines a pattern that executes four times and then exits.

``` objc
Pattern *pat = [[Pattern alloc] initWithName:'pat1'];

[pat sync:@"beat"];
[pat thunk:^{
  [synth playNote:64];
  }];

[pat sync:@"beat"];
[pat thunk:^{
  [synth playNote:60];
  }];

[pat sync:@"beat"];
[pat thunk:^{
  [synth playNote:60];
  }];

[pat sync:@"beat"];
[pat thunk:^{
  [synth playNote:60];
  }];

[pat repeat:4];
```

The Pattern methods are a little-language for specifying how to synchronize with the Metronome.  This pattern says synchronize with a beat (beat 0) and then play note 64.  Then synchronize with the next beat (beat 1) and play note 60.  Because there are fourr `sync:` calls, the pattern synchronizes with each beat in a 4/4 measure.  The `repeat:` call is an annotation on the pattern that specifies its repeat factor.

A Pattern can also specify the passage of time in ways other than synchronizing with events.  A Pattern can spcify the passage of time in "ticks" or "realtime".

``` objc
Pattern *pat2 = [[Pattern alloc] initWithName:'pat2'];

[pat2 sync:@"beat"];
[pat2 thunk:^{ doSomething(); }];

[pat2 ticks:31];
[pat2 thunk:^{ doSomething(); }];

[pat2 seconds:1.3];
[pat2 thunk:^{ doSomethingElse(); }];

```

When run, the Pattern above synchronizes with the next Metronome beat and performs `doSomething()`.  It then sleeps for 31 ticks (remember, there are 120 ticks per quarter note) and performs `doSomething()` again.  It then sleeps for 1.3 seconds and then performs `doSomethingElse()`.

This pattern is not annotate with a `repeat:` repetition factor, so it executes once and exits.

## Synchronization Events

At the present time there are only a small number of named synchronization events.

* beat - the Metronome beat callback 
* downbeat - Metronome beat callback with beat==0
* clock - the MIDI beat clock, 24 clocks per quarter

## Sub-patterns

Patterns can call other patterns, which execute as subroutines.  The Pattern `pat:` method specifies a sub-pattern.  A sub-pattern blocks its parent until it is done.

Consider the following pattern.  It plays four sixteenth notes, synchronized with the next beat.

``` objc
Pattern *pat3 = [[Pattern alloc] initWithName:@"pat3"];
[pat3 sync:@"beat"];
[pat3 thunk:^{ [synth playNote:70; ]}];
[pat ticks:30];
[pat3 thunk:^{ [synth playNote:70; ]}];
[pat ticks:30];
[pat3 thunk:^{ [synth playNote:70; ]}];
[pat ticks:30];
[pat3 thunk:^{ [synth playNote:70; ]}];
```

This pattern could be incorporated into a parent pattern.  The pattern below plays a note on beat 0 and beat 1, on beat 2 it plays four sixteenths, and then on beat 3 it plays a note.  The pattern then repeats 4 times.

``` objc
Pattern *pat4 = [[Pattern alloc] initWithName:@"pat4"];

[pat4 sync:@"beat"];
[pat4 thunk:^{ [synth playNote:64; ]}];

[pat4 sync:@"beat"];
[pat4 thunk:^{ [synth playNote:60; ]}];

[pat4 pat:pat3]; // play the sixteenth notes

[pat4 sync:@"beat"];
[pat4 thunk:^{ [synth playNote:60; ]}];
```


## Patterns in StepTalk

StepTalk is a Smalltalk-dialect interpreter that can call Objective-C classes and methods.  Using Smalltalk syntax with Patterns is slightly prettier because of the "cascade" operator (operator semicolon ";" in Smalltalk).

With StepTalk, the first example of this chapter looks like the following.

``` smalltalk
pat := Pattern alloc initWithName:'pat1'.

pat
  sync: #beat;
  block: [ synth playNote:64. ];

  sync: #beat;
  block: [ synth playNote:60. ];

  sync: #beat;
  block: [ synth playNote:60. ];

  sync: #beat;
  block: [ synth playNote:60. ];

  repeat: 4.
```

Note: we haven't quite finished producing a working demo with the McLaren Synth Kit integrated with StepTalk, but when we do, this is what patterns will look like.

## Running Patterns

So far, we have shown how to create patterns, but we haven't shown how to start them or stop them.  For that we need to create a Scheduler and attach it to a Metronome.  Once attached, the Scheduler TAKES OVER all of the callbacks of the Metronome and is controlled by the start/stop/kontinue methods of the Metronome.

Assume that we have previously created a Metronome named `_metro`.  Then the following creates a Scheduler.

``` objc
@property Scheduler *sched;

- (void) makeScheduler {

  _sched = [[Scheduler alloc] init];
  [_sched registerMetronome:_metro];
}
```

Patterns can be added to the Scheduler to be launched when the Scheduler starts.  The following shows how two patterns are added to a Scheduler to start when the Metronome starts.

``` objc
[_sched addLaunch:pat];
[_sched addLaunch:pat4];
```

The tempo of the playing and the starting and stopping are controlled through the underlying Metronome.

``` objc
[_metro setTempo:90 error:&err];
[_metro start];
```

## Logging Patterns

By default, the Scheduler logs the progress of Patterns using `NSLog`.  This behavior can be changed by disabling the logging facility of the scheduler.

``` objc
_sched.log = NO;
```

When enabled, a detailed description of each pattern-related callback will be printed. Some sample output is shown below.  It was collected from the `test8` test in the Tests directory.

``` console
2024-03-11 09:15:38.176 test8[106681:106681]       0    0.0 pat1 #beat
2024-03-11 09:15:38.176 test8[106681:106681]       0    0.0    ONE
2024-03-11 09:15:38.176 test8[106681:106681]       0    0.0 pat2 #beat
2024-03-11 09:15:38.204 test8[106681:106683]       5    0.0 pat1 #clock
2024-03-11 09:15:38.204 test8[106681:106683]       5    0.0    CLOCK AFTER ONE
2024-03-11 09:15:38.843 test8[106681:106683]     120    0.1 pat2 #beat
2024-03-11 09:15:38.843 test8[106681:106683]     120    0.1 pat1 #beat
2024-03-11 09:15:38.843 test8[106681:106683]     120    0.1    TWO
2024-03-11 09:15:39.510 test8[106681:106683]     240    0.2 pat2 #beat
2024-03-11 09:15:39.510 test8[106681:106683]     240    0.2 sixt #beat
2024-03-11 09:15:39.676 test8[106681:106683]     270    0.2 sixt ticks
2024-03-11 09:15:39.843 test8[106681:106687]     300    0.2 sixt ticks
2024-03-11 09:15:40.010 test8[106681:106683]     330    0.2 sixt ticks
2024-03-11 09:15:40.176 test8[106681:106687]     360    0.3 pat2 #beat
2024-03-11 09:15:40.176 test8[106681:106687]     360    0.3 sixt #beat
2024-03-11 09:15:40.343 test8[106681:106683]     390    0.3 sixt ticks
2024-03-11 09:15:40.510 test8[106681:106687]     420    0.3 sixt ticks
2024-03-11 09:15:40.676 test8[106681:106683]     450    0.3 sixt ticks
2024-03-11 09:15:40.676 test8[106681:106683]     450    0.3    INTRO ONE
2024-03-11 09:15:41.143 test8[106681:106683]   2.967    1.0 pat2 seconds
```

Let's strip off the standard NSLog prefix and just look at the output of the scheduler.  The first column is the time in TICKS or SECONDS.  If the pattern event was due to a metronome synchronization or song-position time then the time is reported in ticks.  If it is a realtime event, then the time is reported in seconds.

The next column is the song position in measures and beats.  Both start at 0.  Here we are in 4/4 time so the beat repeats after 3.

The third column is the name of the pattern executing.  We see patterns named 'pat1', 'pat2' and 'sixt' in the example.

The fourth column is the synchronization event: either an event name like "#beat" or a delay operator name like "ticks" or "seconds".

``` console
       0    0.0 pat1 #beat
       0    0.0    ONE
       0    0.0 pat2 #beat
       5    0.0 pat1 #clock
       5    0.0    CLOCK AFTER ONE
     120    0.1 pat2 #beat
     120    0.1 pat1 #beat
     120    0.1    TWO
     240    0.2 pat2 #beat
     240    0.2 sixt #beat
     270    0.2 sixt ticks
     300    0.2 sixt ticks
     330    0.2 sixt ticks
     360    0.3 pat2 #beat
     360    0.3 sixt #beat
     390    0.3 sixt ticks
     420    0.3 sixt ticks
     450    0.3 sixt ticks
     450    0.3    INTRO ONE
   2.967    1.0 pat2 seconds
```

## What can execute in blocks?

As with the Metronome callbacks, the Scheduler "thunk" invocations are also performed on the MIDI dispatch queue by default.  As a programmer, you should take care to not perform operations in the thunk that could block execution or interfere with other threads.

Calls to `NSLog` are generally alright during development.

## Conclusion

The Pattern mechanism abstracts the calllbacks of the Metronome and provides a little-language for specifying rhythmic phrases.  The pattern mechanism only specifies the passage of time in varying ways and leaves the execution of what to do at an instant up to an open-ended block invocation.  This leaves open the option to launch context sounds, control model parameters, or do other things.

Because Patterns are tied to the MIDI clock of the ALSA Seq, Patterns provide tick-accurate timing in a user-friendly way.

## Postscript

Patterns are a very recent addition to the McLaren Synth Kit, and are more likely subject to change more than other parts of the kit.  Additionally, they are not yet a standard part of the library.  Patterns are implemented in files `Pattern.h` and `Pattern.m` in the `MskMetroDemo` directory.

