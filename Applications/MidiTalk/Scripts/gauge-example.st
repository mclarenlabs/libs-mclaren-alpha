[|
"customize a gauge and tie it to the piano"

main
  gauge6 setLegend:'PianoInput' .
  gauge6 setColor: NSColor redColor .
  gauge6 setNeedsDisplay:true .

  piano onNoteOn: [ :midiNote :vel |
    gauge6 setValue:midiNote .
  ] .

]
