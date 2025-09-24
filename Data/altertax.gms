*$macro PUTYEAR years(t):4:0
$macro PUTYEAR t.tl
$setGlobal SIMNAME "AlterTax"
$setGlobal wDir  %baseName%/Agg2
$setGlobal inDir %baseName%/Agg2
$setGlobal oDir  %baseName%/Alt

sets
   tt       "Time framework"       / base, check, shock /
   t(tt)    "Model time framework" / base, check, shock /
   t0(t)    "Initial year"         / base /
   ts(t)    "Simulation years"
;

alias(tsim,t) ;

parameters
   year0       "Base year (in value)"
   FirstYear   "First year (in value)"
   years(tt)   "Vector of years in value"
   gap(tt)     "Gap between model years"
   ifSUB       "Set to 1 to substitute equations" / 1 /
   ifMCP       "Set to 1 to solve using MCP"      / 1 /
   inScale     "Scale for input data"             / 1e-6 /
   cScale      "Scale for input emissions data"   / 1e-3 /
   xpScale     "Scale factor for output"          / 1 /
   ifCal       "For dynamic version of model"     / 0 /
   ifDyn       "For dynamic version of model"     / 0 /
   ifDebug     "To debug model"                   / 0 /
   MRIO        "MRIO flag"                        / %ifMRIO% /
   niter(t)    "Number of iterations for solve"
   iter        "Iteration counter"
;

years(tt) = ord(tt) + 0 ;
loop(t0, year0 = years(t0) ; ) ;
FirstYear = year0 ;
gap(tt)   = 1 ;

singleton set t00(t) ; loop(t0, t00(t0) = yes ; ) ;

niter(t) = 1 ;
niter(t)$sameas("shock",t) = %niter% ;

file logFile / "%baseName%/%baseName%Alt.log" / ;
put logFile ;

$include "AlterTaxPrm.gms"
$include "%baseName%/%baseName%Sets.gms"
$include "model.gms"

* ------------------------------------------------------------------------------
*
*  OVERRIDE GTAP ELASTICITIES
*
* ------------------------------------------------------------------------------

work = 1.06 ;

sigmap(r,a)     = work ;
sigmav(r,a)     = work ;
sigmand(r,a)    = work ;
sigmai(r)       = work ;
sigmam(r,i,aa)  = work ;
sigmaw(r,i)     = work ;
sigmawa(r,i,aa) = work ;
RoRFlag         = capFix ;

*  >>>>> Utility is set to CD in *Prm.gms file

$include "getData.gms"

$include "cal.gms"

if(0,
   options limrow = 0, limcol = 0, solprint=off ;
else
   options limrow = 3000, limcol = 3, solprint=off ;
) ;

gtap.scaleopt   = 1 ;
gtap.tolinfrep  = 1e-5 ;

loop(tsim,

   $$include "iterloop.gms"

   rs(r)    = yes ;
   ts(t)    = no ;
   ts(tsim) = yes ;

   if(sameas(tsim,"shock"),

*  -----------------------------------------------------------------------------
*
*  IMPOSE SHOCK(S)
*
*  -----------------------------------------------------------------------------

      $$include "%BaseName%/%BaseName%Alt.gms"

   ) ;

   if(0,
      put logFile ;
      loop((r,a),
         put "LHS", r.tl, a.tl, (ctax.l(r,a,tsim)*px.l(r,a,tsim)*xp.l(r,a,tsim)*px0(r,a)*xp0(r,a)/inscale):20:12 / ;
         put "RHS", r.tl, a.tl, (sum(em, pcarb0(r)*(inscale/cscale)*procEmi0(r,em,a))/inscale):20:12 / ;
      ) ;
   ) ;

   if(years(tsim) gt year0,

      $$batinclude "solve.gms" gtap

   ) ;

   put logFile ;
   put / ;
   put "Walras (scaled): ", (walras.l(tsim)/inScale):15:6 / ;
   putclose logFile ;
   display walras.l ;

) ;

$batinclude "saveData" shock

Execute_Unload "%oDir%/AlterTax.gdx" ;
