"listen to the Piano and send Notes to the Context"
[|

configurePiano
  piano onNoteOn: [ :midiNote :vel |
    self makeNoteOn:midiNote vel:vel .
  ] .

  piano onNoteOff: [ :midiNote :vel |
    self makeNoteOff:midiNote vel:vel .
  ] .
!

makeNoteOn:midiNote vel:vel
  Transcript show:'makeNoteOn:'; showLine:vel .
  synth80 noteOn:midiNote vel:vel .
!

makeNoteOff:midiNote vel:vel
  Transcript show:'makeNoteOff:'; showLine:vel .
  synth80 noteOff:midiNote vel:vel .
!

"make a pattern that also plays the piano notes"
makePat
  | pat1 |
  pat1 := Pattern alloc initWithName:'pat1' .
  
  pat1
    sync: #downbeat ;
    play: [
      act1 tickle .
      self makeNoteOn:72 vel:127 .
    ] ;

    ticks: 32 ;
    play: [
      self makeNoteOff:72 vel:0 .
    ] ;


    sync: #beat ;
    play: [
      self makeNoteOn:60 vel:65 .
    ] ;

    ticks: 32 ;
    play: [
      self makeNoteOff:60 vel:0 .
    ] ;

    sync: #beat ;
    play: [
      self makeNoteOn:60 vel:65 .
    ] ;

    ticks: 32 ;
    play: [
      self makeNoteOff:60 vel:0 .
      player := MSKSamplePlayer alloc initWithCtx:ctx .
      player setSample:sample .
      player compile .
      ctx addVoice:player .
    ] ;

    sync: #beat ;
    play: [
      self makeNoteOn:60 vel:65 .
    ] ;

    ticks: 32 ;
    play: [
      self makeNoteOff:60 vel:0 .
    ] .

  sched setLiveloop:'loop1' pat:pat1 .
!

main

  "Save the script in the environment"
  patternSynthAndSampleMod := self.

  "Set up the piano"
  self configurePiano.

  "Make a synth80"
  synth80 := Synth80Synth alloc initWithCtx:ctx .
  Transcript show:'synth80:'; showLine:synth80 .

  filepath := synth80 loadPatch:'FatBass' .
  Transcript show:'synth80:'; showLine:filepath .

  "Load a sample"
  sample := MSKSample sampleWithName:'clap1' .

  Transcript show:'sched:'; showLine:sched .
  self makePat .

  Transcript showLine:'loaded'.
  ^self
]