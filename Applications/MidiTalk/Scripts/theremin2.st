"Make an expressive button play and manipulate a note"
[|

configureButton:but note:note
  "configure button1 to play and modulate a note"
  " | envModel env oscModel osc | "

  but setMidiNote:note .

  but onNoteOn: [ :midiNote :vel |

    envModel := MSKEnvelopeModel alloc init .

    env := MSKExpEnvelope alloc initWithCtx:ctx .
    env setOneshot: NO .
    env setModel: envModel .
    env compile .

    oscModel := MSKOscillatorModel alloc init .

    osc := MSKGeneralOscillator alloc initWithCtx:ctx .
    osc setINote: midiNote .
    osc setModel: oscModel .
    osc setSEnvelope: env .
    osc compile .

    ctx addVoice: osc .
  ] .

  but onNoteOff: [ :midiNote :vel |
    env noteOff .
  ] .

  but onKeyPressure: [ :midiNote :vel |
    "modulate the cents property of the oscillator with the keypressure value"
    oscModel setCents: vel .
  ] .

!
main

  "Save the script in the environment"
  theremin2Mod := self.

  "Set up Button One"
  self configureButton:but1 note:64 .
  self configureButton:but2 note:68 .
  self configureButton:but3 note:75 .
  self configureButton:but4 note:79 .

  self configureButton:but5 note:84 .
  self configureButton:but6 note:88 .
  self configureButton:but7 note:95 .
  self configureButton:but8 note:99 .

  Transcript showLine:'Theremin2: Each button produces a note.' .
  Transcript showLine:'Drag while holding the button to modulate its pitch.' .
  ^self
]