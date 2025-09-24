$setGlobal BaseName ANX1
$setGlobal inDir .
$setGlobal outDir z:/Output/Env11/%BaseName%

Sets
   scen /
      BaU         "Reference"
      noShk       "Re-run the baseline with no shock"
   /
;

Table Sims(scen,*)
             Run   ifCal    StartYear
BaU           1       1         2030
noShk         1       0         2030
;

alias (scen, scenStart) ;
set mapStart(scen,scenStart) /
   BaU.BaU
   noShk.BaU
/ ;

alias(scen, BaUScen)
set mapBau(scen,BaUScen) /
   BaU.BaU
   noShk.BaU
/ ;

loop(scen,loop(mapStart(scen,scenStart), loop(mapBau(scen, BaUScen),
   if(Sims(Scen,"Run"),
*     Make a copy of the 'runsim' file
      put_utility 'shell' / 'copy runsim.gms run' Scen.tl:0 '.gms' ;
*     Run the simulation
      if(Sims(scen,"StartYear") le 2017,
*        Not using an earlier simulation
         put_utility 'shell' / 'gams run' Scen.tl:0 ' --simName=' Scen.tl:0 ' --BauName=' BaUScen.tl:0 ' --startName=BaUx --startYear=' Sims(Scen,"StartYear"):4:0 ' --simType=RcvDyn --ifCal=' Sims(Scen,"ifCal"):1:0 ' --baseName=%BaseName% --odir=%outDir% -idir=..\Model -scrdir=%outDir%' ;
      else
*        Starting from an existing simulation
         put_utility 'shell' / 'gams run' Scen.tl:0 ' --simName=' Scen.tl:0 ' --BauName=' BaUScen.tl:0 ' --startName=' scenStart.tl:0 ' --startYear=' Sims(Scen,"StartYear"):4:0 ' --simType=RcvDyn --ifCal=' Sims(Scen,"ifCal"):1:0 ' --baseName=%BaseName% --odir=%outDir% -idir=..\Model -scrdir=%outDir%' ;
      ) ;
   ) ;
))) ;
