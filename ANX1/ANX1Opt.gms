* --------------------------------------------------------------------------------------------------
*
*  Define a first set of global options
*
*     wdir        Active directory (normally not changed)
*     SSPMOD      OECD, IIASA, IEO or WEO
*     SSPSCEN     SSP1, SSP2, SSP3, SSP4, SSP5, EMFSCEN
*     POPSCEN     SSP1, SSP2, SSP3, SSP4, SSP5, UNMED2010, UNMED2012, UNMED2015, UNMED2017, GIDD
*     OVERLAYPOP  0=keep GTAP base year pop level, 1=use SSP pop level for 2011
*     TASS        Aggregate land supply function: KELAS, LOGIST, HYPERB, INFTY
*     WASS        Aggregate water supply function: KELAS, LOGIST, HYPERB, INFTY
*     utility     LES, ELES, AIDADS, CDE
*     NRITER      Best to keep 0 for the moment
*     savfFlag    Set to capFix for fixed foreign savings, set to capFlex for endogenous savf
*
* --------------------------------------------------------------------------------------------------

$setGlobal wdir          %system.fp%
$setGlobal DataFolder    .
$setGlobal SSPMOD        OECD
$setGlobal SSPSCEN       SSP2
$setGlobal LABSCEN       SSP2
$setGlobal POPSCEN       SSP2
$setGlobal OVERLAYPOP    0
$setGlobal TASS          LOGIST
$setGlobal WASS          LOGIST
$setGlobal utility       CDE
$setGlobal NRITER        0
$setGlobal savfFlag      capFix
$setGlobal intRate       0.05
$setGlobal costCurve     HYPERB
$setGlobal NTM_MODULE    OFF
$setGlobal MRIO_MODULE   OFF
$setGlobal RD_MODULE     OFF
$setGlobal DEPL_MODULE   OFF
$setGlobal CLIM_MODULE   OFF
$setGlobal DAMAGE_MODULE OFF
$setGlobal FBS_MODULE    OFF
$setGlobal ifBKSTP       OFF
$setGlobal ifDEPR0       ON
$setGlobal ifVINT        0

$iftheni "%simType%" == "compStat"

*  Define dynamic setup for a comparative static simulation

sets
   $$iftheni "%simName%" == "Comp"
      tt       "Full time horizon"        / base, check, shock /
      t(tt)    "Simulation time horizon"  / base, check, shock /
   $$else
*     tt       "Full time horizon"        / base, check, "All", "CO2", "NCO2", "CO2CAP" /
*     t(tt)    "Simulation time horizon"  / base, check, "All", "CO2", "NCO2", "CO2CAP" /
      tt       "Full time horizon"        / base, check, COMB1*COMB5, AllGHG5, AllGHG4, AllGHG3, AllGHG2, AllGHG1 /
      t(tt)    "Simulation time horizon"  / base, check, COMB1*COMB5, AllGHG5, AllGHG4, AllGHG3, AllGHG2, AllGHG1 /
   $$endif
   v        "Vintages"                 / Old /
   vOld(v)  "Old vintage"              / Old /
   vNew(v)  "New vintage"              / Old /
;
singleton set t0(t)   / base / ;
singleton set tLag(t) / base / ;

Parameters
   years(tt)
   firstYear      "First year of full time horizon"
   baseYear       "Simulation base year"
   finalYear
   gap(t)
;

years(tt) = ord(tt) ;
baseYear  = years(t0) ;
gap(t)    = 1 ;
firstYear = smin(tt,years(tt)) ;
finalYear = smax(t,years(t)) ;

Scalars
   ifDyn       Set to 1 for dynamic simulation         / 0 /
   ifCal       Set to 1 for dynamic calibration        / 0 /
   ifVint      Set to 1 for vintage capital spec       / 0 /
;

$elseifi "%simType%" == "RcvDyn"

*  Define dynamic setup for a dynamic simulation
*  tt must start in 2007 because of scenario file

sets
   tt       "Full time horizon"                / 1950*2100 /
*  t(tt)    "Simulation time horizon"          / 2014*2030, 2035, 2040, 2045, 2050 /
   t(tt)    "Simulation time horizon"          / 2017*2030 /
   tf(t)    "Final simulation year"            / 2030 /
   tf0(t)   "Year for starting savf phaseout"  / 2023 /
   tfT(t)   "Year for finishing savf phaseout" / 2030 /

$ifthen.vint %ifVINT% == 0
   v        "Vintages"                         / Old /
   vOld(v)  "Old vintage"                      / Old /
   vNew(v)  "New vintage"                      / Old /
$else.vint
   v        "Vintages"                         / Old, New /
   vOld(v)  "Old vintage"                      / Old /
   vNew(v)  "New vintage"                      / New /
$endif.vint
;
singleton set t0(t)   / 2017 / ;
singleton set tLag(t) / 2017 / ;

parameters
   years(tt)      "Contains years in value (dynamic)"
   firstYear      "First year of full time horizon"
   baseYear       "Simulation base year"
   finalYear      "Simulation final year"
   gap(t)         "Time-step"
;

firstYear = smin(tt, tt.val) ;
years(tt) = firstYear - 1 + ord(tt) ;
gap(t)    = 1$t0(t) + (years(t) - years(t-1))$(not t0(t)) ;
baseYear  = years(t0) ;
finalYear = smax(t,years(t)) ;

Scalars
   ifVint      Set to 1 for vintage capital spec       / %ifVint% /
   ifDyn       Set to 1 for dynamic simulation         / 1 /
   ifCal       Set to 1 for dynamic calibration        / %ifCal% /
;

$else

   Display "Wrong simulation type" ;
   Abort "Check listing file" ;

$endif

sets
   sim      / %SIMNAME% /
   ts(t)
;

alias(t,tsim) ;
alias(v,vp) ;
scalar nriter / %NRITER% / ;

Parameters
   riter
   iter
   nSubs
;

*  A number of other global options

scalars
   inScale     "Scale factor for input data"             / 1e-6 /
   outScale    "Scale factor for output data"            / 1e6 /
   popScale    "Scale factor for population"             / 1e-6 /
   lScale      "Scale factor for labor volumes"          / 1e-12 /
   eScale      "Scale factor for energy"                 / 1e-3 /
   rScale      "Scale factor for reserves"               / 1e-3 /
   watScale    "Scale factor for water"                  / 1e-12 /
   cScale      "Scale factor for emissions"              / 1e-3 /
   ifCEQ       "Convert emissions to CEq"                / 0 /
   ArmFlag     "Set to 1 for agent-based Armington"      / 1 /
$iftheni "%MRIO_MODULE%" == "ON"
   MRIO        "Set to 1 for MRIO model"                 / 1 /
$else
   MRIO        "Set to 1 for MRIO model"                 / 0 /
$endif
   intRate     "Interest rate"                           / %intRate% /
   ifNRG       "Set to 1 to use energy volumes"          / 1 /
   ifNRGNest   "Set to 1 for energy nesting"             / 1 /
   ifNRGACES   "Set to 1 for ACES in energy nesting"     / 1 /
   ifMCP       "Set to 1 for MCP"                        / 1 /
   ifLandCET   "Set to 1 to use CET for land allocation" / 1 /
   ifSUB       "Set to 1 to substitute out equations"    / 1 /
   IFPOWER     "Set to 1 for power module"               / 1 /
   IFWATER     "Set to 1 for water module"               / 0 /
   ifAggTrade  "Set to 1 to aggregate trade in SAM"      / 0 /
   skLabgrwgt  "Set to between 0 and 1"                  / 0 /
   EXR         "Exchange rate"                           / 1 /
;

*  CSV results go to this file

file
   fsam   / "%odir%/%SIMNAME%SAM.csv" /
   screen / %SIMNAME%LOG.txt /
;

*  This file is optional--sometimes useful to debug model

*file debug / %odir%\%SIMNAME%DBG.csv / ;
file debug / %SIMNAME%DBG.gms / ;

if(1,
   put debug ;
   debug.ap = 0 ;
*  put "Var,Region,Sector,Qual,Year,Value" / ;
*  debug.pc=5 ;
*  debug.nd=9 ;
) ;

*  CSV output options

scalars
   ifSAM       "Flag for SAM CSV file" / 1 /
   ifSAMAppend "Flag to append to existing SAM CSV file" / 0 /
;

*  Start initializing the model--read the dimensions, the base data, the parameters and the model specification

$include "getData.gms"

$include "%BASENAME%Prm.gms"

$iftheni "%CLIM_MODULE%" == "ON"
   $$include "ClimDataV10.gms"
$endif

$include "model.gms"

*  Set the unemployment regime
*ueFlag(r,l,z) = fullEmpl ;
ueFlag(r,l,z) = MonashUE ;

savfFlag = %savfFlag% ;

*  Load the generic scenario initialization files

$iftheni "%simType%" == "compStat"

   $$include "compScen.gms"

$elseifi "%simType%" == "RcvDyn"

   $$include "initScen.gms"

   yexo(r,'agr-a',t) = 1.0 ;
   yexo("SAS",'agr-a',t)$(years(t) le 2030) = 1.5 ;
   yexo("CHN",'agr-a',t)$(years(t) le 2030) = 1.5 ;

   aeei(r,"oil-a",v,t) = 0 ;
   aeei(r,"coa-a",v,t) = 0 ;
   aeei(r,"gas-a",v,t) = 0 ;
   aeei(r,"clp-a",v,t) = 0 ;
   aeei(r,"p_c-a",v,t) = 0 ;
   aeei(r,"olp-a",v,t) = 0 ;

$iftheni "%ifBKSTP%" == "ON"
   aeei(r,"ccs-a",v,t) = 0 ;
   aeei(r,"gcs-a",v,t) = 0 ;
$endif
$endif

*  Overrides

vdep(r) = 0 ;
sigmalnd(r,a) = 1.01 ;

ifnco2 = 1 ;

ifARMACES(e)$ifNRGACES = yes ;

display sigmaxp0, sigmaxp ;

$include "init.gms"

if(%utility% eq CDE,

   $$iftheni exist "%BASENAME%cde.gdx"

      execute_load "%BASENAME%cde.gdx", eh0, bh0 ;

*     Initialize income elasticity for ELES calibration
*     !!!! TAKEN FROM CDE FUNCTION
      loop((h,t0),
         incElas(k,r) = ((eh0(k,r)*bh0(k,r)
                      - sum(kp$xcFlag(r,kp,h), hshr.l(r,kp,h,t0)*eh0(kp,r)*bh0(kp,r)))
                      / sum(kp$xcFlag(r,kp,h), hshr.l(r,kp,h,t0)*eh0(kp,r)) - (bh0(k,r)-1)
                      + sum(kp$xcFlag(r,kp,h), hshr.l(r,kp,h,t0)*bh0(kp,r))) ;
      ) ;
      if(0,
         display eh0, bh0 ;
         abort "Temp" ;
      ) ;
   $$endif
) ;

$include "cal.gms"

$include "elasDiag.gms"
* execute_unload "%BaUName%Parm.gdx", r,a,v,i,aa,sigmaxp,sigmap,sigmaw,sigmam ;

$include "closure.gms"

$iftheni.BaU "%simType%" == "RcvDyn"

*  !!!! Problem with investment target

   invTargetT(r,t)$(t.val gt 2029) = invTargetT(r,"2029") ;
*  invTargetT("sas",t) = invTargetT("sas",t)$(t.val lt 2021) + 23$(t.val ge 2021) ;

*  Load a baseline, if it exists

   if(ifDyn,

      if(ifCal eq 0,

*        Load the reference data

         execute_load "%odir%/%BaUName%.gdx",
            gl, gk, xfd, wchiNRS, chinrs, chirw, chiAPS, rwage, ldz,
            alpha_dt, alpha_mt, alpha_d, alpha_m, alpha_w
            lambdafBaU=lambdaf.l, lambdaKBaU=lambdak.l, emiXscBaU = emiXsc ;

         glBaU(r,t)        = gl.l(r,t) ;
         gkBaU(r,t)        = gk.l(r,t) ;
        xfdBaU(r,fd,t)    = xfd.l(r,fd,t) ;
         chiNRSBaU(r,a,t)  = chiNRS.l(r,a,t) ;
         wchiNRSBaU(a,t)   = wchiNRS.l(a,t) ;
         chirwBaU(r,l,z,t) = chirw.l(r,l,z,t) ;
         chiAPSBaU(r,h,t)  = chiAPS.l(r,h,t) ;

         rwageBaU(r,l,z,t) = rwage.l(r,l,z,t) ;
         ldzBaU(r,l,z,t)   = ldz.l(r,l,z,t) ;

         xfd.lo(r,fd,t)   = -inf ;
         xfd.up(r,fd,t)   = +inf ;

      ) ;

*     Load values from a previous scenario if it exists

      $$ifthen.srtPoint exist "%odir%/%startNAME%.gdx"
         execute_loadpoint "%odir%/%startNAME%.gdx" ;
         ifInitFlag = 1 ;
         startYear = %startYear% ;
      $$endif.srtPoint
*     $$include "%simName%DBG.gms"
   ) ;

$endif.BaU

emigbl.l(em,t0)$emiGbl0(em) = 1 ;

*  Set the solution options

options limrow=3, limcol=3, iterlim=1000, solprint=off ;
core.tolinfrep    = 1e-5 ;
coreBaU.tolinfrep = 1e-5 ;
coreDyn.tolinfrep = 1e-5 ;

$ontext
$iftheni.BaU "%simType%" == "RcvDyn"

*Target increase in ely share for agents
*parameter elyShrAgents(r,aa);
*elyShrAgents(r,aa) = 1;

parameter
   elyShrAgents(r,a)
   elyShr(r,pb,elyc)
;

elyShrAgents(r,a) = na ;
elyShr(r,pb,elyc) = na ;

$$iftheni.Base "%BaUName%" == "BaU"

*  Increase electricity share by 20% vis-a-vis non-electric bundle

elyShrAgents(r,a) = 2.0 ;

*  In power bundle, target renewable bundle

table elyShr00(r,pb)
          Renp      Hydp      Nucp
USA        30        na        na
EUR        30        na        na
XOE        20        na        na
CHN        30        na        na
RUS        20        na        na
OPC        na        na        na
XEA        10        na        na
SAS        12        na        na
XLC        15        na        na
ROW        10        na        na
;

elyShr(r,pb,elyc) = elyShr00(r,pb) ;

$else.Base
   if(DynPhase ge 1000,
      Abort "Wrong BaU name..."
   ) ;
$endif.Base

$endif.BaU

$iftheni.elyShr "%simType%" == "RcvDyn"

*  Target electricity share across agents

parameter
   sElyShrAgent(r,aa,t)
;

scalar elyFinalYear ; elyFinalYear = 2030 ;

singleton set tf00(t) ; tf00(t)$(years(t) eq elyFinalYear) = yes ;

if(dynPhase ge 3,
   if(ifNRGACES,

*     ACES

*     Total energy consumed

      sElyShrAgent(r,a,t0)$(elyShrAgents(r,a) > 1) = sum(v,
               xaNRG0(r,a,"ely")*xaNRG.l(r,a,"ely",v,t0)
            +  xnely0(r,a)*xnely.l(r,a,v,t0)) ;

*     Volume share of ELY in total energy use

      sElyShrAgent(r,a,t0)$sElyShrAgent(r,a,t0) = sum(v,
               xaNRG0(r,a,"ely")*xaNRG.l(r,a,"ely",v,t0))
            /  sElyShrAgent(r,a,t0) ;

*     Set share for target year
*     sElyShrAgent(r,a,t)$(years(t) eq elyFinalYear) = min(max(0.95, sElyShrAgent(r,a,t0)), elyShrAgents(r,a)*sElyShrAgent(r,a,t0)) ;

      sElyShrAgent(r,a,tf00) = min(0.95, elyShrAgents(r,a)*sElyShrAgent(r,a,t0)) ;

*     Target eletricity bundle

      loop(t$(years(t) gt baseYear),
         if(years(t) le elyFinalYear,
            alpha_NRGB(r,a,"ely",v,t)$sElyShrAgent(r,a,t0)
               = alpha_NRGB(r,a,"ely",v,t-1)*power(1 + ((sElyShrAgent(r,a,tf00)/sElyShrAgent(r,a,t0))**(1/(elyFinalYear-baseYear))-1), gap(t)) ;
         elseif(years(t) gt elyFinalYear),
            alpha_NRGB(r,a,"ely",v,t)$sElyShrAgent(r,a,t0) = alpha_NRGB(r,a,"ely",v,t-1) ;
         ) ;
      ) ;

*     Target non-electric bundle

      loop(t$(years(t) gt baseYear),
         if(years(t) le elyFinalYear,
            alpha_nely(r,a,v,t)$(1-sElyShrAgent(r,a,t0))
               = alpha_nely(r,a,v,t-1)*power(1 + (((1-sElyShrAgent(r,a,tf00))/(1-sElyShrAgent(r,a,t0)))**(1/(elyfinalYear-baseYear))-1), gap(t)) ;
         elseif(years(t) gt elyFinalYear),
            alpha_nely(r,a,v,t)$(1-sElyShrAgent(r,a,t0)) = alpha_nely(r,a,v,t-1) ;
         ) ;
      ) ;

   else

*     Standard CES

*     Total energy expenditure
      sElyShrAgent(r,a,t0)$(elyShrAgents(r,a) > 1) = sum(v,
               paNRG0(r,a,"ely")*xaNRG0(r,a,"ely")*paNRG.l(r,a,"ely",v,t0)*xaNRG.l(r,a,"ely",v,t0)
            +  pnely0(r,a)*xnely0(r,a)*pnely.l(r,a,v,t0)*xnely.l(r,a,v,t0)) ;

*     Value share of ELY in total energy cost

      sElyShrAgent(r,a,t0)$sElyShrAgent(r,a,t0) = sum(v,
               paNRG0(r,a,"ely")*xaNRG0(r,a,"ely")*paNRG.l(r,a,"ely",v,t0)*xaNRG.l(r,a,"ely",v,t0))
            /  sElyShrAgent(r,a,t0) ;

*     Set share for target year
*     sElyShrAgent(r,a,t)$(years(t) eq elyFinalYear) = min(max(0.95, sElyShrAgent(r,a,t0)), elyShrAgents(r,a)*sElyShrAgent(r,a,t0)) ;

      sElyShrAgent(r,a,tf00) = min(0.95, elyShrAgents(r,a)*sElyShrAgent(r,a,t0)) ;

*     Target eletricity bundle

      loop(t$(years(t) gt baseYear),
         if(years(t) le elyFinalYear,
            alpha_NRGB(r,a,"ely",v,t)$sElyShrAgent(r,a,t0)
               = alpha_NRGB(r,a,"ely",v,t-1)*power(1 + ((sElyShrAgent(r,a,tf00)/sElyShrAgent(r,a,t0))**(1/(elyFinalYear-baseYear))-1), gap(t)) ;
         elseif(years(t) gt elyFinalYear),
            alpha_NRGB(r,a,"ely",v,t)$sElyShrAgent(r,a,t0) = alpha_NRGB(r,a,"ely",v,t-1) ;
         ) ;
      ) ;

*     Target non-electric bundle

      loop(t$(years(t) gt baseYear),
         if(years(t) le elyFinalYear,
            alpha_nely(r,a,v,t)$(1-sElyShrAgent(r,a,t0))
               = alpha_nely(r,a,v,t-1)*power(1 + (((1-sElyShrAgent(r,a,tf00))/(1-sElyShrAgent(r,a,t0)))**(1/(elyfinalYear-baseYear))-1), gap(t)) ;
         elseif(years(t) gt elyFinalYear),
            alpha_nely(r,a,v,t)$(1-sElyShrAgent(r,a,t0)) = alpha_nely(r,a,v,t-1) ;
         ) ;
      ) ;
   ) ;
) ;

if(0,
   display sElyShrAgent, alpha_nely, alpha_NRGB ;
) ;
$endif.elyShr


$iftheni.powerTwists "%simType%" == "RcvDyn"

* Specify the twists for the power bundles

* display elyshr;

parameter elyShrTgtYear(r) /
USA        2030
EUR        2030
XOE        2030
CHN        2030
RUS        2030
OPC        2030
XEA        2030
SAS        2030
XLC        2030
ROW        2030
/ ;

parameter
   pbShr0(r,pb,elyc)      "Base year shares"
   pbShrT(r,pb,elyc)      "Desired shares"
   pbShrG(r,pb,elyc)      "Annualized growth rates of shares"
   pbShrTr(r,pb,elyc,t)   "Share trends"
;

set pbt(r,pb,elyc) "Targeted power bundle(s)" ;
alias(pbp,pb) ;

*  Calculate base year shares

pbShr0(r,pb,elyc) = sum(pbp,xpb.l(r,pbp,elyc,t0)*xpb0(r,pbp,elyc)) ;
pbShr0(r,pb,elyc)$pbShr0(r,pb,elyc) = xpb.l(r,pb,elyc,t0)*xpb0(r,pb,elyc)/pbShr0(r,pb,elyc) ;

*  If elyShr = na, assume base year shares

elyShr(r,pb,elyc)$(elyShr(r,pb,elyc) = na and pbShr0(r,pb,elyc)) = 100*pbShr0(r,pb,elyc) ;
* display pbshr0;

elyShr(r,pb,elyc) = 100*pbShr0(r,pb,elyc)$(elyShr(r,pb,elyc) = na and pbShr0(r,pb,elyc))
             + elyShr(r,pb,elyc)$(elyShr(r,pb,elyc) ne na and elyShr(r,pb,elyc) > 0)
             + na$(elyShr(r,pb,elyc) ne na and elyShr(r,pb,elyc) = 0)
             ;

pbt(r,pb,elyc)$(elyShr(r,pb,elyc) ne na) = yes ;

*  Direct calculation of lambdapow wrt to final desired share

*  Set targetted shares
pbShrT(r,pb,elyc)$(pbt(r,pb,elyc) and elyShr(r,pb,elyc) ne 0) = 0.01*elyShr(r,pb,elyc) ;

*  Allocate residual share to other bundles using base year shares
pbshrT(r,pb,elyc)$(not pbt(r,pb,elyc)) = (1 - sum(pbp$pbt(r,pbp,elyc), pbShrT(r,pbp,elyc)))
                              *  pbShr0(r,pb,elyc)/sum(pbp$(not pbt(r,pbp,elyc)), pbshr0(r,pbp,elyc)) ;

* display pbshrT;

*  Calculate the trend for shares

pbShrG(r,pb,elyc)$pbShr0(r,pb,elyc) = (pbshrT(r,pb,elyc)/pbShr0(r,pb,elyc))**(1/(elyShrTgtYear(r) - FirstYear)) - 1 ;
pbShrTr(r,pb,elyc,t0) = pbShr0(r,pb,elyc) ;
loop(t$(years(t) gt baseyear),
   pbShrTr(r,pb,elyc,t)$(pbt(r,pb,elyc)  and years(t) le elyShrTgtYear(r)) = pbShrTr(r,pb,elyc,t-1)*power(1 +  pbShrG(r,pb,elyc), gap(t)) ;
   pbshrTr(r,pb,elyc,t)$(not pbt(r,pb,elyc) and years(t) le elyShrTgtYear(r)) = sum(pbp$(not pbt(r,pbp,elyc)), pbshr0(r,pbp,elyc)) ;
   pbshrTr(r,pb,elyc,t)$(not pbt(r,pb,elyc) and years(t) le elyShrTgtYear(r) and pbshrTr(r,pb,elyc,t))
      = (1 - sum(pbp$pbt(r,pbp,elyc), pbShrTr(r,pbp,elyc,t)))*pbShr0(r,pb,elyc)/pbshrTr(r,pb,elyc,t) ;
   pbshrTr(r,pb,elyc,t)$(years(t) gt elyShrTgtYear(r)) = pbShrTr(r,pb,elyc,t-1) ;
) ;

*  Update the lambda's

loop(t$(years(t) gt baseyear and dynPhase ge 3),
   lambdapow(r,pb,elyc,t)$pbShrTr(r,pb,elyc,t) = lambdapow(r,pb,elyc,t-1)
         * (pbShrTr(r,pb,elyc,t-1)/pbShrTr(r,pb,elyc,t))**(1/sigmapow(r,elyc)) ;
) ;

$endif.powerTwists

$offtext
*  Define cost curve assumptions

Parameters
   costTgt(r,a)      "Cost reduction target for each activity"
   costMin(r,a)      "Long-term cost minimum--costMin < costTgt"
   costTgtYear(r,a)  "Target year"
   ifCostCurve(r,a)  "Cost curve flag"
;

*  Default assumptions

costTgt(r,a) = na ;
costMin(r,a) = na ;
costTgtYear(r,a) = na ;
ifCostCurve(r,a) = 0 ;

$iftheni.CostCurve "%simType%" == "RcvDyn"

*  Initialize for wind, solar, other

costTgt(r,"wnd-a")     = 0.90 ;
costMin(r,"wnd-a")     = 0.80 ;
costTgtYear(r,"wnd-a") = 2030 ;
ifCostCurve(r,"wnd-a") = 1 ;

costTgt(r,"sol-a")     = 0.80 ;
costMin(r,"sol-a")     = 0.60 ;
costTgtYear(r,"sol-a") = 2030 ;
ifCostCurve(r,"sol-a") = 1 ;

costTgt(r,"xel-a")     = 0.80 ;
costMin(r,"xel-a")     = 0.60 ;
costTgtYear(r,"xel-a") = 2030 ;
ifCostCurve(r,"xel-a") = 1 ;

$endif.CostCurve


$iftheni.bkStop "%ifBKSTP%" == "ON"
$iftheni.DYN "%simType%" == "RcvDyn"
*  Phase in assumptions

Table BStpPhaseIn(elya, *)
      Start   Stop  StopShare

clp-a  2030   2050     0.7
ccs-a  2030   2050     0.3

gsp-a  2030   2050     0.7
gcs-a  2030   2050     0.3

nuc-a  2030   2050     0.7
adv-a  2030   2050     0.3

;

loop(t$(t.val ge 2030),
   loop(elya$BStpPhaseIn(elya, "StopShare"),
*     Time increment
      work = (t.val - BStpPhaseIn(elya, "Start"))/(BStpPhaseIn(elya, "Stop")-BStpPhaseIn(elya, "Start")) ;
      alpha_s(r,elya,elyc,t)$shr0_s(r,elya,elyc) = (BStpPhaseIn(elya, "StopShare")/shr0_s(r,elya,elyc) - 1)*work + 1 ;
   ) ;
) ;

* display alpha_s ; abort "Temp" ;
$endif.DYN
$endif.bkStop

set ml / ml1*ml10 / ;
