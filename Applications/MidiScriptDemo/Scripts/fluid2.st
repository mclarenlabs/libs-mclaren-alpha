"
  Find FLUID Synth in the system.
  Map PIANO keys to Piano notes.
  Map PAD to percussion sounds.
  Map Gauge1 to Volume CC.

  Be sure to start fluidsynth running in a terminal first
    $ fluidsynth /usr/share/sounds/sf3/default-GM.sf3 
"


[| :global

"
  Create the Sequencer port.  Connect it to SEND to FLUIDSynth.
"

makeSeq | errp |
  
  Transcript showLine:('makeSeq').
  errp := NSErrorPtr alloc init.

  seq := ASKSeq alloc initWithError:errp.
  seq startSequencer.

  "Try to find the FLUID Synth"
  fluid := seq parseAddress:'FLUID' error:errp.
  Transcript showLine:('FLUID: ', fluid description).
  seq connectTo:fluid getClient port:fluid getPort error:errp.

!

"
  Configure PAD - its labels and MIDI notes to play percussion
"


configurePad

  pad setLabelFont: (NSFont userFontOfSize:12).


  "Column 0"
  pad labels replaceObjectAtIndex:0 withObject:'snare'.
  pad midiMap replaceObjectAtIndex:0 withObject:40.

  pad labels replaceObjectAtIndex:4 withObject:'clap'.
  pad midiMap replaceObjectAtIndex:4 withObject:39.

  pad labels replaceObjectAtIndex:8 withObject:'slap'.
  pad midiMap replaceObjectAtIndex:8 withObject:58.

  pad labels replaceObjectAtIndex:12 withObject:'claves'.
  pad midiMap replaceObjectAtIndex:12 withObject:75.

  "Column 1"
  pad labels replaceObjectAtIndex:1 withObject:'bass1'.
  pad midiMap replaceObjectAtIndex:1 withObject:35.

  pad labels replaceObjectAtIndex:5 withObject:'bass2'.
  pad midiMap replaceObjectAtIndex:5 withObject:36.

  pad labels replaceObjectAtIndex:9 withObject:'hihat'.
  pad midiMap replaceObjectAtIndex:9 withObject:46.

  pad labels replaceObjectAtIndex:13 withObject:'tamb'.
  pad midiMap replaceObjectAtIndex:13 withObject:54.

  "Column 2"
  pad labels replaceObjectAtIndex:2 withObject:'hi\nbong'.
  pad midiMap replaceObjectAtIndex:2 withObject:60.

  pad labels replaceObjectAtIndex:6 withObject:'lo\nbong'.
  pad midiMap replaceObjectAtIndex:6 withObject:61.

  pad labels replaceObjectAtIndex:10 withObject:'whist'.
  pad midiMap replaceObjectAtIndex:10 withObject:71.

  pad labels replaceObjectAtIndex:14 withObject:'triang'.
  pad midiMap replaceObjectAtIndex:14 withObject:81.

  "Column 3"
  pad labels replaceObjectAtIndex:15 withObject:'hi\ntimb'.
  pad midiMap replaceObjectAtIndex:15 withObject:65.

  pad labels replaceObjectAtIndex:11 withObject:'lo\ntimb'.
  pad midiMap replaceObjectAtIndex:11 withObject:66.

  pad labels replaceObjectAtIndex:7 withObject:'hi\nagogo'.
  pad midiMap replaceObjectAtIndex:7 withObject:67.

  pad labels replaceObjectAtIndex:3 withObject:'lo\nagogo'.
  pad midiMap replaceObjectAtIndex:3 withObject:68.

  "Refresh"
  pad setNeedsDisplay: 1.  "cause it to refresh"

!

"
  Configure gauge1 to send CC10 (volume) messages
"
configureGauge1

  gauge1 setLegend: 'vol'.
  gauge1 setFormat: '%g'.
  gauge1 setUserStart: 0.
  gauge1 setUserEnd: 127.
  gauge1 setCoarseAdj: 1.
  gauge1 setFineAdj: 1.
  gauge1 setDoubleValue: 127.

  "assign the block so that it is retained"
  gauge1CallbackBlock := [ :sender |
    val := sender doubleValue.
    MIDIVOL := 7.
    ev := ASKSeqEvent eventWithControlChange:MIDIVOL val:val chan:0.
    Transcript showLine:('event: ', ev description).
    ev setSubs.
    ev setDirect.
    seq output:ev.

  ].

  gauge1 setAction:#value:.
  gauge1 setTarget:gauge1CallbackBlock.

!

main
  |  local |

  "Retain the script because it is not assigned anywhere."
  self retain.

  "Register a button callback"
  but1 setTarget:self.
  but1 setMidiNote:60.
  but1 setTitle:'cello'.

  but2 setMidiNote:65.
  but2 setTarget:self.
  but2 setTitle:'cello'.

  but3 setTarget:self.
  but3 setMidiNote:70.
  but3 setTitle:'cello'.

  but4 setMidiNote:75.
  but4 setTarget:self.
  but4 setTitle:'cello'.

  self makeSeq.

  "Tell FLUID to play CELLO on channel 2"
  ev := ASKSeqEvent eventWithPgmChange:42 chan:2.
  ev setSubs.
  ev setDirect.
  seq output:ev.
  

  disp := ASKSeqDispatcher alloc initWithSeq:seq.
  disp setTarget:self.

  "listen for piano notes"
  piano setTarget:self.

  "listen for pad notes"
  pad setTarget:self.

  "configure the pad"
  self configurePad.

  "configure Gauge1: volume control"
  self configureGauge1.

  "be sure to return self"
  ^self
!
butNoteOn:midiNote vel:vel
  Transcript showLine:('butDown: ', midiNote description).
  ev := (ASKSeqEvent eventWithNoteOn:midiNote vel:vel chan:2)
     setSubs ;
     setDirect .
  seq output:ev.
!
butNoteOff:midiNote vel:vel
  Transcript showLine:('butUp: ', midiNote description).
  ev := ASKSeqEvent eventWithNoteOff:midiNote vel:vel chan:2.
  ev setSubs.
  ev setDirect.
  seq output:ev.
!
butKeyPressure:midinote vel:vel
  Transcript showLine:('butPressure: ', midinote description, ' ', vel description).
  "
    ev := ASKSeqEvent eventWithKeyPressure:midiNote vel:vel chan:2.
  "
  ev := ASKSeqEvent eventWithControlChange:1 val:vel chan:2.
  Transcript showLine:('event: ', ev description).
  ev setSubs.
  ev setDirect.
  seq output:ev.
!
pianoNoteOn:midiNote vel:vel
  Transcript showLine:('piano noteOn: ', midiNote description).
  ev := ASKSeqEvent eventWithNoteOn:midiNote vel:vel chan:0.
  ev setSubs.
  ev setDirect.
  seq output:ev.
!
pianoNoteOff:midiNote vel:vel
  Transcript showLine:('piano noteOff: ', midiNote description).
  ev := ASKSeqEvent eventWithNoteOff:midiNote vel:vel chan:0.
  ev setSubs.
  ev setDirect.
  seq output:ev.
!
padNoteOn:midiNote vel:vel
  ev := ASKSeqEvent eventWithNoteOn:midiNote vel:vel chan:9.
  ev setSubs.
  ev setDirect.
  seq output:ev.
!
padNoteOff:midiNote vel:vel
  ev := ASKSeqEvent eventWithNoteOff:midiNote vel:vel chan:9.
  ev setSubs.
  ev setDirect.
  seq output:ev.
!
seqNoteOn:midiNote vel:vel chan:chan
  piano pianoNoteOn:midiNote vel:vel.
  Transcript showLine:('seq noteOn: ', midiNote description).
!
seqNoteOff:midiNote vel:vel chan:chan
  piano pianoNoteOff:midiNote vel:vel.
  Transcript showLine:('seq noteOff: ', midiNote description).
!
gauge2Action:sender
  Transcript showLine:('gauge2Action: ').
  val := gauge2 doubleValue + 0.
  Transcript show:'gauge2: '.
  Transcript showLine:val.
]
