"launch a one-shot note on piano keypress"
[|

makeNote:midiNote
  | env osc |
  env := MSKExpEnvelope alloc initWithCtx:ctx .
  env setOneshot: true .
  env setShottime: 0.1 .
  env setModel: envModel .
  env compile .

  osc := MSKGeneralOscillator alloc initWithCtx:ctx .
  osc setINote:midiNote .
  osc setModel: oscModel .
  osc setSEnvelope: env .
  osc compile .

  ctx addVoice:osc
!

main

  "retain the script in the environment"
  currentScript := self .

  envModel := MSKEnvelopeModel alloc init .
  oscModel := MSKOscillatorModel alloc init .

  self makeNote:60 .
  piano onNoteOn: [ :midiNote :vel |
    self makeNote:midiNote .
  ] .

]
