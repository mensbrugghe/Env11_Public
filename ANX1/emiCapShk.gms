if(ord(tsim) gt 2,

*  Cap "CO2e" emissions--including process emissions

   rq("WLD") = yes ;

   ifEmiCap("WLD","CO2e","ALL") = yes ;

*  Phase in a 30% reduction
   if(ord(tsim) lt 8,
      work = ((0.75-1)/(7-2))*(ord(tsim)-2) + 1 ;
   else
      work = ((1-0.75)/(12-7))*(ord(tsim)-8) + 0.75 ;
   ) ;
   put screen ; put / ;
   put tsim.tl, work / ; putclose screen ;

   EmiCap.fx("WLD","CO2e","All",tsim) = work*sum(r, emiTotETS.l(r, "CO2e", "ALL", t0)*emiTotETS0(r,"CO2e","All")) ;

   loop(mapEM("CO2e", ghg),
      ifEmiRCap(r,ghg,aa)      = yes ;
      emitax.lo(r,ghg,aa,tsim) = -inf ;
      emitax.up(r,ghg,aa,tsim) = +inf ;
      if(ord(tsim) ge 8,
         ifProcEmiRCap(r,ghg,a)   = yes ;
         procEmiTax.lo(r,ghg,a,tsim) = -inf ;
         procEmiTax.up(r,ghg,a,tsim) = +inf ;
      ) ;
   ) ;

   emiCTAX.lo("WLD","CO2e","ALL",tsim) = 0 ;
   emiCTAX.up("WLD","CO2e","All",tsim) = +inf ;
) ;
