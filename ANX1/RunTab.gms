$setGlobal BaseName  ANX1
$setGlobal outDir    z:\Output\Env11\%BaseName%

Sets
   scen /
      BaU         "Reference"
      noShk       "Re-run the baseline with no shock"
   /
;

Table Sims(scen,*)
             Run   ifCal
BaU           1       1 
noShk         1       0 
;

alias(scen, BaUScen)
set mapBau(scen,BaUScen) /
   BaU.BaU
   noShk.BaU
/ ;

scalar ifAppend / 0 / ;
loop(scen,loop(mapBau(scen, BaUScen),
   if(Sims(Scen,"Run"),
      display Scen ;
      put_utility 'shell' / 'gams makCSV' ' --simName=' Scen.tl:0 ' --BauName=' BaUScen.tl:0 ' --ifAppend=' ifAppend:1:0 ' --simType=RcvDyn --ifCal=' Sims(Scen,"ifCal"):1:0 ' --baseName=%BaseName% --odir=%outDir% -idir=..\Model -scrdir=%outDir%' ;
   ) ;
   ifAppend = 1 ;
)) ;

*  Run the Excel updating file

execute.checkErrorLevel "%BaseName%Pivot.cmd"
$ifE errorLevel<>0 $abort 'Problem creating/updating Excel Pivot tables'