rs(rr)  = no ;
sd(s,d) = no ;

ifGbl = 0 ;

if((0 and years(tsim) = 2050) or years(tsim) gt startyear, for(riter=1 to nriter by 1, loop(rr,

*  Loop over region rr

   rs(rr) = yes ;
   sd(s,d)$(rs(s) or rs(d)) = yes ;
   work=sum((s,i,d)$(sd(s,d) and xw.l(s,i,d,tsim)), 1) ; display sd, work ;

*
*  Fix PE prices and update import prices
*
   pe.fx(s,i,d,tsim)  = pe.l(s,i,d,tsim) ;

*  Fix global flows

   xw.fx(s,i,d,tsim)  = xw.l(s,i,d,tsim) ;
   xtt.fx(r,img,tsim) = xtt.l(r,img,tsim) ;
   pdt.fx(r,img,tsim) = pdt.l(r,img,tsim) ;

*  Exogenize global trust

   trustY.fx(tsim) = trustY.l(tsim) ;

*  Endogenize ODA

   loop(r,
      if(rs(r),
         ODAOut.lo(r,tsim)$OdaOut0(r) = -inf ;
         ODAOut.up(r,tsim)$OdaOut0(r) = +inf ;
      else
         ODAOut.fx(r,tsim) = ODAOut.l(r,tsim) ;
      ) ;
   ) ;

*  Exogenize remittance inflows

   loop(d,
      if(rs(d),
         remit.lo(s,l,d,tsim)$remit0(s,l,d) = -inf ;
         remit.up(s,l,d,tsim)$remit0(s,l,d) = +inf ;
      else
         remit.fx(s,l,d,tsim)$(not rs(d)) = remit.l(s,l,d,tsim) ;
      ) ;
   ) ;

*  Fix chisave

   chisave.fx(tsim) = chisave.l(tsim) ;

*  Endogenize imports

   xw.lo(s,i,d,tsim)$(xwFlag(s,i,d) and sd(s,d)) = -inf ;
   xw.up(s,i,d,tsim)$(xwFlag(s,i,d) and sd(s,d)) = +inf ;

*  Endogenize export prices

   pe.lo(s,i,d,tsim)$(xwFlag(s,i,d) and sd(s,d) and omegaw(s,i) ne inf) = -inf ;
   pe.up(s,i,d,tsim)$(xwFlag(s,i,d) and sd(s,d) and omegaw(s,i) ne inf) = +inf ;

*  Endogenize pd and xtt

   pdt.lo(r,i,tsim)$(rs(r) and xdtFlag(r,i) ne 0) = -inf ;
   pdt.up(r,i,tsim)$(rs(r) and xdtFlag(r,i) ne 0) = +inf ;
   xtt.lo(r,img,tsim)$(rs(r) and xttFlag(r,img) ne 0) = -inf ;
   xtt.up(r,img,tsim)$(rs(r) and xttFlag(r,img) ne 0) = +inf ;

   loop(r,
      if(rs(r),
         pmt.lo(r,i,tsim)$xmtFlag(r,i) = -inf ;
         pmt.up(r,i,tsim)$xmtFlag(r,i) = +inf ;
         pmtNDX.lo(r,i,tsim)$(xmtFlag(r,i) and ifARMACES(i)) = -inf ;
         pmtNDX.up(r,i,tsim)$(xmtFlag(r,i) and ifARMACES(i)) = +inf ;
         xmt.lo(r,i,tsim)$xmtFlag(r,i) = -inf ;
         xmt.up(r,i,tsim)$xmtFlag(r,i) = +inf ;
         pet.lo(r,i,tsim)$xetFlag(r,i) = -inf ;
         pet.up(r,i,tsim)$xetFlag(r,i) = +inf ;
         petNDX.lo(r,i,tsim)$(xetFlag(r,i) and ifARMACES(i)) = -inf ;
         petNDX.up(r,i,tsim)$(xetFlag(r,i) and ifARMACES(i)) = +inf ;
         xet.lo(r,i,tsim)$xetFlag(r,i) = -inf ;
         xet.up(r,i,tsim)$xetFlag(r,i) = +inf ;
      else
         pmt.fx(r,i,tsim)$xmtFlag(r,i) = pmt.l(r,i,tsim) ;
         pmtNDX.fx(r,i,tsim)$(xmtFlag(r,i) and ifARMACES(i)) = pmtNDX.l(r,i,tsim) ;
         xmt.fx(r,i,tsim)$xmtFlag(r,i) = xmt.l(r,i,tsim) ;
         pet.fx(r,i,tsim)$xetFlag(r,i) = pet.l(r,i,tsim) ;
         petNDX.fx(r,i,tsim)$(xetFlag(r,i) and ifARMACES(i)) = petNDX.l(r,i,tsim) ;
         xet.fx(r,i,tsim)$xetFlag(r,i) = xet.l(r,i,tsim) ;
      ) ;
   ) ;

*  !!!! Testing when we have emission taxes
   emiTax.fx(r,em,aa,tsim)$ifEmiRCap(r,em,aa) = max(0.003, emiTax.l(r,em,aa,tsim)) ;

*  solve

*  !!!! Need to change this so that it solves using NLP

   options nlp=conopt4 ;
*  options mcp=nlpec ;
   option cns=CONOPT4 ;
*  option cns=ipopt ;
   if(0,
      solve %1 using cns ;
   else
      solve %1 using mcp ;
   ) ;

   put screen ;
   if (%1.solvestat eq 1,
      put // "Solved iteration ", riter:<2:0, " out of ", nriter:2:0,
             " iteration(s) for region ", rr.tl, " in year ", years(tsim):4:0 // ;
   else
      execute_unload "%odir%\%SIMNAME%.gdx" ; ;
      put // "Failed to solve for iteration ", riter:<2:0, " out of ", nriter:2:0,
             " iteration(s) for region ", rr.tl, " in year ", years(tsim):4:0 // ;
      Abort$(1) "Solution failure" ;
   ) ;
   putclose screen ;

   rs(r)   = no ;
   sd(s,d) = no ;

*  Update global variables

   $$ondotl

   trustY(tsim)$trustY0 = sum(r, (yqtf0(r)/trustY0)*yqtf(r,tsim)) ;
   pmuv(tsim) = pmuv(tsim-1)*sqrt((mQMUV(tsim,tsim-1)/mQMUV(tsim-1,tsim-1))
              *                   (mQMUV(tsim,tsim)/mQMUV(tsim-1,tsim))) ;
   pwfact(tsim) = pwfact(tsim-1)
             *   sqrt((mqfactw(tsim,tsim-1)/mqfactw(tsim-1,tsim-1))
             *        (mqfactw(tsim,tsim)/mqfactw(tsim-1,tsim))) ;
   pw(a,tsim) = pw(a,tsim-1)*sqrt((mQX(a,tsim,tsim-1)/mQX(a,tsim-1,tsim-1))
              *                   (mQX(a,tsim,tsim)/mQX(a,tsim-1,tsim))) ;
   chisave(tsim) = sum((r,inv), m_phiInv(r,tsim-1)*pfd(r,inv,tsim)/pfd(r,inv,tsim-1))
                 / sum(r,       m_phiSav(r,tsim-1)*psave(r,tsim)/psave(r,tsim-1)) ;
   pwgdp(tsim) = sum(r, gdpmp(r,tsim))/sum(r, rgdpmp(r,tsim)) ;
   pwsav(tsim) = pmuv(tsim) ;
   pnum(tsim)  = 0*pwfact(tsim) + 1*pwgdp(tsim) + 0*pmuv(tsim) ;

   emiGbl(em, tsim)$emiGbl0(em) = sum(r, emiTot(r, em,tsim)*(emiTot0(r,em)/emiGbl0(em)))
                 +  emiOthGbl(em,tsim)/emiGbl0(em) ;

   sw(tsim) = sum(r, (welfwgt(r,tsim)*pop0(r)*pop(r,tsim)/((1-epsw(tsim))*sw0*sum(rp,pop0(rp)*pop(rp,tsim))))
         *         (sum(h, ev0(r,h)*ev(r,h,tsim))/(pop0(r)*pop(r,tsim)))**(1-epsw(tsim))) ;

   swt(tsim) = sum(r, (welftwgt(r,tsim)*pop0(r)*pop(r,tsim)/((1-epsw(tsim))*swt0*sum(rp,pop0(rp)*pop(rp,tsim))))
          *         ((sum(h, ev0(r,h)*ev(r,h,tsim)) + sum(gov, evf0(r,gov)*evf(r,gov,tsim)))
          /                  (pop0(r)*pop(r,tsim)))**(1-epsw(tsim))) ;

   swt2(tsim) = sum(r, (welftwgt(r,tsim)*pop0(r)*pop(r,tsim)
           /           ((1-epsw(tsim))*swt20*sum(rp,pop0(rp)*pop(rp,tsim))))
           *   ((sum(h, ev0(r,h)*ev(r,h,tsim)) + sum(gov, evf0(r,gov)*evf(r,gov,tsim))
           +        evs(r,tsim)*evs0(r))
           /    (pop0(r)*pop(r,tsim)))**(1-epsw(tsim)))
))) ;

* display ev.l, evs.l, swt2.l ;

*
*  --- include all regions again
*
rs(r)   = yes ;
sd(s,d) = yes ;
ifGbl   = 1 ;
obj.l   = sum(t$ts(t), sw(t)) ;
*
*  --- release bounds on variables fixed in individual solves
*      and introduce original lower bounds
*
pe.lo(s,i,d,tsim)$xwFlag(s,i,d) = 0.001*pe.l(s,i,d,tsim) ;
pe.up(s,i,d,tsim)$xwFlag(s,i,d) = +inf ;

xw.lo(s,i,d,tsim)$xwFlag(s,i,d) = -inf;
xw.up(s,i,d,tsim)$xwFlag(s,i,d) = +inf;

pmt.lo(r,i,tsim)$xmtFlag(r,i) = -inf ;
pmt.up(r,i,tsim)$xmtFlag(r,i) = +inf ;
pmtNDX.lo(r,i,tsim)$(xmtFlag(r,i) and ifARMACES(i)) = -inf ;
pmtNDX.up(r,i,tsim)$(xmtFlag(r,i) and ifARMACES(i)) = +inf ;
xmt.lo(r,i,tsim)$xmtFlag(r,i) = -inf ;
xmt.up(r,i,tsim)$xmtFlag(r,i) = +inf ;
pet.lo(r,i,tsim)$xetFlag(r,i) = -inf ;
pet.up(r,i,tsim)$xetFlag(r,i) = +inf ;
petNDX.lo(r,i,tsim)$(xetFlag(r,i) and ifARMACES(i)) = -inf ;
petNDX.up(r,i,tsim)$(xetFlag(r,i) and ifARMACES(i)) = +inf ;
xet.lo(r,i,tsim)$xetFlag(r,i) = -inf ;
xet.up(r,i,tsim)$xetFlag(r,i) = +inf ;

pdt.lo(r,i,tsim)$xdtFlag(r,i) = -inf ;
pdt.up(r,i,tsim)$xdtFlag(r,i) = +inf ;

xtt.lo(r,img,tsim)$xttFlag(r,img) = -inf ;
xtt.up(r,img,tsim)$xttFlag(r,img) = +inf ;

trustY.lo(tsim)$trustY0 = -inf ;
trustY.up(tsim)$trustY0 = +inf ;

ODAOut.lo(r,tsim)$OdaOut0(r) = -inf ;
ODAOut.up(r,tsim)$OdaOut0(r) = +inf ;

remit.lo(s,l,d,tsim)$remit0(s,l,d) = -inf ;
remit.up(s,l,d,tsim)$remit0(s,l,d) = +inf ;

chisave.lo(tsim) = -inf ;
chisave.up(tsim) = +inf ;

emiTax.lo(r,em,aa,tsim)$ifEmiRCap(r,em,aa) = -inf ;
emiTax.up(r,em,aa,tsim)$ifEmiRCap(r,em,aa) = +inf ;

if(ifMCP,
   option cns = conopt4 ;
   if(1,
      solve %1 using mcp ;
   else
      solve %1 using nlp maximizing obj ;
   ) ;
else
*  options nlp=knitro ;
   option cns = conopt4 ;
   option nlp = conopt4 ;

   solve %1 using cns ;
) ;

solveStat("solveStat",tsim) = %1.solvestat ;
solveStat("Walras", tsim)   = walras.l(tsim) / inScale ;

put screen ;
if (%1.solvestat eq 1,
   put // "Solved global model in year ", years(tsim):4:0 // ;
else
   execute_unload "%odir%\%SIMNAME%.gdx" ; ;
   put // "Failed to solve global model in year ", years(tsim):4:0 // ;
   Abort$(1) "Solution failure" ;
) ;
putclose screen ;

*  Update substituted out variables

$onDotL
if(ifSUB,
   pp.l(r,a,i,tsim)   = M_PP(r,a,i,tsim) ;

   pa.l(r,i,aa,tsim)  = M_PA(r,i,aa,tsim) ;
   pd.l(r,i,aa,tsim)  = M_PD(r,i,aa,tsim) ;
   pm.l(r,i,aa,tsim)  = M_PM(r,i,aa,tsim) ;

   pwe.l(s,i,d,tsim) = M_PWE(s,i,d,tsim) ;
   pwm.l(s,i,d,tsim) = M_PWM(s,i,d,tsim) ;
   pdm.l(s,i,d,tsim) = M_PDM(s,i,d,tsim) ;

$iftheni "%MRIO_MODULE%" == "ON"
   pdma.l(s,i,d,aa,tsim) = M_PDMA(s,i,d,aa,tsim) ;
$endif

   pwmg.l(s,i,d,tsim) = M_PWMG(s,i,d,tsim) ;
   xwmg.l(s,i,d,tsim)$xwmg0(s,i,d) = M_XWMG(s,i,d,tsim) ;
   xmgm.l(img,s,i,d,tsim)$xmgm0(img,s,i,d) = M_XMGM(img,s,i,d,tsim) ;

   pfp.l(r,f,a,tsim) = M_PFP(r,f,a,tsim) ;
) ;

SPCTAR(s,i,d,tsim) = sum(rq$mapra(rq,d), M_EMIX(rq,s,i,d,tsim)*emiTaxX(rq,s,i,d,tsim)) ;

$offDotL

*  Update income and price elasticities

omegaad.fx(r,h)
      = (sum(k$xcFlag(r,k,h), (betaad.l(r,k,h,tsim)-alphaad.l(r,k,h,tsim))
      *     log(xc.l(r,k,h,tsim)*xc0(r,k,h)/(pop0(r)*pop.l(r,tsim)) - gammac.l(r,k,h,tsim)))
      - power(1+exp(u.l(r,h,tsim)*u0(r,h)),2)*exp(-u.l(r,h,tsim)*u0(r,h)))
      $(%utility% eq AIDADS)

      + 1$(%utility% ne AIDADS)
      ;

omegaad.fx(r,h) = 1/omegaad.l(r,h) ;

etah.l(r,k,h,tsim)$xcFlag(r,k,h)

   = (muc0(r,k,h)*muc.l(r,k,h,tsim)/((pc.l(r,k,h,tsim)*xc.l(r,k,h,tsim)
   *                      pc0(r,k,h)*xc0(r,k,h))/(yd.l(r,tsim)*yd0(r))))$(%utility% eq ELES)

   + ((muc.l(r,k,h,tsim)*muc0(r,k,h) - (betaad.l(r,k,h,tsim)-alphaad.l(r,k,h,tsim))*omegaad.l(r,h))
   / (hshr0(r,k,h)*hshr.l(r,k,h,tsim)))$(%utility% eq AIDADS or %utility% eq LES)

   + ((eh.l(r,k,h,tsim)*bh.l(r,k,h,tsim)
   - sum(kp$xcFlag(r,kp,h), hshr0(r,kp,h)*hshr.l(r,kp,h,tsim)*eh.l(r,kp,h,tsim)*bh.l(r,kp,h,tsim)))
   / sum(kp$xcFlag(r,kp,h), hshr0(r,kp,h)*hshr.l(r,kp,h,tsim)*eh.l(r,kp,h,tsim))
   - (bh.l(r,k,h,tsim)-1)
   + sum(kp$xcFlag(r,kp,h), hshr0(r,kp,h)*hshr.l(r,kp,h,tsim)*bh.l(r,kp,h,tsim)))$(%utility% eq CDE)
   ;

epsh.l(r,k,kp,h,tsim)$(xcFlag(r,k,h) and xcFlag(r,kp,h))

   = (-muc0(r,k,h)*muc.l(r,k,h,tsim)*pc.l(r,kp,h,tsim)*pop.l(r,tsim)*gammac.l(r,kp,h,tsim)
   *  pc0(r,kp,h)/(pc.l(r,k,h,tsim)*xc.l(r,k,h,tsim)*pc0(r,k,h)*xc0(r,k,h))
   - kron(k,kp)*(1 - pop.l(r,tsim)*gammac.l(r,k,h,tsim)*pop0(r)
   / (xc.l(r,k,h,tsim)*xc0(r,k,h))))$(%utility% eq ELES)

   + ((muc.l(r,kp,h,tsim)*muc0(r,kp,h)-kron(k,kp))
   *  (muc.l(r,k,h,tsim)*muc0(r,k,h)*supy0(r,h)*supy.l(r,h,tsim))
   /  (hshr0(r,k,h)*hshr.l(r,k,h,tsim)*((yd.l(r,tsim)-(savh.l(r,h,tsim)*(savh0(r,h)/yd0(r))))/pop.l(r,tsim))
   *  (yd0(r)/pop0(r))) - (hshr0(r,kp,h)*hshr.l(r,kp,h,tsim)*etah.l(r,k,h,tsim)))
   $(%utility% eq AIDADS or %utility% eq LES)

   + (hshr0(r,kp,h)*hshr.l(r,kp,h,tsim)*(-bh.l(r,kp,h,tsim)
   - (eh.l(r,k,h,tsim)*bh.l(r,k,h,tsim)
   - sum(k1$xcFlag(r,k1,h), hshr0(r,k1,h)*hshr.l(r,k1,h,tsim)*eh.l(r,k1,h,tsim)*bh.l(r,k1,h,tsim)))
   /  sum(k1$xcFlag(r,k1,h), hshr0(r,k1,h)*hshr.l(r,k1,h,tsim)*eh.l(r,k1,h,tsim)))
   + kron(k,kp)*(bh.l(r,k,h,tsim)-1))$(%utility% eq CDE)
   ;

* display epsh.l ;

$iftheni.FBS "%FBS_MODULE%" == "ON"

*  Update nutrition

*  Import shares by source

m_shr(s,i,d) = sum(r, xw.l(r,i,d,tsim)*xw0(r,i,d)*pdm.l(r,i,d,tsim)*pdm0(r,i,d)) ;
m_shr(s,i,d)$m_shr(s,i,d) = xw.l(s,i,d,tsim)*xw0(s,i,d)*pdm.l(s,i,d,tsim)*pdm0(s,i,d)/m_shr(s,i,d) ;

*  Nutrition from domestic sources
nutr(r,i,ucat,sua,"lcl",tsim)
   = nutr(r,i,ucat,sua,"lcl",tsim-1) * sum(aa$sameas(ucat,aa),
      (xd.l(r,i,aa,tsim) / xd.l(r,i,aa,tsim-1))$xd.l(r,i,aa,tsim-1) + (1)$(xd.l(r,i,aa,tsim-1) eq 0)) ;

*  Nutrition from imported sources
nutr(d,i,ucat,sua,srcr,tsim)$(not sameas(srcr,"lcl"))
   = nutr(d,i,ucat,sua,srcr,tsim-1) * sum(sameas(ucat,aa), sum(s$sameas(s,srcr),
           [((xw.l(s,i,d,tsim)/xw.l(s,i,d,tsim-1))$xw.l(s,i,d,tsim-1) + (1)$(xw.l(s,i,d,tsim-1) eq 0))
         + [((xm.l(d,i,aa,tsim)/xm.l(d,i,aa,tsim-1))$xm.l(d,i,aa,tsim-1) + (1)$(xm.l(d,i,aa,tsim-1) eq 0))
         - sum(r$xw.l(r,i,d,tsim-1), m_shr(r,i,d)*xw.l(r,i,d,tsim)/xw.l(r,i,d,tsim-1))]])) ;

*  Update loss
nutr(r,i,"LSS","LOSS_Kt",srcr,tsim)
*  From imports
   = (nutr(r,i,"LSS","LOSS_Kt",srcr,tsim-1)*sum(s$sameas(s,srcr),
      ((xw.l(s,i,r,tsim)/xw.l(s,i,r,tsim-1))$xw.l(s,i,r,tsim-1) + 1$(xw.l(s,i,r,tsim-1) ne 0))))
   $(not sameas(srcr,"LCL"))
*  From local production
   + (nutr(r,i,"LSS","LOSS_Kt",srcr,tsim-1)*((xdt.l(r,i,tsim)/xdt.l(r,i,tsim-1))$xdt.l(r,i,tsim-1)
   +  (1)$(xdt.l(r,i,tsim-1) eq 0)))
   $sameas(srcr,"LCL") ;
$endif.FBS

avgEmiIntT(rq,emq,aets,t) = sum(r$maprcp(rq,r), EmiTotETS.l(rq,r,emq,aets,t)*emiTotETS0(rq,r,emq,aets))
                          /  sum(r$maprcp(rq,r), sum(mapETS(rq,aets,a), px0(r,a)*xp0(r,a)*xp.l(r,a,t))) ;

