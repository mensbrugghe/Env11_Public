* ------------------------------------------------------------------------------
*
*     Options for creating CSV cubes
*
*     Users typically select years to output and CSV cubes to create
*
* ------------------------------------------------------------------------------

*  Set folder for Excel files (it has to be full pathname)

$setGlobal xclDir "v:\env11\Anx1\Doc\"

*  Options for CreatePivot file

$setGlobal indir     %oDir%
$setGlobal wdir      %system.fp%
$setGlobal modDir    "..\Model"

*  AgMIP cube?
$setGlobal AgMIP No


$setGlobal DEPLFlag  OFF
$setGlobal simTgt    BaU
$setGlobal regTgt    USA
$setGlobal timeTgt   2017
$setGlobal actTgt    AGR-a

$ontext
$setGlobal DEPLFlag  OFF
$setGlobal simTgt    BAU
$setGlobal regTgt    USA
$setGlobal timeTgt   CHECK
$setGlobal actTgt    AGR-a
$offtext

*  Select report years

$iftheni "%simType%" == "compStat"

$ontext
   set tr(t) "Reporting years" / base, check, shock / ;
   set trb(t) "Bilateral trade years" / base, check, shock / ;
$offtext

   set tr(t) "Reporting years" / base, check, COMB1*COMB5, AllGHG1*AllGHG5 / ;
   set trb(t) "Bilateral trade years" / base, check / ;
   set trm(t) "MRIO years" / BASE / ;

$elseifi "%simType%" == "RcvDyn"

   set tr(t) "Reporting years" / 2017*2030 / ;
   set trb(t) "Bilateral trade years" / 2017, 2030 / ;
   set trm(t) "MRIO years" / 2017, 2030 / ;

$endif

*  Select reporting activities (a subset of aga -- activities + aggregate activities

set aggaga(aga) "Activities to report" ;

*  Report all

aggaga(aga) = yes ;

*  Select MRIO reporting commodities

set mrioc(r,i) "Commodities to report" ;
mrioc(r,i) = no ;

scalar elyPrmNrgConv "Primary electric conversion factor" / 3 / ;

set cpiLab / CPIFUD, CPINFD, CPITOT / ;
set mapCPILab(CPINDX,CPILAB) / TOT.cpiFUD, TOT.CPINFD, TOT.CPITOT / ;

set fpagg / nsk, skl, cap, nrs, lnd / ;
set mapfp(fpagg,fp) /
   nsk.nsk
   skl.skl
   cap.cap
   nrs.nrs
   lnd.lnd
/ ;

*  Pivot tables to create

*  List of tables

set tables /
   gdppop      "Macro data"
   factp       "Factor prices"
   kappah      "Household direct tax rate"
   rgovshr     "Government expenditures"
   savinv      "Savings investment balance"
   xp          "Output by activity"
   va          "Value added by activity and factor"
   inv         "Investment"
   emi         "Emissions"
   cost        "Production costs"
   ydecomp     "Growth decomposition"
   trade       "Trade by sector"
   ToT         "Terms of trade"
   fdem        "Final demand"
   bilat       "Bilateral trade"
   lab         "Labor demand"
   pow         "Power module"
   sam         "SAM module"
   MRIO        "MRIO table"
   nrg         "Energy module"
   depl        "Depletion variables"
   climate     "Climate module"
   shock       "For future use"
   demand      "Demand"
   welfDecomp  "Welfare decomposition"
   fbs         "Nutrition module"
   AgMIP       "Cube for AgMIP submission"
/ ;

*  Selected tables

set ifTab(tables) /
   gdppop      "Macro data"
*  emi         "Emissions"
*  sam         "SAM module"
*  MRIO        "MRIO table"
*  climate     "Climate module"
*  factp       "Factor prices"
*  kappah      "Household direct tax rate"
*  rgovshr     "Government expenditures"
*  savinv      "Savings investment balance"
*  xp          "Output by activity"
*  va          "Value added by activity and factor"
*  inv         "Investment"
*  cost        "Production costs"
*  ydecomp     "Growth decomposition"
*  trade       "Trade by sector"
*  ToT         "Terms of trade"
*  fdem        "Final demand"
*  bilat       "Bilateral trade"
*  lab         "Labor demand"
*  pow         "Power sector variables"
*  nrg         "Energy module"
*  depl        "Depletion variables"
*  shock       "For future use"
*  fbs         "Nutrition module"
*  welfDecomp  "Welfare decomposition"
*  AgMIP       "Cube for AgMIP submission"
/ ;
