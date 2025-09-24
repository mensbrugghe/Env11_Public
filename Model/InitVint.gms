rwork(r) = power(1-depr(r,tsim), gap(tsim))/rwork(r) ;

xpn.l(r,a,v,tsim)  = xpn.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
xpx.l(r,a,v,tsim)  = xpx.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
xghg.l(r,a,v,tsim) = xghg.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
va.l(r,a,v,tsim)   = va.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
kef.l(r,a,v,tsim)  = kef.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
va1.l(r,a,v,tsim)  = va1.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
va2.l(r,a,v,tsim)  = va2.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
kf.l(r,a,v,tsim)   = kf.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
xnrg.l(r,a,v,tsim) = xnrg.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
ksw.l(r,a,v,tsim)  = ksw.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
ks.l(r,a,v,tsim)   = ks.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
kv.l(r,a,v,tsim)   = kv.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
xpv.l(r,a,v,tsim)  = xpv.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;

if(ifNRGNest,
   xnely.l(r,a,v,tsim)     = xnely.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
   xolg.l(r,a,v,tsim)      = xolg.l(r,a,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
   xaNRG.l(r,a,NRG,v,tsim) = xaNRG.l(r,a,NRG,vOld0,tsim)*(rwork(r)$vOld(v) + (1-rwork(r))$vNew(v)) ;
) ;

kslo.l(r,a,tsim) = kv.l(r,a,vOld0,tsim) ;
loop(vNew, kshi.l(r,a,tsim) = kv.l(r,a,vNew,tsim) ; ) ;
