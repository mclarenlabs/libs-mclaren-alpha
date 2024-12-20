"Record from the rec context into a Sample"
[|

configureButton
  but1 onNoteOn: [ :midiNote :vel |
    self recordToSample .
    recorder recOn .
  ] .

  but1 onNoteOff: [ :midiNote :vel |
    recorder recOff .
    playsample := recsample .
  ] .
!

playSavedSample
  player := MSKSamplePlayer alloc initWithCtx:ctx .

  player setSample: playsample .
  player compile .

  ctx addVoice: player .
!

recordToSample
  recsample := MSKSample alloc initWithFrames:(44100*4) channels:2 .
  recorder := MSKSampleRecorder alloc initWithCtx:rec .

  recorder setSample: recsample .
  recorder setSInput: rec rbuf .
  recorder compile .

  rec addVoice: recorder .
!

main

  currentScript := self.

  playsample := MSKSample alloc initWithFrames:(44100*4) channels:2 .

  self configureButton .

  pat1 := Pattern alloc initWithName:'pattern1' .
  pat1
    sync: #beat ;
    play: [self playSavedSample . ] ;
    repeat: 100 .
  
  sched addLaunch:pat1 .
  metro start .
]