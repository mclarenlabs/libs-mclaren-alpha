"
   Demonstrate the cascade operator (;) for configuring objects.
"

[|

main

   gauge1
     setLegend:'g1' ;
     setFormat:'%03g' ;
     setUserStart:400 ;
     setUserEnd:500 ;
     setDoubleValue:480 ;
     setNeedsDisplay:1 .

   gauge2
     setLegend:'g2' ;
     setFormat:'%03g' ;
     setUserStart:100 ;
     setUserEnd:200 ;
     setDoubleValue:150 ;
     setNeedsDisplay:1 .

   gauge3
     setLegend:'g3' ;
     setFormat:'%03g' ;
     setUserStart:0 ;
     setUserEnd:100 ;
     setDoubleValue:20 ;
     setNeedsDisplay:1 .

   gauge4
     setLegend:'g4' ;
     setFormat:'%03g' ;
     setUserStart:0 ;
     setUserEnd:100 ;
     setDoubleValue:90 ;
     setNeedsDisplay:1 .

]