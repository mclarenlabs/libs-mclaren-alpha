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

configureButtons
  but1 setTitle: '' .
  but2 setTitle: '' .
  but3 setTitle: '' .
  but4 setTitle: '' .
  
  but5 setTitle: 'SIN' .
  but5 onNoteOn: [ :midiNote :vel |
    oscModel setOsctype: MSK_OSCILLATOR_TYPE_SIN .
  ] .

  but6 setTitle: 'SAW' .
  but6 onNoteOn: [ :midiNote :vel |
    oscModel setOsctype: MSK_OSCILLATOR_TYPE_SAW .
  ] .

  but7 setTitle: 'SQUARE' .
  but7 onNoteOn: [ :midiNote :vel |
    oscModel setOsctype: MSK_OSCILLATOR_TYPE_SQUARE .
  ] .

  but8 setTitle: 'TRIANGLE' .
  but8 onNoteOn: [ :midiNote :vel |
    oscModel setOsctype: MSK_OSCILLATOR_TYPE_TRIANGLE .
  ] .
!

main

  "retain the script in the environment"
  currentScript := self .

  self configureButtons .

  envModel := MSKEnvelopeModel alloc init .
  oscModel := MSKOscillatorModel alloc init .

  self makeNote:60 .
  piano onNoteOn: [ :midiNote :vel |
    self makeNote:midiNote .
  ] .

]
