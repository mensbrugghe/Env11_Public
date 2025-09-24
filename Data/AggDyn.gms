* ------------------------------------------------------------------------------
*
*  Aggregate the dynamic scenarios
*
* ------------------------------------------------------------------------------

Sets
   c           "Set of countries"
   reg         "GTAP regions"
   mapc(reg,c) "Mapping of countries to GTAP regions"
   r           "The modeled regions"
   mapr(r,reg) "The mapping from GTAP regions to the modeled regions"
   mapreg(r,c) "Mapping from countries to the modeled regions"
;

$gdxIn "%GTAPDIR%/%DataBase%Dat.gdx"
$load c, reg
$loaddc mapc
$gdxIn "%BaseName%/fnl/%Basename%Dat.gdx"
$load r=reg
$loaddc mapr=mapr0

*  Create the final mapping between c and r
loop((c,reg,r)$(mapc(reg,c) and mapr(r,reg)),
   mapreg(r,c) = yes ;
) ;

*  For testing purposes--there is a difference between ENV10 and ENV11 mappings
*$$gdxIn "v:/Env10/Data/ANX1/Fnl/ANX1Scn.gdx"
*$$load mapreg

Sets
   tt             "Full time path"              / 1950*2100 /
   th(tt)         "History"                     / 1950*2100 /
   Scen0          "Set of all scenarios"
   tranche        "Set of population cohorts"
   trs(tranche)   "Cohorts less total"
   mod            "Set of models"
   GHGCodes       "Set of GHG codes"
   vwb            "Set of World Bank variables"
   sex            "Gender set"
   sexx(sex)      "Excludes total"
   var            "SSP variable names"
   ed             "Education set"
;
$show
$gdxIn "%satDir%/%SSPFile%"
$load Scen0=Scen, tranche, mod=yMod, GHGCodes, vwb, sex, ed, var=v
$loaddc sexx

Sets
   Scen        "Set of all scenarios including GIDD" / set.Scen0, GIDD /
   SSP(scen)   "SSP scenarios"
;
$loaddc SSP, trs

alias(tt, tssp) ;

Parameters
   tPop(scen, c, tranche, tssp)
   popScen(scen, c, sex, tranche, ed, tssp)
   gdpScen(mod, ssp, var, c, tssp)
   popHist(c, tranche, th)
   GNPWDI(vwb,c,tt)
   ghghist(ghgcodes,c,th)
;

*  Load the SSP database

*  !!!! To fix: the SSP database contains ISO codes not in 'c', e.g., XKX and CHI
*execute_loaddc "%SSPFile%", tPop=pop, popScen, gdpScen, GNPWDI, popHist, ghgHist, popHist ;
* 13-May-2025: PopScen is now in a separate file
execute_load "%satDir%/%SSPFile%", tPop=pop, gdpScen, GNPWDI, popHist, ghgHist, popHist ;
execute_load "%satDir%/Pop%SSPFile%", popScen;

*  Education sets
*  !!!! May wish to move this to a file
sets
   edw "GIDD education labels" /
      educ0_6     "educ0_6"
      educ6_9     "educ6_9"
      educ9up     "educ9up"
      eductot     "eductot"
      /

   edwx(edw) "GIDD education labels /x total" /
      educ0_6     "educ0_6"
      educ6_9     "educ6_9"
      educ9up     "educ9up"
      /

   edj "Combined SSP/GIDD education levels" /
      elev0       "ENONE/EDUC0_6"
      elev1       "EPRIM/EDUC6_9"
      elev2       "ESECN/EDUC9UP"
      elev3       "ETERT"
      elevt       "Total"
   /
   mape2(edj, edw) "Mapping of GIDD education to edj" /
      elev0.EDUC0_6
      elev1.EDUC6_9
      elev2.EDUC9UP
      elevt.eductot
   /
   mape1(edj, ed) "Mapping of SSP education to edj" /
      elev0.NONE
      elev1.(PRMX,PRIM)
      elev2.(SECL,SECU)
      elev3.TERT
*     elevt.TOTL
   / 
;

Parameters
   tpop1(scen, r, tranche, tssp)
   popScen1(scen, r, tranche, edj, tssp)
   gdpScen1(mod, ssp, var, r, tssp)
   EXRREF(c)                           "Reference year exchange rate"
   PPP(c)
   PPP1(r,tssp)
   EXRREF1(r)
   popHist1(r, tranche, th)
   ghghist1(ghgcodes,r,th)
;
*  !!!! New: only aggregate data for which we have full data--this is based currently on the OECD's GDP series (until we gap fill)

$set VGDP      GDP|PPP
$set VGDPPC    GDP_per_capita|PPP
$set PPPYEAR   2017

Set
   GDPFlag(c)
;

singleton set vgdp(var)   / "%VGDP%" / ;
singleton set vgdppc(var) / "%VGDPPC%" / ;

GDPFlag(c)$gdpScen("OECD", "SSP2", vgdp, c, "%refyear%") = yes ;

*  Aggregate population (ignore gender)

tpop1(scen, r, tranche, tssp)             = sum(mapreg(r,c)$GDPFlag(c), tpop(scen, c, tranche, tssp)) ;
popScen1(scen, r, tranche, edj, tssp)     = sum(mapreg(r,c)$GDPFlag(c), sum((sexx,ed)$mape1(edj,ed), popScen(scen, c, sexx, tranche, ed, tssp))) ;
popHist1(r, tranche, th)                  = sum(mapreg(r,c)$GDPFlag(c), popHist(c, tranche, th)) ;
popScen1(scen, r, tranche, "elevt", tssp) = sum(edj$(not sameas(edj,"elevt")), popScen1(scen, r, tranche, edj, tssp)) ;

*  Aggregate GDP

singleton set tppp(tt) "PPP reference year" / %PPPYEAR% / ;

*  9-MAY-2022:DvdM Change to PPP05 for all variables
gdpScen1(mod, ssp, vgdp, r, tssp) = sum(mapreg(r,c)$GDPFlag(c), gdpScen(mod, ssp, vgdp, c, tssp)) ;
gdpScen1(mod, ssp, vgdppc, r, tssp)$tpop1(ssp,r,"PTOTL",tssp)
   = gdpScen1(mod, ssp, vgdp, r, tssp) / tpop1(ssp, r, "PTOTL", tssp) ;

* execute_unload "xxx", mape1, GDPFlag, gdpScen, tpop1, gdpScen1, popScen, popScen1 ; Abort$1 "Temp" ;
*  Aggregate PPP

*  Calculate country-specific PPP from WB data
PPP(c) = (GNPWDI("PPP",c,tppp) / GNPWDI("ATL",c,tppp))$GNPWDI("ATL",c,tppp) ;
*  Get the regional PPP using GDP weights
PPP1(r,tssp) = sum(mapreg(r,c)$(PPP(c) and GDPFlag(c)), gdpScen("OECD", "SSP2", vgdp, c, tssp)) ;
PPP1(r,tssp) = ( sum(mapreg(r,c)$(PPP(c) and GDPFlag(c)), gdpScen("OECD", "SSP2", vgdp, c, tssp) * PPP(c)) / PPP1(r,tssp))$PPP1(r,tssp)
             + 1$(not PPP1(r,tssp)) ;

*  Calculate the reference year exchange rate
EXRREF(c)  = (GNPWDI("LCU",c,"%RefYear%") / GNPWDI("ATL",c,"%RefYear%"))$GNPWDI("ATL",c,"%RefYear%") ;
EXRREF1(r) =  sum(mapreg(r,c)$(EXRREF(c) and GDPFlag(c)), GNPWDI("ATL",c,"%RefYear%")) ;
EXRREF1(r) = (sum(mapreg(r,c)$(EXRREF(c) and GDPFlag(c)), GNPWDI("ATL",c,"%RefYear%") * EXRREF(c)) / EXRREF1(r))$EXRREF1(r)
           + 1$(not EXRREF1(r)) ;

*  Aggregate GHG

ghghist1(ghgcodes,r,th)$(not sameas(ghgcodes,"NRGUSE")) = sum(mapreg(r,c)$GDPFlag(c), ghghist(ghgcodes, c, th)) ;
*  Energy is evaluated in per capita terms
ghghist1("NRGUSE",r,th) = sum(mapreg(r,c), popHist(c,"PTOTL",th)) ;
ghghist1("NRGUSE",r,th)$ghghist1("NRGUSE",r,th)
   = sum(mapreg(r,c)$GDPFlag(c), ghghist("NRGUSE", c, th)*popHist(c,"PTOTL",th))
   / ghghist1("NRGUSE",r,th) ;


* ------------------------------------------------------------------------------
*
*  Aggregate the GIDD population/education scenarios
*
* ------------------------------------------------------------------------------

*  !!!! Need to update for new GTAP versions

parameters
   GIDDPopProj(reg, edw, tranche, tssp)
   GIDDPopProj1(r, edw, tranche, tssp)
;

execute_load "%satDir%/%GIDDFile%", GIDDPopProj ;

*  Load the GIDD scenario

popScen1("GIDD", r, tranche, edj, tssp) = sum(reg$mapr(r,reg), sum(edw$mape2(edj, edw), GiDDPopProj(reg, edw, tranche, tssp))) ;

popScen1(scen,r,trs,"elevt",tssp) = sum(edj$(not sameas(edj,"elevt")), popScen1(scen,r,trs,edj,tssp)) ;
popScen1(scen,r,"ptotl",edj,tssp) = sum(trs, popScen1(scen,r,trs,edj,tssp)) ;
*  execute_unload "xxx.gdx", popScen1 ; ABort$1 "Temp" ;
tpop1("GIDD",r,tranche,tssp) = popScen1("GIDD",r,tranche,"elevt",tssp) ;

* --------------------------------------------------------------------------------------------------
*
*  Aggregate the WEO targets
*
* --------------------------------------------------------------------------------------------------

sets
   weo   "Set of WEO forecasts"
   ind   "Set of WEO indicators"
;

Parameter
   WEOData(weo,c,ind,tt) "WEO data"
;

$gdxin "../satAcct/WEOData.gdx"
$load weo, ind

execute_loaddc "../satAcct/WEOData.gdx", WEOData ;

set vWEO "WEO variables"   /
      RGDPDREF   "Real GDP in reference year dollars"
   /
   WEOFlag(weo,tt)
;

Parameter
   RGDPDREF(weo, c, tt)
   WEOData1(weo, r, vWEO, tt)
;

weoFlag(weo,tt)$sum(c,WEOData(weo, c, "PPPGDP", tt)) = yes ;

RGDPDREF(weo, c, "%RefYear%") = WEOData(weo, c, "NGDPD", "%RefYear%")$(WEOData(weo, c, "NGDPD", "%RefYear%") ne na) ;

loop((weo,tt)$(tt.val gt %RefYear% and weoFlag(weo,tt)),
   RGDPDREF(weo, c, tt)$(WEOData(weo, c, "NGDP_RPCH", tt) ne na) = RGDPDREF(weo, c, tt-1)*(1 + 0.01*WEOData(weo, c, "NGDP_RPCH", tt)) ;
) ;

scalar period ;

for(period=%RefYear% downto 1980 by 1,
   loop(tt$(tt.val = period),
      RGDPDREF(weo, c, tt-1)$(WEOData(weo, c, "NGDP_RPCH", tt) ne na) = RGDPDREF(weo, c, tt)/(1 + 0.01*WEOData(weo, c, "NGDP_RPCH", tt)) ;
   ) ;
) ;

WEOData1(weo, r, "RGDPDREF", tt) = sum(mapreg(r,c), RGDPDREF(weo, c, tt)) ;
execute_unload "%baseName%/Fnl/%baseName%Scn.gdx",
   c, reg, r, mapc, mapr, mapreg,
   Scen, SSP, tranche, trs, mod, GHGCodes, vwb, sex, sexx, var, edj,
   weo, vWEO, vgdp, vgdppc,
   tpop1=popscen, gdpscen1=gdpscen, PPP1=PPP, EXRREF1=EXRREF, popHist1=popHist, popScen1=educScen, weoData1=WEOData,
   ghgcodes, ghghist1=ghghist ;
;
