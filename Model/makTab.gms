$if not setglobal startYear $setglobal startYear 0

* $include "faotab.gms"

*  Some set up for R

file freg / regions.csv / ;
file yearf / years.csv / ;
alias(ra,sa) ; alias(ra,da) ;
if(0,
   put freg ;
   put "ISO,Name" / ;
   freg.pc=5 ;
   loop(ra,
      put ra.tl, ra.te(ra) / ;
   ) ;

   put yearf ;
   put "Years" / ;
   yearf.pc=5 ;
   loop(t$tr(t),
      put years(t):4:0 / ;
   ) ;
) ;

$macro reScale1(varName, i__1, suffix)  &varName.fx(r,i__1,t) = &varName.l(r,i__1,t)*&varName&suffix(r,i__1) ;

Parameters
   val                     "Contains value"
   pndx(ra,fd,t)           "Price index for fd"
   pendx(ra,t)             "Export price index"
   pttndx(ra,t)            "TT export price index"
   pmndx(ra,t)             "Import price index"
   gdp(ra,t)               "Nominal GDP"
   rgdp(ra,t)              "Real GDP"
   pweBaU(s,i,r,t)         "BaU FOB price"
   pwmBaU(s,i,r,t)         "BaU CIF price"
   xwBaU(s,i,r,t)          "BaU (export) trade flows"
   xwmBaU(s,i,r,t)         "BaU (import) trade flows"
   lambdawBaU(s,i,r,t)     "BaU import iceberg parameter"
   lambdaxBaU(s,i,r,t)     "BaU export iceberg parameter"
;

pndx(ra,fd,t) = 1 ;
pendx(ra,t)   = 1 ;
pmndx(ra,t)   = 1 ;
pttndx(ra,t)  = 1 ;

*  Load the baseline

$iftheni.BaU "%simtype%" == "RcvDyn"
  execute_load "%odir%/%BaUName%.gdx", pwe0, pwm0, pweBaU=pwe.l, pwmBaU=pwm.l, xwBaU=xw.l, lambdawBaU=lambdaw, lambdaxBaU=lambdax ;
  xwmBaU(s,i,r,t) = lambdawBaU(s,i,r,t)*lambdaxBaU(s,i,r,t)*xwBaU(s,i,r,t) ;
$else.BaU
  execute_load "%odir%/%SIMNAME%.gdx", pwe0, pwm0, pweBaU=pwe.l, pwmBaU=pwm.l, xwBaU=xw.l, lambdawBaU=lambdaw, lambdaxBaU=lambdax ;
  xwmBaU(s,i,r,t) = lambdawBaU(s,i,r,t)*lambdaxBaU(s,i,r,t)*xwBaU(s,i,r,t) ;
$endif.BaU

*  Population/GDP

execute_load "%odir%/%SIMNAME%.gdx", popT, pop, pop0, rgdpmp, rgdpmp0, gdpmp, gdpmp0,
   ev, ev0, xfd, xfd0, yfd0, yfd, pfd, pfd0, gdpScen, ygov, ygov, pa, pa0, xa, xa0, trent, trent0, kstock, kstock0,
   pwe0, pwe, xw0, xw, pdt0, pdt, xtt, xtt0, lambdaw, lambdax, pwm0, pwm, pfact, pfact0,
   itransfers, lsz, ldz, lsz0, ldz0, cpi, cpi0, etfp, tls, tls0 ;

file csvgdppop / "%odir%\gdppop.csv" / ;

$macro QFD(fd,tp,tq)   (sum((r,i)$mapra(ra,r), pa0(r,i,fd)*xa0(r,i,fd)*pa.l(r,i,fd,tp)*xa.l(r,i,fd,tq)))

$macro QEXPT(sa,tp,tq)  \
   (sum((s,i,d)$(mapra(sa,s)), \
      pwe0(s,i,d)*xw0(s,i,d)*(pwe.l(s,i,d,tp)/lambdax(s,i,d,tp))*lambdax(s,i,d,tq)*xw.l(s,i,d,tq)))
$macro QIMPT(da,tp,tq) \
   (sum((s,i,d)$(mapra(da,d)), \
      pwm0(s,i,d)*xw0(s,i,d)*pwm.l(s,i,d,tp) \
    *    lambdaw(s,i,d,tq)*lambdax(s,i,d,tq)*xw.l(s,i,d,tq)))
$macro QXTT(ra,tp,tq)  (sum((r,img)$(mapra(ra,r)), pdt0(r,img)*xtt0(r,img)*pdt.l(r,img,tp)*xtt.l(r,img,tq)))

if(ifTab("gdpPop"),
   put csvgdppop ;
   if(%ifAppend%,
      csvgdppop.ap = 1 ;
      put csvgdppop ;
   else
      csvgdppop.ap = 0 ;
      put csvgdppop ;
      put "Var,Sim,Region,Year,Value" / ;
   ) ;
   csvgdppop.pc = 5 ;
   csvgdppop.nd = 9 ;
   loop((ra,t),
      vol = outScale*sum(r$mapra(ra,r), rgdpmp.l(r,t)*rgdpmp0(r)) ;
      rgdp(ra,t) = vol ;
      put "rgdpmp",  "%SIMNAME%", ra.tl, PUTYEAR(t), (vol) / ;
      work = outscale*sum(r$mapra(ra,r), rgdpmp.l(r,t)*rgdpmp0(r)*etfp.l(r,t)) ;
      put "etfp",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work/rgdp(ra,t)) / ;
      val = outScale*sum(r$mapra(ra,r), gdpmp.l(r,t)*gdpmp0(r)) ;
      gdp(ra,t) = val ;
      put "gdpmp",  "%SIMNAME%", ra.tl, PUTYEAR(t), (val) / ;
      work$vol = 100*val / vol ;
      put "pgdpmp",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work = sum(r$mapra(ra,r), popT(r,"PLT15",t))/popscale ;
      put "PLT15",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work = sum(r$mapra(ra,r), popT(r,"P1564",t))/popscale ;
      put "P1564",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work = sum(r$mapra(ra,r), popT(r,"P65UP",t))/popscale ;
      put "P65UP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work = sum(r$mapra(ra,r), popT(r,"PTOTL",t))/popscale ;
      put "PopT",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work = sum(r$mapra(ra,r), pop0(r)*pop.l(r,t))/popscale ;
      put "Pop",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work$work = vol / work ;
      put "rgdppc", "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work = sum(r$mapra(ra,r), rgdpmp0(r)*rgdpmp.l(r,t)) ;
      if(work ne 0,
         work = sum(r$mapra(ra,r), rgdpmp0(r)*rgdpmp.l(r,t)*pfact0(r)*pfact.l(r,t)) / work ;
      ) ;
      put "PFACT",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;

      vol = outScale*sum(r$mapra(ra,r), kstock.l(r,t)*kstock0(r)) ;
      put "kstock",  "%SIMNAME%", ra.tl, PUTYEAR(t), (vol) / ;
      val  = outScale*sum(r$mapra(ra,r), trent.l(r,t)*trent0(r)*kstock.l(r,t)*kstock0(r)) ;
      if(vol ne 0, put "TRENT", "%SIMNAME%", ra.tl, PUTYEAR(t), (val/vol) / ; ) ;

*     !!!! Caution summing over households
      vol = outScale*sum(r$mapra(ra,r), sum(h, ev.l(r,h,t)*ev0(r,h))) ;
      put "EV",  "%SIMNAME%", ra.tl, PUTYEAR(t), (vol) / ;
      vol = outScale*sum((gov,r)$mapra(ra,r), yfd.l(r,gov,t)*yfd0(r,gov)*pfd.l(r,gov,t0)/pfd.l(r,gov,t)) ;
      put "EVG", "%SIMNAME%", ra.tl, PUTYEAR(t), (vol) / ;
      vol = outScale*sum((inv,r)$mapra(ra,r), yfd.l(r,inv,t)*yfd0(r,inv)*pfd.l(r,inv,t0)/pfd.l(r,inv,t)) ;
      put "EVI", "%SIMNAME%", ra.tl, PUTYEAR(t), (vol) / ;
      vol = outScale*sum((r,h)$mapra(ra,r), ((savh.l(r,h,t)*savh0(r,h) + savg.l(r,t))/psave.l(r,t))*psave.l(r,t0)) ;
      put "EVS", "%SIMNAME%", ra.tl, PUTYEAR(t), (vol) / ;
      vol = outscale*(sum(r$mapra(ra,r), sum(h, ev.l(r,h,t)*ev0(r,h)))
          +           sum((gov,r)$mapra(ra,r), yfd.l(r,gov,t)*yfd0(r,gov)*pfd.l(r,gov,t0)/pfd.l(r,gov,t))
          +           sum((inv,r)$mapra(ra,r), yfd.l(r,inv,t)*yfd0(r,inv)*pfd.l(r,inv,t0)/pfd.l(r,inv,t))) ;
      put "EVT", "%SIMNAME%", ra.tl, PUTYEAR(t), (vol) / ;

*     !!!! Caution summing over households
      vol = sum(r$mapra(ra,r), sum(h, ev.l(r,h,t)*ev0(r,h))) ;
      loop(mapCPILAB(cpindx,cpilab)$vol,
         val = sum(r$mapra(ra,r), sum(h, ev.l(r,h,t)*ev0(r,h)*cpi.l(r,h,CPINDX,t)))/vol ;
         put CPILAB.tl, "%SIMNAME%", ra.tl, PUTYEAR(t), (val) / ;
      ) ;

      vol = outScale*sum(r$mapra(ra,r), tls.l(r,t)*tls0(r)) ;
      put "TLS", "%SIMNAME%", ra.tl, PUTYEAR(t), (vol) / ;

      $$iftheni "%simType%" == "CompStat"
         pndx(ra,fd,t) = QFD(fd,t0,t0) ;
         pndx(ra,fd,t)$pndx(ra,fd,t) = (1)$(sameas(t,t0))
                       + (pndx(ra,fd,t0)*sqrt((QFD(fd,t,t0)/QFD(fd,t0,t0))*(QFD(fd,t,t)/QFD(fd,t0,t))))$(not sameas(t,t0)) ;
      $$else
         pndx(ra,fd,t) = QFD(fd,t0,t0) ;
         pndx(ra,fd,t)$pndx(ra,fd,t) = (1)$(sameas(t,t0))
                       + (pndx(ra,fd,t-1)*sqrt((QFD(fd,t,t-1)/QFD(fd,t-1,t-1))*(QFD(fd,t,t)/QFD(fd,t-1,t))))$(not sameas(t,t0)) ;
      $$endif

      loop(fd,
         if(h(fd),
            put "PCONS",  "%SIMNAME%", ra.tl, PUTYEAR(t), (100*pndx(ra,fd,t)) / ;
            work = outScale*sum(r$mapra(ra,r), sum(h, yfd.l(r,fd,t)*yfd0(r,fd))) ;
            put "YFD",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
            put "XFD",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work/pndx(ra,fd,t)) / ;
         ) ;
         if(gov(fd),
            put "PGOV",  "%SIMNAME%", ra.tl, PUTYEAR(t), (100*pndx(ra,fd,t)) / ;
            work = outScale*sum(r$mapra(ra,r), sum(h, yfd.l(r,fd,t)*yfd0(r,fd))) ;
            put "YFDG",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
            put "XFDG",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work/pndx(ra,fd,t)) / ;
         ) ;
         if(inv(fd),
            put "PINV",  "%SIMNAME%", ra.tl, PUTYEAR(t), (100*pndx(ra,fd,t)) / ;
            work = outScale*sum(r$mapra(ra,r), sum(h, yfd.l(r,fd,t)*yfd0(r,fd))) ;
            put "YFDI",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
            put "XFDI",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work/pndx(ra,fd,t)) / ;
         ) ;

$iftheni "%IFI_MODULE%" == "ON"
         if(ifi(fd),
            put "PIFI",  "%SIMNAME%", ra.tl, PUTYEAR(t), (100*pndx(ra,fd,t)) / ;
            work = outScale*sum(r$mapra(ra,r), sum(h, yfd.l(r,fd,t)*yfd0(r,fd))) ;
            if(work ne 0,
               put "YFDIFI",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
               put "XFDIFI",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work/pndx(ra,fd,t)) / ;
            ) ;
         ) ;
$endif
      ) ;

      $$iftheni "%simType%" == "CompStat"
         pendx(ra,t)  = (1)$(sameas(t,t0))
                      + (pendx(ra,t0)*sqrt((QEXPT(ra,t,t0)/QEXPT(ra,t0,t0))*(QEXPT(ra,t,t)/QEXPT(ra,t0,t))))$(not sameas(t,t0)) ;
         pmndx(ra,t)  = (1)$(sameas(t,t0))
                      + (pmndx(ra,t0)*sqrt((QIMPT(ra,t,t0)/QIMPT(ra,t0,t0))*(QIMPT(ra,t,t)/QIMPT(ra,t0,t))))$(not sameas(t,t0)) ;
         pttndx(ra,t) = (1)$(sameas(t,t0))
                      + (pttndx(ra,t0)*sqrt((QXTT(ra,t,t0)/QXTT(ra,t0,t0))*(QXTT(ra,t,t)/QXTT(ra,t0,t))))$(not sameas(t,t0)) ;
      $$else
         pendx(ra,t) = (1)$(sameas(t,t0))
                     + (pendx(ra,t-1)*sqrt((QEXPT(ra,t,t-1)/QEXPT(ra,t-1,t-1))*(QEXPT(ra,t,t)/QEXPT(ra,t-1,t))))$(not sameas(t,t0)) ;
         pmndx(ra,t) = (1)$(sameas(t,t0))
                     + (pmndx(ra,t-1)*sqrt((QIMPT(ra,t,t-1)/QIMPT(ra,t-1,t-1))*(QIMPT(ra,t,t)/QIMPT(ra,t-1,t))))$(not sameas(t,t0)) ;
         pttndx(ra,t) = (1)$(sameas(t,t0))
                      + (pttndx(ra,t-1)*sqrt((QXTT(ra,t,t-1)/QXTT(ra,t-1,t-1))*(QXTT(ra,t,t)/QXTT(ra,t-1,t))))$(not sameas(t,t0)) ;
      $$endif
      display pttndx ;

      val = QEXPT(ra,t,t) ;
      if(val ne 0,
         put "EXP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
         put "REXP", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val/pendx(ra,t)) / ;
         put "PEXP", "%SIMNAME%", ra.tl, PUTYEAR(t), (100*pendx(ra,t)) / ;
      ) ;
*     Value of exports at baseline prices
      val = sum((s,i,d)$(mapra(ra,s)), pwe0(s,i,d)*xw0(s,i,d)*pweBaU(s,i,d,t)*xw.l(s,i,d,t)) ;
      put "EXP_BaUP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
*     Value of baseline exports at shocked prices
      val = sum((s,i,d)$(mapra(ra,s)), pwe0(s,i,d)*xw0(s,i,d)*pwe.l(s,i,d,t)*xwBaU(s,i,d,t)) ;
      put "EXP_BaUX",  "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
      val = sum((r,img)$mapra(ra,r), pdt0(r,img)*xtt0(r,img)*pdt.l(r,img,t)*xtt.l(r,img,t)) ;
      if(val ne 0,
         put "TTEXP",   "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
         put "RTTEXP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val/pttndx(ra,t)) / ;
         put "PTTEXP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (100*pttndx(ra,t)) / ;
      ) ;

      val = QIMPT(ra,t,t)
      if(val ne 0,
         put "IMP",   "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
         put "RIMP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val/pmndx(ra,t)) / ;
         put "PIMP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (100*pmndx(ra,t)) / ;
      ) ;

*     Value of imports at baseline prices
      val = sum((s,i,d)$(mapra(ra,d)), pwm0(s,i,d)*xw0(s,i,d)*pwmBaU(s,i,d,t)
          *    lambdaw(s,i,d,t)*lambdax(s,i,d,t)*xw.l(s,i,d,t)) ;
      put "IMP_BaUP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
*     Value of baseline imports at shocked prices
      val = sum((s,i,d)$(mapra(ra,d)), pwm0(s,i,d)*xw0(s,i,d)*pwm.l(s,i,d,t)
          *    lambdawBaU(s,i,d,t)*lambdaxBaU(s,i,d,t)*xwBaU(s,i,d,t)) ;
      put "IMP_BaUX",  "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;

      loop(gy,
         val = sum(r$mapra(ra,r), ygov.l(r,gy,t)*ygov0(r,gy)) ;
         put gy.tl, "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
      ) ;
      val = sum((r)$mapra(ra,r), ntmY.l(r,t)*NTMY0(r)) ;
      put "NTMY", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
      val = sum((r)$mapra(ra,r), itransfers.l(r,t)) ;
      if(val,
         put "ITransfers", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
      ) ;
      loop(lagg$sameas(lagg,"Tot"),
         loop(z$sameas(z,"nsg"),
            vol = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), lsz0(r,l,z)*lsz.l(r,l,z,t)) ;
            if(vol > 0,
               val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), ldz0(r,l,z)*ldz.l(r,l,z,t)) ;
               put "UEZ_pct", "%SIMNAME%", ra.tl, PUTYEAR(t), (100 - 100*val/vol) / ;
            ) ;
         ) ;
      ) ;
   ) ;
) ;

putclose csvgdppop ;

*  Aggregate factor prices

execute_load "%odir%/%SIMNAME%.gdx", pf, pf0, xf, xf0,
      ptland, ptland0, tland, tland0 ;

file csvfactp / "%odir%\factp.csv" / ;

if(ifTab("factp"),
   put csvfactp ;
   if(%ifAppend%,
      csvfactp.ap = 1 ;
      put csvfactp ;
   else
      csvfactp.ap = 0 ;
      put csvfactp ;
      put "Var,Sim,Region,Year,Value" / ;
   ) ;
   csvfactp.pc = 5 ;
   csvfactp.nd = 9 ;
   loop((ra,t),
      loop(l,
         work = outScale*sum((r,a)$mapra(ra,r), xf0(r,l,a)*xf.l(r,l,a,t)) ;
         work$work = outScale*sum((r,a)$mapra(ra,r),
            pf0(r,l,a)*pf.l(r,l,a,t)*xf0(r,l,a)*xf.l(r,l,a,t))/work ;
         put l.tl:0:0, "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      ) ;
      loop(cap,
         work = outScale*sum((r,a)$mapra(ra,r), xf0(r,cap,a)*xf.l(r,cap,a,t)) ;
         work$work = outScale*sum((r,a)$mapra(ra,r),
            pf0(r,cap,a)*pf.l(r,cap,a,t)*xf0(r,cap,a)*xf.l(r,cap,a,t))/work ;
         put "trent",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      ) ;
      work = outScale*sum((r,lnd)$mapra(ra,r), tland0(r,lnd)*tland.l(r,lnd,t)) ;
      work$work = outScale*sum((r,lnd)$mapra(ra,r),
         ptland0(r,lnd)*ptland.l(r,lnd,t)*tland0(r,lnd)*tland.l(r,lnd,t))/work ;
      put "ptland",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      loop(nrs,
         work = outScale*sum((r,a)$mapra(ra,r), xf0(r,nrs,a)*xf.l(r,nrs,a,t)) ;
         work$work = outScale*sum((r,a)$mapra(ra,r),
            pf0(r,nrs,a)*pf.l(r,nrs,a,t)*xf0(r,nrs,a)*xf.l(r,nrs,a,t))/work ;
         put "ptnrs", "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      ) ;
      loop(wat,
         work = outScale*sum((r,a)$mapra(ra,r), xf0(r,wat,a)*xf.l(r,wat,a,t)) ;
         work$work = outScale*sum((r,a)$mapra(ra,r),
            pf0(r,wat,a)*pf.l(r,wat,a,t)*xf0(r,wat,a)*xf.l(r,wat,a,t))/work ;
         put "pth2o", "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      ) ;
   ) ;
) ;
putclose csvfactp ;

*  Houseshold taxes as a share of household income

execute_load "%odir%/%SIMNAME%.gdx", kappah, yh, yh0,
   pftax, chiFtax, ifMFtaxFlag, alphaFtax, ifAFtaxFlag, pf, pf0, xf, xf0, gdpmp, gdpmp0,
   chiEmi, emir, part, emiTax, xa0, xa, emird, xd0, xd, emirm, xm, xm0 ;

file csvkappah / "%odir%\kappah.csv" / ;

if(ifTab("kappah"),
   put csvkappah ;
   if(%ifAppend%,
      csvkappah.ap = 1 ;
      put csvkappah ;
   else
      csvkappah.ap = 0 ;
      put csvkappah ;
      put "Var,Sim,Region,Year,Value" / ;
   ) ;
   csvkappah.pc = 5 ;
   csvkappah.nd = 9 ;
   loop((ra,t),
      work = sum(r$mapra(ra,r), gdpmp.l(r,t)*gdpmp0(r)) ;
      put "GDPMP",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work/inscale) / ;
      work = sum(r$mapra(ra,r), kappah.l(r,t)*yh.l(r,t)*yh0(r)) ;
      put "kappahY",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work/inscale) / ;
      vol = sum(r$mapra(ra,r), yh.l(r,t)*yh0(r)) ;
      work$vol = 100*work / vol ;
      put "kappah",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      $$ondotl
      loop((fpagg),
*        work = sum(r$mapra(ra,r), sum(a, alphaFtax.l(r,t)*ifAFtaxFlag(r,fp,a)*pf.l(r,fp,a,t)*pf0(r,fp,a)*xf.l(r,fp,a,t)*xf0(r,fp,a))) ;
         work = sum(r$mapra(ra,r), sum(mapfp(fpagg,fp), sum(a$ifAfTaxFlag(r,fp,a), (M_PFTAX(r,fp,a,t) - pftax.l(r,fp,a,t0))*pf.l(r,fp,a,t)*pf0(r,fp,a)*xf.l(r,fp,a,t)*xf0(r,fp,a)))) ;
         if(work ne 0,
*           !!!! HARDCODED INDICES
            if(sameas(fpagg,"nsk"),
               put "NSK_SubsY", "%SIMNAME%", ra.tl, PUTYEAR(t), (work/inscale) / ;
            elseif(sameas(fpagg,"skl")),
               put "SKL_SubsY", "%SIMNAME%", ra.tl, PUTYEAR(t), (work/inscale) / ;
            elseif(sameas(fpagg,"cap")),
               put "CAP_SubsY", "%SIMNAME%", ra.tl, PUTYEAR(t), (work/inscale) / ;
            ) ;
         ) ;
      ) ;
      work = sum(r$mapra(ra,r), sum((em,i,aa),
         (chiEmi(r,em,aa,t)*emir(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)*xa(r,i,aa,t)*xa0(r,i,aa))
         $(ArmSpec(r,i) eq aggArm)
      +  (chiEmi(r,em,aa,t)*emird(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)*xd(r,i,aa,t)*xd0(r,i,aa)
      +   chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)*xm(r,i,aa,t)*xm0(r,i,aa))
         $(ArmSpec(r,i) eq stdArm))) ;
      if(work ne 0,
         put "ctaxY", "%SIMNAME%", ra.tl, PUTYEAR(t), (work/inscale) / ;
      ) ;
      $$offdotl
   ;
   ) ;
) ;
putclose csvkappah ;

*  Government expenditures as a share of GDP

execute_load "%odir%/%SIMNAME%.gdx",
   xfd, xfd0, yfd, yfd0, rgdpmp, rgdpmp0, ygov0, ygov, ntmY, ntmy0, emiQuotaY, ODAIn, ODAOut ;

file csvrgovshr / "%odir%\rgovshr.csv" / ;

if(ifTab("rgovshr"),
   put csvrgovshr ;
   if(%ifAppend%,
      csvrgovshr.ap = 1 ;
      put csvrgovshr ;
   else
      csvrgovshr.ap = 0 ;
      put csvrgovshr ;
      put "Var,Sim,Region,Year,Value" / ;
   ) ;
   csvrgovshr.pc = 5 ;
   csvrgovshr.nd = 9 ;
   loop((ra,t),
      work = sum(r$mapra(ra,r), rgdpmp.l(r,t)*rgdpmp0(r)) ;
      work$work = 100*sum((r,gov)$mapra(ra,r), xfd.l(r,gov,t)*xfd0(r,gov)) / work ;
      put "rgovshr",  "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
   ) ;
   loop((ra,t),
      work = sum((r,gov)$mapra(ra,r), yfd.l(r,gov,t)*yfd0(r,gov)) ;
      put "GEXP", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*work) / ;
      loop(gy,
         val = sum(r$mapra(ra,r), ygov.l(r,gy,t)*ygov0(r,gy)) ;
         put gy.tl, "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
      ) ;
      val = sum((r)$mapra(ra,r), ntmY.l(r,t)*NTMY0(r)) ;
      put "NTMY", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ;
      val = sum((r)$mapra(ra,r), sum((emq,aets),emiQuotaY.l(r,emq,aets,t))) ;
      if(val ne 0, put "emiQuotaY", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ; ) ;
      val = sum((r)$mapra(ra,r), ODAIn.l(r,t)*ODAIn0(r)) ;
      if(val ne 0, put "ODAIn", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ; ) ;
      val = sum((r)$mapra(ra,r), ODAOut.l(r,t)*ODAOut0(r)) ;
      if(val ne 0, put "ODAOut", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ; ) ;
      val = sum((r)$mapra(ra,r), savg.l(r,t)) ;
      if(val ne 0, put "SAVG", "%SIMNAME%", ra.tl, PUTYEAR(t), (outscale*val) / ; ) ;
   ) ;
) ;
putclose csvrgovshr ;

*  Domestic savings/investment

execute_load "%odir%/%SIMNAME%.gdx", yfd, yfd0, xfd, xfd0, savh, savh0, savg, pwsav,
   savf, deprY, deprY0, gdpmp, gdpmp0, rgdpmp, rgdpmp0, yd, yd0 ;

file csvsavinv / "%odir%\savinv.csv" / ;

if(ifTab("savinv"),
   put csvsavinv ;
   if(%ifAppend%,
      csvsavinv.ap = 1 ;
      put csvsavinv ;
   else
      csvsavinv.ap = 0 ;
      put csvsavinv ;
      put "Var,Sim,Region,Year,Value" / ;
   ) ;
   csvsavinv.pc = 5 ;
   csvsavinv.nd = 9 ;
   loop((ra,t),
      work = sum(r$mapra(ra,r), rgdpmp.l(r,t)*gdpmp0(r)) ;
      put "gdpmp", "%SIMNAME%", ra.tl, PUTYEAR(t), (work*outscale) / ;
      work = sum(r$mapra(ra,r), rgdpmp.l(r,t)*rgdpmp0(r)) ;
      put "rgdpmp", "%SIMNAME%", ra.tl, PUTYEAR(t), (work*outscale) / ;
      work$work = 100*sum((r,inv)$mapra(ra,r), xfd.l(r,inv,t)*xfd0(r,inv)) / work ;
      put "rinvshr", "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work = sum((r,inv)$mapra(ra,r), xfd.l(r,inv,t)*xfd0(r,inv)) ;
      put "rinv", "%SIMNAME%", ra.tl, PUTYEAR(t), (work*outscale) / ;
      work = sum((r,inv)$mapra(ra,r), yfd.l(r,inv,t)*yfd0(r,inv)) ;
      put "inv", "%SIMNAME%", ra.tl, PUTYEAR(t), (work*outscale) / ;
      work = sum((r,h)$mapra(ra,r), savh.l(r,h,t)*savh0(r,h)) ;
      put "savh", "%SIMNAME%", ra.tl, PUTYEAR(t), (work*outscale) / ;
      work = 100*work / sum((r)$mapra(ra,r), yd.l(r,t)*yd0(r)) ;
      put "aps", "%SIMNAME%", ra.tl, PUTYEAR(t), (work) / ;
      work = sum(r$mapra(ra,r), savg.l(r,t)) ;
      put "savg", "%SIMNAME%", ra.tl, PUTYEAR(t), (work*outscale) / ;
      work = sum(r$mapra(ra,r), pwsav.l(t)*savf.l(r,t)) ;
      put "savf", "%SIMNAME%", ra.tl, PUTYEAR(t), (work*outscale) / ;
      work = sum(r$mapra(ra,r), deprY.l(r,t)*deprY0(r)) ;
      put "deprY", "%SIMNAME%", ra.tl, PUTYEAR(t), (work*outscale) / ;
   ) ;
) ;
putclose csvsavinv ;

file csvxp / "%odir%\Output.csv" / ;

if(ifTab("xp"),
   put csvxp ;
   if(%ifAppend%,
      csvxp.ap = 1 ;
      put csvxp ;
   else
      csvxp.ap = 0 ;
      put csvxp ;
      put "Var,Sim,Region,Activity,Year,Value" / ;
   ) ;
   csvxp.pc = 5 ;
   csvxp.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", px, xp, px0, xp0 ;

   reScale1(px, a, 0)
   reScale1(xp, a, 0)

   loop((ra,aga,t),
      vol = sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), xp.l(r,a,t)) ;
      if(vol ne 0,
*        Unweighted aggregation of volumes
         put "xp",  "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (outScale*vol) / ;
*        Base year price weighted aggregation of volumes
         work = sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), px.l(r,a,t0)*xp.l(r,a,t)) ;
         put "xpw", "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (outScale*work) / ;
*        Value of output
         val = sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), px.l(r,a,t)*xp.l(r,a,t)) ;
         put "xpd", "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (outScale*val) / ;
*        Volume weighted prices
         work = sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), px.l(r,a,t)*xp.l(r,a,t)) ;
         put "px", "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (work/vol) / ;
*        Price index
         work = sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), px.l(r,a,t)*xp.l(r,a,t0))
              / sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), px.l(r,a,t0)*xp.l(r,a,t0))
         put "pxn", "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (work) / ;
      ) ;
   ) ;
) ;

set vagg /
   set.endw
   tlab        "All labor"
   tcap        "All non-labor"
   tot         "All value added"
/ ;

set mapvagg(vagg,fp) ;
mapvagg(vagg,fp)$(sameas(vagg,fp)) = yes ;
mapvagg("tlab",l) = yes ;
mapvagg("tcap",fp)$(not l(fp)) = yes ;
mapvagg("tot",fp) = yes ;
* display mapvagg ; abort "Temp" ;

*  Value added

file csvva / "%odir%\VA.csv" / ;

Parameters
   pfBaU(r,fp,a,t)
   xfBaU(r,fp,a,t)
;

scalar growth ;
scalar discRate / 0.04 / ;
parameter discFactor(tt) ;
discFactor(t0) = 1 ;
loop(tt$(years(tt) gt years(t0)),
   discFactor(tt) = discFactor(tt-1) / (1 + discRate) ;
) ;

put screen ; put / ;

if(ifTab("va"),
   put csvva ;
   if(%ifAppend%,
      csvva.ap = 1 ;
      put csvva ;
   else
      csvva.ap = 0 ;
      put csvva ;
      put "Var,Sim,Region,Activity,Factor,Year,Value" / ;
   ) ;
   csvva.pc = 5 ;
   csvva.nd = 9 ;

*  Load the baseline

   $$iftheni.BaU "%simtype%" == "RcvDyn"
      execute_load "%odir%/%BaUName%.gdx", pf0, xf0, pf, xf ;
      pfBaU(r,fp,a,t) = pf0(r,fp,a)*pf.l(r,fp,a,t) ;
      xfBaU(r,fp,a,t) = xf0(r,fp,a)*xf.l(r,fp,a,t) ;
   $$else.BaU
      execute_load "%odir%/%SIMNAME%.gdx", pf0, xf0, pf, xf ;
      pfBaU(r,fp,a,t) = pf0(r,fp,a)*pf.l(r,fp,a,t0) ;
      xfBaU(r,fp,a,t) = xf0(r,fp,a)*xf.l(r,fp,a,t0) ;
   $$endif.BaU

   execute_load "%odir%/%SIMNAME%.gdx", pf0, xf0, pf, xf, pftax, chiFtax, ifMFtaxFlag, alphaFtax, ifAFtaxFlag
      pfp, px, xp, px0, xp0 ;
$ondotl
   loop((ra,vagg,aga,t)$(aggaga(aga)),
      val = sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a)),
         pf.l(r,fp,a,t)*pf0(r,fp,a)*xf.l(r,fp,a,t)*xf0(r,fp,a)) ;
      if(val ne 0,
         put "va_d",  "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (outscale*val) / ;
         vol = sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a)),
            pf.l(r,fp,a,t0)*pf0(r,fp,a)*xf.l(r,fp,a,t)*xf0(r,fp,a)) ;
         put "va_n",  "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (outscale*vol) / ;
         put "pva_n",  "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (val/vol) / ;
         put "rpva_n", "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), ((val/vol)/sum(h,pndx(ra,h,t))) / ;
         vol = sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a)),
            xf.l(r,fp,a,t)*xf0(r,fp,a)) ;
         put "va",    "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (outscale*vol) / ;
         put "pva",   "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (val/vol) / ;

         vol = sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a)),
            M_PFTAX(r,fp,a,t)*pf.l(r,fp,a,t)*pf0(r,fp,a)*xf.l(r,fp,a,t)*xf0(r,fp,a)) ;
         put "pftax",   "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (vol/val) / ;
         vol = sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), px0(r,a)*px.l(r,a,t)*xp0(r,a)*xp.l(r,a,t)) ;
         put "va_shr", "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (100*val/vol) / ;
      ) ;
   ) ;
   if(1,
*     Annualize and discount
      loop((ra,vagg,aga)$(aggaga(aga)),
*        Initialize with base year
         val = sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a)),
                  pf.l(r,fp,a,t0)*pf0(r,fp,a)*xf.l(r,fp,a,t0)*xf0(r,fp,a)) ;
         if(val ne 0,
            put "vaa_d",    "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t0), (outScale*val) / ;
            put "vaa_disc", "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t0), (outScale*discFactor(t0)*val) / ;
*           Loop over remaining simulation years
            loop(t$(not t0(t)),
               growth = (sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a)),
                  pf.l(r,fp,a,t)*pf0(r,fp,a)*xf.l(r,fp,a,t)*xf0(r,fp,a))/val)**(1/gap(t)) ;
*              Loop over intermediate years
               loop(tt$(years(tt) gt years(t-1) and years(tt) le years(t)),
                  put csvva ;
                  put "vaa_d", "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(tt), (outScale*val*power(growth,years(tt)-years(t-1))) / ;
                  put "vaa_disc", "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(tt), (outScale*discFactor(tt)*val*power(growth,years(tt)-years(t-1))) / ;
               ) ;
*              Update the reference year
               val = val*power(growth, years(t) - years(t-1)) ;
            ) ;
         ) ;
      ) ;
   ) ;
$offdotl

*  Displacement

   if(1,
      loop((ra,vagg,aga,t,t0)$agaa(aga),
         vol = sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a)), xfBau(r,fp,a,t)) ;
         put "BaU_Use", "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (outscale*vol) / ;
         vol = sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a) and xf0(r,fp,a)*xf.l(r,fp,a,t) >= xfBau(r,fp,a,t)),
                  (xf0(r,fp,a)*xf.l(r,fp,a,t) - xfBau(r,fp,a,t))) ;
         put "displ+", "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (outscale*vol) / ;
         vol = sum((r,fp,a)$(mapra(ra,r) and mapvagg(vagg,fp) and mapaga(aga,a) and xf0(r,fp,a)*xf.l(r,fp,a,t) < xfBau(r,fp,a,t)),
                   (xf0(r,fp,a)*xf.l(r,fp,a,t) - xfBau(r,fp,a,t))) ;
         put "displ-", "%SIMNAME%", ra.tl, aga.tl, vagg.tl, PUTYEAR(t), (outscale*vol) / ;
      ) ;
   ) ;

   putclose csvva ;
) ;

*  Investment

Parameters
   tinv        "Total investment"
   tva         "Total value added"
;

file csvinv / "%odir%\INV.csv" / ;

if(ifTab("inv"),
   put csvinv ;
   if(%ifAppend%,
      csvinv.ap = 1 ;
      put csvinv ;
   else
      csvinv.ap = 0 ;
      put csvinv ;
      put "Var,Sim,Region,Activity,Year,Value" / ;
   ) ;
   csvinv.pc = 5 ;
   csvinv.nd = 9 ;
   execute_load "%odir%/%SIMNAME%.gdx",
      kstock, trent, kv, pk, kstock0, trent0, kv0, pk0, tkaps, tkaps0, pfd, pfd0, depr ;

*  Get value added

   execute_load "%odir%/%SIMNAME%.gdx", pf, xf, pf0, xf0 ;

*  Sectoral investment

   loop((ra,inv,t)$(years(t) gt years(t0)),

      tinv = outScale*sum((r,a)$(mapra(ra,r)), (depr(r,t-1)/(1-power(1-depr(r,t-1),gap(t))))
              *   pfd0(r,inv)*pfd.l(r,inv,t-1)
              *   (sum(v, kv0(r,a)*kv.l(r,a,v,t)) - power(1-depr(r,t-1),gap(t))*sum(v, kv0(r,a)*kv.l(r,a,v,t-1)))
              *      (kstock0(r)*kstock.l(r,t0)/(tkaps0(r)*tkaps.l(r,t0)))) ;
      tva = sum((r,a)$(mapra(ra,r)), sum(fp, pf0(r,fp,a)*pf.l(r,fp,a,t)*xf0(r,fp,a)*xf.l(r,fp,a,t))) ;

      loop(aga,
         work = outscale*sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), (depr(r,t-1)/(1-power(1-depr(r,t-1),gap(t))))
              *   (sum(v, kv0(r,a)*kv.l(r,a,v,t))
                     - power(1-depr(r,t-1),gap(t))*sum(v, kv0(r,a)*kv.l(r,a,v,t-1)))
                     * (kstock0(r)*kstock.l(r,t0)/(tkaps0(r)*tkaps.l(r,t0)))) ;
         put "inv_sec", "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (work) / ;
         work = outscale*sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), (depr(r,t-1)/(1-power(1-depr(r,t-1),gap(t))))
              *   pfd0(r,inv)*pfd.l(r,inv,t-1)
              *   (sum(v, kv0(r,a)*kv.l(r,a,v,t)) - power(1-depr(r,t-1),gap(t))*sum(v, kv0(r,a)*kv.l(r,a,v,t-1)))
              *      (kstock0(r)*kstock.l(r,t0)/(tkaps0(r)*tkaps.l(r,t0)))) ;
         put "invd_sec", "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (work) / ;
         put "invd_shr", "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (100*work/tinv) / ;

         val = sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), sum(fp, pf0(r,fp,a)*pf.l(r,fp,a,t)*xf0(r,fp,a)*xf.l(r,fp,a,t))) ;
         put "va_shr",   "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), (100*val/tva) / ;

         if(val,
            put "invRatio", "%SIMNAME%", ra.tl, aga.tl, PUTYEAR(t), ((work/tinv)/(val/tva)) / ;
         ) ;
      ) ;
   ) ;
) ;

*  Emissions

file csvemi / "%odir%\EMI.csv" / ;


$iftheni "%simtype%" == "RcvDyn"
   alias(tt,th) ;
$else
   set th / 1950*2100 / ;
$endif

Parameter
   cumEmiPart(ra,em,t)
   emiReg(ra,em,t)
   ghgHist(ghgCodes,r,th)
   emiRef(ra,ghgCodes)
   gwpA(ra,em)
;

$if not set emiRefYear $set emiRefYear 2005
singleton set tref(th) "GHG reference year" / %emiRefYear% / ;

cumEmiPart(ra,em,t) = 0 ;

if(ifTab("emi"),
   put csvemi ;
   if(%ifAppend%,
      csvemi.ap = 1 ;
      put csvemi ;
   else
      csvemi.ap = 0 ;
      put csvemi ;
      put "Var,Sim,Region,Agent,Emission,Unit,Year,Value" / ;
   ) ;
   csvemi.pc = 5 ;
   csvemi.nd = 9 ;

*  execute_load "%odir%/%SIMNAME%.gdx", emiTot, emi, emiTot0, emi0, emiTotETS, emiTotETS0, ifEmiCap, emiCTax,
*     ghgHist, ygov, ygov0 ;
   execute_load "%odir%/%SIMNAME%.gdx", emiTot, emi, emiTot0, emi0, emiTotETS, emiTotETS0, ifEmiCap, emiCTax,
      ygov, ygov0, procEmi0, procEmi, emiRebateExog, emiRebateX ;

   emiRef(ra,GHGCodes) = sum(r$mapra(ra,r), ghgHist(GHGCodes, r, tref)) ;
*  emiRef(ra,GHGCodes) = 1 ;

*  Emissions in mt
   gwpA(ra,ghg) = sum(mapra(ra,r), emiTot0(r,ghg)/gwp(r,ghg)) ;
   gwpA(ra,ghg)$gwpA(ra,ghg) = sum(mapra(ra,r), emiTot0(r,ghg))/gwpA(ra,ghg) ;
   gwpA(ra,em) = gwpa(ra,em) + 1$(not gwpA(ra,em)) ;

$ondotl
*  Conversion from GG to MT is 1000

   loop((em,t,ra),
      emiReg(ra,em,t) = sum(r$mapra(ra,r), emiTot0(r,em)*emiTot.l(r,em,t)) ;

$iftheni "%simtype%" == "RcvDyn"
      cumEmiPart(ra,em,t)$emiReg(ra,em,t) = (emiReg(ra,em,t))$t0(t)
                           + (cumEmiPart(ra,em,t-1) + (emiReg(ra,em,t) - emiReg(ra,em,t-1))
                           / (1 - (emiReg(ra,em,t-1)/emiReg(ra,em,t))**(1/gap(t))))$(not t0(t)) ;
$else
      cumEmiPart(ra,em,t) = 0 ;
$endif

      if(emiReg(ra,em,t) ne 0,
         if(ghg(em),
            put "emi",    "%SIMNAME%", ra.tl, "Tot", em.tl, "CEQ",   PUTYEAR(t), ((12/44)*emiReg(ra,em,t)/cscale) / ;
            put "emi",    "%SIMNAME%", ra.tl, "Tot", em.tl, "CO2EQ", PUTYEAR(t), (emiReg(ra,em,t)/cscale) / ;
            put "emi",    "%SIMNAME%", ra.tl, "Tot", em.tl, "MT",    PUTYEAR(t), (emiReg(ra,em,t)/(cscale*gwpA(ra,em))) / ;
            put "CumEmi", "%SIMNAME%", ra.tl, "Tot", em.tl, "CEQ",   PUTYEAR(t), ((12/44)*cumEmiPart(ra,em,t)/cscale) / ;
            put "CumEmi", "%SIMNAME%", ra.tl, "Tot", em.tl, "CO2EQ", PUTYEAR(t), (cumEmiPart(ra,em,t)/cscale) / ;
            put "CumEmi", "%SIMNAME%", ra.tl, "Tot", em.tl, "MT",    PUTYEAR(t), (cumEmiPart(ra,em,t)/(cscale*gwpA(ra,em))) / ;
         else
            put "emi",    "%SIMNAME%", ra.tl, "Tot", em.tl, "MT", PUTYEAR(t), ((1e-3)*emiReg(ra,em,t)/cscale) / ;
            put "CumEmi", "%SIMNAME%", ra.tl, "Tot", em.tl, "MT", PUTYEAR(t), ((1e-3)*cumEmiPart(ra,em,t)/cscale) / ;
         ) ;

*        Relative to reference year
         if(sameas(em,"CO2") and emiRef(ra,"CO2"),
            put  "emiRef%", "%SIMNAME%", ra.tl, "Tot", "CO2", "CO2EQ", PUTYEAR(t), (100*emiReg(ra,"CO2",t)/(cscale*emiRef(ra,"CO2"))-100) / ;
            put  "emiRef", "%SIMNAME%", ra.tl, "Tot", "CO2", "CO2EQ", PUTYEAR(t), (emiRef(ra,"CO2")) / ;
         ) ;
      ) ;

      loop(aga,
         work = sum((r,a,i)$(mapra(ra,r) and mapaga(aga,a)), emi0(r,em,i,a)*emi.l(r,em,i,a,t)) ;
         if(work ne 0,
            if(ghg(em),
               put "emi_io", "%SIMNAME%", ra.tl, aga.tl, em.tl, "CEQ",   PUTYEAR(t), ((12/44)*work/cscale) / ;
               put "emi_io", "%SIMNAME%", ra.tl, aga.tl, em.tl, "CO2EQ", PUTYEAR(t), (work/cscale) / ;
               put "emi_io", "%SIMNAME%", ra.tl, aga.tl, em.tl, "MT",    PUTYEAR(t), (work/(cscale*gwpA(ra,em))) / ;
            else
               put "emi_io", "%SIMNAME%", ra.tl, aga.tl, em.tl, "MT", PUTYEAR(t), ((1e-3)*work/cscale) / ;
            ) ;
         ) ;
         work = sum((r,a,i)$(mapra(ra,r) and mapaga(aga,a)), (chiRebate(r,em,i,a,t)*m_EMIREBATE(r,em,i,a,t))) ;
         if(work ne 0,
            if(ghg(em),
               put "emiRebate", "%SIMNAME%", ra.tl, aga.tl, em.tl, "CEQ",   PUTYEAR(t), ((12/44)*work/cscale) / ;
               put "emiRebate", "%SIMNAME%", ra.tl, aga.tl, em.tl, "CO2EQ", PUTYEAR(t), (work/cscale) / ;
               put "emiRebate", "%SIMNAME%", ra.tl, aga.tl, em.tl, "MT",    PUTYEAR(t), (work/(cscale*gwpA(ra,em))) / ;
            else
               put "emiRebate", "%SIMNAME%", ra.tl, aga.tl, em.tl, "MT", PUTYEAR(t), ((1e-3)*work/cscale) / ;
            ) ;
         ) ;
      ) ;

      loop(aga,
         work = sum((r,a,fp)$(mapra(ra,r) and mapaga(aga,a)), emi0(r,em,fp,a)*emi.l(r,em,fp,a,t)) ;
         if(work ne 0,
            if(ghg(em),
               put "emi_fp", "%SIMNAME%", ra.tl, aga.tl, em.tl, "CEQ",   PUTYEAR(t), ((12/44)*work/cscale) / ;
               put "emi_fp", "%SIMNAME%", ra.tl, aga.tl, em.tl, "CO2EQ", PUTYEAR(t), (work/cscale) / ;
               put "emi_fp", "%SIMNAME%", ra.tl, aga.tl, em.tl, "MT",    PUTYEAR(t), (work/(cscale*gwpA(ra,em))) / ;
            else
               put "emi_fp", "%SIMNAME%", ra.tl, aga.tl, em.tl, "MT", PUTYEAR(t), ((1e-3)*work/cscale) / ;
            ) ;
         ) ;
      ) ;

      loop(aga,
         work = sum((r,a,is)$(sameas(is,"tot") and mapra(ra,r) and mapaga(aga,a)), emi0(r,em,is,a)*emi.l(r,em,is,a,t)) ;
         if(work ne 0,
            if(ghg(em),
               put "emi_xp", "%SIMNAME%", ra.tl, aga.tl, em.tl, "CEQ",   PUTYEAR(t), ((12/44)*work/cscale) / ;
               put "emi_xp", "%SIMNAME%", ra.tl, aga.tl, em.tl, "CO2EQ", PUTYEAR(t), (work/cscale) / ;
               put "emi_xp", "%SIMNAME%", ra.tl, aga.tl, em.tl, "MT",    PUTYEAR(t), (work/(cscale*gwpA(ra,em))) / ;
            else
               put "emi_xp", "%SIMNAME%", ra.tl, aga.tl, em.tl, "MT", PUTYEAR(t), ((1e-3)*work/cscale) / ;
            ) ;
         ) ;
      ) ;

      loop(fd,
         work = sum((r,is)$(mapra(ra,r) and emir(r,em,is,fd)), emi0(r,em,is,fd)*emi.l(r,em,is,fd,t)) ;
         if(work ne 0,
            if(ghg(em),
               put "emi_io", "%SIMNAME%", ra.tl, fd.tl, em.tl, "CEQ",   PUTYEAR(t), ((12/44)*work/cscale) / ;
               put "emi_io", "%SIMNAME%", ra.tl, fd.tl, em.tl, "CO2EQ", PUTYEAR(t), (work/cscale) / ;
               put "emi_io", "%SIMNAME%", ra.tl, fd.tl, em.tl, "MT",    PUTYEAR(t), (work/(cscale*gwpA(ra,em))) / ;
            else
               put "emi_io", "%SIMNAME%", ra.tl, fd.tl, em.tl, "MT", PUTYEAR(t), ((1e-3)*work/cscale) / ;
            ) ;
         ) ;
      ) ;
   ) ;

   loop((emq,t,ra),
      loop(aets,
         work = sum(r$mapra(ra,r), emiTotETS0(ra,r,emq,aets)*emiTotETS.l(ra,r,emq,aets,t)) ;
         if(work ne 0,
            put "emiETS", "%SIMNAME%", ra.tl, aets.tl, emq.tl, "CO2EQ", PUTYEAR(t), (work/cscale) / ;
         ) ;
         if(emiCTax.l(ra,emq,aets,t),
            put "emiCTAX", "%SIMNAME%", ra.tl, aets.tl, emq.tl, "CO2EQ", PUTYEAR(t), (1000*emiCTAX.l(ra,emq,aets,t)) / ;
            put "emiCTAX_LCU", "%SIMNAME%", ra.tl, aets.tl, emq.tl, "CO2EQ", PUTYEAR(t), (1000*EXR*emiCTAX.l(ra,emq,aets,t)) / ;
         ) ;
      ) ;
      val = sum(r$mapra(ra,r), ygov.l(r,"ctax",t)*ygov0(r,"ctax")) ;

      val = sum(mapra(ra,r),
               (sum((em,i,aa)$(mapEM(emq,em) and ArmSpec(r,i) eq aggArm),chiEmi.l(r,em,aa,t)*emir(r,em,i,aa)*part(r,em,i,aa)*emiTax.l(r,em,aa,t)*xa.l(r,i,aa,t)*xa0(r,i,aa)))
          +    (sum((em,i,aa)$(mapEM(emq,em) and ArmSpec(r,i) eq stdArm), chiEmi(r,em,aa,t)*emird(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)*xd(r,i,aa,t)*xd0(r,i,aa))
          +     sum((em,i,aa)$(ArmSpec(r,i) eq stdArm), chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)*xm(r,i,aa,t)*xm0(r,i,aa)))) ;

      vol = sum(mapra(ra,r),
               (sum((em,i,aa)$(mapEM(emq,em) and ArmSpec(r,i) eq aggArm),chiEmi.l(r,em,aa,t)*emir(r,em,i,aa)*part(r,em,i,aa)*xa.l(r,i,aa,t)*xa0(r,i,aa)))
          +    (sum((em,i,aa)$(mapEM(emq,em) and ArmSpec(r,i) eq stdArm), chiEmi(r,em,aa,t)*emird(r,em,i,aa)*part(r,em,i,aa)*xd(r,i,aa,t)*xd0(r,i,aa))
          +     sum((em,i,aa)$(mapEM(emq,em) and ArmSpec(r,i) eq stdArm), chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*xm(r,i,aa,t)*xm0(r,i,aa)))) ;

      if(vol ne 0,
         put "AvgCTax", "%SIMNAME%", ra.tl, "All", emq.tl, "CO2EQ", PUTYEAR(t), (1000*val/vol) / ;
         put "AvgCTax_LCU", "%SIMNAME%", ra.tl, "All", emq.tl, "CO2EQ", PUTYEAR(t), (1000*EXR*val/vol) / ;
      ) ;
   ) ;

   loop((t,ra),
      loop((ghg,aga),
         work = sum((r,a)$(mapra(ra,r) and mapaga(aga,a)), procEmi0(r,ghg,a)*procEmi.l(r,ghg,a,t)) ;
         if(work ne 0,
            put "ProcE", "%SIMNAME%", ra.tl, aga.tl, ghg.tl, "CO2EQ", PUTYEAR(t), (work/cscale) / ;
         ) ;
      ) ;
   ) ;
   putclose csvemi ;
$offdotl
) ;

Parameters
   cshr(is)       "Cost shares"
   delpx          "Change in aggregate price"
   delxp          "Change in aggregate volume"
   cwgt           "Share weights"
;

cwgt = 0.5 ;

*  Cost structure

file csvcost / "%odir%\Cost.csv" / ;

if(ifTab("cost"),
   put csvcost ;
   if(%ifAppend%,
      csvcost.ap = 1 ;
      put csvcost ;
   else
      csvcost.ap = 0 ;
      put csvcost ;
      put "Var,Sim,Region,Activity,Input,Qualifier,Year,Value" / ;
   ) ;
   csvcost.pc = 5 ;
   csvcost.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", px, xp, px0, xp0
      pa, pa0, xa, xa0, pfp, pfp0, pf, pf0, xf, xf0 ;

   loop((r,a,t)$(years(t) gt years(t0) and xpFlag(r,a)),
      delpx = (px.l(r,a,t)/px.l(r,a,t-1))**(1/gap(t)) - 1 ;
      delxp = (xp.l(r,a,t)/xp.l(r,a,t-1))**(1/gap(t)) - 1 ;
      put "delpx", "%SIMNAME%",  r.tl, a.tl, "tot", "", PUTYEAR(t), (delpx) / ;
      put "delxp","%SIMNAME%",   r.tl, a.tl, "tot", "", PUTYEAR(t), (delxp) / ;
      loop(i$xaFlag(r,i,a),
         cshr(i) = cwgt*(pa0(r,i,a)*xa0(r,i,a))*pa.l(r,i,a,t-1)*xa.l(r,i,a,t-1)/((px0(r,a)*xp0(r,a))*px.l(r,a,t-1)*xp.l(r,a,t-1))
                 + (1-cwgt)*pa0(r,i,a)*xa0(r,i,a)*pa.l(r,i,a,t)*xa.l(r,i,a,t)/((px0(r,a)*xp0(r,a))*px.l(r,a,t)*xp.l(r,a,t))
                 ;
         put "pcshr", "%SIMNAME%",  r.tl, a.tl, i.tl, "io", PUTYEAR(t), (cshr(i)*((pa.l(r,i,a,t)/pa.l(r,i,a,t-1))**(1/gap(t)) - 1)) / ;
         put "xcshr", "%SIMNAME%",  r.tl, a.tl, i.tl, "io", PUTYEAR(t), (cshr(i)*((xa.l(r,i,a,t)/xa.l(r,i,a,t-1))**(1/gap(t)) - 1 - delxp)) / ;
         put "cshr",  "%SIMNAME%",  r.tl, a.tl, i.tl, "io", PUTYEAR(t), (cshr(i)) / ;
      ) ;
      loop(f$xfFlag(r,f,a),
         cshr(f) = cwgt*(pfp0(r,f,a)*xf0(r,f,a))*pfp.l(r,f,a,t-1)*xf.l(r,f,a,t-1)/(px0(r,a)*xp0(r,a)*px.l(r,a,t-1)*xp.l(r,a,t-1))
                 + (1-cwgt)*(pfp0(r,f,a)*xf0(r,f,a))*pfp.l(r,f,a,t)*xf.l(r,f,a,t)/(px0(r,a)*xp0(r,a)*px.l(r,a,t)*xp.l(r,a,t))
                 ;
         put "pcshr", "%SIMNAME%",  r.tl, a.tl, f.tl, "fp", PUTYEAR(t), (cshr(f)*((pfp.l(r,f,a,t)/pfp.l(r,f,a,t-1))**(1/gap(t)) - 1)) / ;
         put "xcshr", "%SIMNAME%",  r.tl, a.tl, f.tl, "fp", PUTYEAR(t), (cshr(f)*((xf.l(r,f,a,t)/xf.l(r,f,a,t-1))**(1/gap(t)) - 1 - delxp)) / ;
         put "cshr",  "%SIMNAME%",  r.tl, a.tl, f.tl, "fp", PUTYEAR(t), (cshr(f)) / ;
      ) ;
   ) ;
   putclose csvcost ;
) ;


*  Sources of growth

parameters
   fshr(r,fp,a,t)    "Factor share in value added"
   qdel(r,fp,a,t)    "Volume source of growth"
   ldel(r,fp,a,t)    "Productivity source of growth"
   rgdpfc(r,t)       "Real GDP at factor cost -- excl. indirect taxes"
   gdpfc(r,t)        "Nominal GDP at factor cost -- excl. indirect taxes"
;

file ydecomp / "%odir%\ydecomp.csv" / ;

if(ifTab("ydecomp"),
   put ydecomp ;
   if(%ifAppend%,
      ydecomp.ap = 1 ;
      put ydecomp ;
   else
      ydecomp.ap = 0 ;
      put ydecomp ;
      put "Var,Sim,Region,Activity,Factor,Year,Value" / ;
   ) ;
   ydecomp.pc = 5 ;
   ydecomp.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", pf, pf0, xf, xf0, lambdaf ;

   fshr(r,f,a,t) = pf0(r,f,a)*xf0(r,f,a)*pf.l(r,f,a,t)*xf.l(r,f,a,t) ;
   qdel(r,f,a,t) = xf0(r,f,a)*xf.l(r,f,a,t) ;
   ldel(r,f,a,t) = lambdaf.l(r,f,a,t) ;

   gdpfc(r,t) = sum((fp,a), fshr(r,fp,a,t)) ;
   loop(t0,
      rgdpfc(r,t) =  sum((a,f), pf0(r,f,a)*pf.l(r,f,a,t0)*lambdaf.l(r,f,a,t)*xf0(r,f,a)*xf.l(r,f,a,t)) ;
   ) ;
   loop((ra,t),
      put "gdpfc",  "%SIMNAME%", ra.tl, "Tot", "Tot", PUTYEAR(t), (outscale*sum(r$mapra(ra,r), gdpfc(r,t))) / ;
      put "rgdpfc", "%SIMNAME%", ra.tl, "Tot", "Tot", PUTYEAR(t), (outscale*sum(r$mapra(ra,r), rgdpfc(r,t))) / ;
      put "pgdpfc", "%SIMNAME%", ra.tl, "Tot", "Tot", PUTYEAR(t), (sum(r$mapra(ra,r), gdpfc(r,t))/sum(r$mapra(ra,r), rgdpfc(r,t))) / ;
   ) ;
   fshr(r,fp,a,t) = fshr(r,fp,a,t) / gdpfc(r,t) ;
   loop((r,t)$(years(t) gt years(t0)),
      loop((fp,a)$(qdel(r,fp,a,t-1)*qdel(r,fp,a,t) gt 0),
         put "qdel",  "%SIMNAME%", r.tl, a.tl, fp.tl, PUTYEAR(t),
            (100*(0.5*fshr(r,fp,a,t-1) + (1-0.5)*fshr(r,fp,a,t))*((qdel(r,fp,a,t)/qdel(r,fp,a,t-1))**(1/gap(t))-1)) / ;
      ) ;
      loop((fp,a)$ldel(r,fp,a,t-1),
         put "ldel",  "%SIMNAME%", r.tl, a.tl, fp.tl, PUTYEAR(t),
            (100*(0.5*fshr(r,fp,a,t-1) + (1-0.5)*fshr(r,fp,a,t))*((ldel(r,fp,a,t)/ldel(r,fp,a,t-1))**(1/gap(t))-1)) / ;
      ) ;
   ) ;
) ;

*  Trade

file trade / "%odir%\trade.csv" / ;

parameters
   trdvol(ra,ia,t)
   trdval(ra,ia,t)
   trdtax(ra,ia,t)
;

if(ifTab("trade"),
   put trade ;
   if(%ifAppend%,
      trade.ap = 1 ;
      put trade ;
   else
      trade.ap = 0 ;
      put trade ;
      put "Var,Sim,Region,Commodity,Year,Value" / ;
   ) ;
   trade.pc = 5 ;
   trade.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", xw, pe, pwe, pwm, pdm, xw0, pe0, pwe0, pwm0, pdm0, lambdaw, lambdax,
         gamma_eda, gamma_edd, gamma_edm, pat, xa, pat0, xa0, pdt, pmt, xd, xm, pdt0, xd0, pmt0, xm0, mtax, emiX, emiTaxX ;

   trdval(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(d, pwe0(r,i,d)*xw0(r,i,d)*pwe.l(r,i,d,t)*xw.l(r,i,d,t))) ;
   trdvol(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(d, pwe0(r,i,d)*xw0(r,i,d)*pwe.l(r,i,d,t0)*lambdax(r,i,d,t)*xw.l(r,i,d,t))) ;

   if(0,
*     Use contemporary volume weights
      trdtax(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(d, pe0(r,i,d)*xw0(r,i,d)*pe.l(r,i,d,t)*xw.l(r,i,d,t))) ;
      trdtax(ra,ia,t)$trdtax(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(d, pwe0(r,i,d)*xw0(r,i,d)*pwe.l(r,i,d,t)*xw.l(r,i,d,t)))
                                      / trdtax(ra,ia,t) - 1 ;
   else
*     Use fixed volume weights
      trdtax(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(d, pe0(r,i,d)*xw0(r,i,d)*pe.l(r,i,d,t)*xw.l(r,i,d,t0))) ;
      trdtax(ra,ia,t)$trdtax(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(d, pwe0(r,i,d)*xw0(r,i,d)*pwe.l(r,i,d,t)*xw.l(r,i,d,t0)))
                                      / trdtax(ra,ia,t) - 1 ;
   ) ;

   loop((ra,ia,t)$trdval(ra,ia,t),
         put "exp_d", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*trdval(ra,ia,t)) / ;
         put "exp",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*trdvol(ra,ia,t)) / ;
         put "etax",  "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (100*trdtax(ra,ia,t)) / ;
   ) ;

   trdval(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwe0(s,i,r)*xw0(s,i,r)*pwe.l(s,i,r,t)*xw.l(s,i,r,t))) ;
   trdvol(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwe0(s,i,r)*xw0(s,i,r)*pwe.l(s,i,r,t0)*lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t))) ;

   loop((ra,ia,t)$trdval(ra,ia,t),
         put "imp_fob_d", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*trdval(ra,ia,t)) / ;
         put "imp_fob",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*trdvol(ra,ia,t)) / ;
   ) ;

   trdval(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t)*xw.l(s,i,r,t))) ;
   trdvol(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t0)*lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t))) ;

   if(0,
*     Use contemporary volume weights
      trdtax(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t)*lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t))) ;
      trdtax(ra,ia,t)$trdtax(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pdm0(s,i,r)*xw0(s,i,r)*pdm.l(s,i,r,t)*lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t)))
                                      / trdtax(ra,ia,t) - 1 ;
   else
*     Use fixed volume weights
      trdtax(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t)*xw.l(s,i,r,t0))) ;
      trdtax(ra,ia,t)$trdtax(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pdm0(s,i,r)*xw0(s,i,r)*pdm.l(s,i,r,t)*xw.l(s,i,r,t0)))
                                      / trdtax(ra,ia,t) - 1 ;
   ) ;

   loop((ra,ia,t)$trdval(ra,ia,t),
         put "imp_cif_d", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*trdval(ra,ia,t)) / ;
         put "imp_cif",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*trdvol(ra,ia,t)) / ;
         put "mtax",      "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (100*trdtax(ra,ia,t)) / ;
   ) ;

*  Special tariffs
$ondotl
   loop((ra,ia,t)$trdval(ra,ia,t),
      work = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t)*xw.l(s,i,r,t))) ;
      work$work = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, M_SPCTAR(s,i,r,t)*pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t)*xw.l(s,i,r,t)))/work ;
      if(work ne 0,
         put "SPCTAR_PCT", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (100*work) / ;
         work = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwm0(s,i,r)*xw0(s,i,r)*xw.l(s,i,r,t))) ;
         work$work = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, M_SPCTAR(s,i,r,t)*pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t)*xw.l(s,i,r,t)))/work ;
         put "SPCTAR", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (work) / ;
      ) ;
   ) ;
$offdotl

   trdval(ra,ia,t) = sum((r,i,aa)$(mapra(ra,r) and mapia(ia,i)),
      (gamma_eda(r,i,aa)*pat.l(r,i,t)*xa.l(r,i,aa,t)*(pat0(r,i)*xa0(r,i,aa)))
      $(ArmSpec(r,i) eq aggArm)
   +  (gamma_edd(r,i,aa)*pdt.l(r,i,t)*xd.l(r,i,aa,t)*(pdt0(r,i)*xd0(r,i,aa))
   +   gamma_edm(r,i,aa)*pmt.l(r,i,t)*xm.l(r,i,aa,t)*(pmt0(r,i)*xm0(r,i,aa)))
      $(ArmSpec(r,i) eq stdArm)) ;

   loop((ra,ia,t)$trdval(ra,ia,t),
      put "Absorb", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*trdval(ra,ia,t)) / ;
   ) ;

   putclose trade ;

) ;

*  Terms of trade
$ontext
file csvtot / "%odir%\ToT.csv" / ;

Parameters
   pfBaU(r,fp,a,t)
   xfBaU(r,fp,a,t)
   pweBaU(s,i,r,t)
   pwmBaU(s,i,r,t)
   xwBaU(s,i,r,t)
   xwmBaU(s,i,r,t)
   lambdawBaU(s,i,r,t)
   lambdaxBaU(s,i,r,t)
;


if(ifTab("ToT"),
   put csvtot ;
   if(%ifAppend%,
      csvtot.ap = 1 ;
      put csvtot ;
   else
      csvtot.ap = 0 ;
      put csvtot ;
      put "Var,Sim,Region,Activity,Factor,Year,Value" / ;
   ) ;
   csvtot.pc = 5 ;
   csvtot.nd = 9 ;

*  Load the baseline

   $$iftheni.BaU "%simtype%" == "RcvDyn"
      execute_load "%odir%/%BaUName%.gdx", pwe0, pwm0, pweBaU=pwe.l, pwmBaU=pwm.l, xwBaU=xw.l, lambdawBaU=lambdaw, lambdaxBaU=lambdax ;
      xwmBaU(s,i,r,t) = lambdawBaU(s,i,r,t)*lambdaxBaU(s,i,r,t)*xwBaU(s,i,r,t) ;
   $$else.BaU
      execute_load "%odir%/%SIMNAME%.gdx", pwe0, pwm0, pweBaU=pwe.l, pwmBaU=pwm.l, xwBaU=xw.l, lambdawBaU=lambdaw, lambdaxBaU=lambdax ;
      xwmBaU(s,i,r,t) = lambdawBaU(s,i,r,t)*lambdaxBaU(s,i,r,t)*xwBaU(s,i,r,t) ;
   $$endif.BaU

   execute_load "%odir%/%SIMNAME%.gdx", pwe, pwm, xw, lambdaw, lambdax ;


   trdval(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwe0(s,i,r)*xw0(s,i,r)*pwe.l(s,i,r,t)*xw.l(s,i,r,t))) ;
   trdvol(ra,ia,t) = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), sum(s, pwe0(s,i,r)*xw0(s,i,r)*pwe.l(s,i,r,t0)*lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw.l(s,i,r,t))) ;


   putclose csvtot ;
) ;
$offtext

*  Final demand

file fdem / "%odir%\fdem.csv" / ;

if(ifTab("fdem"),
   put fdem ;
   if(%ifAppend%,
      fdem.ap = 1 ;
      put fdem ;
   else
      fdem.ap = 0 ;
      put fdem ;
      put "Var,Sim,Region,Commodity,Year,Value" / ;
   ) ;
   fdem.pc = 5 ;
   fdem.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", xs, xs0, ps, ps0, xa, xa0, pat, pat0, pa, pa0,
      xdt0, xmt0, xdt, xmt, pdt0, pdt, pmt, pmt0, xet, xet0, pet, pet0 ;

   loop((ra,ia,t),
      vol = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xs0(r,i)*xs.l(r,i,t)*ps0(r,i)) ;
      if(vol ne 0,
         val = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), ps0(r,i)*ps.l(r,i,t)*xs0(r,i)*xs.l(r,i,t)) ;
         put "PS", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
      ) ;

*     Intermediate demand
      vol = sum((r,i,a)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,a)*xa.l(r,i,a,t)*pa0(r,i,a)) ;
      if(vol ne 0,
         val =  sum((r,i,a)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,a)*xa.l(r,i,a,t)*pa.l(r,i,a,t)*pa0(r,i,a)) ;
         put "XAN",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*vol) / ;
         put "XAN_D", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*val) / ;
         put "PAN",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
      ) ;
      vol = sum((r,i,a)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,a)*xa.l(r,i,a,t)*pat0(r,i)) ;
      if(vol ne 0,
         val =  sum((r,i,a)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,a)*xa.l(r,i,a,t)*pat.l(r,i,t)*pat0(r,i)) ;
         put "PANT",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
      ) ;
      loop(fd$inv(fd),
         vol = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pa0(r,i,fd)) ;
         if(vol ne 0,
            val =  sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pa.l(r,i,fd,t)*pa0(r,i,fd)) ;
            put "XAI",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*vol) / ;
            put "XAI_D", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*val) / ;
            put "PAI",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
         ) ;
         vol = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pat0(r,i)) ;
         if(vol ne 0,
            val =  sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pat.l(r,i,t)*pat0(r,i)) ;
            put "PAIT",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
         ) ;
      ) ;
      loop(fd$h(fd),
         vol = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pa0(r,i,fd)) ;
         if(vol ne 0,
            val =  sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pa.l(r,i,fd,t)*pa0(r,i,fd)) ;
            put "XAC",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*vol) / ;
            put "XAC_D", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*val) / ;
            put "PAC",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
         ) ;
         vol = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pat0(r,i)) ;
         if(vol ne 0,
            val =  sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pat.l(r,i,t)*pat0(r,i)) ;
            put "PACT",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
         ) ;
      ) ;
      loop(fd$gov(fd),
         vol = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pa0(r,i,fd)) ;
         if(vol ne 0,
            val =  sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pa.l(r,i,fd,t)*pa0(r,i,fd)) ;
            put "XAG",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*vol) / ;
            put "XAG_D", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*val) / ;
            put "PAG",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
         ) ;
         vol = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pat0(r,i)) ;
         if(vol ne 0,
            val =  sum((r,i)$(mapra(ra,r) and mapia(ia,i)), xa0(r,i,fd)*xa.l(r,i,fd,t)*pat.l(r,i,t)*pat0(r,i)) ;
            put "PAGT",   "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (val/vol) / ;
         ) ;
      ) ;
*     Armington shares
      vol = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), pdt0(r,i)*xdt0(r,i)*xdt.l(r,i,t)) ;
      val = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), pmt0(r,i)*xmt0(r,i)*xmt.l(r,i,t)) ;
      if(val+vol > 0,
         put "XDT_ASHR", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (100*vol/(vol+val)) / ;
         put "XMT_ASHR", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (100*val/(vol+val)) / ;
      ) ;
      val = sum((r,i)$(mapra(ra,r) and mapia(ia,i)), pet0(r,i)*xet0(r,i)*xet.l(r,i,t)) ;
      if(val+vol > 0,
         put "XDT_XSHR", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (100*vol/(vol+val)) / ;
         put "XET_XSHR", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (100*val/(vol+val)) / ;
      ) ;
   ) ;
   putclose fdem ;
) ;

*  Absorption

file fabs / "%odir%\demand.csv" / ;

if(ifTab("demand"),
   if(%ifAppend%,
      fabs.ap = 1 ;
      put fabs ;
   else
      fabs.ap = 0 ;
      put fabs ;
      put "Var,Sim,Region,Commodity,Agent,Year,Value" / ;
   ) ;
   fabs.pc = 5 ;
   fabs.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", xa, xa0, pa, pa0 ;

   loop((r,i,aa,t)$xa.l(r,i,aa,t),
*     Intermediate demand
      vol = xa0(r,i,aa)*xa.l(r,i,aa,t)*pa0(r,i,aa) ;
      put "XA", "%SIMNAME%", r.tl, i.tl, aa.tl, PUTYEAR(t), (outscale*vol) / ;
      val = xa0(r,i,aa)*xa.l(r,i,aa,t)*pa.l(r,i,aa,t)*pa0(r,i,aa) ;
      put "XA_d", "%SIMNAME%", r.tl, i.tl, aa.tl, PUTYEAR(t), (outscale*val) / ;
      put "PA",   "%SIMNAME%", r.tl, i.tl, aa.tl, PUTYEAR(t), (val/vol) / ;
   ) ;
   putclose fabs ;
) ;

*  Terms of trade

file totf / "%odir%\ToT.csv" / ;

$macro mQEXP(sa,ia,tp,tq) \
   (sum((s,i,d)$(mapia(ia,i) and mapra(sa,s)), pwe0(s,i,d)*xw0(s,i,d)*(pwe.l(s,i,d,tp)/(lambdax(s,i,d,tp)))*lambdax(s,i,d,tq)*xw.l(s,i,d,tq)))
$macro mQIMP(ia,da,tp,tq) \
   (sum((s,i,d)$(mapia(ia,i) and mapra(da,d)), pwm0(s,i,d)*xw0(s,i,d)*(pwm.l(s,i,d,tp)/(lambdaw(s,i,d,tp)*lambdax(s,i,d,tp))) \
   *  lambdaw(s,i,d,tq)*lambdax(s,i,d,tq)*xw.l(s,i,d,tq)))

Parameter
   pexp(ra,ia,t)
   pimp(ra,ia,t)
;

if(ifTab("ToT"),
   put totf ;
   if(%ifAppend%,
      totf.ap = 1 ;
      put totf ;
   else
      totf.ap = 0 ;
      put totf ;
      put "Var,Sim,Region,Commodity,Year,Value" / ;
   ) ;
   totf.pc = 5 ;
   totf.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", xw, pwe, pwm, xw0, pwe0, pwm0, lambdaw, lambdax ;
   pexp(ra,ia,t) = 100 ;
   pimp(ra,ia,t) = 100 ;

   loop((ra,ia,t),

      if(years(t) > baseYear,
         $$iftheni "%simtype%" == "RcvDyn"
            vol = mqexp(ra,ia,t,t-1) ;
            if(vol ne 0,
               pexp(ra,ia,t) = pexp(ra,ia,t-1)
                             * sqrt((vol/mqexp(ra,ia,t-1,t-1))*(mqexp(ra,ia,t,t)/mqexp(ra,ia,t-1,t))) ;
            ) ;
            vol = mqimp(ia,ra,t,t-1) ;
            if(vol ne 0,
               pimp(ra,ia,t) = pimp(ra,ia,t-1)
                             * sqrt((vol/mqimp(ia,ra,t-1,t-1))*(mqimp(ia,ra,t,t)/mqimp(ia,ra,t-1,t))) ;
            ) ;
         $$else
            vol = mqexp(ra,ia,t,t0) ;
            if(vol ne 0,
               val = mqexp(ra,ia,t0,t) ;
               put "EXPq0", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*vol) / ;
               put "EXPp0", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*val) / ;
               pexp(ra,ia,t) = pexp(ra,ia,t0)
                             * sqrt((vol/mqexp(ra,ia,t0,t0))*(mqexp(ra,ia,t,t)/val)) ;
            ) ;
            vol = mqimp(ia,ra,t,t0) ;
            if(vol ne 0,
               val = mqimp(ia,ra,t0,t) ;
               put "IMPq0", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*vol) / ;
               put "IMPp0", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*val) / ;
               pimp(ra,ia,t) = pimp(ra,ia,t0)
                             * sqrt((vol/mqimp(ia,ra,t0,t0))*(mqimp(ia,ra,t,t)/val)) ;
            ) ;
         $$endif
      else
         vol = mqexp(ra,ia,t,t0) ;
         if(vol ne 0,
            val = mqexp(ra,ia,t0,t) ;
            put "EXPq0", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*vol) / ;
            put "EXPp0", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*val) / ;
         ) ;
         vol = mqimp(ia,ra,t,t0) ;
         if(vol ne 0,
            val = mqimp(ia,ra,t0,t) ;
            put "IMPq0", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*vol) / ;
            put "IMPp0", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (outscale*val) / ;
         ) ;
      ) ;

      put "PEXP", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (pexp(ra,ia,t)) / ;
      put "PIMP", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (pimp(ra,ia,t)) / ;
      if(pimp(ra,ia,t) ne 0,
         put "ToT", "%SIMNAME%", ra.tl, ia.tl, PUTYEAR(t), (100*pexp(ra,ia,t)/pimp(ra,ia,t)) / ;
      ) ;

   ) ;

   putclose ToTf ;

) ;

*  Bilateral trade

set a_m / int, cons, cgds, tot / ;
set mapa_m(a_m,aa) ;
mapa_m('int',a) = yes ;
loop(fd$(not sameas(fd, "inv")),
   mapa_m('cons',fd) = yes ;
   mapa_m('cons',fd) = yes ;
) ;
mapa_m('cgds',inv) = yes ;
mapa_m('tot', aa)  = yes ;

file bilat / "%odir%\bilat.csv" / ;

if(ifTab("bilat"),
   put bilat ;
   if(%ifAppend%,
      bilat.ap = 1 ;
      put bilat ;
   else
      bilat.ap = 0 ;
      put bilat ;
      if(MRIO ne 1,
         put "Var,Sim,Source,Commodity,Destination,Year,Value" / ;
      else
         put "Var,Sim,Source,Commodity,Destination,Agent,Year,Value" / ;
      ) ;
   ) ;
   bilat.pc = 5 ;
   bilat.nd = 9 ;

$iftheni "%MRIO_MODULE%" == "ON"

   execute_load "%odir%/%SIMNAME%.gdx", xwa, pwe, pwm, xwa0, pwe0, pwm0, lambdaw, lambdax, mtaxa, pdma, pdma0, xd, xd0, pd, pd0 ;
   execute_load "%odir%/%SIMNAME%.gdx", xw, pwe, pwm, xw0, pwe0, pwm0, lambdaw, lambdax, mtax, ntmAVE, tmarg, emiX, emiTaxX, mtax ;

   loop((s,i,d,aa,t)$(ArmSpec(d,i) eq MRIOArm and trb(t)),
      vol = pwe0(s,i,d)*pwe.l(s,i,d,t0)*xwa.l(s,i,d,aa,t)*xwa0(s,i,d,aa) ;
      if(vol ne 0,
*        Real exports
         put "XWs", "%SIMNAME%", s.tl, i.tl, d.tl, aa.tl, PUTYEAR(t), (outscale*vol) / ;
*        Real imports
         vol = pwm0(s,i,d)*pwm.l(s,i,d,t0)*xwa.l(s,i,d,aa,t)*xwa0(s,i,d,aa) ;
         put "XWd", "%SIMNAME%", s.tl, i.tl, d.tl, aa.tl, PUTYEAR(t), (outscale*vol) / ;
         val = pdma0(s,i,d,aa)*pdma.l(s,i,d,aa,t0)*xwa.l(s,i,d,aa,t)*xwa0(s,i,d,aa) ;
         put "XW_pd", "%SIMNAME%", s.tl, i.tl, d.tl, aa.tl, PUTYEAR(t), (outscale*val) / ;
*        Tariff
         put "MTAX", "%SIMNAME%", s.tl, i.tl, d.tl, aa.tl, PUTYEAR(t), (100*mtaxa.l(s,i,d,aa,t)) / ;
      ) ;
   ) ;

   loop((i,d,aa,t)$(ArmSpec(d,i) eq MRIOArm and trb(t)),
      val = pd0(d,i,aa)*pd.l(d,i,aa,t)*xd0(d,i,aa)*xd.l(d,i,aa,t) ;
      if(val ne 0,
         put "XD_pd", "%SIMNAME%", "DOM", i.tl, d.tl, aa.tl, PUTYEAR(t), (outscale*val) / ;
      ) ;
   ) ;

   loop((s,i,d,t)$(ArmSpec(d,i) ne MRIOArm and trb(t)),
      vol = pwe0(s,i,d)*lambdax(s,i,d,t)*xw.l(s,i,d,t)*xw0(s,i,d) ;
      if(vol ne 0,
*        Real exports
         put "XWs", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (outscale*vol) / ;
*        Average margin
         put "TMARG", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (100*tmarg.l(s,i,d,t)) / ;
*        Nominal exports FOB proces
         put "XWs_d", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (outscale*pwe.l(s,i,d,t)*pwe0(s,i,d)*xw.l(s,i,d,t)*xw0(s,i,d)) / ;
*        Export price index
         put "PWE", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (pwe.l(s,i,d,t)*pwe0(s,i,d)) / ;
*        Import iceberg parameter
         put "lambdaw", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (lambdaw(s,i,d,t)) / ;
*        Export iceberg parameter
         put "lambdax", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (lambdax(s,i,d,t)) / ;
*        Real imports
         put "XWd", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (outscale*pwm0(s,i,d)*lambdaw(s,i,d,t)*lambdax(s,i,d,t)*xw.l(s,i,d,t)*xw0(s,i,d)) / ;
*        Nominal imports
         put "XWd_d", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (outscale*pwm.l(s,i,d,t)*pwm0(s,i,d)*xw.l(s,i,d,t)*xw0(s,i,d)) / ;
*        Import price index
         put "PWM", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (pwm.l(s,i,d,t)*pwm0(s,i,d)) / ;
*        Average tariff
         put "MTAX", "%SIMNAME%", s.tl, i.tl, d.tl, "TOT", PUTYEAR(t), (100*mtax.l(s,i,d,t)) / ;
      ) ;
   ) ;
$ontext
   loop((sa,ia,da,a_m,t)$trb(t),
      vol = sum((s,i,d,aa)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d) and mapa_m(a_m,aa)), pwe0(s,i,d)*pwe.l(s,i,d,t0)*xwa.l(s,i,d,aa,t)*xwa0(s,i,d,aa)) ;
      if(vol ne 0,
*        Real exports
         put "XWs", "%SIMNAME%", sa.tl, ia.tl, da.tl, a_m.tl, PUTYEAR(t), (outscale*vol) / ;
*        Real imports
         vol = sum((s,i,d,aa)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d) and mapa_m(a_m,aa)), pwm0(s,i,d)*pwm.l(s,i,d,t0)*xwa.l(s,i,d,aa,t)*xwa0(s,i,d,aa)) ;
         put "XWd", "%SIMNAME%", sa.tl, ia.tl, da.tl, a_m.tl, PUTYEAR(t), (outscale*vol) / ;
*        Average tariff
*        Use base year weights
         val = sum((s,i,d,aa)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d) and mapa_m(a_m,aa)), mtaxa.l(s,i,d,aa,t)*pwm0(s,i,d)*pwm.l(s,i,d,t0)*xwa.l(s,i,d,aa,t0)*xwa0(s,i,d,aa)) ;
         vol = sum((s,i,d,aa)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d) and mapa_m(a_m,aa)), pwm0(s,i,d)*pwm.l(s,i,d,t0)*xwa.l(s,i,d,aa,t0)*xwa0(s,i,d,aa)) ;
         val$vol = val/vol ;
         if(val <= 100,
            put "MTAX", "%SIMNAME%", sa.tl, ia.tl, da.tl, a_m.tl, PUTYEAR(t), (val) / ;
         ) ;
$offtext
$ontext
*        Delta tariffs
         vol = sum((s,i,d,aa)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d) and mapa_m(a_m,aa)), pwm0(s,i,d)*pwm.l(s,i,d,t0)*xwa.l(s,i,d,aa,t0)*xwa0(s,i,d,aa)) ;
         if(vol <> 0,
            vol = sum((s,i,d,aa)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d) and mapa_m(a_m,aa)), mtaxa.l(s,i,d,aa,t0)*pwm0(s,i,d)*pwm.l(s,i,d,t0)*xwa.l(s,i,d,aa,t0)*xwa0(s,i,d,aa))
                / vol ;
            if(100*abs(vol-val) > 0.01,
               put "MTAXD", "%SIMNAME%", sa.tl, ia.tl, da.tl, a_m.tl, PUTYEAR(t), (val) / ;
               put "MTAXD", "%SIMNAME%", sa.tl, ia.tl, da.tl, a_m.tl, PUTYEAR(t), (val) / ;
            ) ;
         ) ;
$offtext

*     ) ;
*  ) ;

$else

   execute_load "%odir%/%SIMNAME%.gdx", xw, pwe, pwm, xw0, pwe0, pwm0, lambdaw, lambdax, mtax, ntmAVE, tmarg, emiX, emiTaxX, mtax, rq ;
   loop((sa,ia,da,t)$trb(t),
      vol = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), pwe0(s,i,d)*lambdax(s,i,d,t)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
      if(vol ne 0,
*        Real exports
         put "XWs", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (outscale*vol) / ;
*        Average margin
         val = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), tmarg.l(s,i,d,t)*pwe0(s,i,d)*lambdax(s,i,d,t)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
         put "TMARG", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (100*val/vol) / ;
*        Nominal exports FOB proces
         val = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), pwe.l(s,i,d,t)*pwe0(s,i,d)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
         put "XWs_d", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (outscale*val) / ;
*        Export price index
         put "PWE", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (val/vol) / ;
*        Import iceberg parameter
         val = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), lambdaw(s,i,d,t)*pwe0(s,i,d)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
         put "lambdaw", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (val/vol) / ;
*        Export iceberg parameter
         val = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), lambdax(s,i,d,t)*pwe0(s,i,d)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
         put "lambdax", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (val/vol) / ;
*        Real imports
         vol = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), pwm0(s,i,d)*lambdaw(s,i,d,t)*lambdax(s,i,d,t)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
         put "XWd", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (outscale*vol) / ;
*        Nominal imports
         val = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), pwm.l(s,i,d,t)*pwm0(s,i,d)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
         put "XWd_d", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (outscale*val) / ;
*        Import price index
         put "PWM", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (val/vol) / ;
*        Average tariff
         vol = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), mtax.l(s,i,d,t)*pwm.l(s,i,d,t)*pwm0(s,i,d)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
         put "MTAX", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (100*vol/val) / ;
*        Average NTM AVE
         vol = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), ntmAVE.l(s,i,d,t)*pwm.l(s,i,d,t)*pwm0(s,i,d)*xw.l(s,i,d,t)*xw0(s,i,d)) ;
         put "NTMAVE", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (100*vol/val) / ;

$ondotl
         work = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), pwm0(s,i,d)*xw0(s,i,d)*pwm.l(s,i,d,t)*xw.l(s,i,d,t)) ;
         work$work = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)),
            M_SPCTAR(s,i,d,t)*pwm0(s,i,d)*xw0(s,i,d)*pwm.l(s,i,d,t)*xw.l(s,i,d,t))/work ;
         if(work ne 0,
            put "SPCTAR_PCT", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (100*work) / ;
            work = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)), pwm0(s,i,d)*xw0(s,i,d)*xw.l(s,i,d,t)) ;
            work$work = sum((s,i,d)$(mapra(sa,s) and mapia(ia,i) and mapra(da,d)),
               M_SPCTAR(s,i,d,t)*pwm0(s,i,d)*xw0(s,i,d)*pwm.l(s,i,d,t)*xw.l(s,i,d,t))/work ;
            put "SPCTAR", "%SIMNAME%", sa.tl, ia.tl, da.tl, PUTYEAR(t), (work) / ;
         ) ;
$offdotl
      ) ;
   ) ;

$endif
   putclose bilat ;

) ;

file samFile / "%odir%\SAM.csv" / ;
file flabSAM / "samLabels.txt" / ;

if(ifTab("SAM"),

   if(%ifAppend%,
*     Print the labels in a text file
      put flabSAM ;
      flabSAM.pc = 5 ;
      loop(mapOrder(sortOrder,is),
         put is.tl, is.te(is) / ;
      ) ;
      putclose flabSAM ;
   ) ;

   if(%ifAppend%,
      samFile.ap = 1 ;
      put samFile ;
   else
      samFile.ap = 0 ;
      put samFile ;
      put "Sim,Var,Region,RLab,CLab,Year,Value" / ;
   ) ;
   samFile.pc = 5 ;
   samFile.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", sam, NRGBal ;

*  Dump a zero vector--just to make sure all labels are available

   loop((r,is,js,t)$(sameas(r,"%regTgt%") and sameas(is,"bop") and ord(t) eq 1),
      put "%SIMNAME%", "SAM", r.tl, is.tl, js.tl, PUTYEAR(t), (0) / ;
   ) ;

   loop((r,is,js,t)$(sameas(r,"%regTgt%") and sameas(js,"bop") and ord(t) eq 1),
      put "%SIMNAME%", "SAM", r.tl, is.tl, js.tl, PUTYEAR(t), (0) / ;
   ) ;

   loop((r,is,js,t)$sam(r,is,js,t),
      put "%SIMNAME%", "SAM", r.tl, is.tl, js.tl, PUTYEAR(t), (outscale*sam(r,is,js,t)) / ;
   ) ;

   loop((r,is,js,t)$NRGBAL(r,is,js,t),
      put "%SIMNAME%", "NRGBAL", r.tl, is.tl, js.tl, PUTYEAR(t), (outScale*NRGBAL(r,is,js,t)) / ;
   ) ;

   putclose samFile ;
) ;

file MRIOFile / "%odir%\MRIO.csv" / ;

if(ifTab("MRIO"),

   if(%ifAppend%,
      MRIOFile.ap = 1 ;
      put MRIOFile ;
   else
      MRIOFile.ap = 0 ;
      put MRIOFile ;
      put "Sim,Var,Region,Source,RLab,CLab,Year,Value" / ;
   ) ;
   MRIOFile.pc = 5 ;
   MRIOFile.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", sam, gamma_eda, gamma_edd, gamma_edm,
      pdt0, xdt0, pmt0, xmt0, pat0, xa0, pdm0, xw0, xd0, xm0,
$$iftheni "%MRIO_MODULE%" == "ON"
      pdma0, xwa0, pdma, xwa,
$$endif
      pdt, xdt, pmt, xmt, pat, xa, pdm, xw, xd, xm ;

   loop((r,i,aa,t)$(sam(r,i,aa,t) and trm(t) and MRIOC(r,i)),
      if(ArmSpec(r,i) eq AggArm,
         val  = (pdt0(r,i)*xdt0(r,i)*pdt.l(r,i,t)*xdt.l(r,i,t))
              + (pmt0(r,i)*xmt0(r,i)*pmt.l(r,i,t)*xmt.l(r,i,t)) ;
         if(val ne 0,
            work = gamma_eda(r,i,aa)*pat.l(r,i,t)*xa.l(r,i,aa,t)*(pat0(r,i)*xa0(r,i,aa))/val ;
            val = work * (pdt0(r,i)*xdt0(r,i)*pdt.l(r,i,t)*xdt.l(r,i,t)) ;
            put "%SIMNAME%", "MRIO_D", r.tl, "DOM", i.tl, aa.tl, PUTYEAR(t), (outScale*val) / ;
            loop(s,
               val = work * pdm0(s,i,r)*xw0(s,i,r)*pdm.l(s,i,r,t)*xw.l(s,i,r,t) ;
               put "%SIMNAME%", "MRIO_D", r.tl, s.tl, i.tl, aa.tl, PUTYEAR(t), (outScale*val) / ;
            ) ;
         ) ;
      elseif(ArmSpec(r,i) eq stdArm),
         val = gamma_edd(r,i,aa)*pdt.l(r,i,t)*xd.l(r,i,aa,t)*pdt0(r,i)*xd0(r,i,aa) ;
         put "%SIMNAME%", "MRIO_D", r.tl, "DOM", i.tl, aa.tl, PUTYEAR(t), (outScale*val) / ;
         work = sum(s, pdm0(s,i,r)*xw0(s,i,r)*pdm.l(s,i,r,t)*xw.l(s,i,r,t)) ;
         if(work ne 0,
            work = gamma_edm(r,i,aa)*pmt.l(r,i,t)*xm.l(r,i,aa,t)*pmt0(r,i)*xm0(r,i,aa) / work ;
            loop(s,
               val = pdm0(s,i,r)*xw0(s,i,r)*pdm.l(s,i,r,t)*xw.l(s,i,r,t)*work ;
               put "%SIMNAME%", "MRIO_D", r.tl, s.tl, i.tl, aa.tl, PUTYEAR(t), (outScale*val) / ;
            ) ;
         ) ;
$$iftheni "%MRIO_MODULE%" == "ON"
      elseif(ArmSpec(r,i) eq MRIOArm),
         val = gamma_edd(r,i,aa)*pdt.l(r,i,t)*xd.l(r,i,aa,t)*pdt0(r,i)*xd0(r,i,aa) ;
         put "%SIMNAME%", "MRIO_D", r.tl, "DOM", i.tl, aa.tl, PUTYEAR(t), (outScale*val) / ;
         loop(s,
            val = gamma_edm(r,i,aa)*xwa.l(s,i,r,aa,t)*xwa0(s,i,r,aa)*pdma0(s,i,r,aa)*pdma.l(s,i,r,aa,t)
            put "%SIMNAME%", "MRIO_D", r.tl, s.tl, i.tl, aa.tl, PUTYEAR(t), (outScale*val) / ;
         ) ;
$endif
      ) ;
   ) ;
   loop((r,i,t)$(MRIOC(r,i) and trm(t)),
      work = xtt.l(r,i,t)*xtt0(r,i)*pdt.l(r,i,t)*pdt0(r,i) ;
      if(work,
         put "%SIMNAME%", "MRIO_D", r.tl, "DOM", i.tl, "tmg", PUTYEAR(t), (outScale*work) / ;
      ) ;
   ) ;
   putclose MRIOFile ;
) ;

$iftheni.clim "%CLIM_MODULE%" == "ON"

file climFile / "%odir%\Climate.csv" / ;

if(ifTab("Climate"),

   if(%ifAppend%,
      climFile.ap = 1 ;
      put climFile ;
   else
      climFile.ap = 0 ;
      put climFile ;
      put "Sim,Var,Year,Value" / ;
   ) ;
   climFile.pc = 5 ;
   climFile.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", emiCO20, emiCO2,
      EmiGbl0, EmiGbl, EmiOthInd, EmiLand,
      cumEmiInd0, cumEmiInd, CumEmi0, CumEmi, CumEmiLand,
      MAT, FORC, ForcOth, Temp ;

   loop(t,
      put "%SIMNAME%", "EmiCO2",     PUTYEAR(t), (0.001*EmiCO20*EmiCO2.l(t)/cscale) / ;
      put "%SIMNAME%", "EmiGBL",     PUTYEAR(t), (0.001*EmiGbl0("CO2")*EmiGbl.l("CO2",t)/cscale) / ;
      put "%SIMNAME%", "EmiOthInd",  PUTYEAR(t), (0.001*EmiOTHIND.l(t)/cscale) / ;
      put "%SIMNAME%", "EmiLand",    PUTYEAR(t), (0.001*EmiLand.l(t)/cscale) / ;
      put "%SIMNAME%", "CumEmiInd",  PUTYEAR(t), (0.001*(44/12)*CumEmiInd0*CumEmiInd.l(t)/cscale) / ;
      put "%SIMNAME%", "CumEmi",     PUTYEAR(t), (0.001*(44/12)*CumEmi0*CumEmi.l(t)/cscale) / ;
      put "%SIMNAME%", "CUMEmiLand", PUTYEAR(t), (0.001*(44/12)*CUMEmiLand.l(t)/cscale) / ;
      put "%SIMNAME%", "MAT",        PUTYEAR(t), (MAT.l(t)*mat0) / ;
      put "%SIMNAME%", "MAT_PPM",    PUTYEAR(t), (MAT.l(t)*mat0/2.13) / ;
      loop(em$FORC.l(em,t),
         put "%SIMNAME%", "FORC",    PUTYEAR(t), (FORC.l(em,t)) / ;
      ) ;
      put "%SIMNAME%", "FORCOth",    PUTYEAR(t), (forcoth.l(t)) / ;
      loop(tb,
         if(sameas(tb,"ATMOS"),
            put "%SIMNAME%", "TATM", PUTYEAR(t), (temp.l(tb,t)) / ;
         else
            put "%SIMNAME%", "TOCEAN", PUTYEAR(t), (temp.l(tb,t)) / ;
         ) ;
      ) ;
   ) ;

   putclose climFile ;
) ;
$endif.CLIM

*  Shocks

file fshk / "%odir%\Shock.csv" / ;

if(ifTab("shock"),
   put fshk ;
   if(%ifAppend%,
      fshk.ap = 1 ;
      put fshk ;
   else
      fshk.ap = 0 ;
      put "Var,Sim,Exporter,Commodity,Importer,Year,Value" / ;
   ) ;
   fshk.pc = 5 ;
   fshk.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", mtax, lambdaw, lambdax, lambdaio, ntmAVE ;

   loop((s,i,d,t),
      put "lambdaw", "%SIMNAME%", s.tl, i.tl, d.tl, PUTYEAR(t), (100*lambdaw(s,i,d,t) - 100) / ;
      put "lambdax", "%SIMNAME%", s.tl, i.tl, d.tl, PUTYEAR(t), (100*lambdax(s,i,d,t) - 100) / ;
      put "mtax",    "%SIMNAME%", s.tl, i.tl, d.tl, PUTYEAR(t), (100*mtax.l(s,i,d,t)) / ;
      put "ntmAVE",  "%SIMNAME%", s.tl, i.tl, d.tl, PUTYEAR(t), (100*ntmAVE.l(s,i,d,t)) / ;
   ) ;

$ontext
*  !!!! Weight by output
   loop((r,i,a,t)$dmgi(i),
      put "lambdio", "%SIMNAME%", r.tl, i.tl, a.tl, PUTYEAR(t), (100*lambdaio.l(r,i,a,t) - 100) / ;
   ) ;
$offtext

   putclose fshk ;

) ;

*  Labor demand--need to deal with UE

file labcsv / "%odir%\lab.csv" / ;

if(ifTab("lab"),
   put labcsv ;
   if(%ifAppend%,
      labcsv.ap = 1 ;
      put labcsv ;
   else
      labcsv.ap = 0 ;
      put labcsv ;
      put "Var,Sim,Region,Type,Zone,Year,Value" / ;
   ) ;
   labcsv.pc = 5 ;
   labcsv.nd = 9 ;

    execute_load "%odir%/%SIMNAME%.gdx", ls, twage, migr, awagez, ewagez, rwage, reswage, ldz, lsz,
          ls0, twage0, migr0, awagez0, ewagez0, rwage0, reswage0, ldz0, lsz0, pfd, pfd0 ;

   loop((ra,lagg,t),
      vol = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), ls0(r,l)*ls.l(r,l,t)/lScale) ;
      if(vol > 0,
         val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), twage0(r,l)*twage.l(r,l,t)*ls0(r,l)*ls.l(r,l,t)) ;
         put "ls",  "%SIMNAME%", ra.tl, lagg.tl, "Tot", PUTYEAR(t), (vol/lscale) / ;
         put "twage", "%SIMNAME%", ra.tl, lagg.tl, "Tot", PUTYEAR(t), (val/vol) / ;
*        Real wage
         loop(h,
            val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), (twage0(r,l)*twage.l(r,l,t)/(pfd.l(r,h,t)/pfd0(r,h)))*ls0(r,l)*ls.l(r,l,t)) ;
            put "trwage", "%SIMNAME%", ra.tl, lagg.tl, "Tot", PUTYEAR(t), (val/vol) / ;
         ) ;
      ) ;
      vol = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), migr0(r,l)*migr.l(r,l,t)) ;
      if(vol > 0,
         put "migr", "%SIMNAME%", ra.tl, lagg.tl, "Tot", PUTYEAR(t), (vol/lscale) / ;
      ) ;
      loop(z,
         vol = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), lsz0(r,l,z)*lsz.l(r,l,z,t)) ;
         if(vol > 0,
            put "lsz",   "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (vol/lscale) / ;
            val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), ldz0(r,l,z)*ldz.l(r,l,z,t)) ;
            put "ldz", "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (val/lscale) / ;
            put "UEZ_pct", "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (100 - 100*val/vol) / ;
            val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), awagez0(r,l,z)*awagez.l(r,l,z,t)*lsz0(r,l,z)*lsz.l(r,l,z,t)) ;
            put "awage", "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (val/vol) / ;
            val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), ewagez0(r,l,z)*ewagez.l(r,l,z,t)*lsz0(r,l,z)*lsz.l(r,l,z,t)) ;
            put "ewage", "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (val/vol) / ;
            val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), rwage0(r,l,z)*rwage.l(r,l,z,t)*lsz0(r,l,z)*lsz.l(r,l,z,t)) ;
            put "rwage", "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (val/vol) / ;
            val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), reswage0(r,l,z)*reswage.l(r,l,z,t)*lsz0(r,l,z)*lsz.l(r,l,z,t)) ;
            put "reswage", "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (val/vol) / ;
*           Real wages
            loop(h,
               val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), (awagez0(r,l,z)*awagez.l(r,l,z,t)/(pfd.l(r,h,t)/pfd0(r,h)))*lsz0(r,l,z)*lsz.l(r,l,z,t)) ;
               put "arwage", "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (val/vol) / ;
            ) ;
            loop(h,
               val = sum((r,l)$(mapra(ra,r) and maplagg(lagg,l)), (ewagez0(r,l,z)*ewagez.l(r,l,z,t)/(pfd.l(r,h,t)/pfd0(r,h)))*lsz0(r,l,z)*lsz.l(r,l,z,t)) ;
               put "aewage", "%SIMNAME%", ra.tl, lagg.tl, z.tl, PUTYEAR(t), (val/vol) / ;
            ) ;
         ) ;
      ) ;
   ) ;
   putclose labcsv ;
) ;

*  Power supply

file powcsv / "%odir%\power.csv" / ;

if(ifTab("pow"),
   put powcsv ;
   if(%ifAppend%,
      powcsv.ap = 1 ;
      put powcsv ;
   else
      powcsv.ap = 0 ;
      put powcsv ;
      put "Var,Sim,Region,Activity,Input,Year,Value" / ;
   ) ;
   powcsv.pc = 5 ;
   powcsv.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", xp, px, xp0, px0, xa, xa0 ;

   loop((ra,a,t)$elya(a),
      vol = sum(r$mapra(ra,r),xp0(r,a)*xp.l(r,a,t)) ;
      val = sum(r$mapra(ra,r),px0(r,a)*px.l(r,a,t)*xp0(r,a)*xp.l(r,a,t)) ;
      if(vol,
         put "XP", "%SIMNAME%", ra.tl, a.tl, "Tot", PUTYEAR(t), (vol/inscale) / ;
         put "PX", "%SIMNAME%", ra.tl, a.tl, "Tot", PUTYEAR(t), (val/vol) / ;
         put "XP_MTOE", "%SIMNAME%", ra.tl, a.tl, "Tot", PUTYEAR(t), (emat("gWh", "MTOE")*vol/inscale) / ;
         loop(e$fuel(e),
            work = sum(r$mapra(ra,r), xa0(r,e,a)*xa.l(r,e,a,t)) ;
            if(work ne 0,
               put "XA_MTOE", "%SIMNAME%", ra.tl, a.tl, e.tl, PUTYEAR(t), (work/escale) / ;
            ) ;
         ) ;
      ) ;
   ) ;
   putclose powcsv ;
) ;


file nrgcsv / "%odir%\nrg.csv" / ;

$ontext
parameter
   pnrgndx(ra,Agents,eagg,t)
;
pnrgndx(ra,Agents,eagg,t) = 1 ;
$macro M_PNRG(Agents,eAgg,tp,tq) \
   sum(mapra(ra,r), sum(mapAgents(Agents,aa), sum(mapeAgg(eagg,e), pa0(r,e,aa)*xa0(r,e,aa)*pa.l(r,e,aa,tp)*xa.l(r,e,aa,tq))))
$offtext

if(ifTab("nrg"),
   put nrgcsv ;
   if(%ifAppend%,
      nrgcsv.ap = 1 ;
      put nrgcsv ;
   else
      nrgcsv.ap = 0 ;
      put nrgcsv ;
      put "Var,Sim,Region,Source,Unit,Year,Value" / ;
   ) ;
   nrgcsv.pc = 5 ;
   nrgcsv.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", xp, px, xp0, px0, xa, xa0, phiNrg, pa0, pa ;

*  Fuels

   loop((ra,fuel,t),
      vol = sum((r,aa)$mapra(ra,r), phinrg(r,fuel,aa)*xa0(r,fuel,aa)*xa.l(r,fuel,aa,t)) ;
      if(vol,
         put "NRG", "%SIMNAME%", ra.tl, fuel.tl, "MTOE", PUTYEAR(t), (vol/escale) / ;
         val = sum((r,aa)$mapra(ra,r), pa0(r,fuel,aa)*pa.l(r,fuel,aa,t)*phinrg(r,fuel,aa)*xa0(r,fuel,aa)*xa.l(r,fuel,aa,t)) ;
         put "NRG_Price", "%SIMNAME%", ra.tl, fuel.tl, "$/TOE", PUTYEAR(t), ((outscale*val)/(vol/escale)) / ;
         put "NRG", "%SIMNAME%", ra.tl, fuel.tl, "EJ",   PUTYEAR(t), (emat("MTOE", "EJ")*vol/escale) / ;
      ) ;
   ) ;

*  Electricity

   loop((ra,a,t)$primElya(a),
      vol = sum(r$mapra(ra,r), xp0(r,a)*xp.l(r,a,t)) ;
      if(vol,
         put "NRG", "%SIMNAME%", ra.tl, a.tl, "GWhr", PUTYEAR(t), (elyPrmNrgConv*vol/inscale) / ;
         put "NRG", "%SIMNAME%", ra.tl, a.tl, "MTOE", PUTYEAR(t), (elyPrmNrgConv*emat("gWh", "MTOE")*vol/inscale) / ;
         put "NRG", "%SIMNAME%", ra.tl, a.tl, "EJ",   PUTYEAR(t), (elyPrmNrgConv*emat("gWh", "EJ")*vol/inscale) / ;
      ) ;
   ) ;

*  Power

   loop((ra,a,t)$Elya(a),
      vol = sum(r$mapra(ra,r), xp0(r,a)*xp.l(r,a,t)) ;
      if(vol,
         put "POWER", "%SIMNAME%", ra.tl, a.tl, "GWhr", PUTYEAR(t), (vol/inscale) / ;

         val = sum(r$mapra(ra,r), px0(r,a)*px.l(r,a,t)*xp0(r,a)*xp.l(r,a,t)) ;
         put "P_Power", "%SIMNAME%", ra.tl, a.tl, "c/kwh", PUTYEAR(t), (val/vol) / ;
      ) ;
   ) ;

$ontext
   loop(t,
      loop((ra,Agents,eAgg),
         val = sum(mapra(ra,r), sum(mapAgents(Agents,aa), sum(mapeAgg(eagg,e), pa0(r,e,aa)*xa0(r,e,aa)*pa.l(r,e,aa,t)*xa.l(r,e,aa,t)))) ;
         if(val ne 0,
            put "XA_D", "%SIMNAME%", ra.tl, eagg.tl, Agents.tl, PUTYEAR(t), (val/inscale) / ;
            if(years(t) eq years(t0),
               put "XA", "%SIMNAME%", ra.tl, eagg.tl, Agents.tl, PUTYEAR(t), (val/inscale) / ;
               put "PA", "%SIMNAME%", ra.tl, eagg.tl, Agents.tl, PUTYEAR(t), (1) / ;
            else
               $$iftheni "%simType%" == "CompStat"
                  pnrgndx(ra,Agents,eagg,t) = pnrgndx(ra,Agents,eagg,t0)
                         *sqrt((M_PNRG(Agents,eAgg,t,t0)/M_PNRG(Agents,eAgg,t0,t0))*(Val/M_PNRG(Agents,eAgg,t0,t))) ;
                  put "PA", "%SIMNAME%", ra.tl, eagg.tl, Agents.tl, PUTYEAR(t), (pnrgndx(ra,Agents,eagg,t)) / ;
                  put "XA", "%SIMNAME%", ra.tl, eagg.tl, Agents.tl, PUTYEAR(t), ((val/pnrgndx(ra,Agents,eagg,t))/inscale) / ;
               $$else
                  pnrgndx(ra,Agents,eagg,t) = pnrgndx(ra,Agents,eagg,t-1)
                         *sqrt((M_PNRG(Agents,eAgg,t,t-1)/M_PNRG(Agents,eAgg,t-1,t-1))*(Val/M_PNRG(Agents,eAgg,t-1,t))) ;
                  put "PA", "%SIMNAME%", ra.tl, eagg.tl, Agents.tl, PUTYEAR(t), (pnrgndx(ra,Agents,eagg,t)) / ;
                  put "XA", "%SIMNAME%", ra.tl, eagg.tl, Agents.tl, PUTYEAR(t), ((val/pnrgndx(ra,Agents,eagg,t))/inscale) / ;
               $$endif
            ) ;
         ) ;
      ) ;
   ) ;
$offtext

   putclose nrgcsv ;
) ;

$iftheni.AfCFTA "%BASENAME%" == "AfCFTAxxx"
file csvLab / "%odir%\GIDDLab.csv" / ;

Parameter
   q1(l,a,r)
   wage(l,a,r)
;

if(1,
   if(%ifAppend%,
      csvLab.ap = 1 ;
      put csvLab ;
   else
      csvLab.ap = 0 ;
      put csvLab ;
      put "Var,Sim,Region,Lab,Act,Year,Value" / ;
   ) ;
   csvLab.pc = 5 ;
   csvLab.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", q1, wage, pf0, xf0, pf, xf ;

   loop((r,l,a,t),
      put "Val",  "%SIMNAME%", r.tl, l.tl, a.tl, PUTYEAR(t), (OUTSCALE*pf.l(r,l,a,t)*xf.l(r,l,a,t)*pf0(r,l,a)*xf0(r,l,a)) / ;
      put "VolN", "%SIMNAME%", r.tl, l.tl, a.tl, PUTYEAR(t), (OUTSCALE*xf.l(r,l,a,t)*xf0(r,l,a)) / ;
      put "PrcN", "%SIMNAME%", r.tl, l.tl, a.tl, PUTYEAR(t), (pf.l(r,l,a,t)*pf0(r,l,a)) / ;
      put "VolA", "%SIMNAME%", r.tl, l.tl, a.tl, PUTYEAR(t), (q1(l,a,r)*xf.l(r,l,a,t)) / ;
      put "PrcA", "%SIMNAME%", r.tl, l.tl, a.tl, PUTYEAR(t), (wage(l,a,r)*pf.l(r,l,a,t)) / ;
   ) ;
) ;
$endif.AfCFTA


$iftheni.AfCFTA "%BASENAME%" == "AfCFTA"
file csvOLS / "%odir%\OLS.csv" / ;

Parameter
   weight(r,i,t)
;

if(1,
   if(%ifAppend%,
      csvOLS.ap = 1 ;
      put csvOLS ;
   else
      csvOLS.ap = 0 ;
      put csvOLS ;
      put "Var,Sim,Region,Sector,Year,Value" / ;
   ) ;
   csvOLS.pc = 5 ;
   csvOLS.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", px,px0,xp,xp0,pdm,pdm0,xw,xw0,lambdaw,lambdax,
      pdt,pdt0,xdt,xdt0,mtax,ntmave,pwm,pwm0,pwe,pwe0,ptax,p,p0,x,x0 ;

   loop((r,a,t),
      put "XP_D", "%SIMNAME%", r.tl, a.tl:3:3, PUTYEAR(t), (OUTSCALE*(px.l(r,a,t)*xp.l(r,a,t)*px0(r,a)*xp0(r,a)
                           + sum(i, ptax.l(r,a,i,t)*p.l(r,a,i,t)*p0(r,a,i)*x.l(r,a,i,t)*x0(r,a,i)))) / ;
      put "XP",   "%SIMNAME%", r.tl, a.tl:3:3, PUTYEAR(t), (OUTSCALE*px.l(r,a,t0)*xp.l(r,a,t)*px0(r,a)*xp0(r,a)) / ;
   ) ;
   loop((r,i,t),
      put "XM_D", "%SIMNAME%", r.tl, i.tl:3:3, PUTYEAR(t), (OUTSCALE*sum(s,
         pdm0(s,i,r)*xw0(s,i,r)*pdm.l(s,i,r,t)*xw.l(s,i,r,t))) / ;
      put "XD_D", "%SIMNAME%", r.tl, i.tl:3:3, PUTYEAR(t), (OUTSCALE*(pdt0(r,i)*pdt.l(r,i,t)*(xdt0(r,i)*xdt.l(r,i,t)
                                                          - xtt.l(r,i,t)*xtt0(r,i)))) / ;

*     Use fixed volume weights -- this includes both mtax and ntmave

      weight(r,i,t) = sum(s, pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t)*xw.l(s,i,r,t0)) ;
      weight(r,i,t)$weight(r,i,t) = sum(s, pdm0(s,i,r)*xw0(s,i,r)*pdm.l(s,i,r,t)*xw.l(s,i,r,t0))
                                      / weight(r,i,t) - 1 ;
      put "MTAR", "%SIMNAME%", r.tl, i.tl:3, PUTYEAR(t), (100*weight(r,i,t)) / ;

      weight(r,i,t) = sum(s, pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t0)*xw.l(s,i,r,t0)) ;
      weight(r,i,t)$weight(r,i,t) = sum(s, lambdaw(s,i,r,t)*pwm0(s,i,r)*xw0(s,i,r)*pwm.l(s,i,r,t0)*xw.l(s,i,r,t0))
                                      / weight(r,i,t) ;
      put "Lambdaw", "%SIMNAME%", r.tl, i.tl:3:3, PUTYEAR(t), (100*weight(r,i,t)) / ;

      weight(r,i,t) = sum(d, pwe0(r,i,d)*xw0(r,i,d)*pwe.l(r,i,d,t0)*xw.l(r,i,d,t0)) ;
      weight(r,i,t)$weight(r,i,t) = sum(d,lambdax(r,i,d,t)*pwe0(r,i,d)*xw0(r,i,d)*pwe.l(r,i,d,t0)*xw.l(r,i,d,t0))
                                      / weight(r,i,t) ;
      put "Lambdax", "%SIMNAME%", r.tl, i.tl:3:3, PUTYEAR(t), (100*weight(r,i,t)) / ;
   ) ;
) ;
$endif.AfCFTA

*  Welfare decomposition

Parameters
   pBaU(r,a,i,t)        "Reference prices for p"
   xBaU(r,a,i,t)        "Reference volume for x"
   ptaxBaU(r,a,i,t)     "Reference output tax"
   pfTaxBaU(r,fp,a,t)   "Reference factor tax"
   pdtBaU(r,i,t)        "Reference domestic sales price"
   xdBaU(r,i,aa,t)      "Reference domestic sales"
   pdTaxBaU(r,i,aa,t)   "Reference domestic sales tax"
   pmtBaU(r,i,t)        "Reference imported sales price"
   xmBaU(r,i,aa,t)      "Reference imported sales"
   pmTaxBaU(r,i,aa,t)   "Reference imported sales tax"
   pwmBaU(s,i,r,t)      "Reference CIF import prices"
   xwBaU(s,i,r,t)       "Reference bilateral trade flows"
   mtaxBaU(s,i,r,t)     "Reference bilateral tariffs"
   peBaU(r,i,d,t)       "Reference bilateral export prices"
   etaxBaU(r,i,d,t)     "Reference bilateral export taxes"
   pweBaU(r,i,d,t)      "Reference bilateral FOB export prices"
;

execute_load "%odir%/%SIMNAME%.gdx",
   x, x0, p, p0, ptax,
   pf, pf0, xf, xf0, pftax,
   pdt, pdt0, xd, xd0, pdTax, gamma_edd,
   pmt, pmt0, xm, xm0, pmTax, gamma_edm,
   pwm, pwm0, xw, xw0, mtax,
   pe, pe0, etax, pwe, pwe0
;
execute_load "%odir%/%BaUName%.gdx",
   pBaU=p.l, xBaU=x.l, ptaxBaU=ptax.l,
   pfBaU=pf.l, xfBaU=xf.l, pftaxBaU=ptax.l
   pdtBaU=pdt.l, xdBaU=xd.l, pdTaxBaU=pdTax.l,
   pmtBaU=pmt.l, xmBaU=xm.l, pmTaxBaU=pmTax.l,
   pwmBaU=pwm.l, xwBaU=xw.l, mtaxBaU=mtax.l,
   peBaU=pe.l, pweBaU=pwe.l, etaxBaU=etax.l
;

file csvwelf / "%odir%\welfDecomp.csv" / ;

if(ifTab("welfDecomp"),
   put csvwelf ;
   if(%ifAppend%,
      csvwelf.ap = 1 ;
      put csvwelf ;
   else
      csvwelf.ap = 0 ;
      put csvwelf ;
      put "Var,Sim,Region,Commodity,Agent,Year,Value" / ;
   ) ;
   csvwelf.pc = 5 ;
   csvwelf.nd = 10 ;
   loop((r,a,t),
     work = 0.5*sum(i$x0(r,a,i), p0(r,a,i)*(pBaU(r,a,i,t)*ptaxBaU(r,a,i,t) + p.l(r,a,i,t)*ptax.l(r,a,i,t)) * x0(r,a,i)*(x.l(r,a,i,t) - xBaU(r,a,i,t)))/inscale ;
      if(work,
         put "PTAX", "%SIMNAME%", r.tl, "", a.tl, PUTYEAR(t), work / ;
      ) ;
   ) ;
   loop((r,fp,a,t)$xf0(r,fp,a),
      work = outscale*0.5*pf0(r,fp,a)*(pfBaU(r,fp,a,t)*pftaxBaU(r,fp,a,t) + pf.l(r,fp,a,t)*pftax.l(r,fp,a,t)) * xf0(r,fp,a)*(xf.l(r,fp,a,t) - xfBaU(r,fp,a,t)) ;
      if(work,
         put "PFTAX", "%SIMNAME%", r.tl, fp.tl, a.tl, PUTYEAR(t), work / ;
      ) ;
   ) ;
   loop((r,i,aa,t)$xd0(r,i,aa),
      work = outscale*0.5*pdt0(r,i)*(pdtBaU(r,i,t)*gamma_edd(r,i,aa)*pdTaxBaU(r,i,aa,t) + pdt.l(r,i,t)*gamma_edd(r,i,aa)*pdTax.l(r,i,aa,t))
           * xd0(r,i,aa)*(xd.l(r,i,aa,t) - xdBaU(r,i,aa,t)) ;
      if(work,
         put "PDTAX", "%SIMNAME%", r.tl, i.tl, aa.tl, PUTYEAR(t), work / ;
      ) ;
   ) ;
   loop((r,i,aa,t)$xm0(r,i,aa),
      work = outscale*0.5*pmt0(r,i)*(pmtBaU(r,i,t)*gamma_edm(r,i,aa)*pmTaxBaU(r,i,aa,t) + pdt.l(r,i,t)*gamma_edm(r,i,aa)*pmTax.l(r,i,aa,t))
           * xm0(r,i,aa)*(xm.l(r,i,aa,t) - xmBaU(r,i,aa,t)) ;
      if(work,
         put "PMTAX", "%SIMNAME%", r.tl, i.tl, aa.tl, PUTYEAR(t), work / ;
      ) ;
   ) ;
   loop((r,i,s,t)$xw0(s,i,r),
      work = outscale*0.5*pwm0(s,i,r)*(pwmBaU(s,i,r,t)*mtaxBaU(s,i,r,t) + pwm.l(s,i,r,t)*mtax.l(s,i,r,t)) * xw0(s,i,r)*(xw.l(s,i,r,t) - xwBaU(s,i,r,t)) ;
      if(work,
         put "MTAX", "%SIMNAME%", r.tl, i.tl, s.tl, PUTYEAR(t), work / ;
      ) ;
      work = -outscale*0.5*xw0(s,i,r)*(xwBaU(s,i,r,t) + xw.l(s,i,r,t)) * pwm0(s,i,r)*(pwm.l(s,i,r,t) - pwmBaU(s,i,r,t)) ;
      if(work,
         put "ToTM", "%SIMNAME%", r.tl, i.tl, s.tl, PUTYEAR(t), work / ;
      ) ;
   ) ;
   loop((r,i,d,t)$xw0(r,i,d),
      work = outscale*0.5*pe0(r,i,d)*(peBaU(r,i,d,t)*etaxBaU(r,i,d,t) + pe.l(r,i,d,t)*etax.l(r,i,d,t)) * xw0(r,i,d)*(xw.l(r,i,d,t) - xwBaU(r,i,d,t)) ;
      if(work,
         put "ETAX", "%SIMNAME%", r.tl, i.tl, d.tl, PUTYEAR(t), work / ;
      ) ;
      work = outscale*0.5*xw0(r,i,d)*(xwBaU(r,i,d,t) + xw.l(r,i,d,t)) * pwe0(r,i,d)*(pwe.l(r,i,d,t) - pweBaU(r,i,d,t)) ;
      if(work,
         put "ToTE", "%SIMNAME%", r.tl, i.tl, d.tl, PUTYEAR(t), work / ;
      ) ;
   ) ;
) ;
putclose csvwelf ;


$iftheni.FBS "%FBS_MODULE%" == "ON"
file fbscsv / "%odir%\fbs.csv" / ;

set suapc /
    "feed_kg"
    "seed_kg"
    "loss_kg"
    "othu_kg"
    "food_kg"
    "food_kcal"
    "prot_kg"
    "fats_kg"
    "carb_kg"

/ ;

set mapsua(suapc,sua) /
    "feed_kg"     . "Feed_Kt"
    "seed_kg"     . "Seed_Kt"
    "loss_kg"     . "Loss_Kt"
    "othu_kg"     . "Othu_Kt"
    "food_kg"     . "Food_Kt"
    "food_kcal"   . "Food_TC"
    "prot_kg"     . "Prot_Kt"
    "fats_kg"     . "Fats_Kt"
    "carb_kg"     . "Carb_Kt"
/ ;

Parameter
   convFactor(suapc)    "Conversion factor to convert to per capita and per day"
;
convFactor(suapc) = 1 /365 ; convFactor("food_kcal") = 1000 / 365 ;

if(ifTab("FBS"),

   put fbscsv ;
   if(%ifAppend%,
      fbscsv.ap = 1 ;
      put fbscsv ;
   else
      fbscsv.ap = 0 ;
      put fbscsv ;
      put "Var,Sim,Region,Comm,Use,SUA,Source,Year,Value" / ;
   ) ;
   fbscsv.pc = 5 ;
   fbscsv.nd = 10 ;

   execute_load "%odir%/%SIMNAME%.gdx", nutr ;

   loop((ra,ia,ucat,sua,t),
      work = sum(mapra(ra,r), sum(mapia(ia,i), nutr(r,i,ucat,sua,"LCL",t))) ;
      if(work ne 0,
         put "Nutr", "%SimName%", ra.tl, ia.tl, ucat.tl, sua.tl, "LCL", PUTYEAR(t), (work) / ;
*        Convert to per capita
         loop(mapsua(suapc,sua),
            work = popScale*convFactor(suapc)*work / sum(mapra(ra,r), pop0(r)*pop.l(r,t)) ;
            put "Nutr_pc", "%SimName%", ra.tl, ia.tl, ucat.tl, suapc.tl, "LCL", PUTYEAR(t), (work) / ;
         ) ;
      ) ;
   ) ;
   loop((ra,ia,ucat,sua,sa,t),
      work = sum(mapra(ra,r), sum(mapia(ia,i), sum(sameas(s,srcr)$mapra(sa,s), nutr(r,i,ucat,sua,srcr,t)))) ;
      if(work ne 0,
         put "Nutr", "%SimName%", ra.tl, ia.tl, ucat.tl, sua.tl, sa.tl, PUTYEAR(t), (work) / ;
*        Convert to per capita
         loop(mapsua(suapc,sua),
            work = popScale*convFactor(suapc)*work / sum(mapra(ra,r), pop0(r)*pop.l(r,t)) ;
            put "Nutr_pc", "%SimName%", ra.tl, ia.tl, ucat.tl, suapc.tl, sa.tl, PUTYEAR(t), (work) / ;
         ) ;
      ) ;
   ) ;
) ;
$endif.FBS

$iftheni "%DEPL_MODULE%" == "ON"
*  Depletion module

file deplcsv / "%odir%\depl.csv" / ;

parameter
   fuelScale(a)
;

fuelScale(a) = 1 ;
*  !!!! Fixed label
fuelScale("oil-a") = emat("mtoe", "mb") ;
fuelScale("gas-a") = emat("mtoe", "bcm") ;
fuelScale("coa-a") = emat("mtoe", "mt") ;

if(ifTab("depl"),
   put deplcsv ;
   if(%ifAppend%,
      deplcsv.ap = 1 ;
      put deplcsv ;
   else
      deplcsv.ap = 0 ;
      put deplcsv ;
      put "Var,Sim,Region,Activity,Year,Value" / ;
   ) ;
   deplcsv.pc = 5 ;
   deplcsv.nd = 9 ;

   execute_load "%odir%/%SIMNAME%.gdx", ifDepl, ifDsc, prat, ptrend, px, px0, pgdpmp, omegar, omegard, kink,
      dscRate, chidscRate, dscRate0, extRate, chiextRate, omegae,
      cumExt, CumExt0, extr, extr0, res, res0, resp, resp0, ytdres, ytdres0, resGap, xfPot, xfPot0,
      xf, xf0, pf, pf0, xp, xp0 ;

   loop((r,a,t)$ifDepl(r,a),
      put "PRAT",       "%SimName%", r.tl, a.tl, years(t):4:0, (prat.l(r,a,t)) / ;
      put "PTREND",     "%SimName%", r.tl, a.tl, years(t):4:0, (ptrend(r,a,t)) / ;
      if(not t0(t),
         put "PXG", "%SimName%", r.tl, a.tl, years(t):4:0, ((px.l(r,a,t)/pgdpmp.l(r,t))/(px.l(r,a,t-1)/pgdpmp.l(r,t-1))) / ;
      ) ;
      put "KINK",       "%SimName%", r.tl, a.tl, years(t):4:0, (kink) / ;
      put "OMEGAR",     "%SimName%", r.tl, a.tl, years(t):4:0, (omegar.l(r,a,t)) / ;
      put "OMEGAE",     "%SimName%", r.tl, a.tl, years(t):4:0, (omegar.l(r,a,t)) / ;
      put "OMEGARHI",   "%SimName%", r.tl, a.tl, years(t):4:0, (omegard(r,a,"HI",t)) / ;
      put "OMEGARLO",   "%SimName%", r.tl, a.tl, years(t):4:0, (omegard(r,a,"LO",t)) / ;
      put "OMEGARREF",  "%SimName%", r.tl, a.tl, years(t):4:0, (omegard(r,a,"REF",t)) / ;
      put "OMEGARMID",  "%SimName%", r.tl, a.tl, years(t):4:0, (omegard(r,a,"MID",t)) / ;
      put "dscRate",    "%SimName%", r.tl, a.tl, years(t):4:0, (dscRate.l(r,a,t)) / ;
      put "dscRateRef", "%SimName%", r.tl, a.tl, years(t):4:0, (dscRate0(r,a,"REF")) / ;
      put "chidscRate", "%SimName%", r.tl, a.tl, years(t):4:0, (chidscRate.l(r,a,t)) / ;
      put "extRate",    "%SimName%", r.tl, a.tl, years(t):4:0, (extRate.l(r,a,t)) / ;
      put "chiextRate", "%SimName%", r.tl, a.tl, years(t):4:0, (chiextRate.l(r,a,t)) / ;
      put "cumExt",     "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*cumExt.l(r,a,t)*cumExt0(r,a)/rscale) / ;
      put "extr",       "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*extr.l(r,a,t)*extr0(r,a)/rscale) / ;
      put "resGap",     "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*resGap.l(r,a,t)/rscale) / ;

      put "res",        "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*res.l(r,a,t)*res0(r,a)/rscale) / ;
      put "resp",       "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*resp.l(r,a,t)*resp0(r,a)/rscale) / ;
      put "ytdres",     "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*ytdres.l(r,a,t)*ytdres0(r,a)/rscale) / ;
      loop(nrs,
         put "xfNRS",      "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*xf.l(r,nrs,a,t)*xf0(r,nrs,a)/escale) / ;
         put "pfNRS",      "%SimName%", r.tl, a.tl, years(t):4:0, (pf.l(r,nrs,a,t)*pf0(r,nrs,a)) / ;
      ) ;
      put "xp",      "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*xp.l(r,a,t)*xp0(r,a)/escale) / ;
      put "px",      "%SimName%", r.tl, a.tl, years(t):4:0, (px.l(r,a,t)*px0(r,a)) / ;
      loop((pt)$(reserves(r,a)),
         if(sameas(pt,"REF"), put "resREF", "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*reserves(r,a)) / ; ) ;
         if(sameas(pt,"LO"),  put "resLO",  "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*reserves(r,a)) / ; ) ;
         if(sameas(pt,"HI"),  put "resHI",  "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*reserves(r,a)) / ; ) ;
         if(sameas(pt,"MID"), put "resMID", "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*reserves(r,a)) / ; ) ;
      ) ;
      loop((pt)$(reserves(r,a)),
         if(sameas(pt,"REF"), put "ytdREF", "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*ytdreserves(r,a)) / ; ) ;
         if(sameas(pt,"LO"),  put "ytdLO",  "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*ytdreserves(r,a)) / ; ) ;
         if(sameas(pt,"HI"),  put "ytdHI",  "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*ytdreserves(r,a)) / ; ) ;
         if(sameas(pt,"MID"), put "ytdMID", "%SimName%", r.tl, a.tl, years(t):4:0, (fuelscale(a)*ytdreserves(r,a)) / ; ) ;
      ) ;
   ) ;

   putclose deplcsv ;
) ;
$endif

* -------------------------------------------------------------------------------------------------
*
*  Output code for AgMIP cube
*
* -------------------------------------------------------------------------------------------------

$macro M_PX(r_ag,i_ag,tp,tq) (sum((r,a)$(mapag_r(r_ag,r) and mapag_a(i_ag,a)), px0(r,a)*px.l(r,a,tp)*xp0(r,a)*xp.l(r,a,tq)))
$macro M_PE(r_ag,i_ag,tp,tq) (sum((r,i,d)$(mapag_r(r_ag,r) and mapag_i(i_ag,i)), pwe0(r,i,d)*pwe.l(r,i,d,tp)*xw0(r,i,d)*xw.l(r,i,d,tq)))

$iftheni.AgMIP "%AgMIP%" == "Yes"

   $$include "%BaseName%AgMIP.gms"
   $$include "%BaseName%AgMIPWeights.gms"

   file csvagmip / "%odir%\EnvisageAgMIP.csv" / ;
   Parameters
      pxAgg(r_ag,i_ag,t)     "Chained output price index"
      peAgg(r_ag,i_ag,t)     "Chained export price index"
   ;

   if(ifTab("AgMIP"),
      if(%ifAppend%,
         csvagmip.ap = 1 ;
         put csvagmip ;
      else
         csvagmip.ap = 0 ;
         put csvagmip ;
         put "Model,Sim,Region,Var,Qualifier,Year,Unit,Value" / ;
      ) ;
      csvagmip.pc = 5 ;
      csvagmip.nd = 10 ;

*     Population

      execute_load "%odir%/%SIMNAME%.gdx", pop, pop0 ;
      loop((sameas(sim_ag,"%SIMNAME%"),t)$t_ag(t),
         loop(r_ag,
            work = sum(mapag_r(r_ag,r), popWgt(r)*pop.l(r,t)) ;
            if(work,
               put "Envisage", sim_ag.tl, r_ag.tl, "POPT","TOT",t.val:4:0,"Million",work / ;
            ) ;
         ) ;
      ) ;

*     GDP

      execute_load "%odir%/%SIMNAME%.gdx", rgdpmp, rgdpmp0 ;
      loop((sameas(sim_ag,"%SIMNAME%"),t)$t_ag(t),
         loop(r_ag,
*           Convert to billions
            work = sum(mapag_r(r_ag,r), gdpWgt(r)*rgdpmp.l(r,t)) ;
            if(work,
               put "Envisage", sim_ag.tl, r_ag.tl, "GDPT","TOT",t.val:4:0,"Billion",work / ;
            ) ;
         ) ;
      ) ;

*     Agricultural production, production and export prices
*     Use Fischer ideal price index for prices

      execute_load "%odir%/%SIMNAME%.gdx", px, xp, px0, xp0, pwe0, pwe, xw, xw0 ;
*     Replace 100 with appropriate weight
*     Easiest solution is to re-base px0 and xp0
*     xp0(r,a) = px0(r,a)*xp0(r,a) ;
*     px0(r,a) = FAO_Price(r,a) ;
*     xp0(r,a) = xp0(r,a) / px0(r,a) ;
*     And something similar for export prices

      pxAgg(r_ag,i_ag,t0) = (sum((r,a)$(mapag_r(r_ag,r) and mapag_a(i_ag,a)), px0(r,a)*xp0(r,a))/sum((r,a)$(mapag_r(r_ag,r) and mapag_a(i_ag,a)), xp0(r,a)))
                          $M_PX(r_ag,i_ag,t0,t0)
                          + 0
                          $(not M_PX(r_ag,i_ag,t0,t0)) ;
      peAgg(r_ag,i_ag,t0) = (100)$M_PE(r_ag,i_ag,t0,t0)
                          + 0$(not M_PE(r_ag,i_ag,t0,t0)) ;
      loop(t$(not t0(t)),
         pxAgg(r_ag,i_ag,t)$pxAgg(r_ag,i_ag,t-1) = pxAgg(r_ag,i_ag,t-1)
            * sqrt((M_PX(r_ag,i_ag,t,t-1)/M_PX(r_ag,i_ag,t-1,t-1)) * (M_PX(r_ag,i_ag,t,t)/M_PX(r_ag,i_ag,t-1,t))) ;
         peAgg(r_ag,i_ag,t)$peAgg(r_ag,i_ag,t-1) = peAgg(r_ag,i_ag,t-1)
            * sqrt((M_PE(r_ag,i_ag,t,t-1)/M_PE(r_ag,i_ag,t-1,t-1)) * (M_PE(r_ag,i_ag,t,t)/M_PE(r_ag,i_ag,t-1,t))) ;
      ) ;
      loop((sameas(sim_ag,"%SIMNAME%"),t)$t_ag(t),
         loop((r_ag, i_ag),
            work = sum(mapag_r(r_ag,r), sum(a$mapag_a(i_ag,a), prodWgt(r,a)*xp.l(r,a,t))) ;
            if(work,
               put "Envisage", sim_ag.tl, r_ag.tl, "PROD",i_ag.tl,t.val:4:0,"Million",work / ;
            ) ;
            if(pxAgg(r_ag,i_ag,t),
               put "Envisage", sim_ag.tl, r_ag.tl, "XPRP",i_ag.tl,t.val:4:0,"USD/T", pxAgg(r_ag,i_ag,t) / ;
            ) ;
            if(peAgg(r_ag,i_ag,t),
               put "Envisage", sim_ag.tl, r_ag.tl, "XPRX",i_ag.tl,t.val:4:0,"USD/T", peAgg(r_ag,i_ag,t) / ;
            ) ;
         ) ;
      ) ;

*     Calories

      execute_load "%odir%/%SIMNAME%.gdx", nutr ;

      loop((sameas(sim_ag,"%SIMNAME%"),t)$t_ag(t),
         loop((r_ag),
*           Total population
            work = sum(mapag_r(r_ag,r), popWgt(r)*pop.l(r,t)) ;
            if(work,
*              Total calories
               vol = caloWgt * sum(mapag_r(r_ag,r), sum((i,srcr), nutr(r,i,"hhd","FOOD_TC",srcr,t))) ;
               put "Envisage", sim_ag.tl, r_ag.tl, "CALO", "TOT", t.val:4:0, "kcal/cap/d", (vol/work) / ;
            ) ;
         ) ;
      ) ;

      putclose csvagmip ;
   ) ;
$endif.AgMIP
