*  Standard comparative static closure
chiaps.fx(r,h,t)  = chiaps.l(r,h,t) ;
wprem.fx(r,l,a,t) = wprem.l(r,l,a,t) ;
errW.fx(r,l,z,t)  = errW.l(r,l,z,t) ;
lsz.fx(r,l,z,t)   = lsz.l(r,l,z,t) ;
rsg.fx(r,t)       = rsg.l(r,t) ;
kstock.fx(r,t)    = kstock.l(r,t) ;
RoRd.fx(r,t)      = RoRd.l(r,t) ;
xfd.fx(r,gov,t)   = xfd.l(r,gov,t) ;
$iftheni "%RD_MODULE%" == "ON"
rfdshr.fx(r,r_d,t) = rfdshr.l(r,r_d,t) ;
$endif
$iftheni "%IFI_MODULE%" == "ON"
ifiin.fx(r,t) = ifiin.l(r,t) ;
$endif
pCarb.fx(r,ghg,a,t) = pCarb.l(r,ghg,a,t) ;
pnum.fx(t)        = pnum.l(t) ;
savfRat.fx(r,t)$(savfFlag eq capRFix and not rres(r)) = savfRat.l(r,t) ;
pop.fx(r,t)       = pop.l(r,t) ;
*capu.lo(r,a,vOld,t) = -inf ;
*capu.up(r,a,vOld,t) = 1 ;

$iftheni.RD "%simType%" == "RcvDyn"
$iftheni.DEPL "%DEPL_MODULE%" == "ON"

*  Depletion module assumptions

dscRate.lo(r,a,t)$ifDsc(r,a) = dscRate0(r,a,"lo") ;
dscRate.up(r,a,t)$ifDsc(r,a) = dscRate0(r,a,"hi") ;

*extRate.lo(r,a,t)$(ifDepl(r,a) and not ifDsc(r,a)) = extRate0(r,a,"lo") ;
*extRate.up(r,a,t)$(ifDepl(r,a) and not ifDsc(r,a)) = extRate0(r,a,"hi") ;

chiDscRate.fx(r,a,t) = chiDscRate.l(r,a,t) ;
chiExtRate.fx(r,a,t) = chiExtRate.l(r,a,t) ;

resGap.lo(r,a,t)$(ifDepl(r,a)) = 0 ;

xfGap.lo(r,a,t)$(ifDepl(r,a)) = 0 ;

prat.fx(r,a,t)$(not ifDepl(r,a))        = prat.l(r,a,t) ;
omegar.fx(r,a,t)$(not ifDepl(r,a))      = omegar.l(r,a,t) ;
dscRate.fx(r,a,t)$(not ifDsc(r,a))      = dscRate.l(r,a,t) ;
extRate.fx(r,a,t)$(not ifDepl(r,a))     = extRate.l(r,a,t) ;
cumExt.fx(r,a,t)$(not ifDepl(r,a))      = cumExt.l(r,a,t) ;
res.fx(r,a,t)$(not ifDepl(r,a))         = res.l(r,a,t) ;
resp.fx(r,a,t)$(not ifDepl(r,a))        = resp.l(r,a,t) ;
ytdRes.fx(r,a,t)$(not ifDsc(r,a))       = ytdRes.l(r,a,t) ;
resGap.fx(r,a,t)$(not ifDepl(r,a))      = resGap.l(r,a,t) ;
xfPot.fx(r,a,t)$(not ifDepl(r,a))       = xfPot.l(r,a,t) ;
extr.fx(r,a,t)$(not ifDepl(r,a))        = extr.l(r,a,t) ;

$endif.DEPL
$endif.RD

$iftheni "%CLIM_MODULE%" == "ON"
if(not ifDyn,
   EmiLand.l(t) = EmiLand0 ;
   CumEmiLand.l(t) = CumEmiLand0 ;
) ;

EmiOthInd.fx(t)  = EmiOthInd.l(t) ;
EmiLand.fx(t)    = EmiLand.l(t) ;
CumEmiLand.fx(t) = CumEmiLand.l(t) ;
FORCOth.fx(t)    = FORCOth.l(t) ;
$endif

*  Consumer demand parameters for the 'LES' type utility functions

if(%utility%=CD or %utility%=LES or %utility%=ELES or %utility%=AIDADS,
   gammac.fx(r,k,h,t) = gammac.l(r,k,h,t) ;
   if(%utility%=CD or %utility%=LES or %utility%=ELES,
      muc.fx(r,k,h,t) = muc.l(r,k,h,t) ;
   ) ;
) ;

*  Fix policy variables

ptax.fx(r,a,i,t)   = ptax.l(r,a,i,t) ;
uctax.fx(r,a,v,t)  = uctax.l(r,a,v,t) ;
paTax.fx(r,i,aa,t) = paTax.l(r,i,aa,t) ;
pdTax.fx(r,i,aa,t) = pdTax.l(r,i,aa,t) ;
pmTax.fx(r,i,aa,t) = pmTax.l(r,i,aa,t) ;
etax.fx(s,i,d,t)   = etax.l(s,i,d,t) ;

$iftheni "%MRIO_MODULE%" == "ON"
   mtaxa.fx(s,i,d,aa,t)  = mtaxa.l(s,i,d,aa,t) ;
$else
   mtax.fx(s,i,d,t)  = mtax.l(s,i,d,t) ;
$endif

pftax.fx(r,f,a,t)  = pftax.l(r,f,a,t) ;
kappaf.fx(r,f,a,t) = kappaf.l(r,f,a,t) ;

h2obnd.fx(r,wbndEx,t) = h2obnd.l(r,wbndEx,t) ;

*  Fix technology parameters

axghg.fx(r,a,v,t)         = axghg.l(r,a,v,t) ;
tfp.fx(r,a,v,t)           = tfp.l(r,a,v,t) ;
ftfp.fx(r,a,v,t)          = ftfp.l(r,a,v,t) ;
etfp.fx(r,t)              = etfp.l(r,t) ;
lambdaxp.fx(r,a,v,t)      = lambdaxp.l(r,a,v,t) ;
lambdaghg.fx(r,a,v,t)     = lambdaghg.l(r,a,v,t) ;
lambdak.fx(r,a,v,t)       = lambdak.l(r,a,v,t) ;
lambdaf.fx(r,f,a,t)       = lambdaf.l(r,f,a,t) ;
lambdaio.fx(r,i,a,t)      = lambdaio.l(r,i,a,t) ;
lambdanrgp.fx(r,a,v,t)    = lambdanrgp.l(r,a,v,t) ;
lambdae.fx(r,e,a,v,t)     = lambdae.l(r,e,a,v,t) ;
lambdanrgc.fx(r,k,h,t)    = lambdanrgc.l(r,k,h,t) ;
lambdace.fx(r,e,k,h,t)    = lambdace.l(r,e,k,h,t) ;
lambdah2obnd.fx(r,wbnd,t) = lambdah2obnd.l(r,wbnd,t) ;
tmarg.fx(s,i,d,t)         = tmarg.l(s,i,d,t) ;

*  Fix inactive variables

px.fx(r,a,t)$(not xpFlag(r,a))         = px.l(r,a,t) ;
uc.fx(r,a,v,t)$(not xpFlag(r,a))       = uc.l(r,a,v,t) ;
pxv.fx(r,a,v,t)$(not xpFlag(r,a))      = pxv.l(r,a,v,t) ;
xpn.fx(r,a,v,t)$(not xpFlag(r,a))      = xpn.l(r,a,v,t) ;
xpx.fx(r,a,v,t)$(not xpFlag(r,a))      = xpx.l(r,a,v,t) ;
xpv.fx(r,a,v,t)$(not xpFlag(r,a))      = xpv.l(r,a,v,t) ;
xghg.fx(r,a,v,t)$(not ghgFlag(r,a))    = xghg.l(r,a,v,t) ;
pxghg.fx(r,a,v,t)$(not ghgFlag(r,a))   = pxghg.l(r,a,v,t) ;
procEmi.fx(r,ghg,a,t)$(not procEmiFlag(r,ghg,a)) = procEmi.l(r,ghg,a,t) ;
nd1.fx(r,a,t)$(not nd1Flag(r,a))       = nd1.l(r,a,t) ;
nd2.fx(r,a,t)$(not nd2Flag(r,a))       = nd2.l(r,a,t) ;
xwat.fx(r,a,t)$(not watFlag(r,a))      = xwat.l(r,a,t) ;
xf.fx(r,f,a,t)$(not xfFlag(r,f,a))     = xf.l(r,f,a,t) ;
pnd1.fx(r,a,t)$(not nd1Flag(r,a))      = pnd1.l(r,a,t) ;
pnd2.fx(r,a,t)$(not nd2Flag(r,a))      = pnd2.l(r,a,t) ;
pwat.fx(r,a,t)$(not watFlag(r,a))      = pwat.l(r,a,t) ;
va.fx(r,a,v,t)$(not xpFlag(r,a))       = va.l(r,a,v,t) ;
va1.fx(r,a,v,t)$(not va1Flag(r,a))     = va1.l(r,a,v,t) ;
va2.fx(r,a,v,t)$(not va2Flag(r,a))     = va2.l(r,a,v,t) ;
pva.fx(r,a,v,t)$(not xpFlag(r,a))      = pva.l(r,a,v,t) ;
pva1.fx(r,a,v,t)$(not va1Flag(r,a))    = pva1.l(r,a,v,t) ;
pva2.fx(r,a,v,t)$(not va2Flag(r,a))    = pva2.l(r,a,v,t) ;
landd.fx(r,a,t)$(not landdFlag(r,a))   = landd.l(r,a,t) ;
plandd.fx(r,a,t)$(not landdFlag(r,a))  = plandd.l(r,a,t) ;
planddNDX.fx(r,a,t)$(not landdFlag(r,a)) = planddndx.l(r,a,t) ;
pxp.fx(r,a,v,t)$(not xpFlag(r,a))      = pxp.l(r,a,v,t) ;
pxn.fx(r,a,v,t)$(not xpFlag(r,a))      = pxn.l(r,a,v,t) ;
lab1.fx(r,a,t)$(not lab1Flag(r,a))     = lab1.l(r,a,t) ;
lab2.fx(r,a,t)$(not lab2Flag(r,a))     = lab2.l(r,a,t) ;
plab1.fx(r,a,t)$(not lab1Flag(r,a))    = plab1.l(r,a,t) ;
plab2.fx(r,a,t)$(not lab2Flag(r,a))    = plab2.l(r,a,t) ;
kef.fx(r,a,v,t)$(not kefFlag(r,a))     = kef.l(r,a,v,t) ;
pkef.fx(r,a,v,t)$(not kefFlag(r,a))    = pkef.l(r,a,v,t) ;
kf.fx(r,a,v,t)$(not kfFlag(r,a))       = kf.l(r,a,v,t) ;
pkf.fx(r,a,v,t)$(not kfFlag(r,a))      = pkf.l(r,a,v,t) ;
labb.fx(r,wb,a,t)$(not labbFlag(r,wb,a))  = labb.l(r,wb,a,t) ;
plabb.fx(r,wb,a,t)$(not labbFlag(r,wb,a)) = plabb.l(r,wb,a,t) ;

xnrg.fx(r,a,v,t)$(not xnrgFlag(r,a))      = xnrg.l(r,a,v,t) ;
xnely.fx(r,a,v,t)$(not xnelyFlag(r,a))    = xnely.l(r,a,v,t) ;
xolg.fx(r,a,v,t)$(not xolgFlag(r,a))      = xolg.l(r,a,v,t) ;
xaNRG.fx(r,a,NRG,v,t)$(not xaNRGFlag(r,a,NRG)) = xaNRG.l(r,a,NRG,v,t) ;
paNRG.fx(r,a,NRG,v,t)$(not xaNRGFlag(r,a,NRG)) = paNRG.l(r,a,NRG,v,t) ;
paNRGNDX.fx(r,a,NRG,v,t)$(not xaNRGFlag(r,a,NRG)) = paNRGNDX.l(r,a,NRG,v,t) ;
polg.fx(r,a,v,t)$(not xolgFlag(r,a))      = polg.l(r,a,v,t) ;
polgNDX.fx(r,a,v,t)$(not xolgFlag(r,a))   = polgNDX.l(r,a,v,t) ;
pnely.fx(r,a,v,t)$(not xnelyFlag(r,a))    = pnely.l(r,a,v,t) ;
pnelyNDX.fx(r,a,v,t)$(not xnelyFlag(r,a)) = pnelyNDX.l(r,a,v,t) ;
pnrg.fx(r,a,v,t)$(not xnrgFlag(r,a))      = pnrg.l(r,a,v,t) ;
pnrgNDX.fx(r,a,v,t)$(not xnrgFlag(r,a))   = pnrgNDX.l(r,a,v,t) ;

ksw.fx(r,a,v,t)$(not kFlag(r,a))       = ksw.l(r,a,v,t) ;
pksw.fx(r,a,v,t)$(not kFlag(r,a))      = pksw.l(r,a,v,t) ;
ks.fx(r,a,v,t)$(not kFlag(r,a))        = ks.l(r,a,v,t) ;
pks.fx(r,a,v,t)$(not kFlag(r,a))       = pks.l(r,a,v,t) ;
kv.fx(r,a,v,t)$(not kFlag(r,a))        = kv.l(r,a,v,t) ;

xa.fx(r,i,aa,t)$(not xaFlag(r,i,aa))   = xa.l(r,i,aa,t) ;

x.fx(r,a,i,t)$(shr0_p(r,a,i) eq 0)     = x.l(r,a,i,t) ;
p.fx(r,a,i,t)$(shr0_p(r,a,i) eq 0)     = p.l(r,a,i,t) ;
pp.fx(r,a,i,t)$(shr0_p(r,a,i) eq 0)    = pp.l(r,a,i,t) ;
xp.fx(r,a,t)$(not xpFlag(r,a))         = xp.l(r,a,t) ;
ps.fx(r,i,t)$(not xsFlag(r,i))         = ps.l(r,i,t) ;
psNDX.fx(r,i,t)$(not xsFlag(r,i))      = psNDX.l(r,i,t) ;

xpow.fx(r,elyc,t)$(shr0_pow(r,elyc) eq 0)    = xpow.l(r,elyc,t) ;
ppow.fx(r,elyc,t)$(shr0_pow(r,elyc) eq 0)    = ppow.l(r,elyc,t) ;
ppowndx.fx(r,elyc,t)$(shr0_pow(r,elyc) eq 0) = ppowndx.l(r,elyc,t) ;

xpb.fx(r,pb,elyc,t)$(shr0_pb(r,pb,elyc) eq 0)    = xpb.l(r,pb,elyc,t) ;
ppb.fx(r,pb,elyc,t)$(shr0_pb(r,pb,elyc) eq 0)    = ppb.l(r,pb,elyc,t) ;
ppbndx.fx(r,pb,elyc,t)$(shr0_pb(r,pb,elyc) eq 0) = ppbndx.l(r,pb,elyc,t) ;

deprY.fx(r,t)$(deprY0(r) eq 0)         = 0 ;
yqtf.fx(r,t)$(yqtf0(r) eq 0)           = 0 ;
trustY.fx(t)$(trustY0 eq 0)            = 0 ;
yqht.fx(r,t)$(yqht0(r) eq 0)           = 0 ;
ntmY.fx(r,t)$(ntmFlag eq 0)            = 0 ;
ODAIn.fx(r,t)$(ODAIn0(r) eq 0)         = 0 ;
ODAGbl.fx(t)$(ODAGbl0 eq 0)            = 0 ;
ODAOut.fx(r,t)$(ODAOut0(r) eq 0)       = 0 ;
remit.fx(s,l,d,t)$(remit0(s,l,d) eq 0) = 0 ;

ygov.fx(r,gy,t)$(ygov0(r,gy) eq 0)     = 0 ;

xfd.fx(r,fd,t)$(not fdFlag(r,fd))      = 0 ;
yfd.fx(r,fd,t)$(not fdFlag(r,fd))      = 0 ;
pfd.fx(r,fd,t)$(not fdFlag(r,fd))      = pfd.l(r,fd,t) ;
rfdshr.fx(r,fd,t)$(not fdFlag(r,fd))   = 0 ;
nfdshr.fx(r,fd,t)$(not fdFlag(r,fd))   = 0 ;

xc.fx(r,k,h,t)$(not xcFlag(r,k,h))            = xc.l(r,k,h,t) ;
pc.fx(r,k,h,t)$(not xcFlag(r,k,h))            = pc.l(r,k,h,t) ;
hshr.fx(r,k,h,t)$(not xcFlag(r,k,h))          = hshr.l(r,k,h,t) ;
zcons.fx(r,k,h,t)$(not xcFlag(r,k,h))         = zcons.l(r,k,h,t) ;
xcnnrg.fx(r,k,h,t)$(not xcnnrgFlag(r,k,h))    = xcnnrg.l(r,k,h,t) ;
pcnnrg.fx(r,k,h,t)$(not xcnnrgFlag(r,k,h))    = pcnnrg.l(r,k,h,t) ;
xcnrg.fx(r,k,h,t)$(not xcnrgFlag(r,k,h))      = xcnrg.l(r,k,h,t) ;
pcnrg.fx(r,k,h,t)$(not xcnrgFlag(r,k,h))      = pcnrg.l(r,k,h,t) ;
pcnrgNDX.fx(r,k,h,t)$(not xcnrgFlag(r,k,h))   = pcnrgNDX.l(r,k,h,t) ;
xcnely.fx(r,k,h,t)$(not xcnelyFlag(r,k,h))    = xcnely.l(r,k,h,t) ;
pcnely.fx(r,k,h,t)$(not xcnelyFlag(r,k,h))    = pcnely.l(r,k,h,t) ;
pcnelyNDX.fx(r,k,h,t)$(not xcnelyFlag(r,k,h)) = pcnelyNDX.l(r,k,h,t) ;
xcolg.fx(r,k,h,t)$(not xcolgFlag(r,k,h))      = xcolg.l(r,k,h,t) ;
pcolg.fx(r,k,h,t)$(not xcolgFlag(r,k,h))      = pcolg.l(r,k,h,t) ;
pcolgNDX.fx(r,k,h,t)$(not xcolgFlag(r,k,h))   = pcolgNDX.l(r,k,h,t) ;
xacNRG.fx(r,k,h,NRG,t)$(not xacNRGFlag(r,k,h,NRG))    = xacNRG.l(r,k,h,NRG,t) ;
pacNRG.fx(r,k,h,NRG,t)$(not xacNRGFlag(r,k,h,NRG))    = pacNRG.l(r,k,h,NRG,t) ;
pacNRGNDX.fx(r,k,h,NRG,t)$(not xacNRGFlag(r,k,h,NRG)) = pacNRGNDX.l(r,k,h,NRG,t) ;

xaac.fx(r,i,h,t)$(xaac0(r,i,h) eq 0) = 0 ;
xawc.fx(r,i,h,t)$(hWasteFlag(r,i,h) ne 1) = 0 ;

paac.fx(r,i,h,t)$(xaac0(r,i,h) eq 0) = 1 ;
pah.fx(r,i,h,t)$(xaac0(r,i,h) eq 0)  = 1 ;
paacc.fx(r,i,h,t)$(hWasteFlag(r,i,h) ne 1) = 1 ;
pawc.fx(r,i,h,t)$(hWasteFlag(r,i,h) ne 1)  = 1 ;

xat.fx(r,i,t)$(not xatFlag(r,i))        = xat.l(r,i,t) ;
xdt.fx(r,i,t)$(not xdtFlag(r,i))        = xdt.l(r,i,t) ;
xmt.fx(r,i,t)$(not xmtFlag(r,i))        = xmt.l(r,i,t) ;
pat.fx(r,i,t)$(not xatFlag(r,i))        = pat.l(r,i,t) ;
patNDX.fx(r,i,t)$(not xatFlag(r,i))     = patNDX.l(r,i,t) ;
pa.fx(r,i,aa,t)$(not xaFlag(r,i,aa))    = pa.l(r,i,aa,t) ;
paNDX.fx(r,i,aa,t)$(not xaFlag(r,i,aa)) = paNDX.l(r,i,aa,t) ;

xw.fx(s,i,d,t)$(not xwFlag(s,i,d))     = xw.l(s,i,d,t) ;

$iftheni "%MRIO_MODULE%" == "ON"
   xwa.fx(s,i,d,aa,t)$(not xwaFlag(s,i,d,aa))   = xwa.l(s,i,d,aa,t) ;
   pdma.fx(s,i,d,aa,t)$(not xwaFlag(s,i,d,aa))  = pdma.l(s,i,d,aa,t) ;
   pma.fx(r,i,aa,t)$(not xmFlag(r,i,aa))        = pma.l(r,i,aa,t) ;
$else
   pmt.fx(r,i,t)$(not xmtFlag(r,i))       = pmt.l(r,i,t) ;
   pmtNDX.fx(r,i,t)$(not xmtFlag(r,i))    = pmtNDX.l(r,i,t) ;
   pdm.fx(s,i,d,t)$(not xwFlag(s,i,d))    = pdm.l(s,i,d,t) ;
$endif

$iftheni "%DAMAGE_MODULE%" == "ON"

   dam_tfp.fx(r,a,t)$(not ifDamage(r))   = dam_tfp.l(r,a,t) ;
   dam_lab.fx(r,l,a,t)$(not ifDamage(r)) = dam_lab.l(r,l,a,t) ;
   dam_hht.fx(r,l,a,t)$(not ifDamage(r)) = dam_hht.l(r,l,a,t) ;
   dam_nrg.fx(r,k,h,t)$(not ifDamage(r)) = dam_nrg.l(r,k,h,t) ;
   dam_lnd.fx(r,lnd,t)$(not ifDamage(r)) = dam_lnd.l(r,lnd,t) ;
   dam_tou.fx(r,i,t)$(not ifDamage(r))   = dam_tou.l(r,i,t) ;
   dam_cap.fx(r,t)$(not ifDamage(r))     = dam_cap.l(r,t) ;

   dam_shft_tfp.fx(r,a,t)$(not chi_adp_tfp(r,a,t))    = dam_shft_tfp.l(r,a,t) ;
   dam_shft_lab.fx(r,l,a,t)$(not chi_adp_lab(r,l,a,t)) = dam_shft_lab.l(r,l,a,t) ;
   dam_shft_hht.fx(r,l,a,t)$(not chi_adp_hht(r,l,a,t)) = dam_shft_hht.l(r,l,a,t) ;
   dam_shft_nrg.fx(r,k,h,t)$(not chi_adp_nrg(r,k,h,t)) = dam_shft_nrg.l(r,k,h,t) ;
   dam_shft_lnd.fx(r,lnd,t)$(not chi_adp_lnd(r,lnd,t)) = dam_shft_lnd.l(r,lnd,t) ;
   dam_shft_tou.fx(r,i,t)$(not chi_adp_tou(r,i,t))     = dam_shft_tou.l(r,i,t) ;
   dam_shft_cap.fx(r,t)$(not chi_adp_cap(r,t))         = dam_shft_cap.l(r,t) ;

   yfdexpadp.fx(r,fd,t)$(not ifAdpy(r,fd)) = yfdexpadp.l(r,fd,t) ;

$else

   dam_tfp.fx(r,a,t)    = dam_tfp.l(r,a,t) ;
   dam_lab.fx(r,l,a,t)  = dam_lab.l(r,l,a,t) ;
   dam_hht.fx(r,l,a,t)  = dam_hht.l(r,l,a,t) ;
   dam_nrg.fx(r,k,h,t)  = dam_nrg.l(r,k,h,t) ;
   dam_lnd.fx(r,lnd,t)  = dam_lnd.l(r,lnd,t) ;
   dam_tou.fx(r,i,t)    = dam_tou.l(r,i,t) ;
   dam_cap.fx(r,t)      = dam_cap.l(r,t) ;

   yfdexpadp.fx(r,fd,t) = 0 ;

$ontext
   xd.l(r,i,"adp",t) = xd.l(r,i,"adp",t) ;
   xm.l(r,i,"adp",t) = xm.l(r,i,"adp",t) ;
   xfd.fx(r,adp,t)   = xfd.l(r,adp,t) ;
   yfd.fx(r,adp,t)   = yfd.l(r,adp,t) ;
   yfd.fx(r,"adp",t)$(not ifAdpFlag(r)) = yfd.l(r,"adp",t) ;
   xfd.fx(r,"adp",t)$(not ifAdpFlag(r)) = xfd.l(r,"adp",t) ;
   yfdexpadp.fx(r,fd,t)$(not ifAdpy(r,fd)) = yfdexpadp.l(r,fd,t) ;
$offtext

$endif

pdt.fx(r,i,t)$(not xdtFlag(r,i))       = pdt.l(r,i,t) ;
xet.fx(r,i,t)$(not xetFlag(r,i))       = xet.l(r,i,t) ;
xs.fx(r,i,t)$(not xsFlag(r,i))         = xs.l(r,i,t) ;
pe.fx(s,i,d,t)$(not xwFlag(s,i,d))     = pe.l(s,i,d,t) ;
pet.fx(r,i,t)$(not xetFlag(r,i))       = pet.l(r,i,t) ;
petNDX.fx(r,i,t)$(not xetFlag(r,i))    = petNDX.l(r,i,t) ;
pwe.fx(s,i,d,t)$(not xwFlag(s,i,d))    = pwe.l(s,i,d,t) ;
pwm.fx(s,i,d,t)$(not xwFlag(s,i,d))    = pwm.l(s,i,d,t) ;

xwmg.fx(s,i,d,t)$(not tmgFlag(s,i,d)) = xwmg.l(s,i,d,t) ;
xwmg.fx(s,i,d,t)$(not tmgFlag(s,i,d)) = xwmg.l(s,i,d,t) ;
pwmg.fx(s,i,d,t)$(not tmgFlag(s,i,d)) = pwmg.l(s,i,d,t) ;
xmgm.fx(img,s,i,d,t)$(shr0_mgm(img,s,i,d) eq 0) = xmgm.l(img,s,i,d,t) ;
xtt.fx(r,i,t)$(not xttFlag(r,i))      = xtt.l(r,i,t) ;

pf.fx(r,f,a,t)$(not xfFlag(r,f,a))  = pf.l(r,f,a,t) ;
pfp.fx(r,f,a,t)$(not xfFlag(r,f,a)) = pfp.l(r,f,a,t) ;

ldz.fx(r,l,z,t)$(not lsFlag(r,l,z))     = 0 ;
awagez.fx(r,l,z,t)$(not lsFlag(r,l,z))  = awagez.l(r,l,z,t) ;
urbPrem.fx(r,l,t)$(not tLabFlag(r,l) or (omegam(r,l) eq inf)) = urbPrem.l(r,l,t) ;
ewagez.l(r,l,z,t)$(not lsFlag(r,l,z))   = ewagez.l(r,l,z,t) ;
rwage.l(r,l,z,t)$(not lsFlag(r,l,z))    = rwage.l(r,l,z,t) ;
twage.fx(r,l,t)$(not tlabFlag(r,l))     = twage.l(r,l,t) ;
skillprem.fx(r,l,t)$(not tlabFlag(r,l)) = skillprem.l(r,l,t) ;
ls.fx(r,l,t)$(not tlabFlag(r,l))        = ls.l(r,l,t) ;
uez.fx(r,l,z,t)$(ueFlag(r,l,z) eq fullEmpl)     = uez.l(r,l,z,t) ;
resWage.fx(r,l,z,t)$(ueFlag(r,l,z) eq fullEmpl) = ewagez.l(r,l,z,t) ;

migr.fx(r,l,t)$(not migrFlag(r,l))       = 0 ;
migrMult.fx(r,l,z,t)$(not migrFlag(r,l)) = 1 ;
lsz.fx(r,l,z,t)$(not lsFlag(r,l,z))      = lsz.l(r,l,z,t) ;
glab.fx(r,l,t)$(not tlabFlag(r,l))       = glab.l(r,l,t) ;

pk.fx(r,a,v,t)$(not kFlag(r,a))        = pk.l(r,a,v,t) ;
pkp.fx(r,a,v,t)$(not kFlag(r,a))       = pkp.l(r,a,v,t) ;
kxRat.fx(r,a,v,t)$(not kFlag(r,a))     = kxRat.l(r,a,v,t) ;
rrat.fx(r,a,t)$(not kFlag(r,a))        = rrat.l(r,a,t) ;

tland.fx(r,lnd,t)$(not tlandFlag(r,lnd))         = tland.l(r,lnd,t) ;
ptland.fx(r,lnd,t)$(not tlandFlag(r,lnd))        = ptland.l(r,lnd,t) ;
ptlandndx.fx(r,lnd,t)$(not tlandFlag(r,lnd))     = ptlandndx.l(r,lnd,t) ;
xlb.fx(r,lnd,lb,t)$(shr0_lb(r,lnd,lb,t) eq 0)    = xlb.l(r,lnd,lb,t) ;
plb.fx(r,lnd,lb,t)$(shr0_lb(r,lnd,lb,t) eq 0)    = plb.l(r,lnd,lb,t) ;
plbndx.fx(r,lnd,lb,t)$(shr0_lb(r,lnd,lb,t) eq 0) = plbndx.l(r,lnd,lb,t) ;
xnlb.fx(r,lnd,t)$(shr0_nlb(r,lnd,t) eq 0)        = xnlb.l(r,lnd,t) ;
pnlb.fx(r,lnd,t)$(shr0_nlb(r,lnd,t) eq 0)        = pnlb.l(r,lnd,t) ;
pnlbndx.fx(r,lnd,t)$(shr0_nlb(r,lnd,t) eq 0)     = pnlbndx.l(r,lnd,t) ;

loop(nrs,
   xfnot.fx(r,a,t)$(not xfFlag(r,nrs,a)) = 0 ;
   xfs.fx(r,nrs,a,t)$(not xfFlag(r,nrs,a)) = 0 ;
   xfgap.fx(r,a,t)$(not ifDepl(r,a)) = 0 ;
) ;

th2o.fx(r,t)$(not th2oFlag(r))         = th2o.l(r,t) ;
th2om.fx(r,t)$(not th2oFlag(r))        = th2om.l(r,t) ;
pth2o.fx(r,t)$(not th2oFlag(r))        = pth2o.l(r,t) ;
pth2ondx.fx(r,t)$(not th2oFlag(r))     = pth2ondx.l(r,t) ;
h2obnd.fx(r,wbnd,t)$(not h2obndFlag(r,wbnd))     = h2obnd.l(r,wbnd,t) ;
ph2obnd.fx(r,wbnd,t)$(not h2obndFlag(r,wbnd))    = ph2obnd.l(r,wbnd,t) ;
ph2obndndx.fx(r,wbnd,t)$(not h2obndFlag(r,wbnd)) = ph2obndndx.l(r,wbnd,t) ;

emi.fx(r,em,is,aa,t)$(not emi0(r,em,is,aa))                = 0 ;
emiTot.fx(r,em,t)$(emiTot0(r,em) = 0)                      = 0 ;
emiGbl.fx(em,t)$(emiGbl0(em) = 0)                          = 0 ;
evf.fx(r,fdc,t)$(fdFlag(r,fdc) = 0)                        = 0 ;
emiTotAct.fx(r,emq,a,t)$(emiTotAct0(r,emq,a) = 0)          = 0 ;
emiInt.fx(r,emq,a,t)$(emiInt0(r,emq,a) = 0)                = 0 ;
emiTotETS.fx(ra,r,emq,aets,t)$(emiTotETS0(ra,r,emq,aets) eq 0)   = 0 ;
avgEmiInt.fx(ra,emq,aets,t)$(avgEmiInt0(ra,emq,aets) eq 0) = 0 ;
