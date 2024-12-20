"listen to the Piano and send Notes to the Context"
[|

configurePiano

  "send piano events to this script.  It will send pianoNoteOn and pianoNoteOff"
  piano onNoteOn: [ :midiNote :vel |
    self pianoNoteOn:midiNote vel:vel .
  ].

  piano onNoteOff: [ :midiNote :vel |
    self pianoNoteOff:midiNote vel:vel .
  ].
!

"listen for Piano noteOn and send to the Tone Generator"
pianoNoteOn:midiNote vel:vel
  Transcript show:'pianoNoteOn:'; showLine:vel .
  synth80 noteOn:midiNote vel:vel .
!

"listen for Piano noteOff and send to the Tone Generator"
pianoNoteOff:midiNote vel:vel
  Transcript show:'pianoNoteOff:'; showLine:vel .
  synth80 noteOff:midiNote vel:vel .
!

main

  "Save the script in the environment"
  currentScript := self.

  "Set up the piano"
  self configurePiano.

  "Make a synth80"
  synth80 := Synth80Synth alloc initWithCtx:ctx .
  Transcript show:'synth80:'; showLine:synth80 .

  filepath := synth80 loadPatch:'BrightDrops' .
  filepath := synth80 loadPatch:'DetunedBell' .
  Transcript show:'synth80:'; showLine:filepath .

  Transcript showLine:'loaded'.
  ^self
]