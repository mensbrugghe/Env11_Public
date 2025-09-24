if(years(tsim) ge 2025,
   if(years(tsim) eq 2025,
      if(0,
         emiTax.fx(r,"CO2",aa,tsim) = 0.001*2 ;
         $$batinclude "solve.gms" coreDyn
         emiTax.fx(r,"CO2",aa,tsim) = 0.001*4 ;
         $$batinclude "solve.gms" coreDyn
         emiTax.fx(r,"CO2",aa,tsim) = 0.001*8 ;
         $$batinclude "solve.gms" coreDyn
         emiTax.fx(r,"CO2",aa,tsim) = 0.001*16 ;
         $$batinclude "solve.gms" coreDyn
      ) ;
      emiTax.fx(r,"CO2",aa,tsim) = 0.001*20 ;
   else
      emiTax.fx(r,"CO2",aa,tsim) = emiTax.l(r,"CO2",aa,tsim-1)*power(1.03, gap(tsim)) ;
   ) ;
) ;
