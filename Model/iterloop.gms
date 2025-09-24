*  This is called using batinclude
*  The parameter %1 is a year
*  Variables are initialized for all years greater than %1
*  When starting from a baseline, one would use the baseline
*  values until the first year of a shock. Thus if a shock
*  begins in 2020, make %1 2025, then the beginning value
*  for 2020 will be the baseline value. If there is no shock
*  then make %1 greater than the terminal year, for example 2055
*  if the terminal year is 2050. The model should solve in
*  the first iteration if there is no shock

*  Initialize variables for new iteration

* rwork(r) = %1 ;

rwork(r) = 1 ;
if(years(tsim) gt years(t0) and years(tsim) gt %1,
   if(ifDyn and not ifPhase,
      rwork(r) = (popT(r,"PTOTL",tsim)/popT(r,"PTOTL",tsim-1))
               * (rgdppcT(r,tsim)/rgdppcT(r,tsim-1)) ;
   else
      rwork(r) = 1 ;
   ) ;
*  display rwork ;
*  Only initialize for Phase 0 or if not phasing
   if((ifPhase and dynPhase eq 0) or (not ifPhase),
      $$include "InitVar.gms"
   ) ;

*  Initialize vintage volumes for first simulation year

   if((ifPhase and dynPhase eq 0) or (not ifPhase),
      if(ifVint and ord(tsim) eq 2,
         $$include "InitVint.gms"
      ) ;
   ) ;
) ;

*  Reset the lag

$iftheni "%simType%" == "RcvDyn"
   tLag(tsim-1) = yes ;
$endif

obj.l = sw.l(tsim) ;

*  Re-calibrate the production parameters starting with the
*  second simulation year
*  N.B. We must do this step even in a no-shock scenario
*       since the share parameters are initialized in 'init.gms'
*       !!!! We may want to re-think this in the future, though it
*       doesn't appear to cost much in terms of calculations

if(ifDyn and ord(tsim) ge 2 and dynPhase ge 5,
   $$include "recal.gms"
) ;

*  Fix lagged variables

mlag1(px, a)
mlag1(xp, a)
mlag1(pfd, fd)
mlag1(xfd, fd)
mlag1(yfd, fd)
mlag1(pat, i)
mlag1(pdt, i)
mlag1(xtt, i)
mlag2(pe, i, d)
mlag2(pwe, i, d)
mlag2(pwm, i, d)
mlag2(xw, i, d)
mlag2(pwmg, i, d)
mlag0(rgdppc)
mlag0(rgdpmp)
mlag0(pgdpmp)
mlag0(cons)
mlag0(pcons)
mlag0(gdpmp)
mlag0(pfact)
mlag0(kstock)
mlag0(trent)
mlag0(tkaps)
mlag2(kv, a, v)
mlag2(pk, a, v)
mlag1(urbPrem, l)
mlag1(ls, l)
mlag2(lsz, l, z)
mlag2(ldz, l, z)
mlag2(uez, l, z)
mlag2(rwage, l, z)
mlag2(lambdaf, f, a)
mlag2(lambdak, a, v)
mlag2(pf, f, a)
mlag2(xf, f, a)
mlag2(pc, k, h)
mlag2(xc, k, h)
mlag2(pah, i, h)
mlag1(aps, h)

mlag2(pa, i, aa)
mlag2(xa, i, aa)

mlag2(resWage,l,z)
mlag2(emiTax, em, aa)
mlag0(psave)
mlag1(savh,h)
mlag2(cpi,h,cpindx)
mlag0(savg)

$iftheni "%RD_MODULE%" == "ON"
mlag0(kn)
rd.fx(r,tt)$(years(tt) le years(tsim-1)) = rd.l(r,tt) ;
kn.fx(r,tt)$(years(tt) le years(tsim-1)) = kn.l(r,tt) ;
$endif

$iftheni.RD "%simType%" == "RcvDyn"
$iftheni.DEPL "%DEPL_MODULE%" == "ON"
mlag1(extRate,a)
mlag1(res,a)
mlag1(resP,a)
mlag1(ytdRes,a)
mlag1(extr,a)
$endif.DEPL
$endif.RD

*  Fix global lag variables (no macros)

ptmg.fx(img,tsim-1)      = ptmg.l(img,tsim-1) ;
pw.fx(a,tsim-1)          = pw.l(a,tsim-1) ;
pmuv.fx(tsim-1)          = pmuv.l(tsim-1) ;
pwfact.fx(tsim-1)        = pwfact.l(tsim-1) ;

$iftheni "%CLIM_MODULE%" == "ON"
   emiGbl.fx(em,tsim-1) = emiGbl.l(em,tsim-1) ;
   EmiCO2.fx(tsim-1)    = EmiCO2.l(tsim-1) ;
   CumEmiInd.fx(tsim-1) = CumEmiInd.l(tsim-1) ;
   alpha.fx(tsim-1)     = alpha.l(tsim-1) ;
   CRes.fx(b,tsim-1)    = CRes.l(b,tsim-1) ;
   FORC.fx(em,tsim-1)   = FORC.l(em,tsim-1) ;
   TEMP.fx(tb,tt)$(years(tt) le years(tsim-1)) = TEMP.l(tb,tt) ;
$endif

$iftheni "%DAMAGE_MODULE%" == "ON"
   dam_shft_tfp.fx(r,a,tsim-1)   = dam_shft_tfp.l(r,a,tsim-1) ;
   dam_shft_lab.fx(r,l,a,tsim-1) = dam_shft_lab.l(r,l,a,tsim-1) ;
   dam_shft_hht.fx(r,l,a,tsim-1) = dam_shft_hht.l(r,l,a,tsim-1) ;
   dam_shft_nrg.fx(r,k,h,tsim-1) = dam_shft_nrg.l(r,k,h,tsim-1) ;
   dam_shft_lnd.fx(r,lnd,tsim-1) = dam_shft_lnd.l(r,lnd,tsim-1) ;
   dam_shft_tou.fx(r,i,tsim-1)   = dam_shft_tou.l(r,i,tsim-1) ;
   dam_shft_cap.fx(r,tsim-1)     = dam_shft_cap.l(r,tsim-1) ;
$endif

*  Update the dynamics

if(ifDyn,
   if(years(tsim) gt years(t0),

      if(dynPhase ge 5,
         rwork(r) = (popT(r,"PTOTL",tsim)/popT(r,"PTOTL",tsim-1))
                  * (rgdppcT(r,tsim)/rgdppcT(r,tsim-1)) ;
      else
         rwork(r) = 1 ;
      ) ;

*     Population

      pop.fx(r,tsim) = (pop.l(r,tsim-1)*(popT(r,"PTOTL",tsim)/popT(r,"PTOTL",tsim-1)))$(dynPhase ge 1)
                     + pop.l(r,tsim-1)$(dynPhase lt 1) ;

*     Capital accumulation is endogeous

      tkaps.lo(r,tsim)  = -inf ; tkaps.up(r,tsim)  = +inf ;
      kstock.lo(r,tsim) = -inf ; kstock.up(r,tsim) = +inf ;

*     Energy

      if(dynPhase ge 3,
         if(1,
*           !!!! This formula needs to be changed so that it depends on a different AEEI
            lambdanrgp.fx(r,a,v,tsim) = lambdanrgp.l(r,a,v,tsim-1)
                                      *   power(1 + 0.01*aeei(r,a,v,tsim), gap(tsim)) ;
         else
            lambdae.fx(r,e,a,v,tsim)  = lambdae.l(r,e,a,v,tsim-1)
                                      *   power(1 + 0.01*aeei(r,a,v,tsim), gap(tsim)) ;
         ) ;
         if(1,
            lambdanrgc.fx(r,k,h,tsim) = lambdanrgc.l(r,k,h,tsim-1)
                                      *   power(1 + 0.01*aeeic(r,k,h,tsim), gap(tsim)) ;
         else
            lambdace.fx(r,e,k,h,tsim) = lambdace.l(r,e,k,h,tsim-1)
                                      *   power(1 + 0.01*aeeic(r,k,h,tsim), gap(tsim)) ;
         ) ;
      ) ;

*     Emission rates

      if(dynPhase ge 3,
         emir(r,em,is,aa)$emi0(r,em,is,aa) = emir(r,em,is,aa)
            * power(1 - 0.01*emiRate(r,em,is,aa,tsim), gap(tsim)) ;

         emird(r,em,i,aa)$emi0(r,em,i,aa) = emird(r,em,i,aa)
            * power(1 - 0.01*emiRate(r,em,i,aa,tsim), gap(tsim)) ;

         emirm(r,em,i,aa)$emi0(r,em,i,aa) = emirm(r,em,i,aa)
            * power(1 - 0.01*emiRate(r,em,i,aa,tsim), gap(tsim)) ;
      ) ;

*     International trade and transport margins

      if(dynPhase ge 3,
         tmarg.fx(s,i,d,tsim) = tmarg.l(s,i,d,tsim-1)*power(1 - 0.01*tteff(s,i,d,tsim), gap(tsim)) ;
      ) ;

*     Land (yield?)
*     27-Feb-2018 DvdM: Make yexo apply to livestock capital, not land

      if(dynPhase ge 3,
         loop(a,
            if(acr(a),
               lambdaf.fx(r,lnd,a,tsim) = lambdaf.l(r,lnd,a,tsim-1)*power(1 + 0.01*yexo(r,a,tsim), gap(tsim)) ;
            elseif(alv(a)),
               lambdaf.fx(r,cap,a,tsim) = lambdaf.l(r,cap,a,tsim-1)*power(1 + 0.01*yexo(r,a,tsim), gap(tsim)) ;
            else
               lambdaf.fx(r,lnd,a,tsim) = lambdaf.l(r,lnd,a,tsim-1)*power(1 + 0.01*yexo(r,a,tsim), gap(tsim)) ;
            ) ;
         ) ;
      ) ;

*     Implement assumptions on growth rate of labor -- driven by growth of skilled labor
*     The growth of total labor is given by the SSP population assumptions
*     skLabgrwgt is a user-determined parameter

      if(dynPhase ge 1,
         tls.l(r,tsim)      = tls.l(r,tsim-1)*power(1 + 0.01*gtLab.l(r,tsim),gap(tsim)) ;
         glab.l(r,skl,tsim) = (skLabgrwgt*glabT(r,skl,tsim) + (1-skLabgrwgt)*gtlab.l(r,tsim)) ;
         ls.l(r,skl,tsim)   = power(1 + 0.01*glab.l(r,skl,tsim), gap(tsim))*ls.l(r,skl,tsim-1) ;
         glab.l(r,nsk,tsim) = 100*(((tls0(r)*tls.l(r,tsim) - sum(skl, ls.l(r,skl,tsim)*ls0(r,skl)))
                            / (tls0(r)*tls.l(r,tsim-1) - sum(skl, ls.l(r,skl,tsim-1)*ls0(r,skl)))
                              )**(1/gap(tsim)) - 1) ;
         ls.l(r,nsk,tsim)   = ls.l(r,nsk,tsim-1)*power(1 + 0.01*glab.l(r,nsk,tsim), gap(tsim)) ;

         glabz.fx(r,l,z,tsim) = glab.l(r,l,tsim) ;
      else
         tls.l(r,tsim)        = tls.l(r,tsim-1) ;
         ls.l(r,l,tsim)       = ls.l(r,l,tsim-1) ;
         glab.l(r,l,tsim)     = 0 ;
         glabz.fx(r,l,z,tsim) = 0 ;
      ) ;

      lsz.lo(r,l,z,tsim) = -inf ;
      lsz.up(r,l,z,tsim) = +inf ;

*     Sectoral capital stock

*     Initialize and fix installed capital stock at beginning of period

      if(dynPhase ge 2,
         k0.fx(r,a,tsim)$kFlag(r,a) = sum(v, kv0(r,a)*kv.l(r,a,v,tsim-1))*power(1-depr(r,tsim-1), gap(tsim))/k00(r,a) ;
      else
         k0.fx(r,a,tsim)$kFlag(r,a) = sum(v, (kv0(r,a)/k00(r,a))*kv.l(r,a,v,tsim-1)) ;
      ) ;

      if(dynPhase ge 10,
         if(ifInitFlag ne 1 or years(tsim) gt startYear,
            kslo.l(r,a,tsim)        = k0.l(r,a,tsim) ;
            xpv.l(r,a,vOld,tsim)$xpv0(r,a) = kslo.l(r,a,tsim)*kv0(r,a)/(kxRat0(r,a)*kxRat.l(r,a,vOld,tsim)*xpv0(r,a)) ;
            kv.l(r,a,vOld,tsim) = kslo.l(r,a,tsim) ;
            if(ifVint and ord(tsim) gt 2,
               if(1,
                  if(1,
*                    Grow xpv(new) and kshi using rwork
                     xpv.l(r,a,vNew,tsim)$xpv0(r,a) = rwork(r)*xpv.l(r,a,vNew,tsim-1) ;
                     kshi.l(r,a,tsim) = rwork(r)*kshi.l(r,a,tsim-1) ;
                     kv.l(r,a,vNew,tsim) = kshi.l(r,a,tsim) ;
                  else
*                    Grow kshi, deduce xpv(new) and xp
                     kshi.l(r,a,tsim) = rwork(r)*kshi.l(r,a,tsim-1) ;
                     xpv.l(r,a,vNew,tsim)$xpv0(r,a) = kshi.l(r,a,tsim)*kv0(r,a)/(kxRat0(r,a)*kxRat.l(r,a,vNew,tsim)*xpv0(r,a)) ;
                     xp.l(r,a,tsim)          = sum(v, xpv.l(r,a,v,tsim)) ;
                  ) ;
               else
*                 Grow xp, deduce xpv(new) and kshi
                  xp.l(r,a,tsim) = rwork(r)*xp.l(r,a,tsim-1) ;
                  xpv.l(r,a,vNew,tsim) = max(0, xp.l(r,a,tsim) - sum(vOld, xpv.l(r,a,vOld,tsim))) ;
                  loop(vNew,
                     kshi.l(r,a,tsim)$kv0(r,a) = xpv.l(r,a,vNew,tsim)*xpv0(r,a)*kxRat0(r,a)*kxRat.l(r,a,vNew,tsim)/kv0(r,a) ;
                  ) ;
                  kv.l(r,a,vNew,tsim) = kshi.l(r,a,tsim) ;
               ) ;
            ) ;
            xp.l(r,a,tsim)          = sum(v, xpv.l(r,a,v,tsim)) ;
*           xpv.l(r,a,vNew,tsim)    = max(0, xp.l(r,a,tsim) - sum(vOld,xpv.l(r,a,vOld,tsim))) ;
         ) ;
         if(ifVint,
            kslo.up(r,a,tsim) = k0.l(r,a,tsim) ;
            kslo.lo(r,a,tsim) = 0 ;
            kshi.lo(r,a,tsim) = 0 ;
         ) ;
      ) ;

      if(ifCal and dynPhase ge 1,
         migrMult.l(r,l,z,tsim)$migrFlag(r,l) = (power(1 + 0.01*glabz.l(r,l,z,tsim), gap(tsim))
            * (urbPrem.l(r,l,tsim-1)/urbPrem.l(r,l,tsim))**omegam(r,l) - 1)
            / ((1 + 0.01*glabz.l(r,l,z,tsim))
            * (urbPrem.l(r,l,tsim-1)/urbPrem.l(r,l,tsim))**(omegam(r,l)/gap(tsim))-1) ;

         lsz.l(r,l,z,tsim)$lsz0(r,l,z)
            = power(1 + 0.01*glabz.l(r,l,z,tsim), gap(tsim))*lsz.l(r,l,z,tsim-1)
            + kronm(z)*migrMult.l(r,l,z,tsim)*migr.l(r,l,tsim)*migr0(r,l)/lsz0(r,l,z) ;
         glab.l(r,l,tsim)  = 100*((sum(z,lsz.l(r,l,z,tsim)*lsz0(r,l,z))
                           /  sum(z,lsz.l(r,l,z,tsim-1)*lsz0(r,l,z)))**(1/gap(tsim)) - 1 ) ;
      ) ;

*     World price trends

      if(ifCal,
*        Calibrate to exogenous trends
         loop(a,
            if(pwTrend(a,tsim) ne na,
               pw.fx(a,tsim) = pwTrend(a,tsim) ;
               wchinrs.lo(a,tsim) = -inf ;
               wchinrs.up(a,tsim) = +inf ;
            else
               pw.lo(a,tsim) = -inf ;
               pw.up(a,tsim) = +inf ;
               wchinrs.fx(a,tsim) = wchinrs.l(a,tsim-1) ;
            ) ;
         ) ;
      else
*        Calibrate to exogenous shock
         loop(a,
            if(pwShock(a,tsim) ne na,
               pw.fx(a,tsim) = pwShock(a,tsim) ;
               wchinrs.lo(a,tsim) = -inf ;
               wchinrs.up(a,tsim) = +inf ;
            else
               pw.lo(a,tsim) = -inf ;
               pw.up(a,tsim) = +inf ;
               wchinrs.fx(a,tsim) = wchinrs.l(a,tsim) ;
            ) ;
         ) ;
      ) ;

      if(ifCal,

         if(dynPhase ge 5,
*           GDP growth is given, labor productivity is endogenous

            grrgdppc.fx(r,tsim) = 100*((rgdppcT(r,tsim)/rgdppcT(r,tsim-1))**(1/gap(tsim)) - 1) ;
            if(ifInitFlag = 0,
               gl.l(r,tsim) = gl.l(r,tsim-1) ;
            else
               if(years(tsim) gt %1,
                  gl.l(r,tsim) = gl.l(r,tsim-1) ;
               ) ;
            ) ;
            lambdaf.l(r,l,a,tsim) = lambdaf.l(r,l,a,tsim-1)
               * power(1 + chiglab.l(r,l,tsim) + pik.l(r,l,a,tsim) + glAddShft(r,l,a,tsim)
                         + glMltShft(r,l,a,tsim)*gl.l(r,tsim), gap(tsim)) ;
            lambdaf.lo(r,l,a,tsim)$xfFlag(r,l,a) = -inf ;
            lambdaf.up(r,l,a,tsim)$xfFlag(r,l,a) = +inf ;
            gl.lo(r,tsim) = -inf ; gl.up(r,tsim) = +inf ;

*           Balanced growth path
            klrat.fx(r,tsim) = klrat.l(r,t0) ;
            gk.lo(r,tsim) = -inf ; gk.up(r,tsim) = +inf ;
            lambdak.lo(r,a,v,tsim) = -inf ; lambdak.up(r,a,v,tsim) = +inf ;
         else
            lambdaf.lo(r,l,a,tsim)$xfFlag(r,l,a) = -inf ;
            lambdaf.up(r,l,a,tsim)$xfFlag(r,l,a) = +inf ;
            grrgdppc.lo(r,tsim) = -inf ;
            grrgdppc.up(r,tsim) = +inf ;
            gl.fx(r,tsim) = gl.l(r,tsim-1) ;
         ) ;

*        Government expenditures grow at the rate of GDP growth

         xfd.fx(r,gov,tsim) = xfd.l(r,gov,tsim-1)*rwork(r) ;

*        Calibrate reservation wage shifter
*        This holds UE at base year levels--could have different pathways
*        Fixed UE holds for both reservation wage and Monash closures in the BaU

         chirw.lo(r,l,z,tsim)$(ueFlag(r,l,z) eq resWageUE) = -inf ;
         chirw.up(r,l,z,tsim)$(ueFlag(r,l,z) eq resWageUE) = +inf ;
         uez.fx(r,l,z,tsim) = uez.l(r,l,z,tsim-1) ;

      else

*        Labor productivity is exogenous, GDP growth is endogenous

         gl.fx(r,tsim) = glBaU(r,tsim) ;
         gk.fx(r,tsim) = gkBaU(r,tsim) ;
         lambdaf.fx(r,l,a,tsim) = lambdaf.l(r,l,a,tsim-1)
            * power(1 + chiglab.l(r,l,tsim) + pik.l(r,l,a,tsim) + glAddShft(r,l,a,tsim)
                      + glMltShft(r,l,a,tsim)*gl.l(r,tsim), gap(tsim)) ;
*        lambdaf.lo(r,l,a,tsim)$xfFlag(r,l,a) = -inf ;
*        lambdaf.up(r,l,a,tsim)$xfFlag(r,l,a) = +inf ;
         lambdak.fx(r,a,v,tsim) = lambdak.l(r,a,v,tLag)
            * power(1 + gkAddShft(r,a,v,tsim) + gkMltShft(r,a,v,tsim)*gk.l(r,tsim), gap(tsim)) ;                      
*        lambdak.lo(r,a,v,tsim)$kFlag(r,a) = -inf ;
*        lambdak.up(r,a,v,tsim)$kFlag(r,a) = +inf ;
         
         grrgdppc.lo(r,tsim) = -inf ;
         grrgdppc.up(r,tsim) = +inf ;
         klRat.lo(r,tsim)    = -inf ;
         klRat.up(r,tsim)    = +inf ;

*        Government expenditures are exogenous and equal to the baseline levels

         xfd.fx(r,gov,tsim) = xfdBaU(r,gov,tsim) ;

         eh.fx(r,k,h,tsim)  = ehBaU(r,k,h,tsim) ;
         bh.fx(r,k,h,tsim)  = bhBaU(r,k,h,tsim) ;

         chiAPS.fx(r,h,t)   = chiAPSBaU(r,h,t) ;

*        Reservation wage shifter is exogenous

*        chirw.fx(r,l,z,t) = chirwBaU(r,l,z,t) ;

         errW.lo(r,l,z,tsim)$(ueFlag(r,l,z) eq FullEmpl) = -inf ;
         errW.up(r,l,z,tsim)$(ueFlag(r,l,z) eq FullEmpl) = +inf ;

      ) ;
   ) ;

else

*  Else comparative static exercise

   grrgdppc.fx(r,tsim) = 0 ;

   errW.lo(r,l,z,tsim)$(ueFlag(r,l,z) eq FullEmpl) = -inf ;
   errW.up(r,l,z,tsim)$(ueFlag(r,l,z) eq FullEmpl) = +inf ;

) ;

$iftheni.costCurve "%simType%" == "RcvDyn"

* --------------------------------------------------------------------------------------------------
*
*  Implement cost reductions in selected activities
*
* --------------------------------------------------------------------------------------------------

if(years(tsim) gt baseYear,

   loop((r,a)$ifCostCurve(r,a),

      $$iftheni.type %costCurve% == HYPERB

         work = log((costTgt(r,a) - costMin(r,a))/(1 - costMin(r,a)))
              / log(1/(costTgtYear(r,a) - (baseYear-1))) ;
         work = ((costMin(r,a) + (1-costMin(r,a))*(years(tsim-1)-(baseYear-1))**(-work))
              / (costMin(r,a) + (1-costMin(r,a))*(years(tsim)-(baseYear-1))**(-work))) ;

      $$elseifi.type %costCurve% == LOGIST

         work = -(1/(costTgtYear(r,a)-baseYear))*log((costTgt(r,a)-costMin(r,a))
              /  (costTgt(r,a)*(1 - costMin(r,a))))) ;

         work = (1 + (costMin(r,a)-1)*exp(-work*(years(tsim)-baseYear)))
              / (1 + (costMin(r,a)-1)*exp(-work*(years(tsim)-baseYear - gap(tsim))))) ;

      $$else.type

         Abort "Wrong cost curve type, valid types are 'HYPERB' and 'LOGIST'" ;

      $$endif.type

      if(dynPhase ge 3,
         lambdaxp.fx(r,a,v,tsim) = work*lambdaxp.l(r,a,v,tsim-1) ;
      else
         lambdaxp.fx(r,a,v,tsim) = lambdaxp.l(r,a,v,tsim-1) ;
      ) ;

   ) ;
) ;

$endif.costCurve

$ontext
put screen ; put / ;
if(years(tsim) eq 2024,
   loop(r,
      work = rore.l(r,tsim)*rore0(r) - (rorc.l(r,tsim)*rorc0(r)*(kstocke.l(r,tsim)/kstock.l(r,tsim))**(-epsRor(r,tsim))) ;
      put r.tl:<12, work / ;
   ) ;
*  abort "temp"
) ;
$offtext
