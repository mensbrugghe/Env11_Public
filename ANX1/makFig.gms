*  Load the model
$include "%baseName%Opt.gms"

execute_load "%odir%/%SIMNAME%.gdx", emiTot, emiTot0, procEmi0, procEmi ;

Parameters
   combEmi(r,ghg,t)
   prEmi(r,ghg,t)
;

prEmi(r,ghg,t)   = sum(a, procEmi0(r,ghg,a)*procEmi.l(r,ghg,a,t)) ;
combEmi(r,ghg,t) = emiTot0(r,ghg)*emiTot.l(r,ghg,t) - prEmi(r,ghg,t) ;

display combEmi ;

file csv1 / Fig1.csv / ;
put csv1 ;
csv1.pc=5 ;
csv1.nd=9 ;
put '' ; loop(ghg$(not sameas(ghg,"fgas")), put ghg.tl ; ) ;
csv1.pc=2 ;
loop(ghg,
   put ',"pr_', ghg.tl:card(ghg.tl), '"' ;
) ;
put / ;
csv1.pc=5 ;
loop(r,
   put r.tl ;
   loop(t$sameas(t,"base"),
      loop(ghg$(not sameas(ghg,"fgas")),
         put (combEmi(r,ghg,t)/cscale) ;
      ) ;
      loop(ghg,
         put (prEmi(r,ghg,t)/cscale) ;
      ) ;
      put / ;
   ) ;
) ;

execute_load "%odir%/%SIMNAME%.gdx", emiCTax ;

set red / 1*5 / ;

file csv3 / Fig3.csv / ;
put csv3 ;
csv3.pc=5 ;
csv3.nd=9 ;

put '' ; loop(red, put (5*red.val)::0 ; ) ; put / ;

put 'Comb' ;
loop(t$(ord(t) gt 2 and ord(t) lt 8),
   put (1000*emiCTax.l("WLD","CO2e","All",t)) ;
) ;
put / ;

scalar iter ;
put 'AllGHG' ;
for(iter = 12 downto 8 by 1,
   loop(t$(ord(t) eq iter),
      put (1000*emiCTax.l("WLD","CO2e","All",t)) ;
   ) ;
) ;
put / ;

file csv4a / Fig4a.csv / ;
put csv4a ;
csv4a.pc=5 ;
csv4a.nd=9 ;

put '' ; loop(red, put (5*red.val)::0 ; ) ; put / ;

put 'Comb' ;
loop(t$(ord(t) gt 2 and ord(t) lt 8),
   put (-100*(sum((r,ghg), combEmi(r,ghg,t)) / sum((r,ghg), combEmi(r,ghg,"base")) - 1)) ;
) ;
put / ;

scalar iter ;
put 'AllGHG' ;
for(iter = 12 downto 8 by 1,
   loop(t$(ord(t) eq iter),
      put (-100*(sum((r,ghg), combEmi(r,ghg,t)) / sum((r,ghg), combEmi(r,ghg,"base")) - 1)) ;
   ) ;
) ;
put / ;

file csv4b / Fig4b.csv / ;
put csv4b ;
csv4b.pc=5 ;
csv4b.nd=9 ;

put '' ; loop(red, put (5*red.val)::0 ; ) ; put / ;

put 'Comb' ;
loop(t$(ord(t) gt 2 and ord(t) lt 8),
   put (-100*(sum((r,ghg), prEmi(r,ghg,t)) / sum((r,ghg), prEmi(r,ghg,"base")) - 1)) ;
) ;
put / ;

scalar iter ;
put 'AllGHG' ;
for(iter = 12 downto 8 by 1,
   loop(t$(ord(t) eq iter),
      put (-100*(sum((r,ghg), prEmi(r,ghg,t)) / sum((r,ghg), prEmi(r,ghg,"base")) - 1)) ;
   ) ;
) ;
put / ;

execute_load "%odir%/%SIMNAME%.gdx", ev, ev0 ;

file csv5 / Fig5.csv / ;
put csv5 ;
csv5.pc=5 ;
csv5.nd=9 ;

put '' ; loop(red, put (5*red.val)::0 ; ) ; put / ;

put 'Comb' ;
loop(t$(ord(t) gt 2 and ord(t) lt 8),
   put (-100*(sum((r,h), ev.l(r,h,t)*ev0(r,h)) / sum((r,h), ev.l(r,h,"base")*ev0(r,h)) - 1)) ;
) ;
put / ;

scalar iter ;
put 'AllGHG' ;
for(iter = 12 downto 8 by 1,
   loop(t$(ord(t) eq iter),
      put (-100*(sum((r,h), ev.l(r,h,t)*ev0(r,h)) / sum((r,h), ev.l(r,h,"base")*ev0(r,h)) - 1)) ;
   ) ;
) ;
put / ;

