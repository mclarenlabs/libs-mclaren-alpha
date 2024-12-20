pat := Pattern alloc initWithName:'introAndRepeat' .
pat
  sync: #beat ; play: [ Transcript showLine:'one' . ] ;
  sync: #beat ; play: [ Transcript showLine:'two' . ] ;
  intro ;
  sync: #beat ; play: [ Transcript showLine:'three' . ] ;
  sync: #beat ; play: [ Transcript showLine:'four' . ] ;
  repeat: 4 .

sched addLaunch:pat .
