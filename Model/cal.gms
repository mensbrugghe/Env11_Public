* --------------------------------------------------------------------------------------------------
*
*  Calibrate the production CES nests
*
* --------------------------------------------------------------------------------------------------

loop(vOld,
   shr0_xpn(r,a)$xpFlag(r,a) = pxn0(r,a)*xpn0(r,a)/(uc0(r,a)*xpv0(r,a)) ;
   shr0_ghg(r,a)$xpFlag(r,a) = pxghg0(r,a)*xghg0(r,a)/(uc0(r,a)*xpv0(r,a)) ;
   alpha_xpn(r,a,v,t)        = 1 ;
   alpha_ghg(r,a,v,t)        = 1 ;

   shr0_procEmi(r,ghg,a)$procEmiFlag(r,ghg,a)
      = pCarb0(r,ghg,a)*procEmi0(r,ghg,a)/(pxghg0(r,a)*xghg0(r,a)) ;
   alpha_procEmi(r,ghg,a,v,t) = 1 ;

   shr0_xpx(r,a)             = (pxp0(r,a)*xpx0(r,a)/(pxn0(r,a)*xpn0(r,a)))$(ifNRSTop(r,a))
                             + (1)$(not ifNRSTop(r,a))
                             ;

   shr0_nd1(r,a)$xpFlag(r,a) = pnd10(r,a)*nd10(r,a)/(pxp0(r,a)*xpx0(r,a)) ;
   shr0_va(r,a)$xpFlag(r,a)  = pva0(r,a)*va0(r,a)/(pxp0(r,a)*xpx0(r,a)) ;
   alpha_nd1(r,a,v,t)        = 1 ;
   alpha_va(r,a,v,t)         = 1 ;

   shr0_lab1(r,a)$xpFlag(r,a)
      = (plab10(r,a)*lab10(r,a)/(pva0(r,a)*va0(r,a)))$acr(a)

      + (plab10(r,a)*lab10(r,a)/(pva10(r,a)*va10(r,a)))$alv(a)

      + (plab10(r,a)*lab10(r,a)/(pva0(r,a)*va0(r,a)))$ax(a)
      ;

   shr0_kef(r,a)$kefFlag(r,a)
      = (pkef0(r,a)*kef0(r,a)/(pva20(r,a)*va20(r,a)))$acr(a)

      + (pkef0(r,a)*kef0(r,a)/(pva10(r,a)*va10(r,a)))$alv(a)

      + (pkef0(r,a)*kef0(r,a)/(pva10(r,a)*va10(r,a)))$ax(a)
      ;

   shr0_nd2(r,a)$nd2Flag(r,a)
      = (pnd20(r,a)*nd20(r,a)/(pva10(r,a)*va10(r,a)))$acr(a)

      + (pnd20(r,a)*nd20(r,a)/(pva20(r,a)*va20(r,a)))$alv(a)
      ;

   shr0_va1(r,a)$va1Flag(r,a)
      = (pva10(r,a)*va10(r,a)/(pva0(r,a)*va0(r,a)))$acr(a)

      + (pva10(r,a)*va10(r,a)/(pva0(r,a)*va0(r,a)))$alv(a)

      + (pva10(r,a)*va10(r,a)/(pva0(r,a)*va0(r,a)))$ax(a)
      ;

   shr0_va2(r,a)$va2Flag(r,a)
      = (pva20(r,a)*va20(r,a)/(pva10(r,a)*va10(r,a)))$acr(a)

      + (pva20(r,a)*va20(r,a)/(pva0(r,a)*va0(r,a)))$alv(a)
      ;

   shr0_land(r,a)$landdFlag(r,a)
      = (plandd0(r,a)*landd0(r,a)/(pva20(r,a)*va20(r,a)))
      $(acr(a) or alv(a))

      + (plandd0(r,a)*landd0(r,a)/(pva10(r,a)*va10(r,a)))
      $ax(a)
      ;
   shr0_lnd(r,lnd,a)$xfFlag(r,lnd,a)  = (pfp0(r,lnd,a)*xf0(r,lnd,a)/(plandd0(r,a)*landd0(r,a))) ;
   shrx0_lnd(r,lnd,a)$xfFlag(r,lnd,a) = xf0(r,lnd,a)/landd0(r,a) ;

   alpha_lab1(r,a,v,t)  = 1 ;
   alpha_kef(r,a,v,t)   = 1 ;
   alpha_nd2(r,a,v,t)   = 1 ;
   alpha_va1(r,a,v,t)   = 1 ;
   alpha_va2(r,a,v,t)   = 1 ;
   alpha_land(r,a,v,t)  = 1 ;
   alpha_lnd(r,lnd,a,t) = 1 ;

   shr0_kf(r,a)$kfFlag(r,a)  = pkf0(r,a)*kf0(r,a)/(pkef0(r,a)*kef0(r,a)) ;
   shr0_nrg(r,a)$kfFlag(r,a) = pnrg0(r,a)*xnrg0(r,a)/(pkef0(r,a)*kef0(r,a)) ;
   alpha_kf(r,a,v,t)         = 1 ;
   alpha_nrg(r,a,v,t)        = 1 ;

   shr0_ksw(r,a)$kFlag(r,a) = (pksw0(r,a)*ksw0(r,a) / (pkf0(r,a)*kf0(r,a)))$(not ifNRSTop(r,a))
                            + (1)$ifNRSTop(r,a)

   loop(nrs,
      shr0_nrs(r,a)$xfFlag(r,nrs,a)
         = (pfp0(r,nrs,a)*xf0(r,nrs,a)/(pkf0(r,a)*kf0(r,a)))$(not ifNRSTop(r,a))
         + (pfp0(r,nrs,a)*xf0(r,nrs,a)/(pxn0(r,a)*xpn0(r,a)))$(ifNRSTop(r,a))
   ) ;
   alpha_ksw(r,a,v,t)       = 1 ;
   alpha_nrs(r,a,v,t)       = 1 ;

   shr0_ks(r,a)$kFlag(r,a)    = pks0(r,a)*ks0(r,a)/(pksw0(r,a)*ksw0(r,a)) ;
   shr0_wat(r,a)$watFlag(r,a) = pwat0(r,a)*xwat0(r,a)/(pksw0(r,a)*ksw0(r,a)) ;
   alpha_ks(r,a,v,t)          = 1 ;
   alpha_wat(r,a,v,t)         = 1 ;

   loop(wat,
      shr0_f(r,wat,a,t)$xfFlag(r,wat,a) = pf0(r,wat,a)*xf0(r,wat,a)/(pwat0(r,a)*xwat0(r,a)) ;
   ) ;

   shr0_k(r,a)$kFlag(r,a)       = pkp0(r,a)*kv0(r,a)/(pks0(r,a)*ks0(r,a)) ;
   shr0_lab2(r,a)$lab2Flag(r,a) = plab20(r,a)*lab20(r,a)/(pks0(r,a)*ks0(r,a)) ;
   alpha_k(r,a,v,t)             = 1 ;
   alpha_lab2(r,a,v,t)          = 1 ;

   shr0_labb(r,wb,a,t)$labbFlag(r,wb,a)
      = (plabb0(r,wb,a)*labb0(r,wb,a)/(plab10(r,a)*lab10(r,a)))
      $maplab1(wb)
      + (plabb0(r,wb,a)*labb0(r,wb,a)/(plab20(r,a)*lab20(r,a)))
      $(not maplab1(wb))
      ;

   loop(mapl(wb,l),
      shr0_f(r,l,a,t)$xfFlag(r,l,a)
         = pfp0(r,l,a)*xf0(r,l,a)/(plabb0(r,wb,a)*labb0(r,wb,a)) ;
   ) ;

   alpha_io(r,i,a,t) = 1 ;
   shr0_io(r,i,a,t)$xaFlag(r,i,a)
      = (pa0(r,i,a)*xa0(r,i,a)/(pnd10(r,a)*nd10(r,a)))$mapnd1(i,a)
      + (pa0(r,i,a)*xa0(r,i,a)/(pnd20(r,a)*nd20(r,a)))$mapnd2(i,a)
      + (pa0(r,i,a)*xa0(r,i,a)/(pwat0(r,a)*xwat0(r,a)))$iw(i)
      ;

*  NRG bundle -- !!!! needs to be refined

   if(ifNRGNest,

      shr0_nely(r,a)$xnrgFlag(r,a)
         = pnely0(r,a)*xnely0(r,a)/(pnrg0(r,a)*xnrg0(r,a)) ;
      shrx0_nely(r,a)$xnrgFlag(r,a)
         = xnely0(r,a)/xnrg0(r,a) ;
      shr0_NRGB(r,a,"ELY")$xnrgFlag(r,a)
         = paNRG0(r,a,"ELY")*xaNRG0(r,a,"ELY")/(pnrg0(r,a)*xnrg0(r,a)) ;
      shrx0_NRGB(r,a,"ELY")$xnrgFlag(r,a)
         = xaNRG0(r,a,"ELY")/xnrg0(r,a) ;
      shr0_olg(r,a)$xnelyFlag(r,a)
         = polg0(r,a)*xolg0(r,a)/(pnely0(r,a)*xnely0(r,a)) ;
      shrx0_olg(r,a)$xnelyFlag(r,a)
         = xolg0(r,a)/xnely0(r,a) ;
      shr0_NRGB(r,a,"COA")$xnelyFlag(r,a)
         = paNRG0(r,a,"COA")*xaNRG0(r,a,"COA")/(pnely0(r,a)*xnely0(r,a)) ;
      shrx0_NRGB(r,a,"COA")$xnelyFlag(r,a)
         = xaNRG0(r,a,"COA")/xnely0(r,a) ;
      shr0_NRGB(r,a,"GAS")$xolgFlag(r,a)
         = paNRG0(r,a,"GAS")*xaNRG0(r,a,"GAS")/(polg0(r,a)*xolg0(r,a)) ;
      shrx0_NRGB(r,a,"GAS")$xolgFlag(r,a)
         = xaNRG0(r,a,"GAS")/xolg0(r,a) ;
      shr0_NRGB(r,a,"OIL")$xolgFlag(r,a)
         = paNRG0(r,a,"OIL")*xaNRG0(r,a,"OIL")/(polg0(r,a)*xolg0(r,a)) ;
      shrx0_NRGB(r,a,"OIL")$xolgFlag(r,a)
         = xaNRG0(r,a,"OIL")/xolg0(r,a) ;

      shr0_eio(r,e,a)$xaFlag(r,e,a)
         = sum(NRG$mape(NRG,e), pa0(r,e,a)*xa0(r,e,a)/(paNRG0(r,a,NRG)*xaNRG0(r,a,NRG))) ;
      shrx0_eio(r,e,a)$xaFlag(r,e,a)
         = sum(NRG$mape(NRG,e), xa0(r,e,a)/xaNRG0(r,a,NRG)) ;

      alpha_nely(r,a,v,t)     = 1 ;
      alpha_olg(r,a,v,t)      = 1 ;
      alpha_NRGB(r,a,NRG,v,t) = 1 ;
      alpha_eio(r,e,a,v,t)    = 1 ;

   else

      shr0_eio(r,e,a)$xaFlag(r,e,a)
         = (pa0(r,e,a)*xa0(r,e,a))/(pnrg0(r,a)*xnrg0(r,a)) ;
      shrx0_eio(r,e,a)$xaFlag(r,e,a)
         = xa0(r,e,a)/xnrg0(r,a) ;
      alpha_eio(r,e,a,v,t) = 1 ;

   ) ;
) ;

* --------------------------------------------------------------------------------------------------
*
*  Calibrate the 'make/use' module
*
* --------------------------------------------------------------------------------------------------

shr0_p(r,a,i)$xpFlag(r,a) = p0(r,a,i)*x0(r,a,i) / (px0(r,a)*xp0(r,a)) ;

shr0_s(r,a,i)$xsFlag(r,i) = pp0(r,a,i)*x0(r,a,i) / (ps0(r,i)*xs0(r,i)) ;

*  Calibrate power module

if(IFPOWER,

*  ACES uses initial volume shares

   loop((r,elya,pb,elyc)$(mappow(pb,elya) and x0(r,elya,elyc)),
      shr0_s(r,elya,elyc)$xpb0(r,pb,elyc) = x0(r,elya,elyc)/xpb0(r,pb,elyc) ;
   ) ;

   shr0_pb(r,pb,elyc)$xpow0(r,elyc) = xpb0(r,pb,elyc)/xpow0(r,elyc) ;

*  However, 'etd' and 'pow' are in a standard CES nest and thus uses value shares

   shr0_s(r,etd,elyc)$xs0(r,elyc)
      = pp0(r,etd,elyc)*x0(r,etd,elyc)/(ps0(r,elyc)*xs0(r,elyc)) ;
   shr0_pow(r,elyc)$xs0(r,elyc)
      = ppow0(r,elyc)*xpow0(r,elyc)/(ps0(r,elyc)*xs0(r,elyc)) ;

else
   shr0_pb(r,pb,elyc) = 0 ;
   shr0_pow(r,elyc)   = 0 ;
) ;
alpha_s(r,a,i,t) = 1 ;

* --------------------------------------------------------------------------------------------------
*
*  Calibrate income distribution parameters
*
* --------------------------------------------------------------------------------------------------

*  Capital income allocation parameters

ydistf(r,t)             = sum((a,cap), (1 - kappaf0(r,cap,a))*pf0(r,cap,a)*xf0(r,cap,a)) ;
ydistf(r,t)$ydistf(r,t) = yqtf0(r) / ydistf(r,t) ;
chiTrust(r,t)$trustY0   = yqht0(r)/trustY0 ;

*  Remittance parameters

*  Calculated pre-tax

chiRemit(s,l,r,t)$remit0(s,l,r)
   = remit0(s,l,r)/sum(a, (1-kappaf0(r,l,a))*pf0(r,l,a)*xf0(r,l,a)) ;

*  ODA parameters

chiODAOut(r,t)        = OdaOut0(r)/GDPMP0(r) ;
chiOdaIn(r,t)$ODAGbl0 = ODAin0(r)/ODAGbl0 ;

* --------------------------------------------------------------------------------------------------
*
*  Calibrate final demand
*
* --------------------------------------------------------------------------------------------------

etah.fx(r,k,h,t) = incElas(k,r) ;

zcons0(r,k,h)   = 1 ;
supy0(r,h)      = 1 ;

yd.l(r,t)       = 1 ;
yc.l(r,h,t)     = 1 ;
$iftheni "%simType%" == "compStat"
pop.fx(r,t)     = pop0(r) ;
$else
pop.fx(r,t)     = pop.l(r,t)/pop0(r) ;
$endif
savh.l(r,h,t)   = 1 ;
muc0(r,k,h)     = 1 ;
pc.l(r,k,h,t)   = 1 ;
xc.l(r,k,h,t)   = 1 ;
hshr.l(r,k,h,t) = 1 ;

*  Define the ELES calibration model

model elescal / supyeq, xceq / ;
elescal.holdfixed = 1 ;

if(%utility% = ELES,

*  ELES parameters

   loop(h,
      muc0(r,k,h)     = etah.l(r,k,h,t0)*pc0(r,k,h)*xc0(r,k,h)/yd0(r) ;
      muc.fx(r,k,h,t) = 1 ;
      mus0(r,h)       = 1 - sum(k, muc0(r,k,h)) ;
      mus.fx(r,h,t)   = 1 ;
   ) ;

*  Initialize the gamma parameters and supy

   loop(h,
      gammac.l(r,k,h,t) = 0.1*xc0(r,k,h)/pop0(r) ;
      supy.l(r,h,t)  = yd0(r)/pop0(r) - sum(k, pc0(r,k,h)*gammac.l(r,k,h,t)) ;
   ) ;

   betac.fx(r,h,t) = 1 ;

*  Fix temporarily the other variables

   yd.fx(r,t)        = yd.l(r,t) ;
   pc.fx(r,k,h,t)    = pc.l(r,k,h,t) ;
   xc.fx(r,k,h,t)    = xc.l(r,k,h,t) ;

   ts(t) = no ; ts(t0) = yes ;

*  Solve for the subsistence minima

   options limcol=0, limrow=0 ;
   options solprint=off ;
   solve elescal using mcp ;

*  Re-endogenize variables

   yd.lo(r,t)      = -inf  ; yd.up(r,t)     = +inf ;
   pc.lo(r,k,h,t)  = -inf  ; pc.up(r,k,h,t) = +inf ;
   xc.lo(r,k,h,t)  = -inf  ; xc.up(r,k,h,t) = +inf ;
   muc.lo(r,k,h,t) = -inf  ; muc.up(r,k,h,t) = +inf ;
   etah.lo(r,k,h,t) = -inf ; etah.up(r,k,h,t) = +inf ;

   gammac.l(r,k,h,t) = gammac.l(r,k,h,t0) ;
   supy0(r,h)        = supy.l(r,h,t0) ;
   supy.l(r,h,t)     = 1 ;

   ts(t) = no ;

*  !!!! if uFlag = 0, the input data should be fixed

   uFlag(r,h)$(supy0(r,h) gt 0 and mus0(r,h) gt 0) = 1 ;
   u0(r,h)$uFlag(r,h) = supy0(r,h)
                      / (prod(k$xcFlag(r,k,h), (pc0(r,k,h)/muc0(r,k,h))**muc0(r,k,h))
                      * ((pfd0(r,h)/mus0(r,h))**mus0(r,h))) ;
   u0(r,h)$(not uFlag(r,h)) = 1 ;

   aad.fx(r,h,t) = exp(sum(k$xcFlag(r,k,h),
                            muc0(r,k,h)*log(xc0(r,k,h)/pop0(r) - gammac.l(r,k,h,t0)))
                 +         (mus0(r,h)*log(savh0(r,h)/pop0(r)))$(savh0(r,h) > 0)
                 - u0(r,h) - 1) ;

   etah.l(r,k,h,t)$xcFlag(r,k,h) = muc0(r,k,h)/((pc0(r,k,h)*xc0(r,k,h))/yd0(r)) ;

   epsh.l(r,k,kp,h,t)$(xcFlag(r,k,h) and xcFlag(r,kp,h))
      = -muc0(r,k,h)*pc0(r,kp,h)*pop0(r)*gammac.l(r,kp,h,t)/(pc0(r,k,h)*xc0(r,k,h))
      -  kron(k,kp)*(1 - pop0(r)*gammac.l(r,k,h,t)/xc0(r,k,h)) ;

elseif(%utility% = CD),

*  Cobb-Douglas

   betac.fx(r,h,t)   = 1 ;
   muc0(r,k,h)$xcFlag(r,k,h) = pc0(r,k,h)*xc0(r,k,h) / yc0(r,h) ;
   muc.l(r,k,h,t)    = 1 ;
   gammac.l(r,k,h,t) = 0 ;
   supy0(r,h)        = yc0(r,h)/pop0(r)
                     - sum(k, pc0(r,k,h)*gammac.l(r,k,h,t0)) ;
   supy.l(r,h,t)     = 1 ;

   alphaad.fx(r,k,h,t) = muc0(r,k,h) ;
   betaad.fx(r,k,h,t)  = muc0(r,k,h) ;

   u0(r,h) = 1 ;

   aad.fx(r,h,t)
      = exp(sum(k$xcFlag(r,k,h), muc0(r,k,h)*log(xc0(r,k,h)/pop0(r) - gammac.l(r,k,h,t0)))
      - u0(r,h) - 1) ;

   etah.l(r,k,h,t)$xcFlag(r,k,h) = 1 ;

   epsh.l(r,k,kp,h,t)$(xcFlag(r,k,h) and xcFlag(r,kp,h))
      = -1$(ord(k) eq ord(kp))
      +  0$(ord(k) ne ord(kp))
      ;

elseif(%utility% = LES or %utility% = AIDADS),

*  LES parameters

*  !!!! Needs to be replaced
*  Function calibrated to frisch(500) = -4, frisch(40000) = -1.10  with pc incomes in '000

   frisch(r,h,t) = -1.0/(1 - 0.770304*exp(-0.053423*rgdppc0(r)*0.001*popScale/inScale)) ;

*  display frisch ;

   betac.fx(r,h,t)   = 1 ;
   muc0(r,k,h)$xcFlag(r,k,h) = etah.l(r,k,h,t0)*pc0(r,k,h)*xc0(r,k,h)
                             / yc0(r,h) ;
   muc.l(r,k,h,t)    = 1 ;
   gammac.l(r,k,h,t)$xcFlag(r,k,h) = yc0(r,h)*(hshr0(r,k,h)
                                   + muc0(r,k,h)/frisch(r,h,t))/pc0(r,k,h) ;
   gammac.l(r,k,h,t) = gammac.l(r,k,h,t) / pop0(r) ;
   supy0(r,h) = yc0(r,h)/pop0(r)
              -  sum(k, pc0(r,k,h)*gammac.l(r,k,h,t0)) ;
   supy.l(r,h,t) = 1 ;

   alphaad.fx(r,k,h,t) = muc0(r,k,h) ;
   betaad.fx(r,k,h,t)  = muc0(r,k,h) ;

   u0(r,h) = 1 ;

   aad.fx(r,h,t)
      = exp(sum(k$xcFlag(r,k,h), muc0(r,k,h)*log(xc0(r,k,h)/pop0(r) - gammac.l(r,k,h,t0)))
      - u0(r,h) - 1) ;

   omegaad.fx(r,h)
      = sum(k$xcFlag(r,k,h), (betaad.l(r,k,h,t0)-alphaad.l(r,k,h,t0))
      *     log(xc0(r,k,h)/pop0(r) - gammac.l(r,k,h,t0)))
      - power(1+exp(u0(r,h)),2)*exp(-u0(r,h)) ;
   omegaad.fx(r,h) = 1/omegaad.l(r,h) ;

   etah.l(r,k,h,t)$xcFlag(r,k,h) = (muc0(r,k,h)
      - (betaad.l(r,k,h,t)-alphaad.l(r,k,h,t))*omegaad.l(r,h)) / hshr0(r,k,h) ;

   epsh.l(r,k,kp,h,t)$(xcFlag(r,k,h) and xcFlag(r,kp,h))
      = (muc0(r,kp,h)-kron(k,kp))
      * (muc0(r,k,h)*supy0(r,h))
      / (hshr0(r,k,h)*(yc0(r,h)/pop0(r)))
      - (hshr0(r,kp,h)*etah.l(r,k,h,t)) ;

elseif (%utility% = CDE),

*  !!!! TO BE REVIEWED

   u0(r,h)        = 1 ;
   eh.fx(r,k,h,t) = eh0(k,r) ;
   bh.fx(r,k,h,t) = bh0(k,r) ;
   alphah.fx(r,k,h,t)$xcFlag(r,k,h) = (hshr0(r,k,h)/bh.l(r,k,h,t))
*     * (((yfd0(r,h)/(pop0(r)*pop.l(r,t)))/pc0(r,k,h))**bh.l(r,k,h,t))
      * (((yfd0(r,h)/pop0(r))/pc0(r,k,h))**bh.l(r,k,h,t))
      * (u0(r,h)**(-bh.l(r,k,h,t)*eh.l(r,k,h,t)))
      / sum(kp$xcFlag(r,kp,h), hshr0(r,kp,h)/bh.l(r,kp,h,t)) ;

   zcons0(r,k,h) = alphah.l(r,k,h,t0)*bh.l(r,k,h,t0)*(u0(r,h)**(eh.l(r,k,h,t0)*bh.l(r,k,h,t0)))
                 *  (pc0(r,k,h)/(yfd0(r,h)/pop0(r)))**bh.l(r,k,h,t0) ;

   etah.l(r,k,h,t)$xcFlag(r,k,h) =
      (eh.l(r,k,h,t)*bh.l(r,k,h,t) - sum(kp$xcFlag(r,kp,h),
         hshr0(r,kp,h)*eh.l(r,kp,h,t)*bh.l(r,kp,h,t)))
      / sum(kp$xcFlag(r,kp,h), hshr0(r,kp,h)*eh.l(r,kp,h,t)) - (bh.l(r,k,h,t)-1)
      + sum(kp$xcFlag(r,kp,h), hshr0(r,kp,h)*bh.l(r,kp,h,t)) ;

   epsh.l(r,k,kp,h,t)$(xcFlag(r,k,h) and xcFlag(r,kp,h)) =
      (hshr0(r,kp,h)*(-bh.l(r,kp,h,t)
       - (eh.l(r,k,h,t)*bh.l(r,k,h,t) - sum(k1$xcFlag(r,k1,h),
          hshr0(r,k1,h)*eh.l(r,k1,h,t)*bh.l(r,k1,h,t)))
       /  sum(k1$xcFlag(r,k1,h), hshr0(r,k1,h)*eh.l(r,k1,h,t))) + kron(k,kp)*(bh.l(r,k,h,t)-1)) ;

*  Initialize the BaU levels to base year

   ehBaU(r,k,h,t) = eh.l(r,k,h,t) ;
   bhBaU(r,k,h,t) = bh.l(r,k,h,t) ;
) ;

*  Calibrate the rest of the consumer demand nesting

shr0_cxnnrg(r,k,h)$xcnnrgFlag(r,k,h) = pcnnrg0(r,k,h)*xcnnrg0(r,k,h) / (pc0(r,k,h)*xc0(r,k,h)) ;
shr0_cxnrg(r,k,h)$xcnrgFlag(r,k,h)   = pcnrg0(r,k,h)*xcnrg0(r,k,h) /  (pc0(r,k,h)*xc0(r,k,h))  ;

shr0_c(r,i,k,h)$(xcnnrgFlag(r,k,h) and not e(i))
   = (pa0(r,i,h)*cmat(i,k,r)/pa0(r,i,h))/(pcnnrg0(r,k,h)*xcnnrg0(r,k,h)) ;
shr0_c(r,i,k,h)$(xcnnrgFlag(r,k,h) and not e(i))
   = (pa0(r,i,h)*cmat(i,k,r)/pa0(r,i,h))/(pcnnrg0(r,k,h)*xcnnrg0(r,k,h)) ;

shr0_cnely(r,k,h,t)$xcnelyFlag(r,k,h)
   = pcnely0(r,k,h)*xcnely0(r,k,h)/(pcnrg0(r,k,h)*xcnrg0(r,k,h)) ;
shrx0_cnely(r,k,h,t)$xcnelyFlag(r,k,h)
   = xcnely0(r,k,h)/xcnrg0(r,k,h) ;
shr0_colg(r,k,h,t)$xcolgFlag(r,k,h)
   = pcolg0(r,k,h)*xcolg0(r,k,h)/(pcnely0(r,k,h)*xcnely0(r,k,h)) ;
shrx0_colg(r,k,h,t)$xcolgFlag(r,k,h)
   = xcolg0(r,k,h)/xcnely0(r,k,h) ;
shr0_cNRG(r,k,h,NRG,t)$(xacNRGFlag(r,k,h,NRG) and ifNRGNest)
   = (pacNRG0(r,k,h,NRG)*xacNRG0(r,k,h,NRG)/(pcnrg0(r,k,h)*xcnrg0(r,k,h)))$ely(nrg)
   + (pacNRG0(r,k,h,NRG)*xacNRG0(r,k,h,NRG)/(pcnely0(r,k,h)*xcnely0(r,k,h)))$coa(nrg)
   + (pacNRG0(r,k,h,NRG)*xacNRG0(r,k,h,NRG)/(pcolg0(r,k,h)*xcolg0(r,k,h)))$gas(nrg)
   + (pacNRG0(r,k,h,NRG)*xacNRG0(r,k,h,NRG)/(pcolg0(r,k,h)*xcolg0(r,k,h)))$oil(nrg)
   ;
shrx0_cNRG(r,k,h,NRG,t)$(xacNRGFlag(r,k,h,NRG) and ifNRGNest)
   = (xacNRG0(r,k,h,NRG)/xcnrg0(r,k,h))$ely(nrg)
   + (xacNRG0(r,k,h,NRG)/xcnely0(r,k,h))$coa(nrg)
   + (xacNRG0(r,k,h,NRG)/xcolg0(r,k,h))$gas(nrg)
   + (xacNRG0(r,k,h,NRG)/xcolg0(r,k,h))$oil(nrg)
   ;

alpha_cnely(r,k,h,t)    = 1 ;
alpha_cNRG(r,k,h,NRG,t) = 1 ;

if(ifNRGNest,
   loop(mape(NRG,e),
     shr0_c(r,e,k,h)$xacNRG0(r,k,h,NRG)
         = pa0(r,e,h)*(cmat(e,k,r)/pa0(r,e,h))/(pacNRG0(r,k,h,NRG)*xacNRG0(r,k,h,NRG)) ;
     shrx0_c(r,e,k,h)$xacNRG0(r,k,h,NRG)
         = (cmat(e,k,r)/pa0(r,e,h))/xacNRG0(r,k,h,NRG) ;
   ) ;
else
   shr0_c(r,e,k,h)$xcnrg0(r,k,h)
         = pa0(r,e,h)*(cmat(e,k,r)/pa0(r,e,h))/(pcnrg0(r,k,h)*xcnrg0(r,k,h)) ;
   shrx0_c(r,e,k,h)$xcnrg0(r,k,h)
         = (cmat(e,k,r)/pa0(r,e,h))/xcnrg0(r,k,h) ;
) ;

*  Other final demand

sigmafd(r,fdc)$(sigmafd(r,fdc) eq 1) = 1.01 ;
shr0_fd(r,i,fdc,t)$fdflag(r,fdc) = pa0(r,i,fdc)*xa0(r,i,fdc)/(pfd0(r,fdc)*xfd0(r,fdc)) ;

* --------------------------------------------------------------------------------------------------
*
*  Calibrate trade module
*
* --------------------------------------------------------------------------------------------------

sigmamt(r,i)$(sigmamt(r,i) eq 1.0) = 1.01 ;
sigmaw(r,i)$(sigmaw(r,i) eq 1.0)   = 1.01 ;

*  !!!! Potentially dangerous

work = 0 ;
loop((r,i),
   if(xddFlag(r,i) and xat0(r,i) eq 0,
      if(work = 0,
         put screen ; put / ; put "WARNING: XAT=0, XDT<>0" / / ;
      ) ;
      work = work + 1 ;
      put r.tl:<10, i.tl:<10, "XDT0 = ", xdt0(r,i) / ;
      if(abs(xdt0(r,i)/inscale) le 1e-4,
         xdt0(r,i) = 0 ; xdtFlag(r,i) = 0 ;
      ) ;
   ) ;
) ;
if(work, putclose screen ; ) ;

shr0_dt(r,i)$xdtFlag(r,i)    = pdt0(r,i)*(xdt0(r,i) - xtt0(r,i))/(pat0(r,i)*xat0(r,i)) ;
shr0_mt(r,i)$xmtFlag(r,i)    = pmt0(r,i)*xmt0(r,i)/(pat0(r,i)*xat0(r,i)) ;
shrx0_dt(r,i)$xdtFlag(r,i)   = (xdt0(r,i) - xtt0(r,i))/xat0(r,i) ;
shrx0_mt(r,i)$xmtFlag(r,i)   = xmt0(r,i)/xat0(r,i) ;
alpha_dt(r,i,t)$xddFlag(r,i) = 1 ;
alpha_mt(r,i,t)$xmtFlag(r,i) = 1 ;

*display shr0_dt, xddflag, xdt0, xtt0, pat0, xat0 ;

shr0_d(r,i,aa)$xdFlag(r,i,aa)  = pd0(r,i,aa)*xd0(r,i,aa)/(pa0(r,i,aa)*xa0(r,i,aa)) ;
shr0_m(r,i,aa)$xmFlag(r,i,aa)  = pm0(r,i,aa)*xm0(r,i,aa)/(pa0(r,i,aa)*xa0(r,i,aa)) ;
shrx0_d(r,i,aa)$xdFlag(r,i,aa) = xd0(r,i,aa)/xa0(r,i,aa) ;
shrx0_m(r,i,aa)$xmFlag(r,i,aa) = xm0(r,i,aa)/xa0(r,i,aa) ;
alpha_d(r,i,aa,t)$xdFlag(r,i,aa) = 1 ;
alpha_m(r,i,aa,t)$xmFlag(r,i,aa) = 1 ;

*  Second level Armington

lambdaw(s,i,d,t) = 1 ;
lambdax(s,i,d,t) = 1 ;

$iftheni "%MRIO_MODULE%" == "ON"
   sigmawa(r,i,aa)$(sigmawa(r,i,aa) eq 1) = 1.01 ;
   shr0_wa(s,i,d,aa,t)$xwaFlag(s,i,d,aa)
      = pdma0(s,i,d,aa)*xwa0(s,i,d,aa)/(pma0(d,i,aa)*xm0(d,i,aa)) ;
$endif
sigmaw(r,i)$(sigmaw(r,i) eq 1) = 1.01 ;
shr0_w(s,i,d)$xwFlag(s,i,d)    = pdm0(s,i,d)*xw0(s,i,d)/(pmt0(d,i)*xmt0(d,i)) ;
shrx0_w(s,i,d)$xwFlag(s,i,d)   = xw0(s,i,d)/xmt0(d,i) ;
alpha_w(s,i,d,t)$xwFlag(s,i,d) = 1 ;

*  Top level CET

shr0_dx(r,i,t)$xdtFlag(r,i) = pdt0(r,i)*xdt0(r,i) / (ps0(r,i)*xs0(r,i)) ;
shr0_ex(r,i,t)$xetFlag(r,i) = pet0(r,i)*xet0(r,i) / (ps0(r,i)*xs0(r,i)) ;
shrx0_dx(r,i,t)$xdtFlag(r,i) = xdt0(r,i) / xs0(r,i) ;
shrx0_ex(r,i,t)$xetFlag(r,i) = xet0(r,i) / xs0(r,i) ;

* display shr0_dx, shr0_ex ;

*  Second level CET

shr0_wx(s,i,d,t)$xwFlag(s,i,d)  = pe0(s,i,d)*xw0(s,i,d)/(pet0(s,i)*xet0(s,i)) ;
shrx0_wx(s,i,d,t)$xwFlag(s,i,d) = xw0(s,i,d)/xet0(s,i) ;

put screen ; put / ;
loop((img,s,i,d),
   if(tmgFlag(s,i,d) and xwmg0(s,i,d) eq 0,
      put img.tl, s.tl, i.tl, d.tl / ;
   ) ;
) ;
shr0_mgm(img,s,i,d)$tmgFlag(s,i,d) = ptmg0(img)*xmgm0(img,s,i,d)/(pwmg0(s,i,d)*xwmg0(s,i,d)) ;

sigmamg(img)$(sigmamg(img) eq 1)  = 1.01 ;
shr0_xtmg(r,img,t)$xttFlag(r,img) = pdt0(r,img)*xtt0(r,img)/(ptmg0(img)*xtmg0(img)) ;

* --------------------------------------------------------------------------------------------------
*
*  Calibration of factor supplies
*
* --------------------------------------------------------------------------------------------------

kronm(rur) = -1 ;
kronm(urb) = +1 ;

chim(r,l,t)$migrFlag(r,l) = migr0(r,l)*urbPrem0(r,l)**(-omegam(r,l)) ;

shr0_kvs(r,a,v) = pk0(r,a)*kv0(r,a)/(trent0(r)*tkaps0(r)) ;

*  Curvature parameter in land supply function

gammatl(r,lnd,t)$tland0(r,lnd)
   = (etat(r,lnd))$(%TASS% eq KELAS)

   + (etat(r,lnd)*(pgdpmp0(r)/ptland0(r,lnd))*(landmax.l(r,lnd,t0)
   / (landmax.l(r,lnd,t0) - tland0(r,lnd))))$(%TASS% eq LOGIST)

   + (etat(r,lnd)*tland0(r,lnd)/(landmax.l(r,lnd,t0) - tland0(r,lnd)))$(%TASS% eq HYPERB)

   + (0)$(%TASS% eq INFTY)
   ;

*     Shift parameter in land supply function

chiLand(r,lnd,t)$tland0(r,lnd)
   = (tland0(r,lnd)*(pgdpmp0(r)/ptland0(r,lnd))**etat(r,lnd))$(%TASS% eq KELAS)

   + (exp(gammatl(r,lnd,t0)*(ptland0(r,lnd)/pgdpmp0(r)))
   * ((landmax.l(r,lnd,t0) - tland0(r,lnd))/tland0(r,lnd)))$(%TASS% eq LOGIST)

   + ((landmax.l(r,lnd,t0) - tland0(r,lnd))
   * (ptland0(r,lnd)/pgdpmp0(r))**gammatl(r,lnd,t0))$(%TASS% eq HYPERB)

   + (0)$(%TASS% eq INFTY)

   ;

loop(lb$lb1(lb),
   shr0_lb(r,lnd,lb,t)$tland0(r,lnd)
         = (plb0(r,lnd,lb)*xlb0(r,lnd,lb)/(ptland0(r,lnd)*tland0(r,lnd)))$ifLandCET
         + (xlb0(r,lnd,lb)/tland0(r,lnd))$(not ifLandCET) ;
) ;

*  display tland0, xnlb0, ptland0, pnlb0 ;

shr0_nlb(r,lnd,t)$tland0(r,lnd)
     = (pnlb0(r,lnd)*xnlb0(r,lnd) / (ptland0(r,lnd)*tland0(r,lnd)))$ifLandCET
      + (xnlb0(r,lnd) / tland0(r,lnd))$(not ifLandCET)
      ;

loop(lb$(not lb1(lb)),
   shr0_lb(r,lnd,lb,t)$xnlb0(r,lnd)
         = (plb0(r,lnd,lb)*xlb0(r,lnd,lb)/(pnlb0(r,lnd)*xnlb0(r,lnd)))$ifLandCET
         + (xlb0(r,lnd,lb)/xnlb0(r,lnd))$(not ifLandCET)
         ;
) ;

loop(maplb(lb,a),
   shr0_t(r,lnd,a,t)$xlb0(r,lnd,lb)
      = (pf0(r,lnd,a)*xf0(r,lnd,a) / (plb0(r,lnd,lb)*xlb0(r,lnd,lb)))$ifLandCET
      + (xf0(r,lnd,a) / xlb0(r,lnd,lb))$(not ifLandCET)
      ;
) ;

*  Natural resource supply

loop(nrs,

*  Set flag to infinity if either of the elasticities is infinite

   xfFlag(r,nrs,a)$(xfFlag(r,nrs,a) and (etanrsx(r,a,"lo") = inf or etanrsx(r,a,"hi") = inf))
      = inf ;
   xnrsFlag(r,a) = xfFlag(r,nrs,a) ;

   etanrs.l(r,a,t)$(xfFlag(r,nrs,a) and xfFlag(r,nrs,a) ne inf)
      = etanrsx(r,a,"lo") + 0.5*(etanrsx(r,a,"hi") - etanrsx(r,a,"lo")) ;

   chinrsp(r,a)$xfFlag(r,nrs,a) = (pgdpmp0(r)/pf0(r,nrs,a))$(xfFlag(r,nrs,a) eq inf)
                                + (1)$(xfFlag(r,nrs,a) ne inf) ;

*  display  chinrsp ;

   wchinrs.fx(a,t)                  = 1 ;
   chinrs.fx(r,a,t)$xfFlag(r,nrs,a) = 1 ;
) ;


*  Water supply

if(IFWATER,

*  Curvature parameter water land supply function

   gammatw(r,t) = (etaw(r))$(%WASS% eq KELAS)
                + (etaw(r)*(pgdpmp0(r)/pth2o0(r))*(H2OMax.l(r,t0)
                / (H2OMax.l(r,t0) - th2o0(r))))$(%WASS% eq LOGIST)
                + (etaw(r)*th2o0(r)/(H2OMax.l(r,t0) - th2o0(r)))$(%WASS% eq HYPERB)
                + (0)$(%WASS% eq INFTY)
                ;

*  Shift parameter in water supply function

   chiH2O(r,t)  = (th2o0(r)*(pgdpmp0(r)/pth2o0(r))**etaw(r))$(%WASS% eq KELAS)
                + (exp(gammatw(r,t0)*(pth2o0(r)/pgdpmp0(r)))
                *  ((H2OMax.l(r,t0) - th2o0(r))/th2o0(r)))$(%WASS% eq LOGIST)
                + ((H2OMax.l(r,t0) - th2o0(r))
                *  (pth2o0(r)/pgdpmp0(r))**gammatw(r,t0))$(%WASS% eq HYPERB)
                + (0)$(%WASS% eq INFTY)
                ;
) ;

*  Water ACET -- top level

shr0_1h2o(r,wbnd1,t)$th2om0(r) = h2obnd0(r,wbnd1)/th2om0(r) ;

*  Second level CET

loop(wbnd1,
   shr0_2h2o(r,wbnd2,t)$(mapw1(wbnd1,wbnd2) and h2obnd0(r,wbnd1))
      = h2obnd0(r,wbnd2)/h2obnd0(r,wbnd1) ;
) ;

*  Activity level CET

loop(wat,
   loop(wbnd2$wbnda(wbnd2),
      shr0_3h2o(r,a,t)$h2obnd0(r,wbnd2) = xf0(r,wat,a)/h2obnd0(r,wbnd2) ;

   ) ;
) ;

*  Aggregate demand shifter

loop(wbnd2$wbndi(wbnd2),
   ah2obnd(r,wbnd2,t)$h2obnd0(r,wbnd2) = h2obnd0(r,wbnd2)
      * (ph2obnd0(r,wbnd2) / pgdpmp0(r))**epsh2obnd(r,wbnd2) ;
) ;

* --------------------------------------------------------------------------------------------------
*
*  Miscellaneous calibration
*
* --------------------------------------------------------------------------------------------------

* --------------------------------------------------------------------------------------------------
*
*  Normalize variables
*
* --------------------------------------------------------------------------------------------------

pxv.l(r,a,v,t)           = 1 ;
px.l(r,a,t)              = 1 ;
pxghg.l(r,a,v,t)         = 1 ;
uc.l(r,a,v,t)            = 1 ;
xghg.l(r,a,v,t)$(vOld(v) and xghg0(r,a))  = 1 ;
procEmi.l(r,ghg,a,t)$procEmi0(r,ghg,a)    = 1 ;
pCarb.l(r,ghg,a,t)       = 1 ;
xpn.l(r,a,v,t)$(vOld(v) and xpn0(r,a))    = 1 ;
xpx.l(r,a,v,t)$(vOld(v) and xpx0(r,a))    = 1 ;
pxn.l(r,a,v,t)           = 1 ;

pnd1.l(r,a,t)            = 1 ;
pva.l(r,a,v,t)           = 1 ;
pxp.l(r,a,v,t)           = 1 ;
nd1.l(r,a,t)$nd10(r,a)   = 1 ;
va.l(r,a,v,t)$(vOld(v) and va0(r,a)) = 1 ;

plab1.l(r,a,t)           = 1 ;
plab2.l(r,a,t)           = 1 ;
plabb.l(r,wb,a,t)        = 1 ;
lab1.l(r,a,t)$lab10(r,a)       = 1 ;
lab2.l(r,a,t)$lab20(r,a)       = 1 ;
labb.l(r,wb,a,t)$labb0(r,wb,a) = 1 ;

kef.l(r,a,v,t)$(vOld(v) and kef0(r,a)) = 1 ;
pkef.l(r,a,v,t)          = 1 ;

pnd2.l(r,a,t)            = 1 ;
pva1.l(r,a,v,t)          = 1 ;
pva2.l(r,a,v,t)          = 1 ;
nd2.l(r,a,t)$nd20(r,a)   = 1 ;
va1.l(r,a,v,t)$(vOld(v) and va10(r,a)) = 1 ;
va2.l(r,a,v,t)$(vOld(v) and va20(r,a)) = 1 ;

plandd.l(r,a,t)               = 1 ;
planddNDX.l(r,a,t)            = 1 ;
landd.l(r,a,t)$landdFlag(r,a) = 1 ;

pf.l(r,f,a,t)             = 1 ;
pfp.l(r,f,a,t)            = 1 ;
xf.l(r,f,a,t)$xf0(r,f,a)  = 1 ;
xfs.l(r,l,a,t)$xf0(r,l,a) = 1 ;
FEFlag(r,l)               = yes ;

kf.l(r,a,v,t)$(vOld(v) and kf0(r,a)) = 1 ;
pkf.l(r,a,v,t)           = 1 ;

xnrg.l(r,a,v,t)$(vOld(v) and xnrg0(r,a))  = 1 ;

ksw.l(r,a,v,t)$(vOld(v) and ksw0(r,a)) = 1 ;
pksw.l(r,a,v,t)          = 1 ;

ks.l(r,a,v,t)$(vOld(v) and ks0(r,a)) = 1 ;
pks.l(r,a,v,t)           = 1 ;

xwat.l(r,a,t)$xwat0(r,a) = 1 ;
pwat.l(r,a,t)            = 1 ;

kv.l(r,a,v,t)$(vOld(v) and kv0(r,a)) = 1 ;
pk.l(r,a,v,t)            = 1 ;
pkp.l(r,a,v,t)           = 1 ;
kslo.l(r,a,t)$kv0(r,a)   = 1 ;
kshi.l(r,a,t)$kv0(r,a)   = 0 ;

pat.l(r,i,t)               = 1 ;
patNDX.l(r,i,t)            = 1 ;
pa.l(r,i,aa,t)             = 1 ;
paNDX.l(r,i,aa,t)          = 1 ;
xa.l(r,i,aa,t)$xa0(r,i,aa) = 1 ;

xnely.l(r,a,v,t)$(vOld(v) and xnely0(r,a)) = 1 ;
pnely.l(r,a,v,t)         = 1 ;
pnelyNDX.l(r,a,v,t)      = 1 ;
xolg.l(r,a,v,t)$(vOld(v) and xolg0(r,a)) = 1 ;
polg.l(r,a,v,t)          = 1 ;
polgNDX.l(r,a,v,t)       = 1 ;
pnrg.l(r,a,v,t)          = 1 ;
pnrgNDX.l(r,a,v,t)       = 1 ;
xaNRG.l(r,a,NRG,v,t)$(vOld(v) and xaNRG0(r,a,NRG)) = 1 ;
paNRG.l(r,a,NRG,v,t)     = 1 ;
paNRGNDX.l(r,a,NRG,v,t)  = 1 ;

p.l(r,a,i,t)             = 1 ;
x.l(r,a,i,t)$x0(r,a,i)   = 1 ;
pp.l(r,a,i,t)            = 1 ;
xp.l(r,a,t)$xp0(r,a)     = 1 ;
xpv.l(r,a,v,t)$(vOld(v) and xpv0(r,a)) = 1 ;
xs.l(r,i,t)$xs0(r,i)     = 1 ;
ps.l(r,i,t)              = 1 ;
psNDX.l(r,i,t)           = 1 ;

xpow.l(r,elyc,t)$xpow0(r,elyc) = 1 ;
ppow.l(r,elyc,t)         = 1 ;
ppowndx.l(r,elyc,t)      = 1 ;

xpb.l(r,pb,elyc,t)$xpb0(r,pb,elyc) = 1 ;
ppb.l(r,pb,elyc,t)       = 1 ;
ppbndx.l(r,pb,elyc,t)    = 1 ;

yqtf.l(r,t)$yqtf0(r)     = 1 ;
yqht.l(r,t)$yqht0(r)     = 1 ;
trustY.l(t)$trustY0      = 1 ;
remit.l(s,l,d,t)$remit0(s,l,d) = 1 ;

ODAIn.l(r,t)$odaIn0(r)   = 1 ;
ODAOut.l(r,t)$odaOut0(r) = 1 ;
ODAGBL.l(t)$odaGBL0      = 1 ;

govTr.fx(s,d,t)          = 0 ;
govTr0(s,d)              = 1 ;

savh.l(r,h,t)$savh0(r,h) = 1 ;
ntmY.l(r,t)$ntmy0(r)     = 1 ;
deprY.l(r,t)$deprY0(r)   = 1 ;

yh.l(r,t)$yh0(r)         = 1 ;
yd.l(r,t)$yd0(r)         = 1 ;
yc.l(r,h,t)$yc0(r,h)     = 1 ;
ygov.l(r,gy,t)$ygov0(r,gy) = 1 ;
ygov0(r,gy)$(ygov0(r,gy) eq 0) = 1 ;
aps.l(r,h,t)$aps0(r,h)   = 1 ;
ctaxgap.l(r,t)           = 0 ;

xfd.l(r,fd,t)$xfd0(r,fd) = 1 ;
yfd.l(r,fd,t)$yfd0(r,fd) = 1 ;
pfd.l(r,fd,t)            = 1 ;

xc.l(r,k,h,t)$xc0(r,k,h) = 1 ;
pc.l(r,k,h,t)            = 1 ;
hshr.l(r,k,h,t)$hshr0(r,k,h) = 1 ;
u.l(r,h,t)$u0(r,h)       = 1 ;
supy.l(r,h,t)$supy0(r,h) = 1 ;
zcons.l(r,k,h,t)$zcons0(r,k,h) = 1 ;
muc.l(r,k,h,t)$muc0(r,k,h) = 1 ;
muc.fx(r,k,h,t)$(muc0(r,k,h) and (%utility%=ELES or %utility%=LES or %utility%=AIDADS)) = 1 ;
gammac.fx(r,k,h,t)$(%utility%=ELES or %utility%=LES or %utility%=AIDADS) = gammac.l(r,k,h,t) ;

xcnnrg.l(r,k,h,t)$xcnnrg0(r,k,h) = 1 ;
pcnnrg.l(r,k,h,t)        = 1 ;
xcnrg.l(r,k,h,t)$xcnrg0(r,k,h)   = 1 ;
pcnrg.l(r,k,h,t)         = 1 ;
pcnrgNDX.l(r,k,h,t)      = 1 ;

xcnely.l(r,k,h,t)$xcnely0(r,k,h) = 1 ;
pcnely.l(r,k,h,t)        = 1 ;
pcnelyNDX.l(r,k,h,t)     = 1 ;
xcolg.l(r,k,h,t)$xcolg0(r,k,h) = 1 ;
pcolg.l(r,k,h,t)         = 1 ;
pcolgNDX.l(r,k,h,t)      = 1 ;
xacNRG.l(r,k,h,NRG,t)$xacNRG0(r,k,h,NRG) = 1 ;
pacNRG.l(r,k,h,NRG,t)    = 1 ;
pacNRGNDX.l(r,k,h,NRG,t) = 1 ;

*  !!!! Exceptional --- there is no pah0 !!!!
pah.l(r,i,h,t)           = 1 ;

xaac.l(r,i,h,t)$xaac0(r,i,h) = 1 ;
xawc.l(r,i,h,t)$xawc0(r,i,h) = 1 ;
paacc.l(r,i,h,t)         = 1 ;
paac.l(r,i,h,t)          = 1 ;
pawc.l(r,i,h,t)          = 1 ;

xat.l(r,i,t)$xat0(r,i)   = 1 ;
pdt.l(r,i,t)             = 1 ;
xdt.l(r,i,t)$xdt0(r,i)   = 1 ;
pet.l(r,i,t)             = 1 ;
petNDX.l(r,i,t)          = 1 ;
xet.l(r,i,t)$xet0(r,i)   = 1 ;
pmt.l(r,i,t)             = 1 ;
pmtNDX.l(r,i,t)          = 1 ;
xmt.l(r,i,t)$xmt0(r,i)   = 1 ;

xd.l(r,i,aa,t)$xd0(r,i,aa) = 1 ;
pd.l(r,i,aa,t)           = 1 ;
xm.l(r,i,aa,t)$xm0(r,i,aa) = 1 ;
pm.l(r,i,aa,t)           = 1 ;

xw.l(s,i,d,t)$xw0(s,i,d) = 1 ;
pe.l(s,i,d,t)            = 1 ;
pwe.l(s,i,d,t)           = 1 ;
pwm.l(s,i,d,t)           = 1 ;
pdm.l(s,i,d,t)           = 1 ;
$iftheni "%MRIO_MODULE%" == ON
xwa.l(s,i,d,aa,t)$xwa0(s,i,d,aa) = 1 ;
pdma.l(s,i,d,aa,t)       = 1 ;
pma.l(d,i,aa,t)          = 1 ;
$endif

pwmg.l(s,i,d,t)          = 1 ;
xwmg.l(s,i,d,t)          = 1 ;
xtmg.l(img,t)$xtmg0(img) = 1 ;
ptmg.l(img,t)            = 1 ;
xmgm.l(img,s,i,d,t)$xmgm0(img,s,i,d) = 1 ;
xtt.l(r,i,t)$xtt0(r,i)   = 1 ;

reswage.l(r,l,z,t)         = 1 ;
ewagez.l(r,l,z,t)          = 1 ;
rwage.l(r,l,z,t)           = 1 ;
errW.l(r,l,z,t)            = 0 ;
lsz.l(r,l,z,t)$lsz0(r,l,z) = 1 ;
ldz.l(r,l,z,t)$ldz0(r,l,z) = 1 ;
awagez.l(r,l,z,t)          = 1 ;
twage.l(r,l,t)             = 1 ;
ls.l(r,l,t)$ls0(r,l)       = 1 ;
migr.l(r,l,t)$migr0(r,l)   = 1 ;
urbprem.l(r,l,t)           = 1 ;
tls.l(r,t)$tls0(r)         = 1 ;

tkaps.l(r,t)$tkaps0(r)   = 1 ;
kstock.l(r,t)$kstock0(r) = 1 ;
trent.l(r,t)             = 1 ;
rtrent.l(r,t)            = 1 ;
arent.l(r,t)             = 1 ;
k0.l(r,a,t)$k00(r,a)     = 1 ;
kxRat.l(r,a,v,t)$kxRat0(r,a) = 1 ;
klRat.l(r,t)$klRat0(r)   = 1 ;

xfNot.l(r,a,t)           = 1 ;
xfs.l(r,nrs,a,t)         = 1 ;
xfGap.l(r,a,t)           = 1 ;

$iftheni "%DEPL_MODULE%" == "ON"
cumExt.l(r,a,t)          = 1 ;
res.l(r,a,t)             = 1 ;
resP.l(r,a,t)            = 1 ;
ytdRes.l(r,a,t)          = 1 ;
xfPot.l(r,a,t)           = 1 ;
extr.l(r,a,t)            = 1 ;
$endif

tland.l(r,lnd,t)$tland0(r,lnd)   = 1 ;
ptland.l(r,lnd,t)                = 1 ;
ptlandndx.l(r,lnd,t)             = 1 ;
xlb.l(r,lnd,lb,t)$xlb0(r,lnd,lb) = 1 ;
plb.l(r,lnd,lb,t)                = 1 ;
plbndx.l(r,lnd,lb,t)             = 1 ;
xnlb.l(r,lnd,t)$xnlb0(r,lnd)     = 1 ;
pnlb.l(r,lnd,t)                  = 1 ;
pnlbndx.l(r,lnd,t)               = 1 ;

th2o.l(r,t)$th2o0(r)     = 1 ;
th2om.l(r,t)$th2om0(r)   = 1 ;
pth2o.l(r,t)             = 1 ;
pth2ondx.l(r,t)          = 1 ;
h2obnd.l(r,wbnd,t)$h2obnd0(r,wbnd) = 1 ;
ph2obnd.l(r,wbnd,t)      = 1 ;
ph2obndndx.l(r,wbnd,t)   = 1 ;

ror.l(r,t)               = 1 ;
rorc.l(r,t)              = 1 ;
rore.l(r,t)              = 1 ;
rorg.l(t)                = 1 ;
*  !!!!! Exceptional
rorg0$(savfFlag eq capFlexUSAGE) = 1 ;

emi.l(r,em,is,aa,t)$emi0(r,em,is,aa) = 1 ;
emiTot.l(r,em,t)$emiTot0(r,em)       = 1 ;
emiGbl.l(em,t)$emiGbl0(em)           = 1 ;

emiTotAct.l(r,emq,a,t)$emiTotAct0(r,emq,a)       = 1 ;
emiInt.l(r,emq,a,t)$emiInt0(r,emq,a)             = 1 ;
emiTotETS.l(ra,r,emq,aets,t)$emiTotETS0(ra, r,emq,aets) = 1 ;

$iftheni "%CLIM_MODULE%" == "ON"
EmiCO2.l(t)     = 1 ;
EmiOthInd.l(t)  = EmiOthInd0 ;
CumEmiInd.l(t)  = 1 ;
CumEmi.l(t)     = 1 ;
alpha.l(t)      = alpha0 ;
CRes.l(b,t)     = 1 ;
MAT.l(t)        = 1 ;
FORC.l(em,t)    = FORC0(em) ;
FORCOth.l(t)    = FORCOth0 ;
TEMP.l(tb,tt)   = TEMP0(tb) ;

delTemp.l(r,t)     = delTemp0(r) ;
$endif

dam_tfp.l(r,a,t)    = dam_tfp0(r,a) ;
dam_lab.l(r,l,a,t)  = dam_lab0(r,l,a) ;
dam_hht.l(r,l,a,t)  = dam_hht0(r,l,a) ;
dam_nrg.l(r,k,h,t)  = dam_nrg0(r,k,h) ;
dam_lnd.l(r,lnd,t)  = dam_lnd0(r,lnd) ;
dam_tou.l(r,i,t)    = dam_tou0(r,i) ;
dam_cap.l(r,t)      = dam_cap0(r) ;
yfdexpadp.l(r,fd,t) = yfdexpadp0(r,fd) ;

$iftheni "%DAMAGE_MODULE%" == "ON"
xfd.l(r,adp,t)          = xfd0(r,adp) ;
yfdexpadp.l(r,fd,t)     = yfdexpadp0(r,fd) ;
dam_shft_tfp.l(r,a,t)   = dam_shft_tfp0(r,a) ;
dam_shft_lab.l(r,l,a,t) = dam_shft_lab0(r,l,a) ;
dam_shft_hht.l(r,l,a,t) = dam_shft_hht0(r,l,a) ;
dam_shft_nrg.l(r,k,h,t) = dam_shft_nrg0(r,k,h) ;
dam_shft_lnd.l(r,lnd,t) = dam_shft_lnd0(r,lnd) ;
dam_shft_tou.l(r,i,t)   = dam_shft_tou0(r,i) ;
dam_shft_cap.l(r,t)     = dam_shft_cap0(r) ;

$endif

$iftheni "%RD_MODULE%" == "ON"
kn.l(r,tt)               = 1 ;
rd.l(r,tt)$knowFlag(r)   = rd.l(r,tt)/rd0(r) ;
rd.fx(r,tt)$(knowFlag(r) and tt.val le t0.val) = rd.l(r,tt) ;
$endif

$iftheni.FBS "%FBS_MODULE%" == "ON"
calo.l(r,i,srcr,t)       = 1 ;
$endif.FBS

cons.l(r,t)              = 1 ;
pcons.l(r,t)             = 1 ;
gdpmp.l(r,t)             = 1 ;
pgdpmp.l(r,t)            = 1 ;
rgdpmp.l(r,t)            = 1 ;
rgdppc.l(r,t)            = 1 ;
pop.fx(r,t)              = 1 ;

pfact.l(r,t)             = 1 ;
pwfact.l(t)              = 1 ;
cpi.l(r,h,cpindx,t)      = 1 ;

ev.l(r,h,t)              = 1 ;
evf.l(r,fdc,t)           = 1 ;
evs.l(r,t)               = 1 ;
sw.l(t)                  = 1 ;
swt.l(t)                 = 1 ;
swt2.l(t)                = 1 ;

*  Variables that are not normalized

chiaps.l(r,h,t)          = chiaps0(r,h) ;
skillprem.l(r,l,t)       = skillprem0(r,l) ;
chirw.fx(r,l,z,t)        = chirw0(r,l,z) ;
rrat.l(r,a,t)            = rrat0(r,a) ;
invGFact.l(r,t)          = invGFact0(r) ;
psave.l(r,t)             = psave0(r) ;
savf.l(r,t)              = savf0(r) ;
savg.l(r,t)              = savg0(r) ;
rfdshr.l(r,fd,t)         = rfdshr0(r,fd) ;
nfdshr.l(r,fd,t)         = nfdshr0(r,fd) ;
rsg.l(r,t)               = rsg0(r) ;
savfRat.l(r,t)           = savfRat0(r) ;
pwsav.l(t)               = pwsav0 ;
pnum.l(t)                = pnum0 ;
pmuv.l(t)                = pmuv0 ;
pwgdp.l(t)               = pwgdp0 ;
pw.l(a,t)                = pw0(a) ;
kstocke.l(r,t)           = kstocke0(r) / kstock0(r) ;

*  Tax instruments

uctax.fx(r,a,v,t)        = uctax0(r,a) ;
pftax.fx(r,f,a,t)        = pftax0(r,f,a) ;
patax.fx(r,i,aa,t)       = paTax0(r,i,aa) ;
pdtax.fx(r,i,aa,t)       = pdTax0(r,i,aa) ;
pmtax.fx(r,i,aa,t)       = pmTax0(r,i,aa) ;
ptax.fx(r,a,i,t)         = ptax0(r,a,i) ;
kappaf.fx(r,f,a,t)       = kappaf0(r,f,a) ;
etax.fx(s,i,d,t)         = etax0(s,i,d) ;
etaxi.fx(r,i,t)          = 0 ;
tmarg.fx(s,i,d,t)        = tmarg0(s,i,d) ;
mtax.fx(s,i,d,t)         = mtax0(s,i,d) ;
ntmAVE.fx(s,i,d,t)       = ntmAVE0(s,i,d) ;
$iftheni "%MRIO_MODULE%" == "ON"
mtaxa.fx(s,i,d,aa,t)     = mtaxa0(s,i,d,aa) ;
$endif
wtaxh.fx(r,i,h,t)        = 0 ;
wtaxhx.fx(r,i,h,t)       = 0 ;
*  !!!! Closure dependent
kappah.l(r,t)            = kappah0(r) ;
