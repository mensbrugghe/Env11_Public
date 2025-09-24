if(sameas(tsim,"Shock"),

   if(0,

*     Example of a single country reduction in emissions

      rq("EUR") = yes ;

      ifEmiCap("EUR","CO2","All") = yes ;
      ifEmiRCap(r,"CO2",aa)$(mapr("EUR",r) and mapets("All",aa)) = yes ;

      emiCap.fx("EUR","CO2","All",tsim) = 0.9*emiTot0("EUR","CO2")*emiTot.l("EUR","CO2",t0) ;

      emiTax.lo(r,"CO2",aa,tsim)$(mapr("EUR",r) and mapets("All",aa)) = -inf ;
      emiTax.up(r,"CO2",aa,tsim)$(mapr("EUR",r) and mapets("All",aa)) = +inf ;
      emiCTAX.lo("EUR","CO2","All",tsim) = 0 ;
      emiCTAX.up("EUR","CO2","All",tsim) = +inf ;

   else

*     Example of a global coalition

      rq("WLD") = yes ;
      ifEmiCap("WLD","CO2","All") = yes ;
      ifEmiRCap(r,"CO2",aa)$(mapr("WLD",r) and mapets("All",aa)) = yes ;

      emiCap.fx("WLD","CO2","All",tsim) = 0.9*sum(mapr("WLD",r), emiTot0(r,"CO2")*emiTot.l(r,"CO2",t0)) ;

      emiTax.lo(r,"CO2",aa,tsim)$(mapr("WLD",r) and mapets("All",aa)) = -inf ;
      emiTax.up(r,"CO2",aa,tsim)$(mapr("WLD",r) and mapets("All",aa)) = +inf ;
      emiCTAX.lo("WLD","CO2","All",tsim) = 0 ;
      emiCTAX.up("WLD","CO2","All",tsim) = +inf ;
   ) ;
) ;
