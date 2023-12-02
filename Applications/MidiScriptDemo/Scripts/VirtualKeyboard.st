"
  Create a sequencer Client named 'virtkeyboard'.
  Configure the piano to draw keyDown and keyUp events from external input.
  Configure the piano to send noteOn an noteOff events to the seq.

  This script does not make any connections.  To create connections both ways do
    $ aconnect FOO virtkeyboard
    $ aconnect virtkeyboard FOO
"

[| :clientName

configureSeq

  "Set the property 'sequencer_name' on an options object"
  opts := ASKSeqOptions alloc init.
  opts setSequencer_name:clientName.

  "Configure and start the sequencer"
  errp := NSErrorPtr alloc init.
  seq := ASKSeq alloc initWithOptions:opts error:errp.
  errp hasValue
    ifTrue: [
      Transcript showError:('Sequencer cannot be opened: ', (errp err) description).
    ].

  "Configure an ALSA MIDI dispatcher to send events to this script"
  disp := ASKSeqDispatcher alloc initWithSeq:seq.
  disp setTarget:self.

  "Start it processing events"
  seq startSequencer.
!

configurePiano

  "send piano events to this script.  It will send pianoNoteOn and pianoNoteOff"
  piano setTarget:self.
!

"listen for Piano keypresses and send out as MIDI events"
pianoNoteOn:midiNote vel:vel
  Transcript showLine:('received piano noteOn: ', midiNote description).
  ev := ASKSeqEvent eventWithNoteOn:midiNote vel:vel chan:0.
  ev setSubs.
  ev setDirect.
  seq output:ev.
!

"listen for Piano keypresses and send out as MIDI events"
pianoNoteOff:midiNote vel:vel
  Transcript showLine:('received piano noteOff: ', midiNote description).
  ev := ASKSeqEvent eventWithNoteOff:midiNote vel:vel chan:0.
  ev setSubs.
  ev setDirect.
  seq output:ev.
!

"listen for external noteOn events and display on the Piano"
seqNoteOn:midiNote vel:vel chan:chan
  Transcript showLine:('received SEQ noteOn: ', midiNote description).
  piano pianoNoteOn:midiNote vel:vel.
!

"listen for external noteOff events and display on the Piano"
seqNoteOff:midiNote vel:vel chan:chan
  Transcript showLine:('received SEQ noteOff: ', midiNote description).
  piano pianoNoteOff:midiNote vel:vel.
!


main

  "Save the script in the environment"
  currentScript := self.

  "The ALSA client name to create"
  clientName := 'virtkeyboard'.

  "Set up the seq and give it a nice name"
  self configureSeq.

  "Set up the piano"
  self configurePiano.
]
