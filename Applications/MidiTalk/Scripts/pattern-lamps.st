"file: pattern-lamps.st"

pat1 := Pattern alloc initWithName:'Pattern1' .
pat1
  sync: #downbeat ;
  play: [ lamp4 off. lamp1 on. ] ;
  sync: #beat ;
  play: [ lamp1 off. lamp2 on. ] ;
  sync: #beat ;
  play: [ lamp2 off. lamp3 on. ] ;
  sync: #beat ;
  play: [ lamp3 off. lamp4 on. ] .

sched addLaunch:pat1 .

  