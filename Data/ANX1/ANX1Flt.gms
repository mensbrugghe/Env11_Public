$setGlobal excCombined  0

*$setglobal excSecs "sol, wnd, xel, ccs, gcs, adv"
$setglobal excSecs "sol, wnd, xel"
$setglobal excRegs

scalars
   ifKeepIntermediateConsumption / 1 /
   ifKeepPrivateconsumption      / 1 /
   ifKeepGovernmentconsumption   / 1 /
   ifKeepInvestments             / 1 /
   ifGDPKeep                     / 1 /
   ifKeepFactorincomeplusbop     / 1 /
   ifAdjDepr                     / 1 /
   abstol                        / 1e-10 /
   relTol                        / 0.005 /
   relTolRed                     / 1e-6  /
   nsteps                        / 5 /
   minNumTransactions            / 50000 /
;

file log / %baseName%flt.log / ;
put log ;
