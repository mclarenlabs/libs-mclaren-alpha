"Create a second sequencer interface"
[|

createSeqWithName:name
  | opts errp |
  opts := ASKSeqOptions alloc init .
  opts setSequencer_name: name .

  errp := NSErrorPtr alloc init .
  seq2 := ASKSeq alloc initWithOptions:opts error:errp .

  seq2 isNil ifTrue: [
    Transcript show:'Count not create seq: '; showLine:errp err .
  ]
  ifFalse: [
    disp2 := ASKSeqDispatcher alloc initWithSeq:seq2 .
  ]

!
main
  "Do not create seq2 if there is already one"
  seq2 isNil ifTrue: [
    self createSeqWithName:'foo' .
  ]

]