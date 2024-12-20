"Create an second context for an external device"
[|

randNote
  "choose a random note from a pentatic range"
  | notes data rand note |
  notes := #(63 65   68 70 72   75) .
  data := NSData dataWithRandomBytesOfLength:4 .
  rand := data deserializeIntAtIndex:0 .
  isNegative := rand isLessThan:0 .
  isNegative ifTrue: [
      rand := 0 - rand .
    ] .
  rand := rand modulo: notes count .
  note := notes @ rand .
  ^note
!

createNote:midiNote context:ctx
  |envModel1 env1 oscModel1 osc1 |
  envModel1 := MSKEnvelopeModel alloc init .

  env1 := MSKExpEnvelope alloc initWithCtx:ctx .
  env1 setOneshot: YES .
  env1 setShottime: 0.05 .
  env1 setModel: envModel1 .
  env1 compile .

  oscModel1 := MSKOscillatorModel alloc init .
  oscModel1 setOsctype: MSK_OSCILLATOR_TYPE_SAW .

  osc1 := MSKGeneralOscillator alloc initWithCtx:ctx .
  osc1 setINote: midiNote .
  osc1 setModel: oscModel1 .
  osc1 setSEnvelope: env1 .
  osc1 compile .

  "add it to the selected context"
  ctx addVoice: osc1 .
!

createContext:name
  | rqst errp |

  rqst := MSKContextRequest alloc init .
  rqst setRate: 44000 .
  rqst setPersize: 1024 .
  rqst setPeriods: 2 .

  errp := NSErrorPtr alloc init .
  ctx2 := MSKContext alloc initWithName:name andStream:0 error:errp .

  errp hasValue ifTrue: [
    Transcript show:'could not create context: '; showLine: errp err .
    ^nil
  ] .

  errp := NSErrorPtr alloc init .
  ok := ctx2 configureForRequest:rqst error:errp .

  ok ifFalse: [
    Transcript showLine:'could not configure request' .
    Transcript showLine: errp err .
    ^nil
  ] .

  errp := NSErrorPtr alloc init .
  ok := ctx2 startWithError:errp .
  
  ok ifFalse: [
    Transcript showLine:'could not start thread' .
    ^nil
  ]
!

main

  "retain reference to this script"
  currentScript := self .
  
  ctx2 isNil ifTrue: [
    self createContext:'hw:MGXU' .
  ] .

  "Construct a pattern that plays a random note on each of the contexts"
  pat1 := Pattern alloc initWithName:'pattern1' .
  pat1
    sync: #beat ;
    play: [ self createNote:self randNote context: ctx . ];
    sync: #beat ;
    play: [ self createNote:self randNote context: ctx2 . ];
    repeat: 8 .

  metro start .
  sched launch:pat1 .
  sched launch:pat1 .
  

]