if(1,
*  Make trade imbalances disappear between tf0 and tfT

   loop((t0,tf0,tfT)$(years(tsim) gt years(t0)),
      if (years(tsim) lt years(tf0),
         savfBar(r,tsim) = savfBar(r,tsim-1) ;
      elseif (years(tsim) gt years(tfT)),
         savfBar(r,tsim) = 0 ;
      elseif (years(tfT) eq years(tf0)),
         savfBar(r,tsim) = savfBar(r,tsim-1) ;
      else
         savfBar(r,tsim) = (savfBar(r,tf0)*(years(tfT)-years(tsim))
                         + 0*(years(tsim) - years(tf0)))/(years(tfT) - years(tf0)) ;
      ) ;
   )
) ;

*  Make savings endogenous in baseline and investment fixed

if(ifCal and dynPhase ge 4,
   loop((r,inv,t0)$(years(tsim) gt years(t0)),
      if(invTargetT(r,tsim) ne na,
         chiaps.lo(r,h,tsim)  = -inf ;
         chiaps.up(r,h,tsim)  = +inf ;
         if(not ifPhase,
            if(ifInitFlag ne 1 or years(tsim) gt startYear,
               chiaps.l(r,h,tsim)   = chiaps.l(r,h,tsim-1) ;
            ) ;
         else
            if(dynPhase eq 4,
               chiaps.l(r,h,tsim)   = chiaps.l(r,h,tsim-1) ;
            ) ;
         ) ;

         rfdshr.fx(r,inv,tsim) = 0.01*invTargetT(r,tsim) ;
      else
         chiaps.fx(r,h,tsim)   = chiaps.l(r,h,tsim-1) ;
         rfdshr.lo(r,inv,tsim) = -inf ;
         rfdshr.up(r,inv,tsim) = +inf ;
      ) ;
   ) ;
else
   chiaps.fx(r,h,tsim)   = chiaps.l(r,h,tsim) ;
   rfdshr.lo(r,inv,tsim) = -inf ;
   rfdshr.up(r,inv,tsim) = +inf ;
) ;

*  Make UE fixed and endogenize the wage shifter

if(ifCal and dynPhase ge 5,
   chirw.lo(r,l,z,tsim)$(ueFlag(r,l,z) eq resWageUE) = -inf ;
   chirw.up(r,l,z,tsim)$(ueFlag(r,l,z) eq resWageUE) =  inf ;
   uez.fx(r,l,z,tsim)$(ueFlag(r,l,z) ne fullEmpl)    = uez0(r,l,z) ;
   rwage.lo(r,l,z,tsim)$lsflag(r,l,z) = -inf ;
   rwage.up(r,l,z,tsim)$lsflag(r,l,z) = +inf ;
   ldz.lo(r,l,z,tsim)$lsflag(r,l,z) = -inf ;
   ldz.up(r,l,z,tsim)$lsflag(r,l,z) = +inf ;
else
   uez.fx(r,l,z,tsim)$(ueFlag(r,l,z) eq fullEmpl)    = uez0(r,l,z) ;
   uez.lo(r,l,z,tsim)$(ueFlag(r,l,z) eq resWageUE)   = ueminz(r,l,z,tsim) ;
   uez.lo(r,l,z,tsim)$(ueFlag(r,l,z) eq MonashUE)    = -inf ;
   uez.up(r,l,z,tsim)$(ueFlag(r,l,z) ne fullEmpl)    =  inf ;
   chirw.fx(r,l,z,tsim)$(ueFlag(r,l,z) eq resWageUE) = chirwBaU(r,l,z,tsim) ;
   errW.fx(r,l,z,tsim)$(ueFlag(r,l,z) eq MonashUE)   = 0 ;
   rwage.lo(r,l,z,tsim)$lsflag(r,l,z) = -inf ;
   rwage.up(r,l,z,tsim)$lsflag(r,l,z) = +inf ;
   ldz.lo(r,l,z,tsim)$lsflag(r,l,z) = -inf ;
   ldz.up(r,l,z,tsim)$lsflag(r,l,z) = +inf ;
) ;

errW.lo(r,l,z,tsim)$(lsFlag(r,l,z) and ueFlag(r,l,z) ne MonashUE) = -inf ;
errW.up(r,l,z,tsim)$(lsFlag(r,l,z) and ueFlag(r,l,z) ne MonashUE) = +inf ;

*  Tease a first solution for 2012

if(0 and ifCal,
   if(years(tsim) = baseYear + 1,
      gl.fx(r,tsim) = ((rgdppcT(r,tsim)/rgdppcT(r,tsim-1))**(1/gap(tsim)) - 1) ;
      grrgdppc.lo(r,tsim) = -inf ;
      grrgdppc.up(r,tsim) = +inf ;
      options iterlim = 10000 ;
      $$batinclude "solve.gms" coreDyn
      grrgdppc.fx(r,tsim) = 100*((rgdppcT(r,tsim)/rgdppcT(r,tsim-1))**(1/gap(tsim)) - 1) ;
      gl.lo(r,tsim) = -inf ;
      gl.up(r,tsim) = +inf ;
   ) ;
) ;

*  Update the consumer demand system

if(ifCal,
   if(years(tsim) > baseYear,
      if(0 and %utility% eq CDE,

         if(dynPhase ge 3,
*           ???? Do we hold the eh fixed across dynamic simulations????

*           Calculate real per capita consumption in PPP terms

            rconspc(r) = log(ppp(r)*sum(h, xfd0(r,h)*xfd.l(r,h,tsim-1))/(pop0(r)*pop.l(r,tsim-1))) ;
            loop(t0,
               eh.fx(r,k,h,tsim)$xcFlag(r,k,h)
                  = (min(2*eh.l(r,k,h,t0), max(0.2*eh.l(r,k,h,t0),
                        alpha_v.l(k) + beta_v.l(k)*rconspc(r) + gamma_v.l(k)*rconspc(r)*rconspc(r)
                  +  errp_v.l(r,k,h) - errn_v.l(r,k,h) ))) ;
            ) ;

*           Normalize

            eh.fx(r,k,h,tsim) = eh.l(r,k,h,tsim)/sum(kp, eh.l(r,kp,h,tsim)*hshr0(r,kp,h)*hshr.l(r,kp,h,tsim-1)) ;

*           display eh.l ;
         ) ;
      else
         eh.l(r,k,h,tsim) = eh.l(r,k,h,tsim-1) ;
      ) ;
   ) ;
else
   if(%utility% eq CDE,
      execute_load "%odir%/%BaUNAME%.gdx", eh ;
      eh.fx(r,k,h,tsim) = eh.l(r,k,h,tsim) ;
   ) ;
) ;

*  Update IO coefficients for food in proc foods and services

$ontext
if(years(tsim) > baseYear,
   lambdaio.fx(r,i,a,tsim)$(mapfud(i,a) and not alv(a))
      = lambdaio.l(r,i,a,tsim-1)*power(1 + 0.01*fudEff(i,"Other"), gap(tsim)) ;
   lambdaio.fx(r,i,a,tsim)$(mapfud(i,a) and alv(a) and not feed(i))
      = lambdaio.l(r,i,a,tsim-1)*power(1 + 0.01*fudEff(i,"Feed"), gap(tsim)) ;
   lambdaio.fx(r,i,a,tsim)$(mapfud(i,a) and alv(a) and feed(i))
      = lambdaio.l(r,i,a,tsim-1)*power(1 + 0.01*feedEff(r,i,a,tsim), gap(tsim)) ;
) ;

*  Fix gl at first then continue

if(1 and  ifCal,
   if(years(tsim) ge 2075,
      gl.fx(r,tsim) = gl.l(r,tsim-1) ;
      grrgdppc.lo(r,tsim) = -inf ;
      grrgdppc.up(r,tsim) = +inf ;
      options iterlim = 10000 ;
      $$batinclude "solve.gms" coreDyn
      grrgdppc.fx(r,tsim) = 100*((rgdppcT(r,tsim)/rgdppcT(r,tsim-1))**(1/gap(tsim)) - 1) ;
      gl.lo(r,tsim) = -inf ;
      gl.up(r,tsim) = +inf ;
   ) ;
) ;
$offtext
