"
  This example shows a PDFMPhaseEnvelope oscillator driven by
  two envelopes: an ExpEnvelope controlling its amplitude, and
  a LinEnvelope controlling its phase.

  GUI controls are mapped as follows:
  gauges 1..4: attack, decay, sustain, release
  gauges 5, 6: harmonic, subharmonic
  but1: turn OFF V1 oscillator
  but2: turn ON V1 oscillator,
"
[|

"make an envelope model and tie some gauges to it"
makeEnvelopeModel
  envModel := MSKEnvelopeModel alloc init .

  "set slow attack for this demo"
  envModel setAttack: 0.5 .

  "configure gauge1 for ATTACK"
  gauge1
    setLegend: 'attack' ;
    setUserStart: 0.01 ;
    setUserEnd: 1.0 ;
    setCoarseAdj: 0.01 ;
    setFineAdj: 0.01 .

  "coordinate values"
  gauge1 setValue: envModel attack .
  gauge1 onChange: [ :value |
    envModel setAttack: value .
  ] .

  "configure gauge2 for DECAY"
  gauge2
    setLegend: 'decay' ;
    setUserStart: 0.01 ;
    setUserEnd: 0.5 ;
    setCoarseAdj: 0.01 ;
    setFineAdj: 0.01 .

  "coordinate values"
  gauge2 setValue: envModel decay .
  gauge2 onChange: [ :value |
    envModel setDecay: value .
  ] .

  "configure gauge3 for SUSTAIN"
  gauge3
    setLegend: 'sustain' ;
    setUserStart: 0.01 ;
    setUserEnd: 1.0 ;
    setCoarseAdj: 0.01 ;
    setFineAdj: 0.01 .

  "coordinate values"
  gauge3 setValue: envModel sustain .
  gauge3 onChange: [ :value |
    envModel setSustain: value .
  ] .

  "configure gauge4 for RELEASE"
  gauge4
    setLegend: 'release' ;
    setUserStart: 0.01 ;
    setUserEnd: 2.0 ;
    setCoarseAdj: 0.01 ;
    setFineAdj: 0.01 .

  "coordinate values"
  gauge4 setValue: envModel rel .
  gauge4 onChange: [ :value |
    envModel setRel: value .
  ] .

!

makeModulationModel
  modModel := MSKModulationModel alloc init .
  modModel setModulation: 5.0 .
!

"make an oscillator model and tie gauges 5 and 6 to it"
makeOscillatorModel
  oscModel := MSKOscillatorModel alloc init .
  oscModel setHarmonic: 3 .
  oscModel setSubharmonic: 5.

  "configure gauge5 for harmonic"
  gauge5
    setLegend: 'harmonic' ;
    setUserStart: 1 ;
    setUserEnd: 9 ;
    setCoarseAdj: 1 ;
    setFineAdj: 1 .

  gauge5 setValue: oscModel harmonic .
  gauge5 onChange: [ :value |
    oscModel setHarmonic: value .
  ] .

  "configure gauge6 for harmonic"
  gauge6
    setLegend: 'subharmonic' ;
    setUserStart: 1 ;
    setUserEnd: 9 ;
    setCoarseAdj: 1 ;
    setFineAdj: 1 .

  gauge6 setValue: oscModel subharmonic .
  gauge6 onChange: [ :value |
    oscModel setSubharmonic: value .
  ] .
!

"stop a sounding note"
stopNote:midiNote
  env := envDict @ midiNote .
  env isNil ifFalse: [
    env noteAbort .
  ] .
!

"create the voices (envelope and pdphaseoscillator) to sound a note"
makeNote:midiNote
  | fan expEnv linEnv v1 fmpd |


  expEnv := MSKExpEnvelope alloc initWithCtx:ctx .
  expEnv setIGain: 1.0 .
  expEnv setModel: envModel .
  expEnv compile .

  linEnv := MSKLinEnvelope alloc initWithCtx:ctx .
  linEnv setIGain: 1.0 .
  linEnv setModel: envModel .
  linEnv compile .

  
  fmpd := MSKFMPhaseEnvelopeOscillator alloc initWithCtx:ctx .
  fmpd setINote: midiNote .
  fmpd setModel: oscModel .
  fmpd setModulationModel: modModel .
  fmpd setSEnvelope: expEnv .

  includeV1 ifTrue: [
    v1OscModel := MSKOscillatorModel alloc init .
    v1OscModel setCents: 25 .

    v1 := MSKGeneralOscillator alloc initWithCtx:ctx .
    v1 setINote: midiNote .
    v1 setModel: v1OscModel .
    v1 setSEnvelope: linEnv .
    v1 compile .

    fmpd setSPhaseenvelope: v1 .
  ]
  ifFalse: [
    fmpd setSPhaseenvelope: linEnv .
  ] .
  fmpd compile .

  fan := MSKEnvelopeFanout alloc initWithCtx:ctx .
  fan setEnv1: expEnv .
  fan setEnv2: linEnv .
  fan compile .

  envDict setObject:fan forKey:midiNote .
  ctx addVoice: fmpd .
!

main
  pdphaseExampleMod := self .

  envDict := NSMutableDictionary alloc init .

  self makeEnvelopeModel .
  self makeModulationModel .
  self makeOscillatorModel .

  piano onNoteOn: [ :midiNote :vel |
    self stopNote: midiNote .
    self makeNote: midiNote .
  ] .

  piano onNoteOff: [ :midiNote :vel |
    env := envDict @ midiNote .
    env isNil ifFalse: [
      env noteOff .
    ] .
  ] .

  includeV1 := false .
  but1 setTitle: 'turn OFF V1' .
  but1 onNoteOn: [ :midiNote :vel |
    includeV1 := false .
  ] .

  but2 setTitle: 'turn ON V1' .
  but2 onNoteOn: [ :midiNote :vel |
    includeV1 := true .
  ] .
]