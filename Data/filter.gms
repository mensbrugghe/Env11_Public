*-----------------------------------------------------------------------------------------
$ontext

   Envisage 11 project -- Data preparation modules

   GAMS file : LoadData.gms

   @purpose  : Loads the data for the filter routine

   @author   : Tom Rutherford, with modifications by Wolfgang Britz
               and adjustments for Env10 by Dominique van der Mensbrugghe
   @date     : 21.10.16
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : AggGTAP.cmd
   @Options  :

$offtext
*-----------------------------------------------------------------------------------------

*  Read the user-defined options for this run

$setGlobal PGMName      FILTER
$show
$include "%BaseName%/%BaseName%Flt.gms"

scalars
   ifFirstPass    / 1 /
;

file prnfile / "%BaseName%/%basename%Flt.prn" / ;
put  prnfile ;

*  Get the data

sets
   metaData "Database metaData"
   r        "Regions"
   i        "Commodities"
   img(i)   "Margin commodities"
   fp       "Factors of production"
   fpf(fp)  "Fixed factprs"
   fpm(fp)  "Perfectly mobile factprs"
   fps(fp)  "Sluggish factors"
   lab(fp)  "Labor factors"
   cap(fp)  "Capital factor"
   lnd(fp)  "Land factor"
   nrs(fp)  "Natural resource factor"
   
*  Transfer original sets to new data file
   reg0                 "GTAP regions"
   comm0                "GTAP commodities"
   acts0                "GTAP activities"
   endw0                "GTAP endowments"
   mapr0(r,reg0)        "Regional mapping"
   mapi0(i,comm0)       "Commodity mapping"
   mapa0(i,acts0)       "Activity mapping"
   mapf0(fp,endw0)      "Endowment mapping"
;

$gdxIn "%inFolder%/%BaseName%Dat.gdx"
$load metaData, r=reg, i=comm, fp=endw
$load reg0, comm0, acts0, endw0
$loaddc img=marg, fpf=endwf, fpm=endwm, fps=endws, lab, cap, lnd, nrs
$loaddc mapr0, mapi0, mapa0, mapf0

*  Assumes strict diagonality
alias(i,a) ;

alias(r,s) ; alias(r,d) ; alias(r,rp) ; alias(i,j) ;

*  Declare and read the GTAP data

Parameters
*  From the standard database

   VDFB(i, a, r)              "Firm purchases of domestic goods at basic prices"
   VDFP(i, a, r)              "Firm purchases of domestic goods at purchaser prices"
   VMFB(i, a, r)              "Firm purchases of imported goods at basic prices"
   VMFP(i, a, r)              "Firm purchases of domestic goods at purchaser prices"
   VDPB(i, r)                 "Private purchases of domestic goods at basic prices"
   VDPP(i, r)                 "Private purchases of domestic goods at purchaser prices"
   VMPB(i, r)                 "Private purchases of imported goods at basic prices"
   VMPP(i, r)                 "Private purchases of domestic goods at purchaser prices"
   VDGB(i, r)                 "Government purchases of domestic goods at basic prices"
   VDGP(i, r)                 "Government purchases of domestic goods at purchaser prices"
   VMGB(i, r)                 "Government purchases of imported goods at basic prices"
   VMGP(i, r)                 "Government purchases of domestic goods at purchaser prices"
   VDIB(i, r)                 "Investment purchases of domestic goods at basic prices"
   VDIP(i, r)                 "Investment purchases of domestic goods at purchaser prices"
   VMIB(i, r)                 "Investment purchases of imported goods at basic prices"
   VMIP(i, r)                 "Investment purchases of domestic goods at purchaser prices"

   EVFB(fp, a, r)             "Primary factor purchases at basic prices"
   EVFP(fp, a, r)             "Primary factor purchases at purchaser prices"
   EVOS(fp, a, r)             "Factor remuneration after income tax"

   VXSB(i, r, r)              "Exports at basic prices"
   VFOB(i, r, r)              "Exports at FOB prices"
   VCIF(i, r, r)              "Import at CIF prices"
   VMSB(i, r, r)              "Imports at basic prices"

   VST(i, r)                  "Exports of trade and transport services"
   VTWR(j, i, r, r)           "Margins by margin commodity"

   SAVE(r)                    "Net saving, by region"
   VDEP(r)                    "Capital depreciation"
   VKB(r)                     "Capital stock"
   POP(r)                     "Population"

   MAKS(i,a,r)                "Make matrix at supply prices"
   MAKB(i,a,r)                "Make matrix at basic prices (incl taxes)"
   PTAX(i,a,r)                "Output taxes"
;

execute_loaddc "%inFolder%/%BaseName%Dat.gdx",
   vdfb, vdfp, vmfb, vmfp,
   vdpb, vdpp, vmpb, vmpp,
   vdgb, vdgp, vmgb, vmgp,
   vdib, vdip, vmib, vmip,
   evfb, evfp, evos,
   vxsb, vfob, vcif, vmsb,
   vst, vtwr,
   save, vdep, vkb, pop,
   maks, makb, ptax
;

$include "filter/filter.gms"
