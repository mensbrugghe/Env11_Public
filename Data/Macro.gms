* ----------------------------------------------------------------------------------------
*
*  Step 1: Aggregate the database
*
* ----------------------------------------------------------------------------------------

file logFile / macro_log.txt / ;

Sets
   reg      "Regions"
   comm     "Commodities"
   acts     "Activities"
   endw     "Endowments"
;

$gdxIn "%inFolder%/%BaseName%Dat.gdx"
$load reg, comm, acts, endw

Parameters
   VDFB0(COMM, ACTS, REG)            "Firm purchases of domestic goods at basic prices"
   VDFP0(COMM, ACTS, REG)            "Firm purchases of domestic goods at purchaser prices"
   VMFB0(COMM, ACTS, REG)            "Firm purchases of imported goods at basic prices"
   VMFP0(COMM, ACTS, REG)            "Firm purchases of domestic goods at purchaser prices"
   VDPB0(COMM, REG)                  "Private purchases of domestic goods at basic prices"
   VDPP0(COMM, REG)                  "Private purchases of domestic goods at purchaser prices"
   VMPB0(COMM, REG)                  "Private purchases of imported goods at basic prices"
   VMPP0(COMM, REG)                  "Private purchases of domestic goods at purchaser prices"
   VDGB0(COMM, REG)                  "Government purchases of domestic goods at basic prices"
   VDGP0(COMM, REG)                  "Government purchases of domestic goods at purchaser prices"
   VMGB0(COMM, REG)                  "Government purchases of imported goods at basic prices"
   VMGP0(COMM, REG)                  "Government purchases of domestic goods at purchaser prices"
   VDIB0(COMM, REG)                  "Investment purchases of domestic goods at basic prices"
   VDIP0(COMM, REG)                  "Investment purchases of domestic goods at purchaser prices"
   VMIB0(COMM, REG)                  "Investment purchases of imported goods at basic prices"
   VMIP0(COMM, REG)                  "Investment purchases of domestic goods at purchaser prices"

   EVFB0(ENDW, ACTS, REG)            "Primary factor purchases at basic prices"
   EVFP0(ENDW, ACTS, REG)            "Primary factor purchases at purchaser prices"
   EVOS0(ENDW, ACTS, REG)            "Factor remuneration after income tax"

   VXSB0(COMM, REG, REG)             "Exports at basic prices"
   VFOB0(COMM, REG, REG)             "Exports at FOB prices"
   VCIF0(COMM, REG, REG)             "Import at CIF prices"
   VMSB0(COMM, REG, REG)             "Imports at basic prices"

   VST0(COMM, REG)                   "Exports of trade and transport services"
   VTWR0(COMM, COMM, REG, REG)       "Margins by margin commodity"

   SAVE0(REG)                        "Net saving, by region"
   VDEP0(REG)                        "Capital depreciation"
   VKB0(REG)                         "Capital stock"
   POP0(REG)                         "Population"

   MAKS0(COMM,ACTS,REG)              "Make matrix at supply prices"
   MAKB0(COMM,ACTS,REG)              "Make matrix at basic prices (incl taxes)"
   PTAX0(COMM,ACTS,REG)              "Output taxes"
;

*  Load the GTAP data base

execute_loaddc "%inFolder%/%BaseName%Dat.gdx"  
   vdfb0=vdfb, vdfp0=vdfp, vmfb0=vmfb, vmfp0=vmfp,
   vdpb0=vdpb, vdpp0=vdpp, vmpb0=vmpb, vmpp0=vmpp,
   vdgb0=vdgb, vdgp0=vdgp, vmgb0=vmgb, vmgp0=vmgp,
   vdib0=vdib, vdip0=vdip, vmib0=vmib, vmip0=vmip,
   evfb0=evfb, evfp0=evfp, evos0=evos,
   vxsb0=vxsb, vfob0=vfob, vcif0=vcif, vmsb0=vmsb,
   vst0=vst,   vtwr0=vtwr,
   save0=save, vdep0=vdep,
   vkb0=vkb,   pop0=pop,
   maks0=maks, makb0=makb, ptax0=ptax

;

sets
   aa       "Armington agents"         / ACTS, hhd, gov, inv, tmg /
   a(aa)    "Activities"               / ACTS /
   i  / COMM /
;

Parameters
   VDFB(i, a, REG)               "Firm purchases of domestic goods at basic prices"
   VDFP(i, a, REG)               "Firm purchases of domestic goods at purchaser prices"
   VMFB(i, a, REG)               "Firm purchases of imported goods at basic prices"
   VMFP(i, a, REG)               "Firm purchases of domestic goods at purchaser prices"
   VDPB(i, REG)                  "Private purchases of domestic goods at basic prices"
   VDPP(i, REG)                  "Private purchases of domestic goods at purchaser prices"
   VMPB(i, REG)                  "Private purchases of imported goods at basic prices"
   VMPP(i, REG)                  "Private purchases of domestic goods at purchaser prices"
   VDGB(i, REG)                  "Government purchases of domestic goods at basic prices"
   VDGP(i, REG)                  "Government purchases of domestic goods at purchaser prices"
   VMGB(i, REG)                  "Government purchases of imported goods at basic prices"
   VMGP(i, REG)                  "Government purchases of domestic goods at purchaser prices"
   VDIB(i, REG)                  "Investment purchases of domestic goods at basic prices"
   VDIP(i, REG)                  "Investment purchases of domestic goods at purchaser prices"
   VMIB(i, REG)                  "Investment purchases of imported goods at basic prices"
   VMIP(i, REG)                  "Investment purchases of domestic goods at purchaser prices"

   EVFB(ENDW, a, REG)            "Primary factor purchases at basic prices"
   EVFP(ENDW, a, REG)            "Primary factor purchases at purchaser prices"
   EVOS(ENDW, a, REG)            "Factor remuneration after income tax"

   VXSB(i, REG, REG)             "Exports at basic prices"
   VFOB(i, REG, REG)             "Exports at FOB prices"
   VCIF(i, REG, REG)             "Import at CIF prices"
   VMSB(i, REG, REG)             "Imports at basic prices"

   VST(i, REG)                   "Exports of trade and transport services"
   VTWR(i, i, REG, REG)          "Margins by margin commodity"

   SAVE(REG)                     "Net saving, by region"
   VDEP(REG)                     "Capital depreciation"
   VKB(REG)                      "Capital stock"
   POPG(REG)                     "Population"

   MAKS(i,a,REG)                  "Make matrix at supply prices"
   MAKB(i,a,REG)                  "Make matrix at basic prices (incl taxes)"
   PTAX(i,a,REG)                  "Output taxes"
   
   fbep(ENDW, a, REG)            "Factor subsidies"
   ftrv(ENDW, a, REG)            "Factor taxes"

;

set mape(endw,endw) / nsk.nsk, skl.skl, cap.(cap,lnd,nrs) / ;

vdfb(i,a,reg) = sum((comm,acts), vdfb0(comm,acts,reg)) ;
VDFP(i,a,reg) = sum((comm,acts), vdfp0(comm,acts,reg)) ;
vmfb(i,a,reg) = sum((comm,acts), vmfb0(comm,acts,reg)) ;
VmFP(i,a,reg) = sum((comm,acts), vmfp0(comm,acts,reg)) ;

VDPB(i, REG) = sum(comm, vdpb0(comm,reg)) ;
VDPP(i, REG) = sum(comm, vdpp0(comm,reg)) ;
VMPB(i, REG) = sum(comm, vmpb0(comm,reg)) ;
VMPP(i, REG) = sum(comm, vmpp0(comm,reg)) ;

VDgB(i, REG) = sum(comm, vdgb0(comm,reg)) ;
VDgP(i, REG) = sum(comm, vdgp0(comm,reg)) ;
VMgB(i, REG) = sum(comm, vmgb0(comm,reg)) ;
VMgP(i, REG) = sum(comm, vmgp0(comm,reg)) ;

VDiB(i, REG) = sum(comm, vdib0(comm,reg)) ;
VDiP(i, REG) = sum(comm, vdip0(comm,reg)) ;
VMiB(i, REG) = sum(comm, vmib0(comm,reg)) ;
VMiP(i, REG) = sum(comm, vmip0(comm,reg)) ;

alias(fp,endw) ;
EVFB(ENDW, a, REG) = sum((fp,acts)$mape(endw,fp), EVFB0(fp, acts, REG)) ;
EVFP(ENDW, a, REG) = sum((fp,acts)$mape(endw,fp), EVFP0(fp, acts, REG)) ;
EVOS(ENDW, a, REG) = sum((fp,acts)$mape(endw,fp), EVOS0(fp, acts, REG)) ;

alias(reg,src) ; alias(reg,dst) ;
alias(i,j) ; alias(comm,commp) ;
vxsb(i,src,dst) = sum(comm, vxsb0(comm, src, dst)) ;
VFOB(i,src,dst) = sum(comm, VFOB0(comm, src, dst)) ;
VCIF(i,src,dst) = sum(comm, VCIF0(comm, src, dst)) ;
VMSB(i,src,dst) = sum(comm, VMSB0(comm, src, dst)) ;

VST(i, reg) = sum(comm, vst0(comm,reg)) ;
vtwr(i,j,src,dst) = sum((comm,commp), vtwr0(comm,commp,src,dst)) ;

save(reg) = save0(reg) ;
vdep(reg) = vdep0(reg) ;
vkb(reg)  = vkb0(reg) ;
popg(reg)  = pop0(reg) ;

MAKS(i,a,reg) = sum((comm,acts), MAKS0(comm,acts,reg)) ;
MAKB(i,a,reg) = sum((comm,acts), MAKB0(comm,acts,reg)) ;
PTAX(i,a,reg) = makb(i,a,reg) - maks(i,a,reg) ;

fbep(endw,a,reg) = 0 ;
ftrv(endw,a,reg) = evfp(endw,a,reg) - evfb(endw,a,reg) ;

* --------------------------------------------------------------------------------------------------
*
*     Ignore CO2 emissions data
*
* --------------------------------------------------------------------------------------------------

Parameters
   mdf(i, a, reg)            "CO2 emissions from domestic intermediate demand"
   mmf(i, a, reg)            "CO2 emissions from domestic intermediate demand"
   mdp(i, reg)               "CO2 emissions from domestic private demand"
   mmp(i, reg)               "CO2 emissions from domestic private demand"
   mdg(i, reg)               "CO2 emissions from domestic public demand"
   mmg(i, reg)               "CO2 emissions from domestic public demand"
   mdi(i, reg)               "CO2 emissions from investment demand"
   mmi(i, reg)               "CO2 emissions from investment demand"
   nrgComb(i, a, reg)        "Energy combusted"
;

mdf(i,a,reg) = 0 ;
mmf(i,a,reg) = 0 ;
mdp(i,reg)   = 0 ;
mmp(i,reg)   = 0 ;
mdg(i,reg)   = 0 ;
mmg(i,reg)   = 0 ;
mdi(i,reg)   = 0 ;
mmi(i,reg)   = 0 ;

* --------------------------------------------------------------------------------------------------
*
*     Ignore MRIO data if requested
*
* --------------------------------------------------------------------------------------------------

set amrio "MRIO broad agents" /
   INT      "Aggregate intermediate demand"
   CONS     "Private and public demand"
   CGDS     "Investment demand"
/ ;

Parameters
   viuws(i, amrio,src,dst)        "Bilateral imports by broad agent at border prices"
   viums(i, amrio,src,dst)        "Bilateral imports by broad agent at post-tariff prices"
;
scalar MRIO / 0 / ;

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
   viuws(i, amrio, src, dst) = 0 ;
   viums(i, amrio, src, dst) = 0 ;
) ;


$macro PUTYEAR years(t):4:0
*$macro PUTYEAR t.tl
$setGlobal SIMNAME "Macro"

sets
   tt       "Time framework"       / 2017*2050 /
   t(tt)    "Model time framework" / 2017*2050 /
   ts(t)    "Simulation years"
;

singleton set t0(t)  "Reference year"               / 2017 / ;
singleton set tss(t) "When steady-state takes hold" / 2050 / ;

alias(tsim,t) ;

parameters
   year0          "Base year (in value)"
   FirstYear      "First year (in value)"
   years(tt)      "Vector of years in value"
   gap(tt)        "Gap between model years"
   ifSUB          "Set to 1 to substitute equations" / 1 /
   ifMCP          "Set to 1 to solve using MCP"      / 1 /
   inScale        "Scale for input data"             / 1e-6 /
   cScale         "Scale for input emissions data"   / 1e-3 /
   xpScale        "Scale factor for output"          / 1 /
   ifCal          "For dynamic version of model"     / 0 /
   ifDyn          "For dynamic version of model"     / 1 /
   ifDebug        "To debug model"                   / 0 /
   niter(t)       "Number of iterations for solve"
   iter           "Iteration counter"
   ifSteadyState  "If steady-state simulation"       / 0 /
;

years(tt) = tt.val ;
loop(t0, year0 = years(t0) ; ) ;
FirstYear = year0 ;
gap(tt)   = 1 ;

niter(t) = 1 ;

put logFile ;

* ------------------------------------------------------------------------------
*
*  At a minimum, the user needs to assign the following:
*
*     utility     Utility specification: default is CDE, alternative is CD
*     rorFlag     Valid options are capFlex, capShrFix, capFix
*
* ------------------------------------------------------------------------------

* $setGlobal utility    CDE
$setGlobal utility  CD
$setGlobal savfFlag capFix

acronym CDE, CD, capFlex, capshrFix, capFix, capSFix ;

Singleton Sets
   cap(fp)  "Capital"
   lnd(fp)  "Land"
   nrs(fp)  "Natural resources"

alias(marg,i) ; alias(endw,fp) ; alias(r,reg) ;
Sets
   l(fp)       "Labor accounts"            / nsk, skl /
   fnm(fp)     "Sector specific factors"   / /
   endwm(fp)   "Perfectly mobile endowments" /nsk, skl, cap /
   endws(fp)   "Sluggish endowments"         / /
   em          "Emissions"                 
;

Set
   fm(fp)   "Mobile factors"
;
fm(fp)$(not fnm(fp)) = yes ;

$ifthen exist "%inFolder%/%baseName%NCO2.gdx"
   $$gdxIn "%inFolder%/%baseName%NCO2.gdx"
   $$load em
$else
   set em "Emissions" / CO2 / ;
$endif

set rs(r) "Simulation regions" ;

alias(r,rp) ; alias(r,d); alias(r,s) ; alias(i,j) ; alias(j,jp) ; alias(m,j) ;

Sets
   fd(aa)   "Final demand accounts"    / hhd, gov, inv, tmg /
   h(aa)    "Households"               / hhd /
;

singleton Sets
   gov(fd)  "Government"      / gov /
   inv(fd)  "Investment"      / inv /
   tmg(fd)  "Trade margins"   / tmg /
   cap(fp)  / cap / 
;

*  Parameters from GTAP database

Parameters
   esubva0(acts,r)      "VA nest CES substitution elasticity"

   esubd0(comm,r)        "Top level Armington elasticity"
   esubm0(comm,r)        "Second level Armington elasticity"

   esubt(a,r)        "Top level CES substitution elasticity"
   esubc(a,r)        "ND nest CES substitution elasticity"
   esubva(a,r)       "VA nest CES substitution elasticity"

   etraq(a,r)        "CET make elasticity"
   esubq(i,r)        "CES make elasticity"

   incpar(i,r)       "CDE expansion parameter"
   subpar(i,r)       "CDE substitution parameter"

   esubg(r)          "CES government expenditure elasticity"
   esubi(r)          "CES investment expenditure elasticity"

   esubd(i,r)        "Top level Armington elasticity"
   esubm(i,r)        "Second level Armington elasticity"
   esubs(i)          "CES margin elasticity"

   etrae(fp,r)       "CET elasticity for factors"
   rorFlex0(r)       "Flexibility of foreign capital"
   
   vdm(comm,r)       "Demand for domestic goods"
   vim(comm,r)       "Demand for imported goods"
;

execute_loaddc "%inFolder%/%BaseName%Par.gdx"
   esubva0=esubva,
   esubd0=esubd, esubm0=esubm,
   rorFlex0=rorFlex
;

esubt(a,r) = 0 ;
esubc(a,r) = 0 ;
etraq(a,r) = 1 ;
esubq(i,r) = 0 ;
incpar(i,r) = 1 ;
subpar(i,r) = 1 ;
esubg(r) = 1.01 ;
esubi(r) = 0 ;
esubs(i) = 1.01 ;
etrae(fp,r) = inf ;

esubva(a,r) = sum(acts, esubva0(acts,r)*sum(fp, evfb0(fp, acts,r))) / sum(acts, sum(fp, evfb0(fp, acts,r))) ;
vdm(comm,r) = sum(acts, vdfp0(comm,acts,r)) + vdpp0(comm,r) + vdgp0(comm,r) + vdip0(comm,r) ;
vim(comm,r) = sum(acts, vmfp0(comm,acts,r)) + vmpp0(comm,r) + vmgp0(comm,r) + vmip0(comm,r) ;
esubd(i,r)  = sum(comm, (vdm(comm,r) + vim(comm,r))*esubd0(comm,r)) / sum(comm, (vdm(comm,r) + vim(comm,r))) ;
esubm(i,r)  = sum(comm, vim(comm,r)*esubm0(comm,r)) / sum(comm, vim(comm,r)) ;

*!!!! Convert etrae back to a negative to be consistent with the GTAP in GAMS model

etrae(fp,r)$(etrae(fp,r) ne INF and etrae(fp,r) > 0) = -etrae(fp,r) ;

Parameters

*  Parameters normally sourced from GTAP

   sigmap(r,a)       "Top level CES production elasticity (ND/VA)"
   sigmand(r,a)      "CES elasticity across intermediate inputs"
   sigmav(r,a)       "CES elasticity across factors of production"

   omegas(r,a)       "Commodity supply CET elasticity"
   sigmas(r,i)       "Commodity supply CES elasticity"

   eh0(r,i)          "CDE expansion parameter"
   bh0(r,i)          "CDE substitution parameter"

   sigmag(r)         "CES government expenditure elasticity"
   sigmai(r)         "CES investment expenditure elasticity"

   sigmam(r,i,aa)    "Top level Armington elasticity"
   sigmaw(r,i)       "Second level Armington elasticity"
   sigmawa(r,i,aa)       "Second level Armington elasticity by agent"
   sigmamg(m)        "CES expenditure elasticity for margin services exports"

   omegaf(r,fp)      "CET mobility elasticity for mobile factors"
   rorFlex(r,t)      "Flexibility of foreign capital"

*  Parameters in addition to standard GTAP model

   omegax(r,i)       "Top level output CET elasticity"
   omegaw(r,i)       "Second level export CET elasticity"

   etaf(r,fp)        "Aggregate factor supply elasticity"
   etaff(r,fp,a)     "Sector specific supply elasticity for non-mobile factors"

   mdtx0(r)          "Initial marginal tax rate"
   RoRFlag           "Capital account closure flag"
;

*  Overrides for GTAP-based parameters
*  If no overrides, parameters will be set in 'cal.gms'

sigmap(r,a)    = na ;
sigmand(r,a)   = na ;
sigmav(r,a)    = na ;

omegas(r,a)    = 1 ;
sigmas(r,i)    = 1.01 ;

eh0(r,i)       = na ;
bh0(r,i)       = na ;

sigmag(r)      = na ;
sigmai(r)      = na ;

sigmam(r,i,aa) = na ;
sigmaw(r,i)    = na ;
sigmawa(r,i,aa) = na ;
sigmamg(m)     = na ;

omegaf(r,fp)   =  na ;
rorFlex(r,t)   = rorFlex0(r) ;

*  Overrides

*  Other initialization

omegax(r,i)   = inf ;
omegaw(r,i)   = inf ;

etaf(r,fp)    = 0 ;
etaff(r,fp,a) = 0 ;

mdtx0(r)      = na ;

rorFlag       = capFix ;

*  Additional sets that are aggregation dependent
*!!!! This should be read in
singleton Sets
   rres(r)     "Residual region"    / usa /
;

Sets
   rmuv(r)     "MUV regions"        / AUS, CAN, CHN, DEU, FRA, ITA, JPN, KOR, GBR, USA, XHY /
   imuv(i)  / COMM / ;

$include "model.gms"

RoRFlag         = capFix ;

*  >>>>> Utility is set to CD in *Prm.gms file

*$include "getData.gms"
$include "cal.gms"

if(1,
   options limrow = 0, limcol = 0, solprint=off ;
else
   options limrow = 3, limcol = 3, solprint=off ;
) ;

gtap.scaleopt   = 1 ;
gtap.tolinfrep  = 1e-5 ;

*  Get the projections

sets
   c              "Countries"
   mapreg(r,c)    "Mapping of countries to region"
   scen           "Scenarios"
   ssp(scen)      "SSP scenarios"
   tranche        "Population cohorts"
   trs(tranche)   "Population cohorts less the total"
   sex            "Gender"
   sexx(sex)      "Gender less the total"
   var            "SSP variables"
   ymod           "SSP models"
;
$gdxIn "%inFolder%/%BaseName%Scn.gdx"
$load c, scen, tranche, sex, var, ymod=mod
$loaddc mapreg, ssp, trs, sexx

Parameters
   popScen(Scen,r,tranche,tt)
   gdpScen(ymod,Scen,var,r,tt)
;

execute_load "%inFolder%/%BaseName%Scn.gdx", popScen, gdpScen ;

singleton set theSSP(Scen)  / SSP2 / ;
singleton set theScen(Scen) / SSP2 / ;
singleton set themod(ymod)  / OECD / ;

pop.fx(r,t) = pop.l(r,t0) * popScen(theScen,r,"PTOTL",t) / popScen(theScen,r,"PTOTL",t0) ;
aft(r,l,t)  = aft(r,l,t0) * popScen(theScen,r,"P1564",t) / popScen(theScen,r,"P1564",t0) ;
rgdpmp.fx(r,t) = rgdpmp.l(r,t0) * gdpScen(theMod,theSSP,"GDP|PPP",r,t) / gdpScen(theMod,theSSP,"GDP|PPP",r,t0) ;
rgdppc.l(r,t)  = rgdpmp0(r)*rgdpmp.l(r,t) / pop.l(r,t) ;
loop(t$(not t0(t)),
   ggdppc.l(r,t) = rgdppc.l(r,t) / rgdppc.l(r,t-1) - 1 ;
) ;

afereg.lo(r,t)$(not t0(t)) = -inf ; afereg.up(r,t)$(not t0(t)) = +inf ;

xg.fx(r,t) = xg.l(r,t0) * gdpScen(theMod,theSSP,"GDP|PPP",r,t) / gdpScen(theMod,theSSP,"GDP|PPP",r,t0) ;
betag.lo(r,t)$(not t0(t)) = -inf ; betag.up(r,t)$(not t0(t)) = +inf ;

* display pop.l, aft, etaf, rgdpmp.l, rgdppc.l, ggdppc.l, afeflag ; abort "Temp" ;

loop(tsim,

   options limrow = 3, limcol = 3 ;
   $$include "iterloop.gms"
   
   xg.fx(r,tsim) = xg.l(r,t0) * gdpScen(theMod,theSSP,"GDP|PPP",r,tsim) / gdpScen(theMod,theSSP,"GDP|PPP",r,t0) ;
   betag.lo(r,tsim)$(not t0(tsim)) = -inf ; betag.up(r,tsim)$(not t0(tsim)) = +inf ;

*  Adjust the savings propensity to the level of the rent   
   betas.fx(r,tsim)$(not t0(tsim)) = betas.l(r,tsim-1) * ((arent.l(r,tsim-1)/arent.l(r,t0))**0.75) ;

   rs(r)    = yes ;
   ts(t)    = no ;
   ts(tsim) = yes ;

   if(years(tsim) gt year0,

      $$batinclude "solve.gms" dyncal

   ) ;

   put logFile ;
   put / ;
   put "Walras (scaled): ", (walras.l(tsim)/inScale):15:6 / ;
   putclose logFile ;
   display walras.l ;

) ;

ts(t)$(not t0(t)) = yes ;

*  Unfix lags

$macro m_unfix(var) var.lo(t)$(not t0(t)) = -inf ; var.up(t)$(not t0(t)) = +inf ;
$macro m_unfix0(var,d1) var.lo(d1,t)$(not t0(t)) = -inf ; var.up(d1,t)$(not t0(t)) = +inf ;
$macro m_unfix1(var,d1) var.lo(r,d1,t)$(not t0(t)) = -inf ; var.up(r,d1,t)$(not t0(t)) = +inf ;
$macro m_unfix2(var,d1,d2) var.lo(r,d1,d2,t)$(not t0(t)) = -inf ; var.up(r,d1,d2,t)$(not t0(t)) = +inf ;

m_unfix1(axp,a)
m_unfix1(lambdand,a)
m_unfix1(lambdava,a)
m_unfix2(lambdaio,i,a)
m_unfix2(lambdaf,fp,a)

m_unfix0(betag,r)
m_unfix0(betas,r)

m_unfix2(pf,fp,a)
m_unfix2(xf,fp,a)

m_unfix2(pa,i,aa)
m_unfix2(xa,i,aa)
m_unfix2(pe,i,dst)
m_unfix2(pefob,i,dst)
m_unfix2(pmcif,i,dst)
m_unfix2(xw,i,dst)
m_unfix0(ptmg,m)
m_unfix0(psave,r)
m_unfix0(kapend,r)
m_unfix0(pi,r)

m_unfix1(uh,h)
m_unfix0(yc,r)
m_unfix0(pabs,r)
m_unfix0(pfact,r)
m_unfix0(gdpmp,r)
* m_unfix0(rgdpmp,r)
m_unfix0(pgdpmp,r)

m_unfix(pmuv)
m_unfix(pwfact)

*  Fix zero variables

loop(t0,
   lambdand.fx(r,a,t)$(not ndFlag(r,a)) = 1 ;
   lambdava.fx(r,a,t)$(not vaFlag(r,a)) = 1 ;
   nd.fx(r,a,t)$(not ndFlag(r,a))       = 0 ;
   va.fx(r,a,t)$(not vaFlag(r,a))       = 0 ;
   px.fx(r,a,t)$(not xpFlag(r,a))       = px.l(r,a,t0) ;

   lambdaio.fx(r,i,a,t)$(not xaFlag(r,i,a)) = 1 ;
   xa.fx(r,i,aa,t)$(not xaFlag(r,i,aa))  = 0 ;
   pa.fx(r,i,aa,t)$(not xaFlag(r,i,aa))  = pa.l(r,i,aa,t) ;
   pnd.fx(r,a,t)$(not ndFlag(r,a))       = pnd.l(r,a,t0) ;

   lambdaf.fx(r,fp,a,t)$(not xfFlag(r,fp,a)) = 1 ;
   xf.fx(r,fp,a,t)$(not xfFlag(r,fp,a))   = 0 ;
   pf.fx(r,fp,a,t)$(not xfFlag(r,fp,a))   = pf.l(r,fp,a,t0) ;
   pva.fx(r,a,t)$(not vaFlag(r,a))        = pva.l(r,a,t0) ;

   x.fx(r,a,i,t)$(not xFlag(r,a,i)) = 0.0 ;
   p.fx(r,a,i,t)$(not xFlag(r,a,i)) = p.l(r,a,i,t0) ;
   xs.fx(r,i,t)$(not xsFlag(r,i))   = 0.0 ;
   ps.fx(r,i,t)$(not xsFlag(r,i))   = ps.l(r,i,t0) ;

   zcons.fx(r,i,h,t)$(not xaFlag(r,i,h)) = 0 ;
   xcshr.fx(r,i,h,t)$(not xaFlag(r,i,h)) = 0 ;

   xd.fx(r,i,aa,t)$(not alphad(r,i,aa,t))  = 0 ;
   xm.fx(r,i,aa,t)$(not alpham(r,i,aa,t))  = 0 ;
   pdp.fx(r,i,aa,t)$(not alphad(r,i,aa,t)) = pdp.l(r,i,aa,t) ;
   pmp.fx(r,i,aa,t)$(not alpham(r,i,aa,t)) = pmp.l(r,i,aa,t) ;

   xmt.fx(r,i,t)$(not xmtFlag(r,i)) = 0 ;
   pmt.fx(r,i,t)$(not xmtFlag(r,i)) = pmt.l(r,i,t0) ;

   xw.fx(r,i,rp,t)$(not xwFlag(r,i,rp))    = 0 ;
   pe.fx(r,i,rp,t)$(not xwFlag(r,i,rp))    = pe.l(r,i,rp,t0) ;
   pefob.fx(r,i,rp,t)$(not xwFlag(r,i,rp)) = pefob.l(r,i,rp,t0) ;
   pmcif.fx(r,i,rp,t)$(not xwFlag(r,i,rp)) = pmcif.l(r,i,rp,t0) ;
   pm.fx(r,i,rp,t)$(not xwFlag(r,i,rp))    = pm.l(r,i,rp,t0) ;

   xwmg.fx(r,i,rp,t)$(not tmgFlag(r,i,rp))  = 0 ;
   pwmg.fx(r,i,rp,t)$(not tmgFlag(r,i,rp))  = pwmg.l(r,i,rp,t) ;
   xmgm.fx(m,r,i,rp,t)$(not amgm(m,r,i,rp)) = 0 ;

   xds.fx(r,i,t)$(not xdFlag(r,i))  = 0 ;
   pd.fx(r,i,t)$(not xdFlag(r,i))   = pd.l(r,i,t0) ;
   xet.fx(r,i,t)$(not xetFlag(r,i)) = 0 ;
   pet.fx(r,i,t)$(not xetFlag(r,i)) = pet.l(r,i,t0) ;

   pfa.fx(r,fp,a,t)$(not xfFlag(r,fp,a)) = pfa.l(r,fp,a,t0) ;
   xft.fx(r,fm,t)$(not xftFlag(r,fm))    = 0 ;
   pft.fx(r,fm,t)$(not xftFlag(r,fm))    = pft.l(r,fm,t0) ;

*  01-May-2019: MRIO
   pma.fx(r,i,aa,t)$(not alpham(r,i,aa,t))  = pma.l(r,i,aa,t0) ;
   xwa.fx(s,i,d,aa,t)$(not xwaFlag(s,i,d,aa))  = xwa.l(s,i,d,aa,t0) ;
   pdma.fx(s,i,d,aa,t)$(not xwaFlag(s,i,d,aa)) = pdma.l(s,i,d,aa,t0) ;
) ;

if(0,
*  Fix return to capital across time (except for year 2)
*  By endogenizing savings propensity
*  Cannot change rent in year 2--pre-determined
*  Make betas(t) = betas(t-1) in final year(s)

   obj.l = sum((r,h,t)$ts(t), ev.l(r,h,t)*ev0(r,h)/obj0) ;

   arent.fx(r,t)$(t.val gt t0.val+1) = arent.l(r,t0) ;
   betas.lo(r,t) = -inf ; betas.up(r,t) = +inf ;
   betas.fx(r,t)$(t0(t)) = betas.l(r,t0) ;
   ifSteadyState = 1 ;

   $$batinclude "solve.gms" dyncal
) ;

Parameters
   invTgtT(r,t)
;

invTgtT(r,t) = 100 * xi0(r) * xi.l(r,t) / (rgdpmp0(r) * rgdpmp.l(r,t)) ;

Execute_unload "z:/output/Env11/G20/Macro.gdx"

scalar ifCSV / 1 / ;
file csv / "z:/output/env11/g20/macro.csv" / ;
put csv ;
put "Var,Reg,Rlab,Clab,Year,Value" / ;
csv.pc = 5 ;
csv.nd = 10 ;

set tax / itax, vtax, vsub, ptax, ctax, etax, mtax, dtax / ;
set fda / regy, hhd, gov, inv, bop, depry, tmg / ;

Parameter
   sam(r,i,aa,t)
   samt(r,tax,aa,t)
   samf(r,fp,a,t)
   samm(r,a,i,t)
   samti(r,tax,i,t)
   samy(r,tax,t)
   samyf(r,*,fp,t)
   samexp(r,i,d,t)
   samimp(r,s,i,t)
   samfd(r,fda,fda,t)
   sambopimp(r,s,t)
   sambopexp(r,d,t)
;

sam(r,i,aa,t)      = (pd0(r,i)*xd0(r,i,aa)*pd.l(r,i,t)*xd.l(r,i,aa,t)
                   + ((pmt0(r,i)*pmt.l(r,i,t))$(not MRIO) + (pma0(r,i,aa)*pma.l(r,i,aa,t))$MRIO)
                   *  xm0(r,i,aa)*xm.l(r,i,aa,t))
                   $(not ArmFlag(r,i))
                   + (pat0(r,i)*xa0(r,i,aa)*pat.l(r,i,t)*xa.l(r,i,aa,t))
                   $ArmFlag(r,i) ;
samt(r,"itax",aa,t) = sum(i, (dintx.l(r,i,aa,t)*pd0(r,i)*xd0(r,i,aa)*pd.l(r,i,t)*xd.l(r,i,aa,t)
                   +         mintx.l(r,i,aa,t)*((pmt0(r,i)*pmt.l(r,i,t))$(not MRIO)
                   +          (pma0(r,i,aa)*pma.l(r,i,aa,t))$MRIO)*xm0(r,i,aa)*xm.l(r,i,aa,t))
                   $(not ArmFlag(r,i))
                   +        (aintx.l(r,i,aa,t)*pat0(r,i)*xa0(r,i,aa)*pat.l(r,i,t)*xa.l(r,i,aa,t))
                   $ArmFlag(r,i)) ;
samf(r,fp,a,t)      = pf0(r,fp,a)*xf0(r,fp,a)*pf.l(r,fp,a,t)*xf.l(r,fp,a,t) ;
samt(r,"vtax",a,t)  =
   sum(fp, fcttx.l(r,fp,a,t)*pf0(r,fp,a)*xf0(r,fp,a)*pf.l(r,fp,a,t)*xf.l(r,fp,a,t)) ;
samt(r,"vsub",a,t)  =
   sum(fp, fctts.l(r,fp,a,t)*pf0(r,fp,a)*xf0(r,fp,a)*pf.l(r,fp,a,t)*xf.l(r,fp,a,t)) ;

samm(r,a,i,t)$xFlag(r,a,i) = p0(r,a,i)*x0(r,a,i)*p.l(r,a,i,t)*x.l(r,a,i,t) ;
samti(r,"ptax",i,t)  = sum(a, prdtx.l(r,a,i,t)*p0(r,a,i)*x0(r,a,i)*p.l(r,a,i,t)*x.l(r,a,i,t)) ;
samt(r,"ctax",a,t)  = ctax.l(r,a,t)*px0(r,a)*xp0(r,a)*px.l(r,a,t)*xp.l(r,a,t) ;

*  Income distribution

*  'Standard GTAP' method

samyf(r,"regY",fp,t)
   = sum(a, (1-kappaf.l(r,fp,a,t))*pf0(r,fp,a)*xf0(r,fp,a)*pf.l(r,fp,a,t)*xf.l(r,fp,a,t)) ;
samyf(r,"dtax",fp,t)
   = sum(a, kappaf.l(r,fp,a,t)*pf0(r,fp,a)*xf0(r,fp,a)*pf.l(r,fp,a,t)*xf.l(r,fp,a,t)) ;
samy(r,"vsub",t)  = sum(a, samt(r,"vsub",a,t)) ;
samy(r,"vtax",t)  = sum(a, samt(r,"vtax",a,t)) ;
samti(r,"etax",i,t)    = sum(d, exptx.l(r,i,d,t)*pe0(r,i,d)*pe.l(r,i,d,t)*xw0(r,i,d)*xw.l(r,i,d,t)) ;
samti(r,"mtax",i,t)
   = sum(s, imptx.l(s,i,r,t)*pmcif0(s,i,r)*pmcif.l(s,i,r,t)*xw0(s,i,r)*xw.l(s,i,r,t)) ;
samy(r,"etax",t)  = sum(j, samti(r,"etax",j,t)) ;
samy(r,"mtax",t)  = sum(j, samti(r,"mtax",j,t)) ;
samy(r,"ptax",t)  = sum(i, samti(r,"ptax",i,t)) ;
samy(r,"itax",t)  = sum(aa, samt(r,"itax",aa,t)) ;
samy(r,"dtax",t)  = sum(fp, samyf(r,"dtax",fp,t)) ;

samy(r,"ctax",t)  = sum(a,ctax.l(r,a,t)*px0(r,a)*xp0(r,a)*px.l(r,a,t)*xp.l(r,a,t)) ;

samfd(r,"hhd","regY",t)       = yc0(r)*yc.l(r,t) ;
samfd(r,"gov","regY",t)     = yg0(r)*yg.l(r,t) ;
samfd(r,"inv","regY",t)     = rsav0(r)*rsav.l(r,t) ;

samfd(r,"depry","regY",t) = pi0(r)*pi.l(r,t)*kstock.l(r,t)*kstock0(r)*depr(r,t) ;
samfd(r,"inv","depry",t)    = pi0(r)*pi.l(r,t)*kstock.l(r,t)*kstock0(r)*depr(r,t) ;

samfd(r,"inv","bop",t)   = savf.l(r,t) ;

*  Trade

samimp(r,s,i,t)      = pmcif0(s,i,r)*pmcif.l(s,i,r,t)*xw0(s,i,r)*xw.l(s,i,r,t) ;
sambopimp(r,s,t)  = sum(i, samimp(r,s,i,t)) ;

samexp(r,i,d,t)      = pefob0(r,i,d)*pefob.l(r,i,d,t)*xw0(r,i,d)*xw.l(r,i,d,t) ;
sambopexp(r,d,t)  = sum(i, samexp(r,i,d,t)) ;

loop(tmg,
   samfd(r,"tmg","bop",t) = sum(i, sam(r,i,tmg,t)) ;
) ;

loop((r,i,aa,t)$sam(r,i,aa,t),
   put "sam", r.tl, i.tl, aa.tl, t.val:4:0, (sam(r,i,aa,t)/inscale) / ;
) ;
loop((r,tax,aa,t)$samt(r,tax,aa,t),
   put "sam", r.tl, tax.tl, aa.tl, t.val:4:0, (samt(r,tax,aa,t)/inscale) / ;
) ;
loop((r,fp,a,t)$samf(r,fp,a,t),
   put "sam", r.tl, fp.tl, a.tl, t.val:4:0, (samf(r,fp,a,t)/inscale) / ;
) ;
loop((r,a,i,t)$samm(r,a,i,t),
   put "sam", r.tl, a.tl, i.tl, t.val:4:0, (samm(r,a,i,t)/inscale) / ;
) ;
loop((r,tax,i,t)$samti(r,tax,i,t),
   put "sam", r.tl, tax.tl, i.tl, t.val:4:0, (samti(r,tax,i,t)/inscale) / ;
) ;

loop((r,tax,t)$samy(r,tax,t),
   put "sam", r.tl, "regY", tax.tl, t.val:4:0, (samy(r,tax,t)/inscale) / ;
) ;

loop((r,fp,t)$samyf(r,"regY",fp,t),
   put "sam", r.tl, "regY", fp.tl, t.val:4:0, (samyf(r,"regY",fp,t)/inscale) / ;
) ;

loop((r,fp,t)$samyf(r,"dtax",fp,t),
   put "sam", r.tl, "dtax", fp.tl, t.val:4:0, (samyf(r,"dtax",fp,t)/inscale) / ;
) ;

loop((r,i,d,t)$samexp(r,i,d,t),
   put "sam", r.tl, i.tl, d.tl, t.val:4:0, (samexp(r,i,d,t)/inscale) / ;
) ;

loop((r,s,i,t)$samimp(r,s,i,t),
   put "sam", r.tl, s.tl, i.tl, t.val:4:0, (samimp(r,s,i,t)/inscale) / ;
) ;

alias(fda,fdap) ;
loop((r,fda,fdap,t)$samfd(r,fda,fdap,t),
   put "sam", r.tl, fda.tl, fdap.tl, t.val:4:0, (samfd(r,fda,fdap,t)/inscale) / ;
) ;

loop((r,s,t)$sambopimp(r,s,t),
   put "sam", r.tl, "BoP", s.tl, t.val:4:0, (sambopimp(r,s,t)/inscale) / ;
) ;

loop((r,d,t)$sambopexp(r,d,t),
   put "sam", r.tl, d.tl, "BoP", t.val:4:0, (sambopexp(r,d,t)/inscale) / ;
) ;

