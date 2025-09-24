loop((r,i),
   if(ArmSpec(r,i) eq AggArm,
      sam(r,i,aa,t)  = gamma_eda(r,i,aa)*pat.l(r,i,t)*xa.l(r,i,aa,t)*(pat0(r,i)*xa0(r,i,aa)) ;
   else
      sam(r,i,aa,t) = gamma_edd(r,i,aa)*pdt.l(r,i,t)*xd.l(r,i,aa,t)*pdt0(r,i)*xd0(r,i,aa)
                    + gamma_edm(r,i,aa)*xm.l(r,i,aa,t)*xm0(r,i,aa)
$iftheni "%MRIO_MODULE%" == "ON"
                    *    ((pma0(r,i,aa)*pma.l(r,i,aa,t))$(ArmSpec(r,i) eq MRIOArm)
                    +     (pmt0(r,i)*pmt.l(r,i,t))$(ArmSpec(r,i) eq stdArm))
$else
                    *    pmt0(r,i)*pmt.l(r,i,t)
$endif
                    ;
   ) ;
) ;

sam(r,"itax",aa,t) = sum(i,
     (paTax.l(r,i,aa,t)*gamma_eda(r,i,aa)*pat.l(r,i,t)*xa.l(r,i,aa,t)*(pat0(r,i)*xa0(r,i,aa)))
   $(ArmSpec(r,i) eq AggArm)
   + (pdTax.l(r,i,aa,t)*gamma_edd(r,i,aa)*pdt.l(r,i,t)*xd.l(r,i,aa,t)*(pdt0(r,i)*xd0(r,i,aa))
   +  pmTax.l(r,i,aa,t)*gamma_edm(r,i,aa)
$iftheni "%MRIO_MODULE%" == "ON"
   *     ((pma0(r,i,aa)*pma.l(r,i,aa,t))$(ArmSpec(r,i) eq MRIOArm)
   +      (pmt0(r,i)*pmt.l(r,i,t))$(ArmSpec(r,i) eq stdArm))
$else
   *     pmt0(r,i)*pmt.l(r,i,t)
$endif
   *     xm.l(r,i,aa,t)*xm0(r,i,aa))$(ArmSpec(r,i) ne AggArm)
   ) ;
sam(r,"itax",fd,t) = sam(r,"itax",fd,t) ;

sam(r,"wtax",h,t)  = sum(i$hWasteFlag(r,i,h), (xawc0(r,i,h)*xawc.l(r,i,h,t))*(pa0(r,i,h)*pa.l(r,i,h,t)*wtaxh.l(r,i,h,t)
                   +    wtaxhx.l(r,i,h,t)*pfd0(r,h)*pfd.l(r,h,t))) ;

sam(r,"ctax",aa,t) = sum((i,em),
     (chiEmi.l(r,em,aa,t)*emir(r,em,i,aa)*part(r,em,i,aa)*emiTax.l(r,em,aa,t)*xa.l(r,i,aa,t)*xa0(r,i,aa))
   $(ArmSpec(r,i) eq aggArm)
   + (chiEmi.l(r,em,aa,t)*emird(r,em,i,aa)*part(r,em,i,aa)*emiTax.l(r,em,aa,t)*xd.l(r,i,aa,t)*xd0(r,i,aa)
   +  chiEmi.l(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax.l(r,em,aa,t)*xm.l(r,i,aa,t)*xm0(r,i,aa))
   $(ArmSpec(r,i) ne aggArm)
   ) ;
sam(r,"ctax",a,t) = sum(ghg, (pnum.l(t)*pCarb.l(r,ghg,a,t) + procEmiTax.l(r,ghg,a,t)/pCarb0(r,ghg,a))
                  *     procEmi.l(r,ghg,a,t)*pCarb0(r,ghg,a)*procEmi0(r,ghg,a))
                  + sam(r,"ctax",a,t) - 0.0*emiRebate.l(r,a,t) ;
sam(r,a,"ctax",t) = 1.0*emiRebate.l(r,a,t) ;

sam(r,"ptax",i,t)  = sum(a,ptax.l(r,a,i,t)*p.l(r,a,i,t)*p0(r,a,i)*x.l(r,a,i,t)*x0(r,a,i)) ;
sam(r,"ptax",a,t)  = sum(v, uc.l(r,a,v,t)*uctax.l(r,a,v,t)*xpv.l(r,a,v,t)*(uc0(r,a)*xpv0(r,a))) ;

sam(r,f,a,t) = pf.l(r,f,a,t)*xf.l(r,f,a,t)*pf0(r,f,a)*xf0(r,f,a) ;

$ondotl
if(0,
   sam(r,"vtax",a,t) = sum(f, m_pfTax(r,f,a,t)*pf.l(r,f,a,t)*xf.l(r,f,a,t)*pf0(r,f,a)*xf0(r,f,a)) ;
else
   sam(r,"ltax",a,t) = sum(l, m_pfTax(r,l,a,t)*pf.l(r,l,a,t)*xf.l(r,l,a,t)*pf0(r,l,a)*xf0(r,l,a)) ;
   sam(r,"ktax",a,t) = sum(cap, m_pfTax(r,cap,a,t)*pf.l(r,cap,a,t)*xf.l(r,cap,a,t)*pf0(r,cap,a)*xf0(r,cap,a)) ;
   sam(r,"rtax",a,t) = sum(nrs, m_pfTax(r,nrs,a,t)*pf.l(r,nrs,a,t)*xf.l(r,nrs,a,t)*pf0(r,nrs,a)*xf0(r,nrs,a))
                     + sum(lnd, m_pfTax(r,lnd,a,t)*pf.l(r,lnd,a,t)*xf.l(r,lnd,a,t)*pf0(r,lnd,a)*xf0(r,lnd,a)) ;
) ;

if(0,
   loop(gov,
      sam(r,gov,gy,t) = ygov.l(r,gy,t)*ygov0(r,gy) ;
   ) ;
else
   loop((gov,gy)$(not sameas(gy,"vtax")),
      sam(r,gov,gy,t) = ygov.l(r,gy,t)*ygov0(r,gy) ;
   ) ;

   sam(r,gov,"ltax",t) = sum(a, sum(l, m_pfTax(r,l,a,t)*pf.l(r,l,a,t)*xf.l(r,l,a,t)*pf0(r,l,a)*xf0(r,l,a))) ;
   sam(r,gov,"ktax",t) = sum(a, sum(cap, m_pfTax(r,cap,a,t)*pf.l(r,cap,a,t)*xf.l(r,cap,a,t)*pf0(r,cap,a)*xf0(r,cap,a))) ;
   sam(r,gov,"rtax",t) = sum(a, sum(nrs, m_pfTax(r,nrs,a,t)*pf.l(r,nrs,a,t)*xf.l(r,nrs,a,t)*pf0(r,nrs,a)*xf0(r,nrs,a))
                       + sum(lnd, m_pfTax(r,lnd,a,t)*pf.l(r,lnd,a,t)*xf.l(r,lnd,a,t)*pf0(r,lnd,a)*xf0(r,lnd,a))) ;
) ;
$offdotl

sam(r,a,i,t) = p.l(r,a,i,t)*x.l(r,a,i,t)*p0(r,a,i)*x0(r,a,i) ;

loop(h,

   sam(r,h,f,t) =
      sum(a, (1-kappaf.l(r,f,a,t))*pf.l(r,f,a,t)*xf.l(r,f,a,t)*pf0(r,f,a)*xf0(r,f,a)) ;
   sam(r,h,l,t) = sam(r,h,l,t) - (sum(s, remit.l(s,l,r,t)*remit0(s,l,r))) ;
   sam(r,"dtax",f,t) =
      sum(a, kappaf.l(r,f,a,t)*pf.l(r,f,a,t)*xf.l(r,f,a,t)*pf0(r,f,a)*xf0(r,f,a)) ;
   sam(r,"bop",l,t) = sum(s, remit.l(s,l,r,t)*remit0(s,l,r)) ;
   sam(r,h,"bop",t) = sum((d,l), remit.l(r,l,d,t)*remit0(r,l,d)) ;

   loop(cap,
      sam(r,h,cap,t)     = sam(r,h,cap,t) - yqtf.l(r,t)*yqtf0(r) ;
      sam(r,"bop",cap,t) = yqtf.l(r,t)*yqtf0(r) ;
      sam(r,h,"bop",t)   = sam(r,h,"bop",t) + yqht.l(r,t)*yqht0(r) ;
   ) ;
   sam(r,"deprY",h,t) = deprY.l(r,t)*deprY0(r) ;

) ;

loop(h,
   sam(r,"dtax",h,t)  = kappah.l(r,t)*yh.l(r,t)*yh0(r) ;
   loop(inv,
      sam(r,inv,h,t)  = savh.l(r,h,t)*savh0(r,h) ;
   ) ;
) ;
loop(gov,
   loop(inv,
      sam(r,inv,gov,t) = savg.l(r,t) ;
   ) ;

$iftheni "%RD_MODULE%" == "ON"
   sam(r,r_d,gov,t)   = yfd.l(r,r_d,t)*yfd0(r,r_d) ;
$endif

$iftheni "%IFI_MODULE%" == "ON"
   sam(r,ifi,"BoP",t)   = yfd.l(r,ifi,t)*yfd0(r,ifi) ;
$endif

   sam(r,gov,"bop",t) = sum((emq,aets),emiQuotaY.l(r,emq,aets,t))
                      + ODAIn.l(r,t)*ODAIn0(r) + (pmuv.l(t)*itransfers.l(r,t))$(itransfers.l(r,t) gt 0)
                      ;
   sam(r,"BoP",gov,t) = ODAOut.l(r,t)*ODAOut0(r)
                      - (pmuv.l(t)*itransfers.l(r,t))$(itransfers.l(r,t) lt 0)
$iftheni "%IFI_MODULE%" == "ON"
                      + ifiOutShr(r)*ifiTot.l(t)
$endif
                      ;

) ;
loop(inv,
   sam(r,inv,"deprY",t) = deprY.l(r,t)*deprY0(r) ;
   sam(r,inv,"bop",t)   = pwsav.l(t)*savf.l(r,t) ;
) ;

loop(i,
   sam(r,i,"tmg",t)  = pdt.l(r,i,t)*xtt.l(r,i,t)*(pdt0(r,i)*xtt0(r,i)) ;
   if(ifaggTrade,
*     Aggregate exports at FOB prices
      sam(r,i,"trd",t)  = sum(d, pwe.l(r,i,d,t)*xw.l(r,i,d,t)*pwe0(r,i,d)*xw0(r,i,d)) ;
*     Aggregate imports at FOB prices
      sam(r,"trd",i,t)  = sum(s, pwe.l(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t)*pwe0(s,i,r)*xw0(s,i,r)) ;
   else
*     Exports at FOB prices
      sam(r,i,d,t)      = pwe.l(r,i,d,t)*xw.l(r,i,d,t)*pwe0(r,i,d)*xw0(r,i,d) ;
*     Imports at FOB prices
      sam(r,s,i,t)      = pwe.l(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t)*pwe0(s,i,r)*xw0(s,i,r) ;
   ) ;

*  'Imports' of trade margin services

   sam(r,"tmg",i,t)  = sum(s, ((pwm.l(s,i,r,t)*lambdaw(s,i,r,t))*pwm0(s,i,r)
                     -     pwe.l(s,i,r,t)*pwe0(s,i,r))*lambdax(s,i,r,t)*xw.l(s,i,r,t)*xw0(s,i,r)) ;

*  Import tariff revenue
$ondotl
   sam(r,"mtax",i,t) =
$iftheni "%MRIO_MODULE%" == "ON"
      (sum((s,aa), mtaxa.l(s,i,r,aa,t)*pwm0(s,i,r)*pwm.l(s,i,r,t)*xwa0(s,i,r,aa)*xwa.l(s,i,r,aa,t)))
      $(ArmSpec(r,i) eq MRIOArm)
      + (sum(s, (mtax.l(s,i,r,t)*pwm.l(s,i,r,t)*pwm0(s,i,r)
         + m_spctar(s,i,r,t))*lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t)*xw0(s,i,r)))
      $(ArmSpec(r,i) ne MRIOArm)
$else
      sum(s, (mtax.l(s,i,r,t)*pwm.l(s,i,r,t)*pwm0(s,i,r)
         + m_spctar(s,i,r,t))*lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t)*xw0(s,i,r))
$endif
      ;
$offdotl

*  NTM revenue

   sam(r,"ntmY",i,t) = (sum(s, ntmAVE.l(s,i,r,t)*pwm.l(s,i,r,t)*lambdax(s,i,r,t)*lambdaw(s,i,r,t)*xw.l(s,i,r,t)
                     *     (pwm0(s,i,r)*xw0(s,i,r))))$(ArmSpec(r,i) ne MRIOArm) ;

   sam(r,gov,"ntmY",t) = sum(s, chigNTM(s,r,t)*ntmY.l(r,t)*ntmY0(r)) ;
   sam(r,h,"ntmY",t)   = sum(s, chihNTM(s,r,t)*ntmY.l(r,t)*ntmY0(r)) ;

*  Export tax revenue

   sam(r,"etax",i,t) = sum(d, (pwe.l(r,i,d,t)*pwe0(r,i,d)
                     -     pe.l(r,i,d,t)*pe0(r,i,d)/1)*xw.l(r,i,d,t)*xw0(r,i,d)) ;
) ;

sam(r, "tmg", "bop", t) = sum(i,pdt.l(r,i,t)*xtt.l(r,i,t)*(pdt0(r,i)*xtt0(r,i)))
                        - sum(i, sam(r,"tmg",i,t)) ;

if(ifaggTrade,
   sam(r, "trd", "bop", t) = sum((i,d), pwe.l(r,i,d,t)*pwe0(r,i,d)*xw.l(r,i,d,t)*xw0(r,i,d)) ;
   sam(r, "bop", "trd", t) = sum((i,s), pwe.l(s,i,r,t)*pwe0(s,i,r)*lambdax(s,i,r,t)*xw.l(s,i,r,t)*xw0(s,i,r)) ;
else
   loop(d,
      sam(r, d, "bop", t) = sum(i, pwe.l(r,i,d,t)*pwe0(r,i,d)*xw.l(r,i,d,t)*xw0(r,i,d)) ;
      sam(r, "bop", s, t) = sum(i, pwe.l(s,i,r,t)*pwe0(s,i,r)*lambdax(s,i,r,t)*xw.l(s,i,r,t)*xw0(s,i,r)) ;
   ) ;
) ;

NRGBAL(r,e,aa,t)   = (xa0(r,e,aa)*xa.l(r,e,aa,t))
                   $(ArmSpec(r,e) eq aggArm)
                   + (xd0(r,e,aa)*xd.l(r,e,aa,t) + xm0(r,e,aa)*xm.l(r,e,aa,t))
                   $(ArmSpec(r,e) ne aggArm) ;

*  ELY is priced in GWHR

NRGBAL(r,a,e,t) = x.l(r,a,e,t)*x0(r,a,e)*(1$(not elyc(e)) + 1000*emat("GWH", "MTOE")$elyc(e)) ;

if(ifaggTrade,
*  Aggregate exports
   NRGBAL(r,e,"trd",t)  = sum(d, xw.l(r,e,d,t)*xw0(r,e,d)) ;
*  Aggregate imports
   NRGBAL(r,"trd",e,t)  = sum(s, lambdax(s,e,r,t)*xw.l(s,e,r,t)*xw0(s,e,r)) ;
else
*  Exports
   NRGBAL(r,e,d,t)      = xw.l(r,e,d,t)*xw0(r,e,d) ;
*  Imports at FOB prices
   NRGBAL(r,s,e,t)      = lambdax(s,e,r,t)*xw.l(s,e,r,t)*xw0(s,e,r) ;
) ;
