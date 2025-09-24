* --------------------------------------------------------------------------------------------------
*
*     Read in the GTAP database
*
* --------------------------------------------------------------------------------------------------

Sets
   i        "Commodities"
   a        "Activities"
   r        "Regions"
   fp       "Production factors"
   metaData
;

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
   VTWR(i, j, s, d)     "Margins by margin commodity"

   SAVE(r)              "Net saving, by region"
   VDEP(r)              "Capital depreciation"
   VKB(r)               "Capital stock"
   POP0(r)              "Population"

   MAKS(i,a,r)          "Make matrix at supply prices"
   MAKB(i,a,r)          "Make matrix at basic prices (incl taxes)"
   PTAX(i,a,r)          "Output taxes"

   fbep(fp, a, r)       "Factor subsidies"
   ftrv(fp, a, r)       "Tax on factor use"
   tvom(a,r)            "Value of output"
   check(a,r)           "Check"
;

execute_loaddc "%inDir%/%BaseName%Dat.gdx",
   vdfb, vdfp, vmfb, vmfp,
   vdpb, vdpp, vmpb, vmpp,
   vdgb, vdgp, vmgb, vmgp,
   vdib, vdip, vmib, vmip,
   evfb, evfp, evos,
   vxsb, vfob, vcif, vmsb,
   vst, vtwr,
   save, vdep, vkb, pop0=pop,
   maks, makb
;

*  !!!! MAY WANT TO FIX THIS AT SOME STAGE--THERE IS INCONSISTENCY IN THE
*        HANDLING OF FBEP and FTRV

fbep(fp,a,r) = 0 ;
ftrv(fp,a,r) = evfp(fp,a,r) - evfb(fp,a,r) ;
ptax(i,a,r)  = makb(i,a,r) - maks(i,a,r) ;

* --------------------------------------------------------------------------------------------------
*
*     Read in CO2 emissions data
*
* --------------------------------------------------------------------------------------------------

Parameters
   mdf(i, a, r)            "CO2 emissions from domestic intermediate demand"
   mmf(i, a, r)            "CO2 emissions from domestic intermediate demand"
   mdp(i, r)               "CO2 emissions from domestic private demand"
   mmp(i, r)               "CO2 emissions from domestic private demand"
   mdg(i, r)               "CO2 emissions from domestic public demand"
   mmg(i, r)               "CO2 emissions from domestic public demand"
   mdi(i, r)               "CO2 emissions from investment demand"
   mmi(i, r)               "CO2 emissions from investment demand"
   nrgComb(i, a, r)        "Energy combusted"
;

$ifthen exist "%inDir%/%BaseName%Emiss.gdx"
   execute_loaddc "%inDir%/%BaseName%Emiss.gdx", mdf, mmf, mdp, mmp, mdg, mmg, mdi, mmi, nrgComb ;
$else
   mdf(i,a,r) = 0 ;
   mmf(i,a,r) = 0 ;
   mdp(i,r)   = 0 ;
   mmp(i,r)   = 0 ;
   mdg(i,r)   = 0 ;
   mmg(i,r)   = 0 ;
   mdi(i,r)   = 0 ;
   mmi(i,r)   = 0 ;
$endif

* --------------------------------------------------------------------------------------------------
*
*     Read in the MRIO data if requested
*
* --------------------------------------------------------------------------------------------------

set amrio "MRIO broad agents" /
   INT      "Aggregate intermediate demand"
   CONS     "Private and public demand"
   CGDS     "Investment demand"
/ ;

Parameters
   viuws(i, amrio,s,d)        "Bilateral imports by broad agent at border prices"
   viums(i, amrio,s,d)        "Bilateral imports by broad agent at post-tariff prices"
;

if(MRIO,
   $$ifthen exist "%inDir%/%BaseName%MRIO.gdx"
      execute_load "%inDir%/%BaseName%MRIO.gdx", viums, viuws ;
   $$else
      put logFile ; put / ;
      put "Requested MRIO version, but could not locate MRIO database" / ;
      put "Check for existence or set the MRIO flag to 0" / ;
      abort "No MRIO file" ;
   $$endif
else
   viuws(i, amrio, s, d) = 0 ;
   viums(i, amrio, s, d) = 0 ;
) ;

sets
   ar    "IPCC assessment reports"
;

Parameters
   EMI_IO(EM, i, a, r)     "IO-based emissions"
   EMI_IOP(EM, i, a, r)    "IO-based process emissions"
   EMI_ENDW(EM, fp, a, r)  "Endowment-based emissions"
   EMI_QO(EM, a, r)        "Output-based emissions"
   EMI_HH(EM, i, r)        "Private consumption-based emissions"
   GWP(em,r,ar)            "Global warming potential"
;

$ifthen exist "%inDir%/%BaseName%NCO2.gdx"
   $$load ar
$endif
