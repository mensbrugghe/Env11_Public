if(sameas(tsim,"Shock"),
   pnum.fx(tsim) = 1.5 ;
*  procEmiTax.fx(r,ghg,a,tsim) = 0.001*250 ;
   lambdanrgp.fx(r,a,v,tsim) = 1.0 ;
   lambdanrgc.fx(r,k,h,tsim) = 1.0 ;
   lambdae.fx(r,e,a,v,tsim)  = 1.0 ;
   if(0,
      loop(a$(sameas(a,"oil-a") or sameas(a,"gas-a")),
         pw.fx(a,tsim) = 0.98 ;
         wchinrs.lo(a,tsim) = -inf ;
         wchinrs.up(a,tsim) = +inf ;
         etanrsx(r,a,lh) = 1 ;
         if(0,
            etanrsx("RUS",a,"hi") = 4 ;
            etanrsx("XLC",a,"hi") = 4 ;
         ) ;
*        etanrsx(r,a,"lo") = 1*etanrsx(r,a,"hi") ;
      ) ;
      if(1,
         sigmae(r,a,v)$(sigmae(r,a,v)) = 1.2 ;
         sigmanely(r,a,v)$(sigmanely(r,a,v)) = 1.2 ;
         sigmaolg(r,a,v)$(sigmaolg(r,a,v)) = 1.2 ;
         sigmaNRG(r,a,NRG,v)$(sigmaNRG(r,a,NRG,v)) = 1.2 ;
      ) ;
   ) ;
   if(0,
      emiTax.fx(r,"CO2",a,tsim) = 0.001*14 ;
      emiTax.fx(r,"CO2",a,tsim) = 0.001*14 ;
      $$batinclude "solve.gms" core
      emiTax.fx(r,"CO2",a,tsim) = 0.001*28 ;
      emiTax.fx(r,"CO2",a,tsim) = 0.001*28 ;
      $$batinclude "solve.gms" core
      emiTax.fx(r,"CO2",a,tsim) = 0.001*44 ;
      emiTax.fx(r,"CO2",a,tsim) = 0.001*44 ;
   ) ;
   if(0,
      emiTax.fx("USA","CO2", aa, tsim) = 0.001*44 ;
      kappah.fx("USA",tsim) = kappah.l("USA",tsim-1) ;
      alphaFtax.lo("USA",tsim) = -inf ;
      alphaFtax.up("USA",tsim) = +inf ;
      ifAfTaxFlag("USA",l,a)   = 1 ;
      ifAfTaxFlag("USA",cap,a) = 1 ;
   ) ;

   if(0,
      phTaxpb.lo("USA", pb, elyc, tsim) = -inf ;
      phTaxpb.up("USA", pb, elyc, tsim) = +inf ;
      phTaxpbY.fx("USA",tsim) = 0 ;
      chiphpb.lo("USA",t)     = -inf ;
      chiphpb.up("USA",t)     = +inf ;
      phTaxpbFlag("USA")      = yes ;
      iphpb("USA","NUCP")     = yes ;
      iphpb("USA","HYDP")     = yes ;
      xpb.fx(r,pb,elyc,tsim)$iphpb(r,pb) = xpb.l(r,pb,elyc,tsim) ;
   ) ;
) ;
