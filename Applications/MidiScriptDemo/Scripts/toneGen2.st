"
  Configure the Piano to send noteOn an noteOff events to the ToneGenerator.
  Configure Gauges to set Attack/Sustain/Release levels.
"

[| :globals

configureGauge1
  gauge1
    setLegend:'attack' ;
    setUserStart: 0.01 ;
    setUserEnd: 1.0 ;
    setCoarseAdj: 0.01 ;
    setFineAdj: 0.01 ;
    setDoubleValue: (gen attackTime) ;
    setNeedsDisplay: 1 .

  "configure target and action.  assign the block so that it is retained in a script"
  callbackBlock1 := [ :sender |
    val := sender doubleValue.
    toneGen setAttackTime: val.
  ].
    
  gauge1
    setAction: #value: ;    "the selector for a block with one arg"
    setTarget: callbackBlock1 .
!

configureGauge2
  gauge2
    setLegend:'sustain\nlevel' ;
    setUserStart: 0.1 ;
    setUserEnd: 1.0 ;
    setCoarseAdj: 0.01 ;
    setFineAdj: 0.01 ;
    setDoubleValue: (toneGen sustainLevel) ;
    setNeedsDisplay: 1 .

  "configure target and action.  assign the block so that it is retained in a script"
  callbackBlock2 := [ :sender |
    val := sender doubleValue.
    toneGen setSustainLevel: val.
  ].
    
  gauge2
    setAction: #value: ;    "the selector for a block with one arg"
    setTarget: callbackBlock2 .
!

configureGauge3
  gauge3
    setLegend:'release' ;
    setUserStart: 0.01 ;
    setUserEnd: 2.0 ;
    setCoarseAdj: 0.01 ;
    setFineAdj: 0.01 ;
    setDoubleValue: (toneGen releaseTime) ;
    setNeedsDisplay: 1 .

  "configure target and action.  assign the block so that it is retained in a script"
  callbackBlock3 := [ :sender |
    val := sender doubleValue.
    toneGen setReleaseTime: val.
  ].
    
  gauge3
    setAction: #value: ;    "the selector for a block with one arg"
    setTarget: callbackBlock3 .
!

configurePiano

  "send piano events to this script.  It will send pianoNoteOn and pianoNoteOff"
  piano setTarget:self.
!

"listen for Piano noteOn and send to the Tone Generator"
pianoNoteOn:midiNote vel:vel
  toneGen noteOn:midiNote vel:vel.
!

"listen for Piano noteOff and send to the Tone Generator"
pianoNoteOff:midiNote vel:vel
  toneGen noteOff:midiNote vel:vel.
!

main

  "Save the script in the environment"
  currentScript := self.

  "Set up the piano"
  self configurePiano.

  "Configure gauge1 for Attack Time (seconds)"
  self configureGauge1.

  "Configure gauge2 for Sustain Level (range 0..1)"
  self configureGauge2.

  "Configure gauge3 for Release time (seconds)"
  self configureGauge3.

]
