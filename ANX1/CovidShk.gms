if(years(tsim) eq 2020,
   uez.lo(r,l,"nsg",tsim)    = -inf ;
   uez.up(r,l,"nsg",tsim)    = +inf ;
   if(1,
*     Fix wages
      ewagez.fx(r,l,"nsg",tsim) = ewagez.l(r,l,"nsg",tsim-1) ;
   else
*     Set lower bound on wages and don't allow any expansion
      pf.lo(r,l,a,tsim)    = pf.l(r,l,a,t0) ;
      xfs.fx(r,l,a,tsim)   = xfs.l(r,l,a,t0) ;
      FEFlag(r,l) = no ;
   ) ;

   if(1,
*     Change fiscal closure
      rsg.lo(r,tsim) = -inf ;
      rsg.up(r,tsim) = +inf ;
      kappah.fx(r,tsim) = kappah.l(r,tsim-1) ;
   ) ;

   ftfp.fx(r,a,v,tsim) = 1 - 0.02 ;
) ;
