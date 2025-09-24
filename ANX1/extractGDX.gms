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

$setGlobal wdir         %system.fp%
$setGlobal SSPMOD       OECD
$setGlobal SSPSCEN      SSP2
$setGlobal LABSCEN      SSP2
$setGlobal POPSCEN      UNMED2015
$setGlobal OVERLAYPOP   0
$setGlobal TASS         LOGIST
$setGlobal WASS         LOGIST
$setGlobal utility      CDE
$setGlobal NRITER       0
$setGlobal savfFlag     capFix
$setGlobal intRate      0.05
$setGlobal costCurve    HYPERB
$setGlobal MRIO_MODULE  OFF
$setGlobal RD_MODULE    OFF
$setGlobal DEPL_MODULE  OFF

$show

$iftheni.Prelude "%simType%" == "compStat"

*  Define dynamic setup for a comparative static simulation

sets
   $$iftheni "%simName%" == "Comp"
      tt       "Full time horizon"        / base, check, shock /
      t(tt)    "Simulation time horizon"  / base, check, shock /
      t0(t)    "Base year"                / base /
   $$endif
   v        "Vintages"                 / Old /
   vOld(v)  "Old vintage"              / Old /
   vNew(v)  "New vintage"              / Old /
;

Parameters
   years(tt)
   firstYear      "First year of full time horizon"
   baseYear       "Simulation base year"
   finalYear
   gap(t)
;

years(tt) = ord(tt) ;
gap(t)    = 1 ;
firstYear = smin(tt,years(tt)) ;
loop(t0, baseYear = years(t0) ; ) ;
finalYear = smax(t,years(t)) ;

Scalars
   ifDyn       Set to 1 for dynamic simulation         / 0 /
   ifCal       Set to 1 for dynamic calibration        / 0 /
   ifVint      Set to 1 for vintage capital spec       / 0 /
;

$elseifi.Prelude "%simType%" == "RcvDyn"

*  Define dynamic setup for a dynamic simulation
*  tt must start in 2007 because of scenario file

sets
   tt       "Full time horizon"                / 1960*2100 /
   t(tt)    "Simulation time horizon"          / 2014, 2017*2030 /
   t0(t)    "Base year"                        / 2014 /
   tf(t)    "Final simulation year"            / 2030 /
   tf0(t)   "Year for starting savf phaseout"  / 2030 /
   tfT(t)   "Year for finishing savf phaseout" / 2030 /

   v        "Vintages"                         / Old, New /
   vOld(v)  "Old vintage"                      / Old /
   vNew(v)  "New vintage"                      / New /
;

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
loop(t0, baseYear = years(t0) ; ) ;
finalYear = smax(t,years(t)) ;

Scalars
   ifVint      Set to 1 for vintage capital spec       / 1 /
   ifDyn       Set to 1 for dynamic simulation         / 1 /
   ifCal       Set to 1 for dynamic calibration        / %ifCal% /
;

$else.Prelude

   Display "Wrong simulation type" ;
   Abort "Check listing file" ;

$endif.Prelude

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
   lScale      "Scale factor for labor volumes"          / 1e-6 /
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
   ifNRG       "Set to 1 to use energy volumes"          / 1 /
   intRate     "Interest rate"                           / %intRate% /
   ifNRGNest   "Set to 1 for energy nesting"             / 1 /
   ifMCP       "Set to 1 for MCP"                        / 1 /
   ifLandCET   "Set to 1 to use CET for land allocation" / 0 /
   ifSUB       "Set to 1 to substitute out equations"    / 1 /
   IFPOWER     "Set to 1 for power module"               / 1 /
   IFWATER     "Set to 1 for water module"               / 0 /
   ifAggTrade  "Set to 1 to aggregate trade in SAM"      / 0 /
   skLabgrwgt  "Set to between 0 and 1"                  / 0 /
;

*  CSV results go to this file

file
   fsam   / %odir%\%SIMNAME%SAM.csv /
   screen / con /
;

*  This file is optional--sometimes useful to debug model

file debug / %odir%\%SIMNAME%DBG.csv / ;
if(0,
   put debug ;
   put "Var,Region,Sector,Qual,Year,Value" / ;
   debug.pc=5 ;
   debug.nd=9 ;
) ;

*  CSV output options

scalars
   ifSAM "Flag for SAM CSV file" / 0 /
   ifSAMAppend "Flag to append to existing SAM CSV file" / 0 /
;

*  Start initializing the model--read the dimensions, parameters and the model specification

$include "%BASENAME%Sets.gms"
$include "%BASENAME%Prm.gms"
$include "model.gms"

* Z:\Output\Env10\EUCC0\Elas0XLSX

*set ssims / Elas0*Elas10 / ;
set ssims / BaU, noShk, cTax / ;

file csv / "%oDir%/ExtractGDX.csv" / ;
put csv ;
put "Sims,Var,Region,Qualifier,Year,Value" / ;
csv.pc=5 ;
csv.nd=9 ;

loop(ssims,
   csv.pc=2 ;
   put screen ;
   put_utility 'gdxIn' / "z:\output\env10\Anx1\", ssims.tl:0, ".gdx"
   execute_load uez, ewagez, ewagez0, cpi, cpi0 ;
   put csv ;
   csv.pc=5 ;
   loop((r,t),
      loop(l,
         put ssims.tl, "UEZ", r.tl, l.tl, t.val:4:0, uez.l(r,l,"nsg",t) / ;
      ) ;
   ) ;
) ;
