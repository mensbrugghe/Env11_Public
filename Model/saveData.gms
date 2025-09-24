parameters

*  From the standard database

   VDFBS(i, a, r)       "Firm purchases of domestic goods at basic prices"
   VDFPS(i, a, r)       "Firm purchases of domestic goods at purchaser prices"
   VMFBS(i, a, r)       "Firm purchases of imported goods at basic prices"
   VMFPS(i, a, r)       "Firm purchases of domestic goods at purchaser prices"
   VDPBS(i, r)          "Private purchases of domestic goods at basic prices"
   VDPPS(i, r)          "Private purchases of domestic goods at purchaser prices"
   VMPBS(i, r)          "Private purchases of imported goods at basic prices"
   VMPPS(i, r)          "Private purchases of domestic goods at purchaser prices"
   VDGBS(i, r)          "Government purchases of domestic goods at basic prices"
   VDGPS(i, r)          "Government purchases of domestic goods at purchaser prices"
   VMGBS(i, r)          "Government purchases of imported goods at basic prices"
   VMGPS(i, r)          "Government purchases of domestic goods at purchaser prices"
   VDIBS(i, r)          "Investment purchases of domestic goods at basic prices"
   VDIPS(i, r)          "Investment purchases of domestic goods at purchaser prices"
   VMIBS(i, r)          "Investment purchases of imported goods at basic prices"
   VMIPS(i, r)          "Investment purchases of domestic goods at purchaser prices"

   EVFBS(fp, a, r)      "Primary factor purchases at basic prices"
   EVFPS(fp, a, r)      "Primary factor purchases at purchaser prices"
   EVOSS(fp, a, r)      "Factor remuneration after income tax"

   VXSBS(i, r, r)       "Exports at basic prices"
   VFOBS(i, r, r)       "Exports at FOB prices"
   VCIFS(i, r, r)       "Import at CIF prices"
   VMSBS(i, r, r)       "Imports at basic prices"

   VSTS(i, r)           "Exports of trade and transport services"
   VTWRS(j, i, r, r)    "Margins by margin commodity"

   SAVES(r)             "Net saving, by region"
   VDEPS(r)             "Capital depreciation"
   VKBS(r)              "Capital stock"
   POPS(r)              "GTAP population"

   MAKSS(i, a ,r)       "Make matrix at supply prices"
   MAKBS(i, a, r)       "Make matrix at basic prices (incl taxes)"
   PTAXS(i, a, r)       "Output taxes"

$ontext
   VNTMS(i, r, rp)      "Non-tariff measures revenue"

   remit00S(l,r,rp)     "Initial remittances"
   yqtf0S(r)            "Initial outflow of capital income"
   yqht0S(r)            "Initial inflow of capital income"

   voaS(a,r)            "Value of output"
   voaS(a,r)            "Value of output"
   osep0S(a,r)          "Value of output subsidies"
   osepS(a,r)           "Value of output subsidies"
   cmatS(i,k,r)         "Consumer transition matrix"

   emplS(l,a,r)         "Employment levels"

*  Water data

   h2ocrpS(a,r)         "Water withdrawal in crop activities"
   h2oUseS(wbnd,r)      "Water withdrawal by aggregate uses"

*  Energy matrices

   nrgdfS(i, a, r)     "Usage of domestic products by firm, MTOE"
   nrgmfS(i, a, r)     "Usage of imported products by firm, MTOE"
   nrgdpS(i, r)         "Private usage of domestic products, MTOE"
   nrgmpS(i, r)         "Private usage of imported products, MTOE"
   nrgdgS(i, r)         "Government usage of domestic products, MTOE"
   nrgmgS(i, r)         "Government usage of imported products, MTOE"
   nrgdiS(i, r)         "Investment usage of domestic products, MTOE"
   nrgmiS(i, r)         "Investment usage of imported products, MTOE"
   exiS(i, r, rp)       "Bilateral trade in energy"

   nrgCombS(i, a, r)   "Energy combustion matrix"

   gwhr0S(a,r)          "Electricity output in gwhr"
   gwhrS(r,a)            "Electricity output in gwhr"

*  Carbon emission matrices

   mdfS(i, a, r)       "Emissions from domestic product in current production, .."
   mmfS(i, a, r)       "Emissions from imported product in current production, .."
   mdpS(i, r)           "Emissions from private consumption of domestic product, Mt CO2"
   mmpS(i, r)           "Emissions from private consumption of imported product, Mt CO2"
   mdgS(i, r)           "Emissions from govt consumption of domestic product, Mt CO2"
   mmgS(i, r)           "Emissions from govt consumption of imported product, Mt CO2"
   mdiS(i, r)           "Emissions from invt consumption of domestic product, Mt CO2"
   mmiS(i, r)           "Emissions from invt consumption of imported product, Mt CO2"

*  Combustion-based emission matrices

   EMI_IOS(em, i, a, r)      "IO-based emissions"
   EMI_IOPS(em, i, a, r)     "IO-based processed emissions"
   EMI_endwS(em, fp, a, r)    "Endowment-based emissions"
   EMI_qoS(em, a, r)          "Output-based emissions"
   EMI_hhS(em, i, r)          "Private consumption-based emissions"
;

execute_load "%BASENAME%Dat.gdx"
   vdfb, vdfp, vmfb, vmfp,
   vdpb, vdpp, vmpb, vmpp,
   vdgb, vdgp, vmgb, vmgp,
   vdib, vdip, vmib, vmip,
   evfb, evfp, evos,
   vxsb, vfob, vcif, vmsb,
   vst, vtwr,
   save, vdep, vkb, popg=pop,
*  ptax,
   maks, makb
;
$offtext
;

$ondotl

loop(t$tsave(t),

   VDFBS(i,a,r) = outScale*gamma_edd(r,i,a)*pdt0(r,i)*pdt(r,i,t)*xd0(r,i,a)*xd(r,i,a,t) ;
   VDFPS(i,a,r) = outScale*pd0(r,i,a)*pd(r,i,a,t)*xd0(r,i,a)*xd(r,i,a,t) ;
   VMFBS(i,a,r) = outScale*gamma_edm(r,i,a)*pmt0(r,i)*pmt(r,i,t)*xm0(r,i,a)*xm(r,i,a,t) ;
   VMFPS(i,a,r) = outScale*pm0(r,i,a)*pm(r,i,a,t)*xm0(r,i,a)*xm(r,i,a,t) ;

   VDPBS(i,r) = outScale*sum(h, gamma_edd(r,i,h)*pdt0(r,i)*pdt(r,i,t)*xd0(r,i,h)*xd(r,i,h,t)) ;
   VDPPS(i,r) = outScale*sum(h, pd0(r,i,h)*pd(r,i,h,t)*xd0(r,i,h)*xd(r,i,h,t)) ;
   VMPBS(i,r) = outScale*sum(h, gamma_edm(r,i,h)*pmt0(r,i)*pmt(r,i,t)*xm0(r,i,h)*xm(r,i,h,t)) ;
   VMPPS(i,r) = outScale*sum(h, pm0(r,i,h)*pm(r,i,h,t)*xm0(r,i,h)*xm(r,i,h,t)) ;

   VDGBS(i,r) = outScale*gamma_edd(r,i,gov)*pdt0(r,i)*pdt(r,i,t)*xd0(r,i,gov)*xd(r,i,gov,t) ;
   VDGPS(i,r) = outScale*pd0(r,i,gov)*pd(r,i,gov,t)*xd0(r,i,gov)*xd(r,i,gov,t) ;
   VMGBS(i,r) = outScale*gamma_edm(r,i,gov)*pmt0(r,i)*pmt(r,i,t)*xm0(r,i,gov)*xm(r,i,gov,t) ;
   VMGPS(i,r) = outScale*pm0(r,i,gov)*pm(r,i,gov,t)*xm0(r,i,gov)*xm(r,i,gov,t) ;

   VDIBS(i,r) = outScale*gamma_edd(r,i,inv)*pdt0(r,i)*pdt(r,i,t)*xd0(r,i,inv)*xd(r,i,inv,t) ;
   VDIPS(i,r) = outScale*pd0(r,i,inv)*pd(r,i,inv,t)*xd0(r,i,inv)*xd(r,i,inv,t) ;
   VMIBS(i,r) = outScale*gamma_edm(r,i,inv)*pmt0(r,i)*pmt(r,i,t)*xm0(r,i,inv)*xm(r,i,inv,t) ;
   VMIPS(i,r) = outScale*pm0(r,i,inv)*pm(r,i,inv,t)*xm0(r,i,inv)*xm(r,i,inv,t) ;

   EVFBS(fp,a,r) = outScale*pf(r,fp,a,t)*xf(r,fp,a,t)*(pf0(r,fp,a)*xf0(r,fp,a)) ;
   EVFPS(fp,a,r) = outScale*pfp(r,fp,a,t)*xf(r,fp,a,t)*(pfp0(r,fp,a)*xf0(r,fp,a)) ;
   EVOSS(fp,a,r) = outScale*(1-kappaf(r,fp,a,t))*pf(r,fp,a,t)*xf(r,fp,a,t)*(pf0(r,fp,a)*xf0(r,fp,a)) ;

   VXSBS(i,s,d) = outScale*pe(s,i,d,t)*xw(s,i,d,t)*(pe0(s,i,d)*xw0(s,i,d)) ;
   VFOBS(i,s,d) = outScale*pwe(s,i,d,t)*xw(s,i,d,t)*(pwe0(s,i,d)*xw0(s,i,d)) ;
   VCIFS(i,s,d) = outScale*pwm(s,i,d,t)*xw(s,i,d,t)*(pwm0(s,i,d)*xw0(s,i,d)) ;
   VMSBS(i,s,d) = outScale*pdm(s,i,d,t)*xw(s,i,d,t)*(pdm0(s,i,d)*xw0(s,i,d)) ;

   VSTS(i,r)      = outScale*pdt(r,i,t)*xtt(r,i,t)*pdt0(r,i)*xtt0(r,i) ;
   VTWRS(img,i,s,d) = outScale*ptmg(img,t)*xwmg(s,i,d,t)*ptmg0(img)*xwmg0(s,i,d) ;

   SAVES(r) = outScale*sum(h, savh0(r,h)*savh(r,h,t)) + savg(r,t) ;
   VDEPS(r) = outScale*deprY0(r)*deprY(r,t) ;
   VKBS(r)  = outScale*sum(fp$cap(fp), sum(a, pf(r,fp,a,t)*xf(r,fp,a,t)*(pf0(r,fp,a)*xf0(r,fp,a)))) / chiKaps0(r) ;
   POPS(r)  = pop0(r)*pop(r,t)/popScale ;

   MAKSS(i,a,r) = outScale*p(r,a,i,t)*x(r,a,i,t)*p0(r,a,i)*x0(r,a,i) ;
   MAKBS(i,a,r) = outScale*pp(r,a,i,t)*x(r,a,i,t)*pp0(r,a,i)*x0(r,a,i) ;
   PTAXS(i,a,r) = MAKBS(i,a,r) - MAKSS(i,a,r) ;

   put screen ;
   put_utility 'gdxOut' /  '%BaseName%':0 '%SimName%':0 t.tl:0 'Dat.gdx':0 ;

   execute_unload
      VDFBS=VDFB, VDFPS=VDFP, VMFBS=VMFB, VMFPS=VMFP,
      VDPBS=VDPB, VDPPS=VDPP, VMPBS=VMPB, VMPPS=VMPP,
      VDGBS=VDGB, VDGPS=VDGP, VMPBS=VMPB, VMPPS=VMPP,
      VDIBS=VDIB, VDIPS=VDIP, VMPBS=VMPB, VMPPS=VMPP,
      EVFBS=EVFB, EVFPS=EVFP, EVOSS=EVOS,
      VXSBS=VXSB, VFOBS=VFOB, VCIFS=VCIF, VMSBS=VMSB,
      VSTS=VST, VTWRS=VTWR,
      SAVES=SAVE, VDEPS=VDEP, VKBS=VKB, POPS=POP,
      MAKSS=MAKS, MAKBS=MAKB, PTAXS=PTAX
   ;
) ;
