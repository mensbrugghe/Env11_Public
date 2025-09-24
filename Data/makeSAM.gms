Sets
   i0    "Read in commodities"
   a0    "Read in activities"
   fp0   "Read in production factors"
   r0    "Read in regions"
;

$gdxIn %inDir%\%BaseName%Dat.gdx
$load i0=comm, a0=acts, fp0=endw, r0=reg

Sets
   is    "SAM accounts" /
            set.a0
            set.i0
            set.fp0
            regY        "Regional household"
            hhd         "Households"
            gov         "Government"
            r_d         "Research & development"
            inv         "Investment"
            deprY       "Depreciation"
            tmg         "Intl. trade & transport services"
            itax        "Indirect taxes"
            ptax        "Production taxes"
            mtax        "Import taxes"
            etax        "Export taxes"
            vtax        "Factor taxes"
            ltax        "Labor taxes"
            ktax        "Capital taxes"
            rtax        "Resource taxes"
            vsub        "Factor subsidies"
            wtax        "Water taxes"
            dtax        "Direct taxes"
            ctax        "Carbon taxes"
            ntmY        "NTM revenues"
            TRD         "Aggregate trade account"
            set.r0
            BoP         "Balance of payments"
            Tot         "Total"
      /
      a(is)             "Activities"         / set.a0 /
      i(is)             "Commodities"        / set.i0 /
      fp(is)            "Production factors" / set.fp0 /
      r(is)             "Regions"            / set.r0 /
;
   
alias(r,s) ; alias(r,d) ; alias(i,m) ; alias(i,j) ;
         
parameters
   VDFB(i, a, r)        "Firm purchases of domestic goods at basic prices"
   VDFP(i, a, r)        "Firm purchases of domestic goods at purchaser prices"
   VMFB(i, a, r)        "Firm purchases of imported goods at basic prices"
   VMFP(i, a, r)        "Firm purchases of domestic goods at purchaser prices"
   VDPB(i, r)           "Private purchases of domestic goods at basic prices"
   VDPP(i, r)           "Private purchases of domestic goods at purchaser prices"
   VMPB(i, r)           "Private purchases of imported goods at basic prices"
   VMPP(i, r)           "Private purchases of domestic goods at purchaser prices"
   VDGB(i, r)           "Government purchases of domestic goods at basic prices"
   VDGP(i, r)           "Government purchases of domestic goods at purchaser prices"
   VMGB(i, r)           "Government purchases of imported goods at basic prices"
   VMGP(i, r)           "Government purchases of domestic goods at purchaser prices"
   VDIB(i, r)           "Investment purchases of domestic goods at basic prices"
   VDIP(i, r)           "Investment purchases of domestic goods at purchaser prices"
   VMIB(i, r)           "Investment purchases of imported goods at basic prices"
   VMIP(i, r)           "Investment purchases of domestic goods at purchaser prices"

   EVFB(fp, a, r)       "Primary factor purchases at basic prices"
   EVFP(fp, a, r)       "Primary factor purchases at purchaser prices"
   EVOS(fp, a, r)       "Factor remuneration after income tax"

   VXSB(i, s, d)        "Exports at basic prices"
   VFOB(i, s, d)        "Exports at FOB prices"
   VCIF(i, s, d)        "Import at CIF prices"
   VMSB(i, s, d)        "Imports at basic prices"

   VST(i, r)            "Exports of trade and transport services"
   VTWR(m, i, s, d)     "Margins by margin commodity"

   SAVE(r)              "Net saving, by region"
   VDEP(r)              "Capital depreciation"
   VKB(r)               "Capital stock"
   POP(r)               "Population"

   MAKS(i,a,r)          "Make matrix at supply prices"
   MAKB(i,a,r)          "Make matrix at basic prices (incl taxes)"
   PTAX(i,a,r)          "Output taxes"
;

execute_loaddc "%inDir%\%BaseName%Dat.gdx",
   vdfb, vdfp, vmfb, vmfp,
   vdpb, vdpp, vmpb, vmpp,
   vdgb, vdgp, vmgb, vmgp,
   vdib, vdip, vmib, vmip,
   evfb, evfp, evos,
   vxsb, vfob, vcif, vmsb,
   vst, vtwr,
   save, vdep, vkb, pop=pop,
   maks, makb
;

Alias(is,js) ;

Parameter
   sam(r,is,js)      "SAM accounts"
;

*  Production

sam(r,i,a) = vdfb(i,a,r) + vmfb(i,a,r) ;
sam(r,"itax",a) = sum(i, (vdfp(i,a,r) + vmfp(i,a,r)) - (vdfb(i,a,r) + vmfb(i,a,r))) ;
sam(r,fp,a) = evfb(fp,a,r) ;
sam(r,"vtax",a) = sum(fp, evfp(fp,a,r) - evfb(fp,a,r)) ;

*  Demand
sam(r,i,"hhd")      = vdpb(i,r) + vmpb(i,r) ;
sam(r,"itax","hhd") = sum(i, (vdpp(i,r) + vmpp(i,r)) - (vdpb(i,r) + vmpb(i,r))) ;
sam(r,i,"gov")      = vdgb(i,r) + vmgb(i,r) ;
sam(r,"itax","gov") = sum(i, (vdgp(i,r) + vmgp(i,r)) - (vdgb(i,r) + vmgb(i,r))) ;
sam(r,i,"inv")      = vdib(i,r) + vmib(i,r) ;
sam(r,"itax","inv") = sum(i, (vdip(i,r) + vmip(i,r)) - (vdib(i,r) + vmib(i,r))) ;
sam(r,i,"tmg")      = vst(i,r) ;
sam(r,i,d)          = vfob(i,r,d) ;

*  Income distribution
sam(r,"regY",fp)      = sum(a, evos(fp,a,r)) ;
sam(r,"dtax",fp)      = sum(a, (evfb(fp,a,r) - evos(fp,a,r))) ;
sam(r,"deprY","regY") = vdep(r) ;

*  Supply
sam(r,a,i) = maks(i,a,r) ;
sam(r,"ptax",i) = sum(a, (makb(i,a,r) - maks(i,a,r))) ;
sam(r,s,i) = vcif(i,s,r) ;
sam(r,"mtax",i) = sum(s, (vmsb(i,s,r) - vcif(i,s,r))) ;
sam(r,"etax",i) = sum(d, (vfob(i,r,d) - vxsb(i,r,d))) ;

sam(r,"regY","itax") = sum(js, sam(r,"itax",js)) ;
sam(r,"regY","vtax") = sum(a, sam(r,"vtax",a)) ;
sam(r,"regY","ptax") = sum(i, sam(r,"ptax",i)) ;
sam(r,"regY","mtax") = sum(i, sam(r,"mtax",i)) ;
sam(r,"regY","etax") = sum(i, sam(r,"etax",i)) ;
sam(r,"regY","dtax") = sum(js, sam(r,"dtax",js)) ;
sam(r,"inv","bop")   = sum((i,s), vcif(i,s,r)) - (sum((i,d), vfob(i,r,d)) + sum(i, vst(i,r))) ;
sam(r,"inv","regy")  = save(r) - 0*vdep(r) ;
sam(r,"inv","depry") = vdep(r) ;
sam(r,"hhd","regY")  = sum(i, vdpp(i,r) + vmpp(i,r)) ;
sam(r,"gov","regY")  = sum(i, vdgp(i,r) + vmgp(i,r)) ;
*sam(r,"inv","regY") = sum(i, vdip(i,r) + vmip(i,r)) ;
sam(r,d,"BoP")       = sum(i, vfob(i,r,d)) ;
sam(r,"BoP",s)       = sum(i, vcif(i,s,r)) ;
sam(r,"tmg","BoP")   = sum(i, vst(i,r)) ;

file csv / "%outDir%/%outFile%.csv" /
put csv ;
if(%ifAppend% eq 0,
   csv.ap = 0 ;
   put "Name,Region,Rlab,Clab,Value" / ;
   csv.pc = 5 ;
   csv.nd = 10 ;
else
   csv.ap = 1 ;
   csv.pc = 5 ;
   csv.nd = 10 ;
) ;
loop((r,is,js)$sam(r,is,js),
   put "%Name%", r.tl, is.tl, js.tl, sam(r,is,js) / ;
) ;
