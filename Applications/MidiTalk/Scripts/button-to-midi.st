"Button one sends a midi note C"
[|

main
  but1 onNoteOn: [ :midiNote :vel |
    ev := ASKSeqEvent eventWithNoteOn:62 vel:127 chan:0 .
    ev setSubs .
    ev setDirect .
    seq output:ev .
  ] .
    
  but1 onNoteOff: [ :midiNote :vel |
    ev := ASKSeqEvent eventWithNoteOff:62 vel:0 chan:0 .
    ev setSubs .
    ev setDirect .
    seq output:ev .
  ] .
    


]
