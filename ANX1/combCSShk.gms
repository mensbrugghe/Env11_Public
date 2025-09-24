if(ord(tsim) gt 2,

*  Cap "CO2e" emissions--excluding process emissions

   rq("WLD") = yes ;

   ifEmiCap("WLD","CO2e","ALL") = yes ;

*  Phase in a 30% reduction
   work = ((0.75-1)/(card(t)-2))*(ord(tsim)-2) + 1 ;
   put screen ; put / ;
   put card(t), ord(tsim), work ;
*  abort "Temp" ;

   EmiCap.fx("WLD","CO2e","All",tsim) = work*sum(r, emiTotETS.l(r, "CO2e", "ALL", t0)*emiTotETS0(r,"CO2e","All")) ;

   loop(mapEM("CO2e", ghg),
      ifEmiRCap(r,ghg,aa)      = yes ;
      emitax.lo(r,ghg,aa,tsim) = -inf ;
      emitax.up(r,ghg,aa,tsim) = +inf ;
   ) ;

   emiCTAX.lo("WLD","CO2e","ALL",tsim) = 0 ;
   emiCTAX.up("WLD","CO2e","All",tsim) = +inf ;
) ;
