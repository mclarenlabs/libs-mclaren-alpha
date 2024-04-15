# McLaren Synth Kit - Liveloops

We previously described Patterns: a sequence of instructions, possibly with some amount of repetition.  Patterns are of finite length, and cannot be changed while playing.  Liveloops are an extension to Patterns that allows them to be altered while playing --- that is why they are called "live."  A Liveloop can be re-defined and the new definition takes over the next measure so that the music is not interrupted.]

The reason a Liveloop is called what it is comes from two important qualities.

* "live" - the definition can be changed while it is running
* "loop" - it repeats automatically (and forever)

Regular patterns don't have either of these characteristics.

## A Simple Liveloop

In this section we are going to create a simple pattern, start it playing as a Liveloop, and then alter it while it is running.  Our initial pattern will play a low-tom on beats 1 and 3 and a clap on beats 2 and 4.  (See Applications/McLarenSynthKit/MskMetroDemo/Tests/testlive5.m for more details.)

First, we'll load some samples.

``` objc
MSKSample *tom = [[MSKSample alloc] initWithFilePath:@"./lidtom1.wav" error:&err];
if (err != nil) {
  NSLog(@"could not load sample 'lidtom1.wav'");
  exit(1);
}

MSKSample *lowtom = [tom resampleBy:1.5]; // lower the pitch

MSKSample *clap = [[MSKSample alloc] initWithFilePath:@"./clap1.wav" error:&err];
if (err != nil) {
  NSLog(@"could not load sample 'clap1.wav'");
  exit(1);
}

```

Then we'll create our simple 4-beat pattern.

``` objc
MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat1"];

[pat sync:@"downbeat"];
[pat thunk:^{
  [playSample:lowtom];
  }];
 
[pat sync:@"beat"];
[pat thunk:^{
  [playSample:clap];
  }];
 
[pat sync:@"beat"];
[pat thunk:^{
  [playSample:lowtom];
  }];
 
[pat sync:@"beat"];
[pat thunk:^{
  [playSample:clap];
  }];
```

When played, the pattern above first synchronizes with the next downbeat (waiting if it needs to), and then it will play the lowtom/clap/lowtom/clap pattern.  To play it as a live loop we add it to the scheduler with a name.

``` objc
[_sched Liveloop:@"liveloop1" pat:pat];
```

Now, start it playing by using the metronome transport controls.

``` objc
[_metro start];
```

Now let's suppose we would like to replace "pat1" with a different pattern that plays two hand-claps on the "and" of 3 and four.  Call this "pat2".

``` objc
MSKPattern *pat2 = [[MSKPattern alloc] initWithName:@"pat2"];

[pat sync:@"downbeat"];
[pat thunk:^{
  [playSample:lowtom];
  }];
 
[pat sync:@"beat"];
[pat thunk:^{
  [playSample:clap];
  }];
 
[pat sync:@"beat"];
[pat thunk:^{
  [playSample:lowtom];
  }];
  
[pat ticks:60]; // 60 ticks is an eight note duration
[pat thunk:^{
  [playSample:clap];
  }];

[pat sync:@"beat"];
[pat thunk:^{
  [playSample:clap];
  }];
```

The metronome is still running, and the scheduler is still playing the first pattern.  We can replace it while it's running.

``` objc
[_sched setLiveloop:"liveloop1" pat:pat2];
```

Replacing the named liveloop called "liveloop1" causes the following things to happen.  The initial pattern (named "pat1") will play to completion.  The scheduler will then look for the *current* definition of "liveloop1" from an internal table and it will find "pat2".

The new pattern "pat2" also waits for the next "downbeat" and synchronizes with the metronome and begins its four-beat sequence.  So what we will hear is the transition from "pat1" to "pat2" without any breaks in the rhythm.

## Other Operations on Liveloops

Liveloops can be replaced while they are playing (or when they are not playing).  And they can also be paused and re-enabled.  This is accomplished with the following methods.

``` objc
[_sched disableLiveloop:@"liveloop1"];

[_sched enableLiveloop:@"liveloop1"];
```

**DISABLE**
: Disabling a Liveloop sets a flag that instructs the scheduler to *not* re-start the named liveloop when it finishes playing.  The pattern in the named liveloop will finish what its doing and then stop.

**ENABLE**
: Enabling a Liveloop causes it to get launched again.  If the Liveloop is currently playing, then when it reaches the end it will start over.  If it had previously ended, it will be restarted.  The pattern of the liveloop will again synchronize with the metronome using the named events so that no beats will be dropped.

## Example

An example of a GUI application that allows starting, stopping, changing, disabling and re-enabling liveloops is in [Applications/McLarenSynthKit/LiveloopToy](/Applications/McLarenSynthKit/LiveloopToy).



## Contrasting Patterns and Liveloops

[_sched addPattern:pat1];
[_sched setLiveloop:@"loop1" pat:pat1];
