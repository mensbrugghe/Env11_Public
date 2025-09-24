*  Get the core options

$include "%BaseName%/%BaseName%Opt.gms"

*  Get the regional mappings

Set
   c           "Countries"
   reg         "Regions for this GTAP DB"
   mapc(reg,c) "Mapping from countries to GTAP regions"
   r           "Regions for the GTAP aggregation"
   mapr(r,reg) "Mapping from GTAP DB to current aggregation"
   acts        "Set of aggregate activities"
;

$gdxin %GTAPDir%\%DataBase%DAT.gdx
$load c, reg
$loaddc mapc

$gdxin %BaseName%/Fnl/%BaseName%Dat.gdx
$load r=reg1, acts
$loaddc mapr=mapr0

*  Get the Rystad data

sets
   ri0      "Rystad production sectors"
   rf0      "Resource types"
   s0       "Rystad scenarios"
   Commcl   "Commercialization"
   t        "Years of Rystad data"
;

Parameters
   RysProd(c, ri0, t)                     "Merged production data"
   RysRes(c, ri0, rf0, s0, t)             "Merged resources"
   RysTechRes(c, ri0, rf0, Commcl, t)     "Merged technical resources"
;   

$gdxIn %satDir%\%RystadFile%
$load ri0=fuels, rf0=lfCycle, s0=Scen, Commcl, t
$loaddc RysProd=RystadProd, RysRes=RystadResources, RysTechRes=RystadTechResources

*  Define the mappings for Envisage
sets
   ffl   "Oil and gas fuels" / oil, gas /
   mapRysp(ffl,ri0)  "Mapping from GTAP FFL to Rystad production types" /
                        oil.(oil,cnd,rfg,xlq)
                        gas.(gas,ngl,xgs)
                     /
   resType           "Reserve type"       / res, ytd /
   mapRysr(resType,rf0) /
                        res.(abd, prd, udv, dsc)
                        ytd.(ytd)
                        /
;

set oilgas(acts) "Oil and gas activities" / "%oil%", "%gas%" / ;
singleton set oil(oilgas) / "%oil%" / ;
singleton set gas(oilgas) / "%gas%" / ;
set mapacts(oilgas, ffl)  / "%oil%".oil, "%gas%".gas / ;

Parameters
   extraction(r,oilgas)    "Production (mbbl/year)"
   reserves(r,oilgas)      "Standard proven reserves (mbbl)"
   ytdreserves(r,oilgas)   "Standard yet-to-discover reserves (mbbl)"
;

*  Convert extraction to mbbl/year
extraction(r,oilgas) = (0.001*365)*sum((c,reg)$(mapc(reg,c) and mapr(r,reg)),
      sum((ffl,ri0)$(mapacts(oilgas, ffl) and mapRysp(ffl,ri0)), RysProd(c, ri0, "%RefYear%"))) ;
reserves(r,oilgas) = sum((c,reg)$(mapc(reg,c) and mapr(r,reg)),
      sum((ffl,ri0)$(mapacts(oilgas, ffl) and mapRysp(ffl,ri0)),
      sum(rf0$mapRysr("res",rf0), sum(Commcl, 
         RysTechRes(c, ri0, rf0, Commcl, "%RefYear%"))))) ;
ytdreserves(r,oilgas) = sum((c,reg)$(mapc(reg,c) and mapr(r,reg)),
      sum((ffl,ri0)$(mapacts(oilgas, ffl) and mapRysp(ffl,ri0)),
      sum(rf0$mapRysr("ytd",rf0), sum(Commcl, 
         RysTechRes(c, ri0, rf0, Commcl, "%RefYear%"))))) ;
      
Execute_unload "%BaseName%/Fnl/%BaseName%Depl.gdx",
   r, acts, oilgas, extraction, reserves, ytdreserves ;