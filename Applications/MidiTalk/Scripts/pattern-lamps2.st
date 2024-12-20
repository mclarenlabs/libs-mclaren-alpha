"file: pattern-lamps2.st"

"
  This demonstration mixes beats and realtime and
  shows the pattern repeating twice.
"

pat2 := Pattern alloc initWithName:'Pattern2' .

pat2
  sync: #downbeat ;
  play: [ lamp4 off. lamp1 on. ] ;
  sync: #beat ;
  play: [ lamp1 off. lamp2 on. ] ;
  sync: #beat ;
  play: [ lamp2 off. lamp3 on. ] ;
  seconds: 0.1 ;
  play: [ lamp3 off. lamp4 on. ] ;
  repeat: 2 .

sched addLaunch:pat2 .

  