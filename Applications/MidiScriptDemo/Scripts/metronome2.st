"
  Use ALSA Midi USR1 to schedule Metronome ticks.
  Vary the tempo with a gauge.
"

[|

makeSeq | errp |
  
  Transcript showLine:('makeSeq').
  errp := NSErrorPtr alloc init.

  seq := ASKSeq alloc initWithError:errp.
  errp hasValue
    ifTrue: [
      Transcript showError:('Sequencer cannot be opened: ', (errp err) description).
  ].

  "set global vars for components of sequencer"
  client := seq getClient.
  port := seq getPort.
  queue := seq getQueue.

  "dispatch events back to this script"
  disp := ASKSeqDispatcher alloc initWithSeq:seq.
  disp setTarget:self.

  "start the sequencer running"
  seq startSequencer.
!


"
  Configure gauge1 to configure the SEQ tempo.
"
configureGauge1 | errp |

  gauge1 setLegend: 'tempo'.
  gauge1 setFormat: '%g'.
  gauge1 setUserStart: 30.
  gauge1 setUserEnd: 150.
  gauge1 setCoarseAdj: 1.
  gauge1 setFineAdj: 1.
  gauge1 setDoubleValue: 120.   "the initial queue tempo in BPM from ASKSEq.m"

  "assign the block so that it is retained"
  gauge1CallbackBlock := [ :sender |
    errp := NSErrorPtr alloc init.
    val := sender doubleValue.
    seq setTempo:val error:errp.
    errp hasValue
      ifTrue: [
        Transcript showError:('Sequencer cannot set tempo: ', (errp err) description).
      ].
  ].

  gauge1 setAction:#value:.
  gauge1 setTarget:gauge1CallbackBlock.

!

"
  Configure BUT4 to STOP and BUT3 to START
"

configureButtons

  but4
    setTitle: 'STOP' ;
    setTarget: self ;
    setNoteOnSelector: #stopAction.   "override selector called for button press"

  but3
    setTitle:'START' ;
    setTarget: self ;
    setNoteOnSelector: #startAction.  "override selector called for button press"
    
  but2 setTitle:''.
  but1 setTitle:''.

!

"called by BUT4"
stopAction
  running := false.
!

"called by BUT3"
startAction
  (running == false) ifTrue: [
    running := true.
    self scheduleMeasure:0.
  ].
!

noteOnAndOff:beat

  | duration midiNote |

  duration := quarterNoteDuration / 2.

  (beat == 0)
      ifTrue: [ midiNote := midiHiNote ]
      ifFalse: [midiNote := midiLoNote ].

  evOn := ASKSeqEvent eventWithNoteOn:midiNote vel:127 chan:0.
  evOn setScheduleTick:queue isRelative:1 ttick:(beat * quarterNoteDuration).
  evOn setDest:client port:0.
  seq output:evOn.
  
  evOff := ASKSeqEvent eventWithNoteOff:midiNote vel:0 chan:0.
  evOff setScheduleTick:queue isRelative:1 ttick:(beat * quarterNoteDuration + duration).
  evOff setDest:client port:0.
  seq output:evOff.
!

scheduleMeasure:measure
  | tick duration end ev |

  Transcript showLine:('scheduleMeasure: ', measure description).

  "schedule the four tones"
  #(0 1 2 3) do: [ :beat |
    self noteOnAndOff:beat.
  ].

  "schedule a callback to ourselves using USR1 for next measure"
  running == true
  ifTrue: [
    ev := ASKSeqEvent eventWithUsr1:(measure + 1) d1:0 d2:0.
    ev setScheduleTick:queue isRelative:true ttick:(4 * quarterNoteDuration).
    ev setDest:client port:0.
    seq outputDirect:ev.
  ].


!

seqNoteOn:midiNote vel:vel chan:chan
  toneGen noteOn:midiNote vel:vel.

!

seqNoteOff:midiNote vel:vel chan:chan
  toneGen noteOff:midiNote vel:vel.
!

seqUsr1:d0 d1:d1 d2:d2
  "d0 holds measure number"    	 
  self scheduleMeasure:d0.
!

seqUsr2:d0 d1:d1 d2:d2
  Transcript showLine:('usr2 ', d0 description, ' ', d1 description).
!

main

  midiHiNote := 80.
  midiLoNote := 62.

  "retain this script"
  currentScript := self.
  
  "the resolution of the Seq when allocated"
  quarterNoteDuration := 120.

  "configure a Seq and start the metronome"
  self makeSeq.

  "configure the gauge to control the tempo"
  self configureGauge1.

  "set up the STOP and START buttons"
  self configureButtons.

  "start the first measure"
  running := false.
  self startAction.

]
