*  Note this file assumes explicitly that the intial and final
*  activities and commodites are as in the original data file

parameters
   VDFBF(i, a, r)       "Firm purchases of domestic goods at basic prices"
   VDFPF(i, a, r)       "Firm purchases of domestic goods at purchaser prices"
   VMFBF(i, a, r)       "Firm purchases of imported goods at basic prices"
   VMFPF(i, a, r)       "Firm purchases of domestic goods at purchaser prices"
   VDPBF(i, r)          "Private purchases of domestic goods at basic prices"
   VDPPF(i, r)          "Private purchases of domestic goods at purchaser prices"
   VMPBF(i, r)          "Private purchases of imported goods at basic prices"
   VMPPF(i, r)          "Private purchases of domestic goods at purchaser prices"
   VDGBF(i, r)          "Government purchases of domestic goods at basic prices"
   VDGPF(i, r)          "Government purchases of domestic goods at purchaser prices"
   VMGBF(i, r)          "Government purchases of imported goods at basic prices"
   VMGPF(i, r)          "Government purchases of domestic goods at purchaser prices"
   VDIBF(i, r)          "Investment purchases of domestic goods at basic prices"
   VDIPF(i, r)          "Investment purchases of domestic goods at purchaser prices"
   VMIBF(i, r)          "Investment purchases of imported goods at basic prices"
   VMIPF(i, r)          "Investment purchases of domestic goods at purchaser prices"

   EVFBF(fp, a, r)      "Primary factor purchases at basic prices"
   EVFPF(fp, a, r)      "Primary factor purchases at purchaser prices"
   EVOSF(fp, a, r)      "Factor remuneration after income tax"

   VXSBF(i, r, rp)      "Exports at basic prices"
   VFOBF(i, r, rp)      "Exports at FOB prices"
   VCIFF(i, r, rp)      "Import at CIF prices"
   VMSBF(i, r, rp)      "Imports at basic prices"

   VSTF(i, r)           "Exports of trade and transport services"
   VTWRF(i, j, r, rp)   "Margins by margin commodity"

   SAVEF(r)             "Net saving, by region"
   VDEPF(r)             "Capital depreciation"
   VKBF(r)              "Capital stock"
   POPF(r)              "Population"

   MAKSF(i,a,r)         "Make matrix at supply prices"
   MAKBF(i,a,r)         "Make matrix at basic prices (incl taxes)"
   PTAXF(i,a,r)         "Output taxes"

   TVOAF(a,r)           "Output excl. taxes"
   TVOSF(i,r)           "Value of domestic supply incl. production taxes"
;

scalar reScale ; reScale = 1/inScale ;

loop(t$sameas(t,"%1"),

*  Production matrices

   VDFBF(i,a,r) = rescale*(pd0(r,i)*xd0(r,i,a)*pd.l(r,i,t)*xd.l(r,i,a,t)) ;
   VDFPF(i,a,r) = rescale*(pdp0(r,i,a)*xd0(r,i,a)*pdp.l(r,i,a,t)*xd.l(r,i,a,t)) ;
   VMFBF(i,a,r) = rescale*(((pmt0(r,i)*pmt.l(r,i,t))$(not MRIO) + (pma0(r,i,a)*pma.l(r,i,a,t))$MRIO)
                 *   xm0(r,i,a)*xm.l(r,i,a,t)) ;
   VMFPF(i,a,r)  = rescale*(pmp0(r,i,a)*xm0(r,i,a)*pmp.l(r,i,a,t)*xm.l(r,i,a,t)) ;
   EVFBF(fp,a,r) = rescale*(pf0(r,fp,a)*xf0(r,fp,a)*pf.l(r,fp,a,t)*xf.l(r,fp,a,t)) ;
   EVFPF(fp,a,r) = rescale*(pfa0(r,fp,a)*xf0(r,fp,a)*pfa.l(r,fp,a,t)*xf.l(r,fp,a,t)) ;

*  Income distribution

   EVOSF(fp,a,r) = rescale*((1-kappaf.l(r,fp,a,t))*pf0(r,fp,a)*xf0(r,fp,a)*pf.l(r,fp,a,t)*xf.l(r,fp,a,t)) ;

*  Final demand

   loop(h,
      VDPBF(i,r) = reScale*(pd0(r,i)*xd0(r,i,h)*pd.l(r,i,t)*xd.l(r,i,h,t)) ;
      VDPPF(i,r) = reScale*(pdp0(r,i,h)*xd0(r,i,h)*pdp.l(r,i,h,t)*xd.l(r,i,h,t)) ;
      VMPBF(i,r) = reScale*
         (((pmt0(r,i)*pmt.l(r,i,t))$(not MRIO) + (pma0(r,i,h)*pma.l(r,i,h,t))$MRIO)*xm0(r,i,h)*xm.l(r,i,h,t)) ;
      VMPPF(i,r) = reScale*(pmp0(r,i,h)*xm0(r,i,h)*pmp.l(r,i,h,t)*xm.l(r,i,h,t)) ;
   ) ;

   loop(gov,
      VDGBF(i,r) = reScale*(pd0(r,i)*xd0(r,i,gov)*pd.l(r,i,t)*xd.l(r,i,gov,t)) ;
      VDGPF(i,r) = reScale*(pdp0(r,i,gov)*xd0(r,i,gov)*pdp.l(r,i,gov,t)*xd.l(r,i,gov,t)) ;
      VMGBF(i,r) = reScale*
         (((pmt0(r,i)*pmt.l(r,i,t))$(not MRIO) + (pma0(r,i,gov)*pma.l(r,i,gov,t))$MRIO)*xm0(r,i,gov)*xm.l(r,i,gov,t)) ;
      VMGPF(i,r) = reScale*(pmp0(r,i,gov)*xm0(r,i,gov)*pmp.l(r,i,gov,t)*xm.l(r,i,gov,t)) ;
   ) ;

   loop(inv,
      VDIBF(i,r) = reScale*(pd0(r,i)*xd0(r,i,inv)*pd.l(r,i,t)*xd.l(r,i,inv,t)) ;
      VDIPF(i,r) = reScale*(pdp0(r,i,inv)*xd0(r,i,inv)*pdp.l(r,i,inv,t)*xd.l(r,i,inv,t)) ;
      VMIBF(i,r) = reScale*
         (((pmt0(r,i)*pmt.l(r,i,t))$(not MRIO) + (pma0(r,i,inv)*pma.l(r,i,inv,t))$MRIO)*xm0(r,i,inv)*xm.l(r,i,inv,t)) ;
      VMIPF(i,r) = reScale*(pmp0(r,i,inv)*xm0(r,i,inv)*pmp.l(r,i,inv,t)*xm.l(r,i,inv,t)) ;
   ) ;

*  Bilateral trade

   VXSBF(i,s,d) = reScale*(pe0(s,i,d)*xw0(s,i,d)*pe.l(s,i,d,t)*xw.l(s,i,d,t)) ;
   VFOBF(i,s,d) = reScale*(pefob0(s,i,d)*xw0(s,i,d)*pefob.l(s,i,d,t)*xw.l(s,i,d,t)) ;
   VCIFF(i,s,d) = reScale*(pmcif0(s,i,d)*xw0(s,i,d)*pmcif.l(s,i,d,t)*xw.l(s,i,d,t)) ;
   VMSBF(i,s,d) = reScale*((pm0(s,i,d)*xw0(s,i,d)*pm.l(s,i,d,t)*xw.l(s,i,d,t))$(not MRIO)
                +          sum(aa, pdma0(s,i,d,aa)*pdma.l(s,i,d,aa,t)
                *              xwa0(s,i,d,aa)*xwa.l(s,i,d,aa,t))$MRIO) ;

*  Margin exports

   loop(tmg,
      vstf(m,r) = reScale*((pa0(r,m,tmg)*xa0(r,m,tmg)*pa.l(r,m,tmg,t)*xa.l(r,m,tmg,t))) ;
   ) ;

*  Bilateral margins

   VTWRF(m, i, s, d) = reScale*(ptmg0(m)*xmgm0(m,s,i,d)*ptmg.l(m,t)*xmgm.l(m,s,i,d,t)) ;

   vkbf(r)  = reScale*kstock0(r)*kstock.l(r,t) ;
   savef(r) = reScale*rsav0(r)*rsav.l(r,t) ;
   popf(r)  = pop.l(r,t) ;
   vdepf(r) = rescale*fdepr(r,t)*pi0(r)*kstock0(r)*pi.l(r,t)*kstock.l(r,t) ;

*  MAKE Matrices
   MAKSF(i,a,r) = reScale*(p0(r,a,i)*x0(r,a,i)*p.l(r,a,i,t)*x.l(r,a,i,t)) ;
   MAKBF(i,a,r) = reScale*((1+prdtx.l(r,a,i,t))*p0(r,a,i)*x0(r,a,i)*p.l(r,a,i,t)*x.l(r,a,i,t)) ;
   PTAXF(i,a,r) = MAKBF(i,a,r) - MAKSF(i,a,r) ;
) ;

TVOAF(a,r) = sum(i, VDFPF(i,a,r) + VMFPF(i,a,r)) + sum(fp, EVFPF(fp,a,r)) ;
TVOSF(i,r) = sum(a, VDFBF(i,a,r)) + VDPBF(i,r) + VDGBF(i,r) + VDIBF(i,r) + VSTF(i,r)
           + sum(d, VXSBF(i,r,d)) ;
           
*  Transfer the mapping data

Sets
   reg0     "GTAP regions"
   acts0    "GTAP activities"
   comm0    "GTAP commodities"
   endw0    "GTAP endowments"
   reg1     "Primary aggregation regions"
   acts1    "Primary aggregation activities"
   comm1    "Primary aggregation commodities"
   endw1    "Primary aggregation endowments"
   
   mapr0(reg1,reg0)
   mapr1(r,reg1)
   mapa0(acts1,acts0)
   mapa1(a,acts1)
   mapi0(comm1,comm0)
   mapi1(i,comm1)
   mapf0(endw1,endw0)
   mapf1(fp,endw1)   
;

$gdxIn "%inDir%/%BaseName%Dat.gdx"
$load reg0, acts0, comm0, endw0
$load reg1, acts1, comm1, endw1
$loaddc mapr0, mapa0, mapi0, mapf0
$loaddc mapr1, mapa1, mapi1, mapf1

execute_unload "%oDir%/%BaseName%Dat.gdx",
   metaData,
   ACTS, i=COMM, MARG, r=REG, fp=ENDW,
   fnm=ENDWF, ENDWM, ENDWS,
   l=LAB, CAP, LND, NRS,
   reg0, acts0, comm0, endw0,
   reg1, acts1, comm1, endw1,
   mapr0, mapa0, mapi0, mapf0,
   mapr1, mapa1, mapi1, mapf1,
   VDFBF=VDFB, VDFPF=VDFP, VMFBF=VMFB, VMFPF=VMFP,
   VDPBF=VDPB, VDPPF=VDPP, VMPBF=VMPB, VMPPF=VMPP,
   VDGBF=VDGB, VDGPF=VDGP, VMGBF=VMGB, VMGPF=VMGP,
   VDIBF=VDIB, VDIPF=VDIP, VMIBF=VMIB, VMIPF=VMIP,
   EVFBF=EVFB, EVFPF=EVFP, EVOSF=EVOS,
   VXSBF=VXSB, VFOBF=VFOB, VCIFF=VCIF, VMSBF=VMSB,
   VSTF=VST,   VTWRF=VTWR,
   SAVEF=SAVE, VDEPF=VDEP, VKBF=VKB,   POPF=POP,
   MAKSF=MAKS, MAKBF=MAKB, PTAXF=PTAX,
   TVOAF=VOA, TVOSF=VOS
;

*  26-Sep-2018
*
*  Introduction of NTMs
*

Parameter
   VNTM(i, r, rp)
;

loop(t$sameas(t,"%1"),
   VNTM(i, s, d) = reScale*(ntmAVE.l(s,i,d,t)*pmcif0(s,i,d)*xw0(s,i,d)*pmcif.l(s,i,d,t)*xw.l(s,i,d,t)) ;
) ;

if(NTMFlag,
   execute_unload "%oDir%/%BaseName%NTM.gdx", VNTM ;
) ;

* --------------------------------------------------------------------------------------------------
*
*  MRIO data
*
* --------------------------------------------------------------------------------------------------

Parameters
   VIUWSF(i, amrio,s,d)      "Bilateral imports by broad agent at border prices"
   VIUMSF(i, amrio,s,d)      "Bilateral imports by broad agent at post-tariff prices"
;

if(MRIO,
   loop(t$sameas(t,"%1"),
      VIUWSF(i, "INT", s, d)
         = rescale*sum(a, pmcif0(s,i,d)*xwa0(s,i,d,a)*pmcif.l(s,i,d,t)*xwa.l(s,i,d,a,t)) ;
      VIUMSF(i, "INT", s, d)
         = rescale*sum(a, pdma0(s,i,d,a)*xwa0(s,i,d,a)*pdma.l(s,i,d,a,t)*xwa.l(s,i,d,a,t)) ;
      VIUWSF(i, "CONS", s, d)
         = rescale*sum(fd$(h(fd) or gov(fd)),
               pmcif0(s,i,d)*xwa0(s,i,d,fd)*pmcif.l(s,i,d,t)*xwa.l(s,i,d,fd,t)) ;
      VIUMSF(i, "CONS", s, d)
         = rescale*sum(fd$(h(fd) or gov(fd)),
               pdma0(s,i,d,fd)*xwa0(s,i,d,fd)*pdma.l(s,i,d,fd,t)*xwa.l(s,i,d,fd,t)) ;
      VIUWSF(i, "CGDS", s, d)
         = rescale*sum(fd$inv(fd),
               pmcif0(s,i,d)*xwa0(s,i,d,fd)*pmcif.l(s,i,d,t)*xwa.l(s,i,d,fd,t)) ;
      VIUMSF(i, "CGDS", s, d)
         = rescale*sum(fd$inv(fd),
               pdma0(s,i,d,fd)*xwa0(s,i,d,fd)*pdma.l(s,i,d,fd,t)*xwa.l(s,i,d,fd,t)) ;
   ) ;

   execute_unload "%oDir%/%BaseName%MRIO.gdx", VIUMSF=VIUMS, VIUWSF=VIUWS ;
) ;