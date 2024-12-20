"Make an expressive button play and manipulate a note"
[|

configureBut1
  "configure button1 to play and modulate a note"

  but1 setMidiNote:64 .

  but1 onNoteOn: [ :midiNote :vel |

    env1 := MSKExpEnvelope alloc initWithCtx:ctx .
    env1 setOneshot: NO .
    env1 setModel: envModel1 .
    env1 compile .

    osc1 := MSKGeneralOscillator alloc initWithCtx:ctx .
    osc1 setINote: midiNote .
    osc1 setModel: oscModel1 .
    osc1 setSEnvelope: env1 .
    osc1 compile .

    ctx addVoice: osc1 .
  ] .

  but1 onNoteOff: [ :midiNote :vel |
    env1 noteOff .
  ] .

  but1 onKeyPressure: [ :midiNote :vel |
    "modulate the cents property of the oscillator with the keypressure value"
    oscModel1 setCents: 2 * vel .
  ] .

!
main

  "Save the script in the environment"
  currentScript := self.

  envModel1 := MSKEnvelopeModel alloc init .
  oscModel1 := MSKOscillatorModel alloc init .

  "Set up Button One"
  self configureBut1 .

  Transcript showLine:'loaded'.
  ^self
]