"listen to the Piano and send Notes to the Context"
[|

configurePiano

  piano onNoteOn: [ :midiNote :vel |
    pat := self makePat:midiNote .
    sched launch:pat .
  ] .

  piano onNoteOff: [ :midiNote :vel |
    vel := 0 .
  ] .

!

configureDispatcher

  disp onNoteOn: [ :midiNote :vel :chan |
    Transcript showLine:'onNoteOn' .
    pat := self makePat:midiNote .
    sched launch:pat .
  ] .

  disp onNoteOff: [ :midiNote :vel :chan |
    vel := 0 .
  ] .

!

noteOn:midiNote vel:vel
  Transcript show:'pianoNoteOn:'; showLine:vel .
  synth80 noteOn:midiNote vel:vel .
!

noteOff:midiNote vel:vel
  Transcript show:'pianoNoteOff:'; showLine:vel .
  synth80 noteOff:midiNote vel:vel .
!

"make a pattern that also plays the piano notes"
makePat:midiNote
  | pat1 |
  pat1 := Pattern alloc initWithName:'pat1' .
  
  pat1
    sync: #beat ; "remove this line to play immediately"
    play: [
      self noteOn:midiNote vel:127 .
    ] ;

    ticks: 30 ;
    play: [
      self noteOff:midiNote vel:0 .
    ] ;

    ticks: 10 ;
    play: [
      self noteOn:midiNote vel:100 .
    ] ;

    ticks: 30 ;
    play: [
      self noteOff:midiNote vel:0 .
    ] ;

    ticks: 10 ;
    play: [
      self noteOn:midiNote vel:80 .
    ] ;

    ticks: 30 ;
    play: [
      self noteOff:midiNote vel:0 .
    ] .

  ^pat1
!

main

  "Save the script in the environment"
  tripolet1Mod := self.

  "Set up the piano"
  self configurePiano.

  "Set up MIDI input"
  self configureDispatcher.

  "Make a synth80"
  synth80 := Synth80Synth alloc initWithCtx:ctx .
  Transcript show:'synth80:'; showLine:synth80 .

  " filepath := synth80 loadPatch:'BrightDrops' . "
  filepath := synth80 loadPatch:'DetunedBell' .
  Transcript show:'synth80:'; showLine:filepath .

  "make sure the metronome is started"
  metro start .

  Transcript showLine:'loaded'.
  ^self
]