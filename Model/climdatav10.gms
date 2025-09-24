*  Key parameters for climate module
*  Parameters are sourced from Hansel et al 2020, which has 2015 start year
*  and the DICE model
*  Where needed, they have been calibrated for a 2014 start year

scalar CCModVer / 2014 / ;
scalar ifFaIR2  / 1 / ;

*  Check consistency of start year with climate module

*  !!!! Move to input file?
*  Set to 1 to use average forcing over 2 years for multi-year time steps
scalar ifFORCAVG / 1 / ;
set mapt(tt,t)  "Mapping for each year tt to a solution period t for forcing" ;

$iftheni "%CLIM_MODULE%" == "ON"
   if(ifDyn,
      if(t0.val ne CCModVer,
         Display CCModVer ;
         Abort "Wrong climate module data for this version..." ;
      ) ;

*     Set up the bounds for the forcing impluse for the temperature module
*     E.g. if ifFORCAVG eq 1, bounds for 2023 are 2020 and 2025
*          if ifFORCAVG eq 0, use only 2025 level

      loop(t$(not t0(t)),
*        Lower bound
         if(ifFORCAVG and gap(t) gt 1,
            loop(tt$(tt.val gt t.val-gap(t) and tt.val lt t.val),
               mapt(tt,t-1) = yes ;
            ) ;
         ) ;
         mapt(tt,t)$(tt.val gt t.val-gap(t) and tt.val le t.val)   = yes ;
      ) ;
   else
      mapt(tt,t) = no ;
   ) ;
$endif

*  Sets used for the climate module

sets
   b "Carbon reservoirs" /
      GEOPR "Geological processes"
      DPOCN "Deep ocean"
      BIOSF "Biosphere"
      MXOCN "Ocean mixed layer"
   /

   tb "Temperature boxes" /
      ATMOS    "Atmosphere"
      UPOCN    "Upper ocean"
      DPOCN    "Deep ocean"
   /
;

alias(tb, tbp) ;

scalar CO22C  "Conversion from CO2 to C" ;
CO22C = 44/12 ;

Parameters

*  Emission assumptions

*  Use the 2015 figure for 2014
   EmiLAND0       "Carbon emissions from land 2015 (GtCO2)"              /   2.6 /
   CumEmiLAND0    "Cumulative emissions in 2014 (GTC)"                   / 196.29 /
*  CumEmiLAND0    "Cumulative emissions in 2015 (GTC)"                   / 197.0 /
   EmiCO2Tgt0     "Industrial emissions in 2014--source: EDGAR (GtCO2)"  /  36.24449 /
   CumEmiInd0     "Cumulative emissions in 2014 (GTC)"                   / 390.115 /
*  CumEmiInd0     "Cumulative emissions in 2015 (GTC)"                   / 400.0   /

   ForcOth0       "Non-CO2 forcing 2014 (w/m2)"                          / 0.31 /
*  ForcOth0       "Non-CO2 forcing 2015 (w/m2)"                          / 0.31 /

*  Carbon cycle parameters
*  AMPL uses MAT0=(127.159+93.313+37.840+7.721)+588.000=854.033
   mat00          "Initial Concentration in atmosphere 2014 (GtC)"    / 851.1019 /
*  mat00          "Initial Concentration in atmosphere 2015 (GtC)"    /  854 /
   mat_eq         "Equilibrium concentration atmosphere  (GtC)"       /  588 /
   alpha0         "Initial alpha parameter is calibrated from DICE"   / 0.4577949548 /

** Climate model parameters
   tatm0          "2014 atmospheric temp change (C from 1900)"             / 0.730084 /
   tocean0        "2014 lower stratum temp change (C from 1900)"           / 0.001784 /
*  tatm0          "2015 atmospheric temp change (C from 1900)"             / 0.85     /
*  tocean0        "2015 lower stratum temp change (C from 1900)"           / 0.0068   /
   t2xco2         "Equilibrium temp impact (degree C per doubling CO2)"    / 3.1      /
   fco22x         "Forcings of equilibrium CO2 doubling (Wm-2)"            / 3.6813   /
;

* ------- Box specific carbon cycle parameters

Table CResData(b,*)
            TAU   FRACTION     L2014        L2015
GEOPR   1000000    0.2173    124.85721    127.159
DPOCN     394.4    0.2240     91.44643     93.313
BIOSF     36.54    0.2824     37.06398     37.840
MXOCN     4.304    0.2763      9.73427      7.721
;

Parameters
   tau(b)      "Time constant in carbon cycle model"
   phi(b)      "Emission fraction in carbon cycle"
;
tau(b) = CResData(b,"TAU") ;
phi(b) = CResData(b,"FRACTION") ;

*  Source Millar et al 2017.
*  N.B. r0 = 32.4 in the original paper

scalar r0   "Preindustrial iIRF100" / 35 / ;
scalar rC   "Increase in iIRF100 with cumulative carbon uptake" / 0.019 / ;
scalar rT   "Increase in iIRF100 with warming" / 4.165 / ;

*  For temperature module

*  From Geoffroy et al. 2013, Table 4, multi-model means

Parameters
   lambdaTemp        "Radiative feedback parameter"
   epsilonTemp       "Adjustment factor for transitive temperature"
   heatExch(tb)      "Coefficient of heat exchange"
   effHeatCap(tb)    "Effective heat capacity per box"

   amat(tb,tbp)      "Temperature transition matrix"
   amat1(tb,tbp)     "ID + AMAT"
   fmat(tb)          "Forcing impuluse matrix"
;

if(not ifFaIR2,

*  Use FAIR 1.5 -- only 2 boxes

   lambdaTemp = fco22x/t2xco2 ;
   effHeatCap("atmos") = 7.3 ;
   effHeatCap("upocn") = 106 ;
   heatExch("UPOCN")   = 0.73 ;
   epsilonTemp = 0 ;

else

*  Use FAIR 2.0 -- three boxes

   lambdatemp = 1.15920000002258 ;
   effHeatCap("atmos") =  4.2035927470275 ;
   effHeatCap("upocn") =  14.413011528862 ;
   effHeatCap("dpocn") = 140.7080460951 ;
   heatExch("upocn")   =   2.82511248993597 ;
   heatExch("dpocn")   =   1.02531874647441 ;
   epsilonTemp = 1.2 ;

) ;

amat(tb,tbp) = 0 ;
fmat(tb)     = 0 ;

amat("atmos","atmos") = -(lambdatemp + heatExch("upocn")) ;
amat("atmos","upocn") = heatExch("upocn") ;

amat("upocn","atmos") = heatExch("upocn") ;
amat("upocn","upocn") = -(heatExch("upocn")
                      +    epsilonTemp*heatExch("dpocn")) ;
amat("upocn","dpocn") = epsilonTemp*heatExch("dpocn") ;

amat("dpocn","upocn") = heatExch("dpocn") ;
amat("dpocn","dpocn") = -heatExch("dpocn") ;

amat(tb, tbp)$effHeatCap(tb) = amat(tb, tbp)/effHeatCap(tb) ;

amat1(tb, tbp) = amat(tb, tbp) + 1$sameas(tb,tbp) ;

display amat1 ;

fmat("atmos")$effHeatCap("atmos")  = 1 / effHeatCap("atmos") ;
