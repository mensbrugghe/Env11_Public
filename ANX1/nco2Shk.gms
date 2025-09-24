if(sameas(tsim,"ALL"),
   loop(ml,
      emitax.fx("USA","CO2",aa,tsim) = 0.001*40*ord(ml)/card(ml) ;
      procEmiTax.fx("USA",GHG,a,tsim) = 0.001*40*ord(ml)/card(ml) ;
      if(ord(ml) lt card(ml),
         $$batinclude "solve.gms" core
      ) ;
   ) ;
elseif(sameas(tsim,"CO2")),
   loop(ml,
      emitax.fx("USA","CO2",aa,tsim) = 0.001*40 ;
      procEmiTax.fx("USA",GHG,a,tsim) = 0.001*40*(1 - ord(ml)/card(ml))  ;
      if(ord(ml) lt card(ml),
         $$batinclude "solve.gms" core
      ) ;
   ) ;
elseif(sameas(tsim,"NCO2")),
   loop(ml,
      emitax.fx("USA","CO2",aa,tsim) = 0.001*40*(1 - ord(ml)/card(ml)) ;
      procEmiTax.fx("USA",GHG,a,tsim) = 0.001*40*ord(ml)/card(ml) ;
      if(ord(ml) lt card(ml),
         $$batinclude "solve.gms" core
      ) ;
   ) ;
elseif(sameas(tsim,"CO2CAP")),
   loop(ml,
      emitax.fx("USA","CO2",aa,tsim) = 0.001*40*ord(ml)/card(ml) ;
      procEmiTax.fx("USA",GHG,a,tsim) = 0.001*40*(1 - ord(ml)/card(ml)) ;
      if(ord(ml) lt card(ml),
         $$batinclude "solve.gms" core
      ) ;
   ) ;

   rq("USA") = yes ;
   ifEmiCap("USA","CO2","ALL") = yes ;
   ifEmiRCap("USA","CO2",aa)   = yes ;
   EmiCap.fx("USA","CO2","All",tsim) = (3324.71 + 48.65)*cscale ;

   emitax.lo("USA","CO2",aa,tsim) = -inf ;
   emitax.up("USA","CO2",aa,tsim) = +inf ;
   emiCTAX.lo("USA","CO2","ALL",tsim) = 0 ;
   emiCTAX.up("USA","CO2","All",tsim) = +inf ;
) ;

