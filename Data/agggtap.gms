*-----------------------------------------------------------------------------------------
$ontext

   Envisage 11 project -- Data preparation modules

   GAMS file : AggGTAP.gms

   @purpose  : Aggregate standard GTAP database--emulation the GTAPAgg GEMPACK program.

   @author   : Dominique van der Mensbrugghe
   @date     : 21.10.16
   @since    :
   @refDoc   :
   @seeAlso  :

$offtext
*-----------------------------------------------------------------------------------------

* ----------------------------------------------------------------------------------------
*
*  GAMS program to aggregate a GTAP database
*
* ----------------------------------------------------------------------------------------

file logFile / "%BaseName%/%BaseName%Log.txt" /;
put logFile ;
put "Start of aggregation..." / ;

*  Define the aggregation macros

$macro AGG1(v0,v,x0,x,mapx)                     v(x)     = sum(x0$mapx(x,x0), v0(x0))
$macro AGG2(v0,v,x0,x,mapx,y0,y,mapy)           v(x,y)   = sum((x0,y0)$(mapx(x,x0) and mapy(y,y0)), v0(x0,y0))
$macro AGG3(v0,v,x0,x,mapx,y0,y,mapy,z0,z,mapz) v(x,y,z) = sum((x0,y0,z0)$(mapx(x,x0) and mapy(y,y0) and mapz(z,z0)), v0(x0,y0,z0))
$macro AGG4(v0,v,x0,x,mapx,y0,y,mapy,z0,z,mapz,w0,w,mapw) v(x,y,z,w) = sum((x0,y0,z0,w0)$(mapx(x,x0) and mapy(y,y0) and mapz(z,z0) and mapw(w,w0)), v0(x0,y0,z0,w0))

*  If this is a secondary aggregation, read the initial aggregation sets and mappings

acronyms aggPrimary, aggSecondary ;

*  Declare and load core GTAP sets from the version defined above

Sets
   reg         "Regions in GTAP"
   acts        "Activities in GTAP"
   comm        "Commodities"
   marg(comm)  "Margin activities"
   erg(comm)   "Energy commodities"
   fuel(erg)   "Fuel commodities"
   endw        "Endowments"
   metaData    "Load the metadata"
;

$gdxin "%GTAPDir%/%DataBase%DAT.gdx"
$load metaData
$load reg
$load acts
$load comm
$loaddc marg
$load endw

$gdxin "%GTAPDir%/%DataBase%VOLE.gdx"
$loaddc erg

$gdxin "%GTAPDir%/%DataBase%EMISS.gdx"
$loaddc fuel

alias(reg,r0) ;
alias(reg,rp0) ;
alias(comm, i0) ;
alias(acts, a0) ;
alias(endw, fp0) ;
alias(img0, marg) ;
alias(reg,src) ;
alias(reg,dst) ;

*  Load the aggregation mappings

$include "%BaseName%/%MapName%.gms"

*  Load the primary mappings

$iftheni.AggSec "%aggStep%" == "aggSecondary"
   Sets
      reg0        "Regions in GTAP"
      acts0       "Activities in GTAP"
      comm0       "Commodities in GTAP"
      endw0       "Endowments in GTAP"

      mapr0(reg,reg0)      "Mapping from original regions to primary regions"
      mapa0(acts,acts0)    "Mapping from original activities to primary activities"
      mapi0(comm,comm0)    "Mapping from original commodities to primary commodities"
      mapf0(endw,endw0)    "Mapping from original endowments to primary endowments"
   ;

   $$gdxIn "%GTAPDir%/%DataBase%DAT.gdx"
   $$load   reg0, acts0, comm0, endw0
   $$loaddc mapr0, mapa0, mapi0, mapf0
$endif.AggSec

*  Check mappings

scalar ifAllCheck / 0 / ;
scalar check      / 0 / ;

put "Checking the mappings..." / ;

$batInclude "CheckMap" mapr reg  r  regions
$batInclude "CheckMap" mapa acts a  activities
$batInclude "CheckMap" mapi comm i  commodities
$batInclude "CheckMap" mapf endw fp factors

Abort$ifAllCheck "At least one aggregation mapping requires checking" ;

put "All mappings checked out..." / ;

* ------------------------------------------------------------------------------
*
*  Aggregate the GTAP data
*
* ------------------------------------------------------------------------------

put "Aggregating the main database..." / ;
parameters

*  From the standard database

   VDFB(COMM, ACTS, REG)            "Firm purchases of domestic goods at basic prices"
   VDFP(COMM, ACTS, REG)            "Firm purchases of domestic goods at purchaser prices"
   VMFB(COMM, ACTS, REG)            "Firm purchases of imported goods at basic prices"
   VMFP(COMM, ACTS, REG)            "Firm purchases of domestic goods at purchaser prices"
   VDPB(COMM, REG)                  "Private purchases of domestic goods at basic prices"
   VDPP(COMM, REG)                  "Private purchases of domestic goods at purchaser prices"
   VMPB(COMM, REG)                  "Private purchases of imported goods at basic prices"
   VMPP(COMM, REG)                  "Private purchases of domestic goods at purchaser prices"
   VDGB(COMM, REG)                  "Government purchases of domestic goods at basic prices"
   VDGP(COMM, REG)                  "Government purchases of domestic goods at purchaser prices"
   VMGB(COMM, REG)                  "Government purchases of imported goods at basic prices"
   VMGP(COMM, REG)                  "Government purchases of domestic goods at purchaser prices"
   VDIB(COMM, REG)                  "Investment purchases of domestic goods at basic prices"
   VDIP(COMM, REG)                  "Investment purchases of domestic goods at purchaser prices"
   VMIB(COMM, REG)                  "Investment purchases of imported goods at basic prices"
   VMIP(COMM, REG)                  "Investment purchases of domestic goods at purchaser prices"

   EVFB(ENDW, ACTS, REG)            "Primary factor purchases at basic prices"
   EVFP(ENDW, ACTS, REG)            "Primary factor purchases at purchaser prices"
   EVOS(ENDW, ACTS, REG)            "Factor remuneration after income tax"

   VXSB(COMM, REG, REG)             "Exports at basic prices"
   VFOB(COMM, REG, REG)             "Exports at FOB prices"
   VCIF(COMM, REG, REG)             "Import at CIF prices"
   VMSB(COMM, REG, REG)             "Imports at basic prices"

   VST(MARG, REG)                   "Exports of trade and transport services"
   VTWR(MARG, COMM, REG, REG)       "Margins by margin commodity"

   SAVE(REG)                        "Net saving, by region"
   VDEP(REG)                        "Capital depreciation"
   VKB(REG)                         "Capital stock"
   POP(REG)                         "Population"

   MAKS(COMM,ACTS,REG)              "Make matrix at supply prices"
   MAKB(COMM,ACTS,REG)              "Make matrix at basic prices (incl taxes)"
   PTAX(COMM,ACTS,REG)              "Output taxes"

*  Auxiliary data

   VOA(ACTS, REG)                   "Value of output pre-tax"
   VOS(COMM, REG)                   "Value of domestic supply"
;

*  Load the GTAP data base

execute_loaddc "%GTAPDir%/%DataBase%DAT.gdx"
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

voa(acts,reg) = sum(comm, vdfp(comm,acts,reg) + vmfp(comm,acts,reg)) + sum(endw, evfp(endw,acts,reg)) ;

voa(acts,reg) = voa(acts,reg) + sum(comm, makb(comm,acts,reg) - maks(comm,acts,reg)) ;

vos(comm,reg)$(not marg(comm))
              = sum(acts, vdfb(comm,acts,reg)) + vdpb(comm,reg) + vdgb(comm,reg) + vdib(comm,reg)
              + sum(dst, vxsb(comm,reg,dst)) ;
vos(marg,reg) = sum(acts, vdfb(marg,acts,reg)) + vdpb(marg,reg) + vdgb(marg,reg) + vdib(marg,reg)
              + vst(marg,reg) + sum(dst, vxsb(marg,reg,dst)) ;

* ----------------------------------------------------------------------------------------
*
*  Declare the aggregated parameters
*
* ----------------------------------------------------------------------------------------

alias(r,rp) ; alias(r,s) ; alias(r,d) ; alias(img,i) ; alias(a,a1) ;

parameters
   VDFB1(i, a, r)             "Firm purchases of domestic goods at basic prices"
   VDFP1(i, a, r)             "Firm purchases of domestic goods at purchaser prices"
   VMFB1(i, a, r)             "Firm purchases of imported goods at basic prices"
   VMFP1(i, a, r)             "Firm purchases of domestic goods at purchaser prices"
   VDPB1(i, r)                "Private purchases of domestic goods at basic prices"
   VDPP1(i, r)                "Private purchases of domestic goods at purchaser prices"
   VMPB1(i, r)                "Private purchases of imported goods at basic prices"
   VMPP1(i, r)                "Private purchases of domestic goods at purchaser prices"
   VDGB1(i, r)                "Government purchases of domestic goods at basic prices"
   VDGP1(i, r)                "Government purchases of domestic goods at purchaser prices"
   VMGB1(i, r)                "Government purchases of imported goods at basic prices"
   VMGP1(i, r)                "Government purchases of domestic goods at purchaser prices"
   VDIB1(i, r)                "Investment purchases of domestic goods at basic prices"
   VDIP1(i, r)                "Investment purchases of domestic goods at purchaser prices"
   VMIB1(i, r)                "Investment purchases of imported goods at basic prices"
   VMIP1(i, r)                "Investment purchases of domestic goods at purchaser prices"

   EVFB1(fp, a, r)            "Primary factor purchases at basic prices"
   EVFP1(fp, a, r)            "Primary factor purchases at purchaser prices"
   EVOS1(fp, a, r)            "Factor remuneration after income tax"

   VXSB1(i, r, r)             "Exports at basic prices"
   VFOB1(i, r, r)             "Exports at FOB prices"
   VCIF1(i, r, r)             "Import at CIF prices"
   VMSB1(i, r, r)             "Imports at basic prices"

   VST1(img, r)               "Exports of trade and transport services"
   VTWR1(img, i, r, r)        "Margins by margin commodity"

   SAVE1(r)                   "Net saving, by region"
   VDEP1(r)                   "Capital depreciation"
   VKB1(r)                    "Capital stock"
   POP1(r)                    "Population"

   MAKS1(i,a,r)               "Make matrix at supply prices"
   MAKB1(i,a,r)               "Make matrix at basic prices (incl taxes)"
   PTAX1(i,a,r)               "Output taxes"

*  Auxiliary data
   voa1(a,r)                  "Value of output pre-tax"
   voi1(i,r)                  "Value of supply post-tax"
   vos1(i,r)                  "Value of use of domestic production"
;

*  Aggregate the GTAP matrices

Agg3(vdfb,vdfb1,i0,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg3(vdfp,vdfp1,i0,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg3(vmfb,vmfb1,i0,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg3(vmfp,vmfp1,i0,i,mapi,a0,a,mapa,r0,r,mapr) ;

Agg2(vdpb,vdpb1,i0,i,mapi,r0,r,mapr) ;
Agg2(vdpp,vdpp1,i0,i,mapi,r0,r,mapr) ;
Agg2(vmpb,vmpb1,i0,i,mapi,r0,r,mapr) ;
Agg2(vmpp,vmpp1,i0,i,mapi,r0,r,mapr) ;

Agg2(vdgb,vdgb1,i0,i,mapi,r0,r,mapr) ;
Agg2(vdgp,vdgp1,i0,i,mapi,r0,r,mapr) ;
Agg2(vmgb,vmgb1,i0,i,mapi,r0,r,mapr) ;
Agg2(vmgp,vmgp1,i0,i,mapi,r0,r,mapr) ;

Agg2(vdib,vdib1,i0,i,mapi,r0,r,mapr) ;
Agg2(vdip,vdip1,i0,i,mapi,r0,r,mapr) ;
Agg2(vmib,vmib1,i0,i,mapi,r0,r,mapr) ;
Agg2(vmip,vmip1,i0,i,mapi,r0,r,mapr) ;

Agg3(VXSB,VXSB1,i0,i,mapi,r0,r,mapr,rp0,rp,mapr) ;
Agg3(VFOB,VFOB1,i0,i,mapi,r0,r,mapr,rp0,rp,mapr) ;
Agg3(VCIF,VCIF1,i0,i,mapi,r0,r,mapr,rp0,rp,mapr) ;
Agg3(VMSB,VMSB1,i0,i,mapi,r0,r,mapr,rp0,rp,mapr) ;

Agg3(evfb,evfb1,fp0,fp,mapf,a0,a,mapa,r0,r,mapr) ;
Agg3(evfp,evfp1,fp0,fp,mapf,a0,a,mapa,r0,r,mapr) ;
Agg3(evos,evos1,fp0,fp,mapf,a0,a,mapa,r0,r,mapr) ;

Agg2(VST,VST1,img0,img,mapi,r0,r,mapr) ;

Agg4(VTWR,VTWR1,img0,img,mapi,i0,i,mapi,r0,r,mapr,rp0,rp,mapr) ;

Agg1(SAVE,SAVE1,r0,r,mapr) ;
Agg1(VDEP,VDEP1,r0,r,mapr) ;
Agg1(VKB,VKB1,r0,r,mapr) ;
Agg1(POP,POP1,r0,r,mapr) ;

Agg3(maks,maks1,i0,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg3(makb,makb1,i0,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg3(ptax,ptax1,i0,i,mapi,a0,a,mapa,r0,r,mapr) ;

voa1(a,r) = sum(i, maks1(i,a,r)) ;
voi1(i,r) = sum(a, makb1(i,a,r)) ;

*  Move land to capital

loop((cap,lnd,a)$mapt(a),
   evfp1(cap,a,r) = evfp1(cap,a,r) + evfp1(lnd,a,r) ;
   evfp1(lnd,a,r) = 0 ;
   evfb1(cap,a,r) = evfb1(cap,a,r) + evfb1(lnd,a,r) ;
   evfb1(lnd,a,r) = 0 ;
   evos1(cap,a,r) = evos1(cap,a,r) + evos1(lnd,a,r) ;
   evos1(lnd,a,r) = 0 ;
) ;


*  Move natural resource to capital

loop((cap,nrs,a)$mapn(a),
   evfp1(cap,a,r) = evfp1(cap,a,r) + evfp1(nrs,a,r) ;
   evfp1(nrs,a,r) = 0 ;
   evfb1(cap,a,r) = evfb1(cap,a,r) + evfb1(nrs,a,r) ;
   evfb1(nrs,a,r) = 0 ;
   evos1(cap,a,r) = evos1(cap,a,r) + evos1(nrs,a,r) ;
   evos1(nrs,a,r) = 0 ;
) ;

*  Save the data

sets
   img1(i)  "Margin commodities"
;

img1(i)$(sum(r,vst1(i,r)) > 0) = yes ;

voa1(a,r) = sum(i, vdfp1(i,a,r) + vmfp1(i,a,r)) + sum(fp, evfp1(fp,a,r)) ;

voa1(a,r) = voa1(a,r) + sum(i, makb1(i,a,r) - maks1(i,a,r)) ;

vos1(i,r)$(not img1(i))
              = sum(a, vdfb1(i,a,r)) + vdpb1(i,r) + vdgb1(i,r) + vdib1(i,r)
              + sum(d, vxsb1(i,r,d)) ;
vos1(img1,r) = sum(a, vdfb1(img1,a,r)) + vdpb1(img1,r) + vdgb1(img1,r) + vdib1(img1,r)
              + vst1(img1,r) + sum(d, vxsb1(img1,r,d)) ;

put "Saving the main database..." / ;

*  Create the directory if it does not exist

$if not exist "%BaseName%/%outDir%" $call mkdir "%BaseName%/%outDir%"

execute_unload "%BaseName%/%outDir%/%baseName%Dat.gdx",
   metaData,
   a=acts, i=comm, img1=marg, r=reg, fp=endw,
   fpf=endwf, fpm=endwm, fps=endws,
   l=LAB, cap, lnd, nrs,
$iftheni.AggPrim "%aggStep%" == "aggPrimary"
*  Save the mapping from GTAP to the primary aggregation
   reg=REG0, comm=COMM0, acts=ACTS0, endw=ENDW0,
   mapr=mapr0, mapi=mapi0, mapa=mapa0, mapf=mapf0,
$else.AggPrim
*  Save both primary and secondary mappings
   reg0, comm0, acts0, endw0,
   mapr0, mapi0, mapa0, mapf0
   reg=REG1, comm=COMM1, acts=ACTS1, endw=ENDW1,
   mapr=mapr1, mapi=mapi1, mapa=mapa1, mapf=mapf1,
$endif.AggPrim
   vdfb1=vdfb, vdfp1=vdfp, vmfb1=vmfb, vmfp1=vmfp,
   vdpb1=vdpb, vdpp1=vdpp, vmpb1=vmpb, vmpp1=vmpp,
   vdgb1=vdgb, vdgp1=vdgp, vmgb1=vmgb, vmgp1=vmgp,
   vdib1=vdib, vdip1=vdip, vmib1=vmib, vmip1=vmip,
   evfb1=evfb, evfp1=evfp, evos1=evos,
   vxsb1=vxsb, vfob1=vfob, vcif1=vcif, vmsb1=vmsb,
   vst1=vst,   vtwr1=vtwr,
   save1=save, vdep1=vdep,
   vkb1=vkb,   pop1=pop,
   maks1=maks, makb1=makb, ptax1=ptax,
   voa1=voa, vos1=vos
;

* ------------------------------------------------------------------------------
*
*  Aggregate GTAP parameters
*
* ------------------------------------------------------------------------------

put "Aggregating the standard parameters..." / ;

*  GTAP parameters

parameters
   ESUBT(ACTS,REG)         "Top level production elasticity"
   ESUBC(ACTS,REG)         "Elasticity across intermedate inputs"
   ESUBVA(ACTS,REG)        "Inter-factor substitution elasticity"
   ETRAQ(ACTS,REG)         "CET make elasticity"
   ESUBQ(COMM,REG)         "CES make elasticity"
   INCPAR(COMM, REG)       "CDE expansion parameter"
   SUBPAR(COMM, REG)       "CDE substitution parameter"
   ESUBG(REG)              "CES government expenditure elasticity"
   ESUBI(REG)              "CES investment expenditure elasticity"
   ESUBD(COMM,REG)         "Top level Armington elasticity"
   ESUBM(COMM,REG)         "Second level Armington elasticity"
   ESUBS(MARG)             "CES margin elasticity"
   ETRAE(ENDW,REG)         "CET transformation elasticities for factors"
   RORFLEX(REG)            "Flexibility of expected net ROR wrt investment"
;

*  Load the data

execute_loaddc "%GTAPDir%/%DataBase%PAR.gdx"
   ESUBT, ESUBC, ESUBVA, ETRAQ, ESUBQ,
   INCPAR, SUBPAR, ESUBG, ESUBI,
   ESUBD, ESUBM, ESUBS, ETRAE, RORFLEX
;

*  Aggregate to intermediate levels

parameters
   ESUBT1(a,r)          "Top level production elasticity"
   ESUBC1(a,r)          "Elasticity across intermedate inputs"
   ESUBVA1(a,r)         "Inter-factor substitution elasticity"
*  USER SUPPLIED
*  ETRAQ1(a,r)          "CET make elasticity"
*  ESUBQ1(i,r)          "CES make elasticity"
   INCPAR1(i,r)         "CDE expansion parameter"
   SUBPAR1(i,r)         "CDE substitution parameter"
*  USER SUPPLIED
*  ESUBG1(r)            "CES government expenditure elasticity"
*  ESUBI1(r)            "CES investment expenditure elasticity"
   ESUBD1(i,r)          "Top level Armington elasticity"
   ESUBM1(i,r)          "Second level Armington elasticity"
*  USER SUPPLIED
   ESUBS1(i)            "CES margin elasticity"
   RORFLEX1(r)          "Flexibility of expected net ROR wrt investment"
;

*  Aggregate the data

*  ESUBT -- use regional output as weight

esubt1(a,r) = sum(a0$mapa(a,a0), sum(reg$mapr(r,reg), voa(a0, reg))) ;
esubt1(a,r)$esubt1(a,r) = sum(a0$mapa(a,a0),
      sum(reg$mapr(r,reg), voa(a0, reg)*ESUBT(a0,reg))) / esubt1(a,r) ;

*  ESUBC -- use regional intermediate demand at purchasers' prices as weight

esubc1(a,r) = sum(a0$mapa(a,a0), sum((reg,i0)$mapr(r,reg), (vdfp(i0,a0,reg)+vmfp(i0,a0,reg)))) ;
esubc1(a,r)$esubc1(a,r) = sum(a0$mapa(a,a0), sum((reg,i0)$mapr(r,reg),
      (vdfp(i0,a0,reg)+vmfp(i0,a0,reg))*ESUBC(a0,reg))) / esubc1(a,r) ;

*  ESUBVA -- use regional value added at agents' prices as weight

esubva1(a,r) = sum(a0$mapa(a,a0), sum((reg,fp0)$mapr(r,reg), evfp(fp0, a0, reg))) ;
esubva1(a,r)$esubva1(a,r) = sum(a0$mapa(a,a0),
      sum((reg,fp0)$mapr(r,reg), evfp(fp0, a0, reg)*ESUBVA(a0,reg))) / esubva1(a,r) ;

*  INCPAR, SUBPAR -- Use regional private demand at agents' prices

incpar1(i,r) = sum((i0,r0)$(mapi(i,i0) and mapr(r,r0)), vdpp(i0,r0) + vmpp(i0,r0)) ;
subpar1(i,r) = incpar1(i,r) ;
incpar1(i,r)$incpar1(i,r)
          = sum((i0,r0)$(mapi(i,i0) and mapr(r,r0)), INCPAR(i0,r0)*(vdpp(i0,r0) + vmpp(i0,r0)))
          / incpar1(i,r) ;
subpar1(i,r)$subpar1(i,r)
          = sum((i0,r0)$(mapi(i,i0) and mapr(r,r0)), SUBPAR(i0,r0)*(vdpp(i0,r0) + vmpp(i0,r0)))
          / subpar1(i,r) ;

*  ESUBD -- Use regional aggregate Armington demand

esubd1(i,r) = sum(i0$mapi(i,i0), sum(reg$mapr(r,reg),
               sum(a0, vdfp(i0,a0,reg) + vmfp(i0,a0,reg))
          +            vdpp(i0,reg) + vmpp(i0,reg)
          +            vdgp(i0,reg) + vmgp(i0,reg)
          +            vdip(i0,reg) + vmip(i0,reg)
               )) ;
esubd1(i,r)$esubd1(i,r)
          = sum(i0$mapi(i,i0), sum(reg$mapr(r,reg), ESUBD(i0,reg)*(
               sum(a0, vdfp(i0,a0,reg) + vmfp(i0,a0,reg))
          +            vdpp(i0,reg) + vmpp(i0,reg)
          +            vdgp(i0,reg) + vmgp(i0,reg)
          +            vdip(i0,reg) + vmip(i0,reg))))
          / esubd1(i,r) ;

*  ESUBM -- Use regional aggregate import demand

esubm1(i,r) = sum(i0$mapi(i,i0), sum(reg$mapr(r,reg),
            +  sum(a0, vmfp(i0,a0,reg))
            +          vmpp(i0,reg)
            +          vmgp(i0,reg)
            +          vmip(i0,reg))) ;
esubm1(i,r)$esubm1(i,r)
            = sum(i0$mapi(i,i0), sum(reg$mapr(r,reg), ESUBM(i0,reg)*(
            +  sum(a0, vmfp(i0,a0,reg))
            +          vmpp(i0,reg)
            +          vmgp(i0,reg)
            +          vmip(i0,reg))))
            / esubm1(i,r) ;

esubs1(i) = sum(reg, sum(marg$mapi(i,marg), VST(marg,reg))) ;
esubs1(i)$esubs1(i) =  sum(reg, sum(marg$mapi(i,marg), ESUBS(marg)*VST(marg,reg)))
                    /  esubs1(i) ;

*  RORFLEX -- Use regional level of capital stock

RORFLEX1(r) = sum(r0$mapr(r,r0), vkb(r0)) ;
RORFLEX1(r)$RORFLEX1(r) =sum(r0$mapr(r,r0), RORFLEX(r0)*vkb(r0)) / RORFLEX1(r) ;

*  Save the data

put "Saving the core parameters..." / ;

execute_unload "%BaseName%/%outDir%/%baseName%PAR.gdx",
   a=acts, i=comm, img1=marg, r=reg, fp=endw,
   fpf=endwf, fpm=endwm, fps=endws,
   l=lab, cap, lnd, nrs,
   ESUBT1=ESUBT, ESUBC1=ESUBC, ESUBVA1=ESUBVA, ETRAQ1=ETRAQ, ESUBQ1=ESUBQ,
   INCPAR1=INCPAR, SUBPAR1=SUBPAR, ESUBG1=ESUBG, ESUBI1=ESUBI,
   ESUBD1=ESUBD, ESUBM1=ESUBM, ESUBS1=ESUBS, ETRAE1=ETRAE, RORFLEX1=RORFLEX
;

* ------------------------------------------------------------------------------
*
*  Aggregate energy data
*
* ------------------------------------------------------------------------------

put "Aggregating the energy balances..." / ;

*  Energy matrices

parameters
   EDF(ERG, ACTS, REG)     "Usage of domestic products by firm"
   EMF(ERG, ACTS, REG)     "Usage of imported products by firm"
   EDP(ERG,REG)            "Private consumption of domestic goods"
   EMP(ERG,REG)            "Private consumption of imported goods"
   EDG(ERG,REG)            "Public consumption of domestic goods"
   EMG(ERG,REG)            "Public consumption of imported goods"
   EDI(ERG,REG)            "Investment consumption of domestic goods"
   EMI(ERG,REG)            "Investment consumption of imported goods"
   EXI(ERG, REG, REG)      "Bilateral trade in energy"
   EMAK(ERG, ACTS, REG)    "Energy make matrix"

;

execute_loaddc "%GTAPDir%/%DataBase%VOLE.gdx",
   EDF, EMF, EDP, EMP, EDG, EMG, EDI, EMI, EXI
;

edf(erg,acts,reg)$(vdfp(erg,acts,reg) eq 0) = 0 ;
emf(erg,acts,reg)$(vmfp(erg,acts,reg) eq 0) = 0 ;

edp(erg,reg)$(vdpp(erg,reg) eq 0) = 0 ;
emp(erg,reg)$(vmpp(erg,reg) eq 0) = 0 ;

edg(erg,reg)$(vdgp(erg,reg) eq 0) = 0 ;
emg(erg,reg)$(vmgp(erg,reg) eq 0) = 0 ;

edi(erg,reg)$(vdip(erg,reg) eq 0) = 0 ;
emi(erg,reg)$(vmip(erg,reg) eq 0) = 0 ;

exi(erg,src,dst)$(vmsb(erg,src,dst) eq 0) = 0 ;

Parameters
   eqo(acts,reg)   "Energy output"
;

alias(actsp,acts) ;

*  We should be entering the energy make matrix as an input
*  The code below assumes 'diagonality'

loop(sameas(erg,acts),
   eqo(acts,reg) = sum(actsp,edf(erg,actsp,reg)) + edp(erg,reg) + edg(erg,reg) + edi(erg,reg)
                 + sum(dst, exi(erg,reg,dst)) ;
   emak(erg,acts,reg) = eqo(acts,reg) ;
) ;

parameters
   EDF1(i, a, r)           "Usage of domestic products by firm"
   EMF1(i, a, r)           "Usage of imported products by firm"
   EDP1(i, r)              "Private consumption of domestic goods"
   EMP1(i, r)              "Private consumption of imported goods"
   EDG1(i, r)              "Public consumption of domestic goods"
   EMG1(i, r)              "Public consumption of imported goods"
   EDI1(i, r)              "Investment consumption of domestic goods"
   EMI1(i, r)              "Investment consumption of imported goods"
   EXI1(i, r, rp)          "Bilateral trade in energy"
   EQO1(a,r)               "Output"
   EMAK1(i, a, r)          "Energy make matrix"
;

Agg3(edf,edf1,ERG,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg3(emf,emf1,ERG,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg2(edp,edp1,ERG,i,mapi,r0,r,mapr) ;
Agg2(emp,emp1,ERG,i,mapi,r0,r,mapr) ;
Agg2(edg,edg1,ERG,i,mapi,r0,r,mapr) ;
Agg2(emg,emg1,ERG,i,mapi,r0,r,mapr) ;
Agg2(edi,edi1,ERG,i,mapi,r0,r,mapr) ;
Agg2(emi,emi1,ERG,i,mapi,r0,r,mapr) ;
Agg3(exi,exi1,ERG,i,mapi,r0,r,mapr,rp0,rp,mapr) ;
Agg2(eqo, eqo1, a0, a, mapa, r0, r, mapr) ;
Agg3(emak,emak1,ERG,i,mapi,a0,a,mapa,r0,r,mapr) ;

edf1(i,a,r)$(voi1(i,r) = 0)  = 0 ;
edp1(i,r)$(voi1(i,r) = 0)    = 0 ;
edg1(i,r)$(voi1(i,r) = 0)    = 0 ;
exi1(i,r,rp)$(voi1(i,r) = 0) = 0 ;

*  Save the data

set erg1(i) "Energy carriers" ; erg1(i)$(sum(mapi(i,erg),1)) = yes ;

put "Saving the energy balances..." / ;

execute_unload  "%BaseName%/%outDir%/%baseName%VOLE.gdx",
   a=acts, i=comm, img1=marg, r=reg,
   erg1=ERG,
   EDF1=EDF, EMF1=EMF,
   EDP1=EDP, EMP1=EMP,
   EDG1=EDG, EMG1=EMG,
   EDI1=EDI, EMI1=EMI,
   EXI1=EXI, EQO1=EQO, EMAK1=EMAK
;

* ------------------------------------------------------------------------------
*
*  Aggregate CO2 emissions data
*
* ------------------------------------------------------------------------------

put "Aggregating the CO2 emissions..." / ;

*  CO2 Emission matrices

parameters
   MDF(FUEL, ACTS, REG)          "Emissions from domestic product in current production, .."
   MMF(FUEL, ACTS, REG)          "Emissions from imported product in current production, .."
   MDP(FUEL, REG)                "Emissions from private consumption of domestic product, Mt CO2"
   MMP(FUEL, REG)                "Emissions from private consumption of imported product, Mt CO2"
   MDG(FUEL, REG)                "Emissions from govt consumption of domestic product, Mt CO2"
   MMG(FUEL, REG)                "Emissions from govt consumption of imported product, Mt CO2"
   MDI(FUEL, REG)                "Emissions from invt consumption of domestic product, Mt CO2"
   MMI(FUEL, REG)                "Emissions from invt consumption of imported product, Mt CO2"
   nrgComb(FUEL, ACTS, REG)      "Energy combusted"
;

execute_loaddc "%GTAPDir%/%DataBase%EMISS.gdx",
   MDF, MMF, MDP, MMP, MDG, MMG, MDI, MMI
;

mdf(FUEL,acts,reg)$(vdfp(FUEL,acts,reg) eq 0) = 0 ;
mmf(FUEL,acts,reg)$(vmfp(FUEL,acts,reg) eq 0) = 0 ;

mdp(FUEL,reg)$(vdpp(FUEL,reg) eq 0) = 0 ;
mmp(FUEL,reg)$(vmpp(FUEL,reg) eq 0) = 0 ;

mdg(FUEL,reg)$(vdgp(FUEL,reg) eq 0) = 0 ;
mmg(FUEL,reg)$(vmgp(FUEL,reg) eq 0) = 0 ;

mdi(FUEL,reg)$(vdip(FUEL,reg) eq 0) = 0 ;
mmi(FUEL,reg)$(vmip(FUEL,reg) eq 0) = 0 ;

Set
   fuel1(i)          "Aggregate fuels"
;

parameters
   MDF1(i, a, r)     "Emissions from domestic product in current production, .."
   MMF1(i, a, r)     "Emissions from imported product in current production, .."
   MDP1(i, r)        "Emissions from private consumption of domestic product, Mt CO2"
   MMP1(i, r)        "Emissions from private consumption of imported product, Mt CO2"
   MDG1(i, r)        "Emissions from govt consumption of domestic product, Mt CO2"
   MMG1(i, r)        "Emissions from govt consumption of imported product, Mt CO2"
   MDI1(i, r)        "Emissions from invt consumption of domestic product, Mt CO2"
   MMI1(i, r)        "Emissions from invt consumption of imported product, Mt CO2"
   GlobalEmi(i)      "Global CO2 emissions from i"
   nrgComb1(i,a,r)   "Energy combusted"
;

Agg3(mdf,mdf1,fuel,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg3(mmf,mmf1,fuel,i,mapi,a0,a,mapa,r0,r,mapr) ;
Agg2(mdp,mdp1,fuel,i,mapi,r0,r,mapr) ;
Agg2(mmp,mmp1,fuel,i,mapi,r0,r,mapr) ;
Agg2(mdg,mdg1,fuel,i,mapi,r0,r,mapr) ;
Agg2(mmg,mmg1,fuel,i,mapi,r0,r,mapr) ;
Agg2(mdi,mdi1,fuel,i,mapi,r0,r,mapr) ;
Agg2(mmi,mmi1,fuel,i,mapi,r0,r,mapr) ;

GlobalEmi(i) = sum(r, sum(a, MDF1(i, a, r) + MMF1(i, a, r))
             + MDP1(i, r) + MMP1(i, r)
             + MDG1(i, r) + MMG1(i, r)
             + MDI1(i, r) + MMI1(i, r)) ;

fuel1(i)$GlobalEmi(i) = yes ;

$iftheni.AggPrim "%aggStep%" == "aggPrimary"
*  Calculate combustion

   parameters co2_mtoe(fuel) "Standard emissions coefficients" /
      coa     3.881135
      oil     3.03961
      gas     2.22606
      p_c     2.89167
      gdt     2.22606
   / ;
*  Check this conversion
   co2_mtoe(fuel) = co2_mtoe(fuel)*12/44 ;
   set etr0(fuel)    "Which fuels"        / coa, oil, gas, p_c, gdt / ;

$iftheni.verCheck "%ver%" == "V9RC2POW"
   set atr0(acts)    "Which activities"   / oil, p_c, crp / ;
$elseif.verCheck "%ver%" == "V11CE"
   set atr0(acts)    "Which activities"   / oil, p_c, KFR, NFR, PFR, XCH, BPH, RBR, PLP, PLS, PLR / ;
$else.verCheck
   set atr0(acts)    "Which activities"   / oil, p_c, chm, bph, rpp / ;
$endif.verCheck

   nrgComb(fuel,acts,reg) = ((mdf(fuel,acts,reg) + mmf(fuel,acts,reg))/co2_mtoe(fuel))$(etr0(fuel) and atr0(acts))
                          + (edf(fuel,acts,reg) + emf(fuel,acts,reg))$(not (etr0(fuel) and atr0(acts)))
                          ;

*  Cap combustion to actual energy consumption
   nrgCOMB(fuel,acts,reg) = (edf(fuel,acts,reg) + emf(fuel,acts,reg))$(nrgCOMB(fuel,acts,reg) > (edf(fuel,acts,reg) + emf(fuel,acts,reg)))
                           + nrgCOMB(fuel,acts,reg)$(nrgCOMB(fuel,acts,reg) <= (edf(fuel,acts,reg) + emf(fuel,acts,reg)))
                           ;
$else.AggPrim
   execute_loaddc "%GTAPDir%/%DataBase%EMISS.gdx", nrgComb ;
$endif.AggPrim

*  Aggregate
nrgCOMB1(i,a,r) = sum((reg,fuel,acts)$(mapr(r,reg) and mapi(i,fuel) and mapa(a,acts)), nrgCOMB(fuel,acts,reg)) ;

*  Save the data

put "Saving the CO2 emissions..." / ;

execute_unload  "%BaseName%/%outDir%/%baseName%EMISS.gdx",
   a=acts, i=comm, img1=marg, r=reg, FUEL1=FUEL,
   MDF1=MDF, MMF1=MMF, MDP1=MDP, MMP1=MMP, MDG1=MDG, MMG1=MMG, MDI1=MDI, MMI1=MMI,
   nrgCOMB1=nrgCOMB
;

* ------------------------------------------------------------------------------
*
*  Aggregate non-CO2 emissions data
*
* ------------------------------------------------------------------------------

$set ifNCO2 0
$if exist "%GTAPDir%/%DataBase%NCO2.gdx" $set ifNCO2 1

put "Reading the non-CO2 and process emissions..." / ;

*  Mostly NON-CO2 emission matrices

sets
   EM          "Set of emissions"
   EMN(EM)     "Non-CO2 emissions"
   GHG(EM)     "Greenhouse gas emissions"
   NGHG(EMN)   "Non-greehnouse gas emissions"

   LU_CAT      "Land use categories"
   LU_SubCat   "Land use sub-categories"
   AR          "IPCC Assessment Reports"
;


$ifthen.NCO2 %ifNCO2% == 1

$gdxin "%GTAPDir%/%DataBase%NCO2.gdx"
$load EM, LU_CAT, LU_SubCat, AR
$loaddc EMN, GHG, NGHG

parameters
   EMI_IO(EM, COMM, ACTS, REG)         "IO-based emissions in Mmt"
   EMI_IOP(EM, COMM, ACTS, REG)        "IO-based process emissions in Mmt"
   EMI_ENDW(EM, ENDW, ACTS, REG)       "Endowment-based emissions in Mmt"
   EMI_QO(EM, ACTS, REG)               "Output-based emissions in Mmt"
   EMI_HH(EM, COMM, REG)               "Private consumption-based emissions in Mmt"
   EMI_LU(EM,LU_CAT,LU_SubCat,REG)     "Land-use based emissions"
   GWP(ghg, reg, ar)                   "Global warming potential"
;

*  Load the data

execute_loaddc "%GTAPDir%/%DataBase%NCO2.gdx",
   EMI_IO, EMI_IOP, EMI_ENDW, EMI_QO, EMI_HH, EMI_LU, GWP ;
;

file ecsv / z:\Output\Env11\%baseName%\emi_GTAP.csv / ;
if(0,
   put ecsv ;
   put "SRC,Emi,Region,Input,Agent,Value" / ;
   ecsv.pc = 5 ;
   ecsv.nd = 10 ;
   loop((reg,fuel,acts)$(MDF(fuel,acts,reg) + MMF(fuel,acts,reg)),
      put "COMB", "CO2", reg.tl, fuel.tl, acts.tl, (MDF(fuel,acts,reg) + MMF(fuel,acts,reg)) / ;
   ) ;
   loop((reg,fuel)$(MDP(fuel,reg) + MMP(fuel,reg)),
      put "COMB", "CO2", reg.tl, fuel.tl, "HHD", (MDP(fuel,reg) + MMP(fuel,reg)) / ;
   ) ;
   loop((reg,fuel)$(MDG(fuel,reg) + MMG(fuel,reg)),
      put "COMB", "CO2", reg.tl, fuel.tl, "GOV", (MDG(fuel,reg) + MMG(fuel,reg)) / ;
   ) ;
   loop((reg,fuel)$(MDI(fuel,reg) + MMI(fuel,reg)),
      put "COMB", "CO2", reg.tl, fuel.tl, "INV", (MDI(fuel,reg) + MMI(fuel,reg)) / ;
   ) ;
   loop((em,comm,acts,reg)$EMI_IO(EM, COMM, ACTS, REG),
      put "IO", em.tl, reg.tl, comm.tl, acts.tl, EMI_IO(EM, COMM, ACTS, REG) / ;
   ) ;
   loop((em,comm,acts,reg)$EMI_IOP(EM, COMM, ACTS, REG),
      put "IOP", em.tl, reg.tl, comm.tl, acts.tl, EMI_IOP(EM, COMM, ACTS, REG) / ;
   ) ;
   loop((em,endw,acts,reg)$EMI_ENDW(EM, endw, ACTS, REG),
      put "ENDW", em.tl, reg.tl, endw.tl, acts.tl, EMI_ENDW(EM, endw, ACTS, REG) / ;
   ) ;
   loop((em,acts,reg)$EMI_QO(EM, ACTS, REG),
      put "QO", em.tl, reg.tl, "QO", acts.tl, EMI_QO(EM, ACTS, REG) / ;
   ) ;
   loop((em,comm,reg)$EMI_HH(EM, COMM, REG),
      put "IO", em.tl, reg.tl, comm.tl, "HHD", EMI_HH(EM, COMM, REG) / ;
   ) ;
   Abort "Temp" ;
) ;
 

parameters
   EMI_IO1(EM, i, a, r)             "IO-based emissions in Mmt"
   EMI_IOP1(EM, i, a, r)            "IO-based process emissions in Mmt"
   EMI_ENDW1(EM, fp, a, r)          "Endowment-based emissions in Mmt"
   EMI_QO1(EM, a, r)                "Output-based emissions in Mmt"
   EMI_HH1(EM, i, r)                "Private consumption-based emissions in Mmt"
   EMI_LU1(GHG,LU_CAT,LU_SubCat,r)  "Land-use based emissions"
   GWP1(ghg, r, ar)                 "Global warming potential"
;

*  Aggregate the data

EMI_IO1(EM, i, a, r)
   =sum((mapi(i,comm), mapa(a,acts), mapr(r,reg)), EMI_IO(EM, COMM, ACTS, REG)) ;

EMI_IOP1(EM, i, a, r)
   =sum((mapi(i,comm), mapa(a,acts), mapr(r,reg)), EMI_IOP(EM, COMM, ACTS, REG)) ;

EMI_ENDW1(EM, fp, a, r)
   =sum((mapf(fp,ENDW), mapa(a,acts), mapr(r,reg)), EMI_ENDW(EM, ENDW, ACTS, REG)) ;

EMI_QO1(EM, a, r)
   =sum((mapa(a,acts), mapr(r,reg)), EMI_QO(EM, ACTS, REG)) ;

EMI_HH1(EM, i, r)
   =sum((mapi(i,comm), mapr(r,reg)), EMI_HH(EM, COMM, REG)) ;

EMI_LU1(GHG,LU_CAT,LU_SubCat,r)
   =sum((mapr(r,reg)), EMI_LU(GHG,LU_CAT,LU_SubCat,REG)) ;

*  !!!! Should we add LU emissions?

GWP1(ghg,r,ar) = sum(mapr(r,reg),
     sum((COMM, ACTS), EMI_IO(GHG, COMM, ACTS, REG) + EMI_IOP(GHG, COMM, ACTS, REG))
   + sum((ENDW, ACTS), EMI_ENDW(GHG, ENDW, ACTS, REG))
   + sum((ACTS), EMI_QO(GHG, ACTS, REG))
   + sum((COMM), EMI_HH(GHG, COMM, REG))) ;

GWP1(ghg,r,ar) = (sum(mapr(r,reg), GWP(ghg,REG,ar)*(
     sum((COMM, ACTS), EMI_IO(GHG, COMM, ACTS, REG) + EMI_IOP(GHG, COMM, ACTS, REG))
   + sum((ENDW, ACTS), EMI_ENDW(GHG, ENDW, ACTS, REG))
   + sum((ACTS), EMI_QO(GHG, ACTS, REG))
   + sum((COMM), EMI_HH(GHG, COMM, REG)))) / GWP1(ghg,r,ar))$GWP1(ghg,r,ar)
*  IF THERE ARE NO EMISSIONS
   + (sum(mapr(r,reg), GWP(ghg,REG,ar)) / sum(mapr(r,reg), 1))$(GWP1(ghg,r,ar) eq 0)
   ;

*  Save the data

execute_unload "%BaseName%/%outDir%/%baseName%NCO2.gdx",
   ar, i=comm, fp=endw, a=acts, r=reg, em, emn, ghg, nghg, LU_CAT, LU_SubCat,
   gwp1=GWP,
   emi_IO1=emi_IO, emi_QO1=emi_QO,
   emi_IOP1=emi_IOP,
   emi_ENDW1=emi_ENDW, emi_HH1=emi_HH, emi_LU1=emi_LU ;
;

put "Saving the non-CO2 and process emissions..." / ;

$endif.nco2

* ------------------------------------------------------------------------------
*
*  Additional BoP accounts -- from GMiG and GDyn
*
* ------------------------------------------------------------------------------

$set ifBoP 0
$if exist "%GTAPDir%/%DataBase%BoP.gdx" $set ifBoP 1

put "Reading the auxiliary BoP data..." / ;

$iftheni.BoP %ifBoP% == 1

parameters
   remit(endw,src,dst)  "Initial remittances"
   yqtf(reg)            "Initial outflow of capital income"
   yqht(reg)            "Initial inflow of capital income"
   ODAIn(reg)           "Initial ODA inflows"
   ODAOut(reg)          "Initial ODA outflows"
;

parameters
   remit1(fp,s,d)       "Initial remittances"
   yqtf1(r)             "Initial outflow of capital income"
   yqht1(r)             "Initial inflow of capital income"
   ODAIn1(r)            "Initial ODA inflows"
   ODAOut1(r)           "Initial ODA outflows"
;

*  Remittances and flow of profits

execute_loaddc "%GTAPDir%/%DataBase%BoP.gdx" , remit, yqtf, yqht, ODAIn, ODAOut ;

Agg3(remit,remit1,endw,fp,mapf,r0,s,mapr,rp0,d,mapr) ;
Agg1(yqtf,yqtf1,r0,r,mapr) ;
Agg1(yqht,yqht1,r0,r,mapr) ;
Agg1(ODAIn,ODAIn1,r0,r,mapr) ;
Agg1(ODAOut,ODAOut1,r0,r,mapr) ;

put "Saving the auxiliary BoP data..." / ;

execute_unload "%BaseName%/%outDir%/%baseName%BoP.gdx",
   fp=ENDW, l=LAB, r=REG,
   REMIT1=REMIT, YQTF1=YQTF, YQHT1=YQHT, ODAIn1=ODAIn, ODAOut1=ODAOut ;

$endif.BoP

* ------------------------------------------------------------------------------
*
*  Food balance sheet data
*
* ------------------------------------------------------------------------------

$set ifFBS 0
$if exist "%GTAPDir%/%DataBase%FBS.gdx" $set ifFBS 1

put "Reading the auxiliary FBS data..." / ;

$iftheni.FBS %ifFBS% == 1

Sets
   sua      "SUA accounts"
   ucat     "Use categories (all activities, fnd and loss)"
   srcr     "Source of nutrition (local + all import partners)"
;

$gdxin "%GTAPDir%/%DataBase%FBS.gdx"
$load sua, ucat, srcr

Sets
   ucat1    "Use categators (all activities, fnd and loss)" /
               set.a
               "FND"    "Final demand use"
               "LSS"    "Loss"
            /
   srcr1    "Source of nutrition (local + all import partners" /
               LCL      "Local source of nutrition"
               set.r    "Aggregate regions"
            /
   mapuse(ucat1, ucat)
   mapsrc(srcr1, srcr)
;

loop(mapa(a,acts),
   mapuse(ucat1, ucat)$(sameas(ucat,acts) and sameas(ucat1,a)) = yes ;
) ;
mapuse("FND","FND") = yes ;
mapuse("LSS","LSS") = yes ;

loop(mapr(r,reg),
   mapsrc(srcr1, srcr)$(sameas(srcr,reg) and sameas(srcr1,r)) = yes ;
) ;
mapsrc("LCL","LCL") = yes ;

Parameters
   nutr(comm, ucat, sua, srcr, reg)
   nutr1(i,ucat1,sua,srcr1,r)
;

Execute_loaddc "%GTAPDir%/%DataBase%FBS.gdx" nutr ;

nutr1(i,ucat1,sua,srcr1,r) =
   sum((comm,ucat,srcr,reg)$(mapi(i,comm) and mapuse(ucat1,ucat) and mapsrc(srcr1,srcr) and mapr(r,reg)),
      nutr(comm,ucat,sua,srcr,reg)) ;

put "Saving the auxiliary FBS data..." / ;
execute_unload "%BaseName%/%outDir%/%baseName%FBS.gdx",
      i=COMM, a=ACTS, r=REG, mapuse, mapsrc, ucat1=ucat, srcr1=srcr, sua, nutr1=nutr ;

$endif.FBS

* ------------------------------------------------------------------------------
*
*  Aggregate land use data
*
* ------------------------------------------------------------------------------

$set ifLU 0
$if exist "%GTAPDir%/%DataBase%LU.gdx" $set ifLU 1

put "Reading the auxiliary land-use data..." / ;

$iftheni.LU %ifLU% == 1

Sets
   LC                "Land cover types"
   ENDWLU            "Endowments with AEZ"
   ENDWAEZ(ENDWLU)   "Land endowments"
   fpLU              "Aggregate endowments with AEZ" / set.l, set.cap, set.nrs, set.aez1 /
   fpnLU(fpLU)       "Non-land endowments" / set.l, set.cap, set.nrs /
;

$gdxin "%GTAPDir%/%DataBase%LU.gdx"
$load LC, ENDWLU=ENDW
$loaddc ENDWAEZ=ENDWL

Parameters
   FBEPLU(ENDWLU,ACTS,REG)       "Factor based subsidies"
   FTRVLU(ENDWLU,ACTS,REG)       "Gross factor employment tax revenue"
   EVFBLU(ENDWLU,ACTS,REG)       "Value added at basic prices"
   EVFPLU(ENDWLU,ACTS,REG)       "Value added at purchasers' prices"
   EVOSLU(ENDWLU,ACTS,REG)       "After-tax endowment income"
   CRPPROD(ENDWLU,ACTS,REG)      "Crop production"
   CRPAREA(ENDWLU,ACTS,REG)      "Harvested area"
   LCOV(ENDWLU,LC,REG)           "Land cover"

   FBEPLU1(fpLU,a,r)             "Factor based subsidies"
   FTRVLU1(fpLU,a,r)             "Gross factor employment tax revenue"
   EVFBLU1(fpLU,a,r)             "Value added at basic prices"
   EVFPLU1(fpLU,a,r)             "Value added at purchasers' prices"
   EVOSLU1(fpLU,a,r)             "After-tax endowment income"
   CRPPROD1(fpLU,a,r)            "Crop production"
   CRPAREA1(fpLU,a,r)            "Harvested area"
   LCOV1(fpLU,LC,r)              "Land cover"
;

execute_loaddc "%GTAPDir%/%DataBase%LU.gdx"
   fbeplu, ftrvlu, evfblu, evfplu, evoslu,
   crpprod, crparea, lcov ;

$batInclude "CheckMap" maplu AEZ AEZ1 land-use

$macro M_AggLU(v,suffix) \
   &v&suffix(fpLU,a,r) = sum((ENDW, ENDWLU, fp, ACTS, REG)$(sameas(ENDW,ENDWLU) and sameas(fp,fpLU) and mapf(fp,ENDW)      \
                        and mapa(a,ACTS) and mapr(r,REG)), &v(ENDWLU,ACTS,REG))$(fpnLU(fpLU))                        \
                 + sum((AEZ, AEZ1, ENDWLU, ACTS, REG)$(sameas(AEZ,ENDWLU) and sameas(AEZ1,fpLU) and maplu(AEZ1,AEZ)  \
                        and mapa(a,ACTS) and mapr(r,REG)), &v(ENDWLU,ACTS,REG))$(not fpnLU(fpLU))

M_AggLU(FBEPLU,1) ;
M_AggLU(FTRVLU,1) ;
M_AggLU(EVFBLU,1) ;
M_AggLU(EVFPLU,1) ;
M_AggLU(EVOSLU,1) ;
M_AggLU(CRPPROD,1) ;
M_AggLU(CRPAREA,1) ;

LCOV1(fpLU,LC,r) = sum((ENDW, ENDWLU, fp, REG)$(sameas(ENDW,ENDWLU) and sameas(fp,fpLU) and mapf(fp,ENDW)
                        and mapr(r,REG)), LCOV(ENDWLU,LC,REG))$(fpnLU(fpLU))
                 + sum((AEZ, AEZ1, ENDWLU, REG)$(sameas(AEZ,ENDWLU) and sameas(AEZ1,fpLU) and maplu(AEZ1,AEZ)
                        and mapr(r,REG)), LCOV(ENDWLU,LC,REG))$(not fpnLU(fpLU)) ;

put "Saving the auxiliary land-use data..." / ;
execute_unload "%BaseName%/%outDir%/%baseName%LU.gdx",
   fplu=ENDW, AEZ1=ENDWL, LC, a=ACTS, r=REG,
   EVFBLU1=EVFBLU, EVFPLU1=EVFPLU, EVOSLU1=EVOSLU, FBEPLU1=FBEPLU, FTRVLU1=FTRVLU,
   CRPPROD1=CRPPROD, CRPAREA1=CRPAREA, LCOV1=LCOV
;

$endif.LU

