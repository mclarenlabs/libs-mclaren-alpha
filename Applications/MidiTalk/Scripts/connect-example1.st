"An example of (safely) connecting a MIDI device"
[|

connectFromDevice:name
  "lookup name on the SEQ and connect FROM it to receive events"

  errp := NSErrorPtr alloc init .
  addr := seq parseAddress:name error:errp .

  addr isNil ifTrue: [
    Transcript show:'Cannot find device: '; showLine:name .
    ^nil
  ] .

  Transcript show:'Found device at: '; showLine:addr .

  errp := NSErrorPtr alloc init .
  success := seq connectFrom:addr getClient port:addr getPort error:errp .

  success ifFalse: [
    Transcript show:'Could not connect from device: '; showLine:name .
    Transcript showLine:'Possibly already connected. ' .
  ]
  ifTrue: [
    Transcript show:'Connected device: '; showLine:name .
  ]
!

main
  currentScript = self .
  self connectFromDevice:'Xkey25' .

]
