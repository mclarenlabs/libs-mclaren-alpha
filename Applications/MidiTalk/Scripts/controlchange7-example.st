"This example sends and receives CC7 on Gauge6"
[|


main
  currentScript := self .

  VOLUME := 7 . "the MIDI controller for VOLUME"

  "set the label of gauge6 and update the GUI"
  gauge6
    setLegend:'volume' ;
    setNeedsDisplay: true .

  gauge6 onChange: [ :value |
    evt := ASKSeqEvent eventWithControlChange:VOLUME val:value chan:2 .
    evt setSubs .
    evt setDirect .
    seq output:evt .
  ] .

  disp onControlChange: [ :param :val :chan |
    ((2 == chan) and: (VOLUME == param)) ifTrue: [
      gauge6 setValue:val .
    ] .
  ] .
]