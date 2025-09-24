$setGlobal BaseName ANX1
$setGlobal inDir .
$setGlobal outDir z:/Output/Env11/%BaseName%

Sets
   scen /
      COMP        "Standard comparative static diagnostic simulation"
   /
;

Table Sims(scen,*)
             Run   ifCal
COMP          1       0
;

loop(scen,
   if(Sims(Scen,"Run"),
*     Make a copy of the 'runsim' file
      put_utility 'shell' / 'copy runsim.gms run' Scen.tl:0 '.gms' ;
*     Run the simulation
      put_utility 'shell' / 'gams run' Scen.tl:0 ' --simName=' Scen.tl:0 ' --BauName=' Scen.tl:0 ' --simType=CompStat --ifCal=' Sims(Scen,"ifCal"):1:0 ' --baseName=%BaseName% --odir=%outDir% -idir=..\Model -scrdir=%outDir%' ;
   ) ;
) ;
