* --------------------------------------------------------------------------------------------------
*
*  Get the definitions of the core sets from the GTAP database
*
* --------------------------------------------------------------------------------------------------

$include "miscdat.gms"

Sets
   comm                 "Commodities"
   acts                 "Activities"
   endw                 "Factors of production"
   reg                  "Regions"
   marg(comm)           "Margin commodities"
   endwm(endw)          "Perfectly mobile factors"
   endws(endw)          "'Slugghish' factors"
   endwf(endw)          "Sector-specific factors"
   lab(endw)            "Labor endowments"
   endwT(endw)          "Land endowment"
;

singleton Sets
   endwK(endw)          "Capital endowment"
   endwN(endw)          "Natural resource endowment"
;

$gdxIn "%dataFolder%/%BaseName%Dat.gdx"
$load comm, acts, endw, reg
$loaddc marg, endwm, endws, endwf, lab, endwK=cap, endwT=lnd, endwN=nrs

*  Get the emission sets (if they exist!)

$ifthen.NCO2 exist "%dataFolder%/%BaseName%NCO2.gdx"

Sets
   ar          "IPCC assessment reports"
   em          "All emissions"
   emn(em)     "Non CO2 emissions"
   ghg(em)     "Greenhouse gas emissions"
   nghg(em)    "Non-greenhouse gas emissions"
   LU          "Land use categories"
   LUType      "Land use sub-categories"

;
$gdxIn "%dataFolder%/%BaseName%NCO2.gdx"
$load ar, em, LU=LU_Cat, LUType=LU_Subcat
$loaddc emn, ghg, nghg

$else.NCO2

Sets
   ar          "IPCC assessment reports"        / AR2*AR6 /
   em          "All emissions"                  / CO2 /
   emn(em)     "Non CO2 emissions"              / /
   ghg(em)     "Greenhouse gas emissions"       / CO2 /
   nghg(em)    "Non-greenhouse gas emissions"   / /
   LU          "Land use categories"            / all /
   LUType      "Land use sub-categories"        / none /
;

$endif.NCO2

* --------------------------------------------------------------------------------------------------
*
*  Set up the core sets for the model and data processing--starts from a set of all sets
*
* --------------------------------------------------------------------------------------------------

*  !!!! Perhaps created earlier on (i.e., from the aggregation facility)
set stdlab "Standard SAM labels" /
   TRD          "Trade account"
   regY         "Regional household"
   hhd          "Household"
   gov          "Government"
   r_d          "Research and development"
   inv          "Investment"
$onText
   adptfp       "Adaptation expenditures to dampen total factor productivity effect"
   adplab       "Adaptation expenditures to dampen labor productivity effect"
   adphht       "Adaptation expenditures to dampen health effect"
   adpnrg       "Adaptation expenditures to dampen energy demand effect"
   adplnd       "Adaptation expenditures to dampen land effect"
   adptou       "Adaptation expenditures to dampen tourism revenue effect"
   adpcap       "Adaptation expenditures to dampen capital stock effect"
$offText
   deprY        "Depreciation"
   tmg          "Trade margins"
   itax         "Indirect tax"
   ptax         "Production tax"
   mtax         "Import tax"
   etax         "Export tax"
   vtax         "Taxes on factors of production"
   ltax         "Taxes on labor use"
   ktax         "Taxes on capital use"
   rtax         "Taxes on natural resource use"
   vsub         "Subsidies on factors of production"
   wtax         "Waste tax"
   dtax         "Direct taxation"
   ctax         "Carbon tax"
   ntmY         "NTM revenues"
   bop          "Balance of payments account"
   tot          "Total for row/column sums"
/ ;

set findem(stdlab) "Final demand accounts" /
   hhd          "Household"
   gov          "Government"
   r_d          "Research and development"
   inv          "Investment"
   tmg          "Trade margins"
/ ;

set is "SAM accounts for aggregated SAM" /

*  User-defined activities

   set.acts

*  User-defined commodities

   set.comm

*  User-defined factors

   set.endw

*  Standard SAM accounts

   set.stdlab

*  User-defined regions

   set.reg

/ ;

alias(is, js) ;

set aa(is) "Armington agents" /

   set.acts
   set.findem
/ ;

set a(aa) "Activities" /

   set.acts

/ ;

set i(is) "Commodities" /

   set.comm

/ ;

alias(i, j) ;

set img(i) "Margin commodities" /
   set.marg
/ ;


set fp(is) "Factors of production" /

   set.endw

/ ;

set l(fp) "Labor factors" /
   set.lab
/ ;

*  !!!! Need to modify for WAT
Singleton Sets
   cap(fp)     "Capital"            / set.endwK /
   nrs(fp)     "Natural resource"   / set.endwN /
   wat(fp)     "Water resource"     / /
;

set lnd(fp) "Land endowment(s)" /
   set.endwT
/ ;

* >>>> CAN MODIFY MOBILE VS. NON-MOBILE FACTORS

set fm(fp) "Mobile factors" /
   set.endwm
   set.endws
/ ;

set fnm(fp) "Non-mobile factors" /
   set.endwf
/ ;

set fd(aa) "Domestic final demand agents" /
   set.findem
/ ;

set h(fd) "Households" /
   hhd          "Household"
/ ;

singleton set gov(fd) "Government" /
   gov          "Government"
/ ;

singleton set inv(fd) "Investment" /
   inv          "Investment"
/ ;

set fdc(fd) "Final demand accounts with CES expenditure function" /
   gov          "Government"
   inv          "Investment"
/ ;

set r(is) "Regions" /
   set.reg
/ ;

alias(r, rp) ; alias(r, s) ; alias(r, d) ;

* --------------------------------------------------------------------------------------------------
*
*  Declare and define sets needed for ENVISAGE, but that are not aggregation dependent
*
* --------------------------------------------------------------------------------------------------

set ucat "Use categories (all activities + FND and LSS)" /
   set.acts
   FND         "Final demand"
   LSS         "Losses"
/ ;

set srcr "Source of nutrition (local + all import partners)" /
   set.reg
   LCL       "Local source of nutrition"
/ ;

set sua "Supply utilization accounts" /
   FEED_KT      "Feed in kilotons"
   SEED_KT      "Seed use in kilotons"
   LOSS_KT      "Loss in kilotons"
   OTHU_KT      "Other use in kilotons"
   FOOD_KT      "Food use in kilotons"
   FATS_KT      "Fats in kilotons"
   FOOD_TC      "Food use in tera calories"
   PROT_KT      "Protein use in kilotons"
   CARB_KT      "Carbohydrates in kilotons"
/ ;

set var "GDP variables" /
   "GDP_per_capita|PPP" "GDP per capita in $2017PPP"
   "GDP|PPP"            "GDP in $2017 million"
/ ;

set scen "Scenarios" /
   UNMED2019    "UN Population Division Medium Variant 2019 revision"
   UN2022       "UN 2022 Revision medium variant"
   UN2024       "UN 2022 Revision medium variant"
   SSP1         "Sustainability ('Taking the Green Road')"
   SSP2         "Middle of the Road"
   SSP3         "Regional Rivalry ('A Rocky Road')"
   SSP4         "Inequality ('A Road Divided')"
   SSP5         "Fossil-fueled Development ('Taking the Highway')"
   GIDD         "GIDD population projection"
/ ;

set ssp(scen) "SSP Scenarios" /
   SSP1         "Sustainability ('Taking the Green Road')"
   SSP2         "Middle of the Road"
   SSP3         "Regional Rivalry ('A Rocky Road')"
   SSP4         "Inequality ('A Road Divided')"
   SSP5         "Fossil-fueled Development ('Taking the Highway')"
/ ;

set mod "Models" /
   OECD         "OECD-based SSPs"
   IIASA        "IIASA-based SSPs"
/ ;

set tranche "Population cohorts" /
   PLT15        "Population less than 15"
   P1564        "Population aged 15 to 64"
   P65UP        "Population 65 and over"
   PTOTL        "Total population"
/ ;

set trs(tranche) "Population cohorts" /
   PLT15        "Population less than 15"
   P1564        "Population aged 15 to 64"
   P65UP        "Population 65 and over"
/ ;

set sex   "Gender categories" /
   MALE         "Male"
   FEML         "Female"
   BOTH         "M+F"
/ ;

set sexx(sex) "Gender categories excl total" /
   MALE         "Male"
   FEML         "Female"
/ ;

set ed "Combined SSP/GIDD education levels" /
   elev0        "ENONE/EDUC0_6"
   elev1        "EPRIM/EDUC6_9"
   elev2        "ESECN/EDUC9UP"
   elev3        "ETERT"
   elevt        "Total"
/ ;

set edx(ed) "Education levels excluding totals" /
   elev0        "ENONE/EDUC0_6"
   elev1        "EPRIM/EDUC6_9"
   elev2        "ESECN/EDUC9UP"
   elev3        "ETERT"
/ ;

set gy(is) "Government revenue streams" /
   itax        "Indirect taxes"
   ptax        "Production taxes"
   vtax        "Factor taxes"
   mtax        "Import taxes"
   etax        "Export taxes"
   wtax        "Waste taxes"
   ctax        "Carbon taxes"
   dtax        "Direct taxes"
/ ;

singleton Sets
   itx(gy) "Indirect taxes"      / itax /
   ptx(gy) "Production taxes"    / ptax /
   vtx(gy) "Factor taxes"        / vtax /
   mtx(gy) "Import taxes"        / mtax /
   etx(gy) "Export taxes"        / etax /
   wtx(gy) "Waste taxes"         / wtax /
   ctx(gy) "Carbon taxes"        / ctax /
   dtx(gy) "Direct taxes"        / dtax /
   tot(is) "Total"               / tot /
;

set lh "Market condition flags" /
   lo    "Market downswing"
   hi    "Market upswing"
/ ;

set NRG "Energy bundles used in model" /
   COA          "Coal"
   OIL          "Oil"
   GAS          "Gas"
   ELY          "Electricity"
/ ;

singleton sets
   coa(NRG) "Coal bundle used in model"        / COA    "Coal" /
   oil(NRG) "Oil bundle used in model"         / OIL    "Oil"  /
   gas(NRG) "Gas bundle used in model"         / GAS    "Gas"  /
   ely(NRG) "Electricity bundle used in model" / ELY    "Electricity" /
;


set pt "Price trends" / lo, mid, ref, hi / ;

set emq "Emission control aggregations" /
   CO2         "Carbon dioxide"
   CO2e        "Carbon dioxide equivalent"
/ ;

set mapEM(emq,em) /
CO2.CO2
/ ;

mapEM("CO2e",em)$ghg(em) = yes ;

set GHGCodes "GHG codes from WB WDI database" /
   co2          "CO2 emissions (mt)"
   n2o          "Nitrous oxide emissions (mt of CO2 equivalent)"
   ch4          "Methane emissions (mt of CO2 equivalent)"
   NRGUSE       "Energy use (kg of oil equivalent per capita)"
   HFC          "HFC gas emissions (mt of CO2 equivalent)"
   PFC          "PFC gas emissions (mt ton of CO2 equivalent)"
   SF6          "SF6 gas emissions (mt of CO2 equivalent)"
   OTHR         "Other greenhouse gas emissions, HFC, PFC and SF6 (megaton ton of CO2 equivalent)"
   GHGT         "Total greenhouse gas emissions (mt of CO2 equivalent)"
   LUCFNET      "GHG net emissions/removals by LUCF (Mt of CO2 equivalent)"
/ ;

*  Read in the remaining sets --- these are aggregation dependent and user input
$include "%BaseName%Sets.gms"

* --------------------------------------------------------------------------------------------------
*
*  Load the base SAM from GTAP
*
* --------------------------------------------------------------------------------------------------

parameters

*  From the standard database

   VDFB(i, a, r)        "Firm purchases of domestic goods at basic prices"
   VDFP(i, a, r)        "Firm purchases of domestic goods at purchaser prices"
   VMFB(i, a, r)        "Firm purchases of imported goods at basic prices"
   VMFP(i, a, r)        "Firm purchases of domestic goods at purchaser prices"
   VDPB(i, r)           "Private purchases of domestic goods at basic prices"
   VDPP(i, r)           "Private purchases of domestic goods at purchaser prices"
   VMPB(i, r)           "Private purchases of imported goods at basic prices"
   VMPP(i, r)           "Private purchases of domestic goods at purchaser prices"
   VDGB(i, r)           "Government purchases of domestic goods at basic prices"
   VDGP(i, r)           "Government purchases of domestic goods at purchaser prices"
   VMGB(i, r)           "Government purchases of imported goods at basic prices"
   VMGP(i, r)           "Government purchases of domestic goods at purchaser prices"
   VDIB(i, r)           "Investment purchases of domestic goods at basic prices"
   VDIP(i, r)           "Investment purchases of domestic goods at purchaser prices"
   VMIB(i, r)           "Investment purchases of imported goods at basic prices"
   VMIP(i, r)           "Investment purchases of domestic goods at purchaser prices"


   EVFB(fp, a, r)       "Primary factor purchases at basic prices"
   EVFP(fp, a, r)       "Primary factor purchases at purchaser prices"
   EVOS(fp, a, r)       "Factor remuneration after income tax"

   VXSB(i, s, d)        "Exports at basic prices"
   VFOB(i, s, d)        "Exports at FOB prices"
   VCIF(i, s, d)        "Import at CIF prices"
   VMSB(i, s, d)        "Imports at basic prices"

   VST(i, r)            "Exports of trade and transport services"
   VTWR(j, i, s, d)     "Margins by margin commodity"

   SAVE(r)              "Net saving, by region"
   VDEP(r)              "Capital depreciation"
   VKB(r)               "Capital stock"
   POPG(r)              "GTAP population"

   MAKS(i,a,r)          "Make matrix at supply prices"
   MAKB(i,a,r)          "Make matrix at basic prices (incl taxes)"
*  PTAX(i0,a0,r)        "Output taxes"

   VNTM(i, s, d)        "Non-tariff measures revenue"

   remit00(l,s,d)       "Initial remittances"
   yqtf0(r)             "Initial outflow of capital income"
   yqht0(r)             "Initial inflow of capital income"
   odain0(r)            "Initial inflow of ODA"
   odaout0(r)           "Initial outflow of ODA"

   voa(a,r)             "Value of output"
   osep(a,r)            "Value of output subsidies"
   cmat(i,k,r)          "Consumer transition matrix"

   empl(l,a,r)          "Employment levels"

*  Water data

   h2ocrp(a,r)          "Water withdrawal in crop activities"
   h2oUse(wbnd,r)       "Water withdrawal by aggregate uses"

*  Energy matrices

   nrgdf(i, a, r)       "Usage of domestic products by firm, MTOE"
   nrgmf(i, a, r)       "Usage of imported products by firm, MTOE"
   nrgdp(i, r)          "Private usage of domestic products, MTOE"
   nrgmp(i, r)          "Private usage of imported products, MTOE"
   nrgdg(i, r)          "Government usage of domestic products, MTOE"
   nrgmg(i, r)          "Government usage of imported products, MTOE"
   nrgdi(i, r)          "Investment usage of domestic products, MTOE"
   nrgmi(i, r)          "Investment usage of imported products, MTOE"
   exi(i, s, d)         "Bilateral trade in energy"

   nrgComb(i, a, r)     "Energy combustion matrix"

   gwhr(r,a)            "Electricity output in gwhr"

*  Carbon emission matrices

   mdf(i, a, r)         "Emissions from domestic product in current production, .."
   mmf(i, a, r)         "Emissions from imported product in current production, .."
   mdp(i, r)            "Emissions from private consumption of domestic product, Mt CO2"
   mmp(i, r)            "Emissions from private consumption of imported product, Mt CO2"
   mdg(i, r)            "Emissions from govt consumption of domestic product, Mt CO2"
   mmg(i, r)            "Emissions from govt consumption of imported product, Mt CO2"
   mdi(i, r)            "Emissions from invt consumption of domestic product, Mt CO2"
   mmi(i, r)            "Emissions from invt consumption of imported product, Mt CO2"

*  Combustion-based emission matrices

   EMI_IO(em, i, a, r)        "IO-based emissions"
   EMI_IOP(em, i, a, r)       "IO-based processed emissions"
   EMI_endw(em, fp, a, r)     "Endowment-based emissions"
   EMI_qo(em, a, r)           "Output-based emissions"
   EMI_hh(em, i, r)           "Private consumption-based emissions"
;

execute_loaddc "%dataFolder%/%BaseName%Dat.gdx"
   vdfb, vdfp, vmfb, vmfp,
   vdpb, vdpp, vmpb, vmpp,
   vdgb, vdgp, vmgb, vmgp,
   vdib, vdip, vmib, vmip,
   evfb, evfp, evos,
   vxsb, vfob, vcif, vmsb,
   vst, vtwr,
   save, vdep, vkb, popg=pop,
*  ptax,
   maks, makb
;


$iftheni "%ifDEPR0%" == "ON"
   VDEP(r) = 0 ;
$endif

*  For Comp Stat Overlaypop should always be 0
*  For dynamics, popg = SSP_POP if Overlaypop = 1, else equals GTAP level

if(%OVERLAYPOP% eq 0,
   execute_load "%dataFolder%/%BaseName%Dat.gdx" , popg=pop ;
) ;

$onText
*!!!! TBD
* --------------------------------------------------------------------------------------------------
*
*  Load the satellite file
*
* --------------------------------------------------------------------------------------------------

execute_load "%BASENAME%Sat.gdx"
   nrgComb, h2ocrp, h2oUse
;
$offText

* --------------------------------------------------------------------------------------------------
*
*  Load the energy file
*
* --------------------------------------------------------------------------------------------------

Parameters
   nrgxp0(a,r)    "Energy output express in MTOE"
;

execute_loaddc "%dataFolder%/%BaseName%Vole.gdx"
   nrgdf=edf, nrgmf=emf,
   nrgdp=edp, nrgmp=emp,
   nrgdg=edg, nrgmg=emg,
   nrgdi=edi, nrgmi=emi,
   nrgxp0=eqo
   exi=exi ;
;
gwhr(r,a) = emat("MTOE", "gWh") * nrgxp0(a,r) ;

* --------------------------------------------------------------------------------------------------
*
*  Load the emission files
*
* --------------------------------------------------------------------------------------------------

execute_loaddc "%dataFolder%/%BaseName%Emiss.gdx"
   mdf, mmf, mdp,  mmp, mdg, mmg, mdi, mmi, nrgComb ;

scalar ifNCO2     "Flag to determine if we have non-CO2 gases" ;

$ifthen exist "%dataFolder%/%BaseName%NCO2.gdx"

   Parameter
      EMI_LU(GHG,LU,LUType,r)    "Land-use based emissions"
      GWP0(GHG, r, ar)
   ;

   execute_loaddc  "%dataFolder%/%BaseName%NCO2.gdx",
      GWP0=GWP, EMI_IO, EMI_IOP, EMI_ENDW, EMI_QO, EMI_HH, EMI_LU ;

   ifNCO2 = 1 ;

$else

   EMI_io(em, i, a, r)      = 0 ;
   EMI_iop(em, i, a, r)     = 0 ;
   EMI_endw(em, fp, a, r)   = 0 ;
   EMI_qo(em, a, r)         = 0 ;
   EMI_hh(em, i, r)         = 0 ;

   Parameter
      GWP0(GHG, r, ar)
   ;
   GWP0(ghg,r,ar) = 1 ;
   ifNCO2 = 0 ;

$endif


* --------------------------------------------------------------------------------------------------
*
*  Load the BoP file
*
* --------------------------------------------------------------------------------------------------

$ifthen exist "%dataFolder%/%BaseName%BoP.gdx"

   execute_load "%dataFolder%/%BaseName%BoP.gdx"
      remit00=remit, yqtf0=yqtf, yqht0=yqht, ODAIn0=ODAIn, ODAOut0=ODAOut ;

$else

   remit00(l,s,d) = 0 ;
   yqtf0(r)       = 0 ;
   yqht0(r)       = 0 ;
   ODAIn0(r)      = 0 ;
   ODAOut0(r)     = 0 ;

$endif

* --------------------------------------------------------------------------------------------------
*
*  Load the employment file
*
* --------------------------------------------------------------------------------------------------

$ifthen exist "%dataFolder%/%BaseName%Wages.gdx"

   execute_load "%dataFolder%/%BaseName%Wages.gdx", empl=q ;

*  !!!! It's possible that the filtering process zeroes out VA in EVFB, but not employment

   empl(l,a,r)$(evfb(l,a,r) eq 0) = 0 ;

$else

   empl(l,a,r) = na ;

$endif

* --------------------------------------------------------------------------------------------------
*
*  Load the FBS file
*
* --------------------------------------------------------------------------------------------------

$ifthen.FBS exist "%dataFolder%/%BaseName%FBS.gdx"

   Parameters
      nutr0(i,ucat,sua,srcr,r)    "Reference year nutrition accounts"
   ;
   execute_loaddc "%dataFolder%/%BaseName%FBS.gdx", nutr0=nutr ;

$endif.FBS

* --------------------------------------------------------------------------------------------------
*
*  Load the NTM file
*
* --------------------------------------------------------------------------------------------------

*  !!!! Probably requires aggregation !!!!

scalar NTMFlag    "Flag determining presence of NTMs" ;

$iftheni "%NTM_MODULE%" == "ON"

   $$ifthen exist "%dataFolder%/%BaseName%NTM.gdx"

      ntmFlag = 1 ;

      execute_load "%dataFolder%/%BaseName%NTM.gdx", VNTM ;

   $$else

      ntmFlag = 0 ;

      VNTM(i, r, rp) = 0 ;

   $$endif

$else

      ntmFlag = 0 ;

      VNTM(i, r, rp) = 0 ;

$endif

$onText
* --------------------------------------------------------------------------------------------------
*
*  Load the embodied emissions coefficients
*  !!!! This needs to be refined
*
* --------------------------------------------------------------------------------------------------

set
   temix "Time scope for emix coefficients"  / 1990*2100 /
   scope "Scope levels for emissions"        / scope1*scope3 /
;

Parameter
   EmiX0(s,i,temix,scope) "Export embodied emissions KgCO2 per $"
;

$ifthen.EmiX exist "%dataFolder%/%BaseName%EmiX.gdx"

   execute_loaddc "%dataFolder%/%BaseName%EmiX.gdx", EmiX0 = EmiX ;

*  Convert to tons of CO2 emissions per $1 export

   EmiX0(s,i,temix,scope) = 0.001*EmiX0(s,i,temix,scope) ;

$else.Emix

   EmiX0(s,i,temix,scope) = 0 ;

$endif.EmiX
$offText

* --------------------------------------------------------------------------------------------------
*
*  MRIO module
*
* --------------------------------------------------------------------------------------------------

*  !!!! TO BE REVIEWED--including aggregation

set amrio "End-user accounts in MRIO database" /
   INT   "Intermediate demand"
   CONS  "Private and public demand"
   CGDS  "Investment demand"
/ ;

Parameter
   VIUMS(i,amrio,s,d)      "Value of imports by end-user, tariff-inclusive"
   VIUWS(i,amrio,s,d)      "Value of imports by end-user, at border prices"
   max1
   max2
   max3
   max4
   max5
   mtaxa00(i, amrio,s,d)
;


VIUMS(i,amrio,s,d) = 0 ;
VIUWS(i,amrio,s,d) = 0 ;

alias(amrio, aaa) ;
set mrioIter / mrioi1*mrioi50 / ;
put screen ; put / ;

if(MRIO,

   $$ifthen exist "%dataFolder%/%BaseName%MRIO.gdx"

*     Get the MRIO data

      execute_load "%dataFolder%/%BaseName%MRIO.gdx", viums, viuws ;

*     Verify consistency
*     !!!! Maybe add some tolerance checks !!!!

      if(0,
         mtaxa00(i,amrio,s,d) = (VIUMS(i,amrio,s,d)/VIUWS(i,amrio,s,d))$VIUWS0(i,amrio,s,d)
                              + 1$(not VIUWS0(i0,amrio,s,d)) ;

         loop(mrioIter,

            max1 = smax((i,s,d), abs(sum(aaa,VIUWS(i,aaa,s,d)) - VCIF(i,s,d))) ;
            max2 = smax((i,s,d), abs(sum(aaa,VIUMS(i,aaa,s,d)) - VMSB(i,s,d))) ;
            put "MAX1 = ", max1:15:6, " MAX2 = ", max2:15:6 / ;

            if(1,
               VIUWS0(i,amrio,s,d)$sum(aaa,VIUWS(i,aaa,s,d)) =
                  VIUWS(i,amrio,s,d)*VCIF(i,s,d) / sum(aaa,VIUWS(i,aaa,s,d)) ;
               VIUMS(i,amrio,s,d)$sum(aaa,VIUMS(i,aaa,s,d)) =
                  VIUMS0(i,amrio,s,d)*VMSB(i,s,d) / sum(aaa,VIUMS(i,aaa,s,d)) ;
            ) ;

            max1 = smax((i,s,d), abs(sum(aaa,VIUWS(i,aaa,s,d)) - VCIF(i,s,d))) ;
            max2 = smax((i,s,d), abs(sum(aaa,VIUMS(i,aaa,s,d)) - VMSB(i,s,d))) ;

            put "MAX1 = ", max1:15:6, " MAX2 = ", max2:15:6 / ;

            max3 = smax((i,d), abs(sum(a,VMFB(i,a,d)) - sum(s, VIUMS(i,"INT",s,d)))) ;
            put "MAX3 = ", max3:15:6 / ;
            VIUMS(i,"INT",s,d)$sum(r,VIUMS(i,"INT",r,d))
               = VIUMS(i,"INT",s,d)*sum(a, VMFB(i,a,d))/sum(r,VIUMS(i,"INT",r,d)) ;

            max3 = smax((i,d), abs(sum(a,VMFB(i,a,d)) - sum(s, VIUMS(i,"INT",s,d)))) ;
            put "MAX3 = ", max3:15:6 / ;

            max4 = smax((i,d), abs(VMPB(i,d)+VMGB(i,d) - sum(s, VIUMS(i,"CONS",s,d)))) ;
            put "MAX4 = ", max4:15:6 / ;
            VIUMS(i,"CONS",s,d)$sum(r,VIUMS0(i,"CONS",r,d))
               = VIUMS(i,"CONS",s,d)*(VMPB(i,d)+VMGB(i,d))/sum(r,VIUMS(i,"CONS",r,d)) ;

            max4 = smax((i,d), abs(VMPB(i,d)+VMGB(i,d) - sum(s, VIUMS(i,"CONS",s,d)))) ;
            put "MAX4 = ", max4:15:6 / ;

            max5 = smax((i,d), abs(VMIB(i,d) - sum(s, VIUMS(i,"CGDS",s,d)))) ;
            put "MAX5 = ", max5:15:6 / ;
            VIUMS0(i,"CGDS",s,d)$sum(r,VIUMS(i,"CGDS",r,d))
               = VIUMS(i,"CGDS",s,d)*VMIB(i,d)/sum(r,VIUMS(i,"CGDS",r,d)) ;

            max5 = smax((i,d), abs(VMIB(i,d) - sum(s, VIUMS(i,"CGDS",s,d)))) ;
            put "MAX5 = ", max5:15:6 / ;

            if(ord(mrioiter) eq 1, VIUWS(i,amrio,s,d) = VIUMS(i,amrio,s,d)/mtaxa00(i,amrio,s,d) ;) ;

            max1 = smax((i,s,d), abs(sum(aaa,VIUWS(i,aaa,s,d)) - VCIF(i,s,d))) ;
            max2 = smax((i,s,d), abs(sum(aaa,VIUMS(i,aaa,s,d)) - VMSB(i,s,d))) ;
            put "MAX1 = ", max1:15:6, " MAX2 = ", max2:15:6 / ;
         ) ;

         abort "Temp" ;
      ) ;
   $$endif
) ;

$iftheni.ifDEPL "%DEPL_MODULE%" == "ON"

* --------------------------------------------------------------------------------------------------
*
*  Initialize depletion module
*
* --------------------------------------------------------------------------------------------------

Parameters
   extraction(r,a)         "Base year extraction in mbbl"
   reserves(r,a)           "Base year proven reserves in mbbl"
   ytdreserves(r,a)        "Base year unproven reserves in mbbl"
;

   $$ifthen.ifFile exist "%dataFolder%/%BaseName%DEPL.gdx"

      execute_load "%dataFolder%/%BaseName%DEPL.gdx", extraction, reserves, ytdreserves ;

   $$else.ifFile

      extraction(r,a)     = 0 ;
      reserves(r,a,pt)    = 0 ;
      ytdreserves(r,a,pt) = 0 ;

      put screen ; put / ;
      put ">>>>> ERROR: Requested depletion module, but data file not loaded:" / ;
      put ">>>>>        ", "%dataFolder%/%BaseName%DEPL.gdx" / ;
      Abort "Temp" ;

   $$endif.ifFile

$endif.ifDEPL

$iftheni.R_D "%RD_MODULE%" == "ON"

* --------------------------------------------------------------------------------------------------
*
*  Initialize R&D module
*
* --------------------------------------------------------------------------------------------------

   Parameter
      VDRB(i, r)           "R&D purchases of domestic goods at basic prices"
      VDRP(i, r)           "R&D purchases of domestic goods at purchaser prices"
      VMRB(i, r)           "R&D purchases of imported goods at basic prices"
      VMRP(i, r)           "R&D purchases of domestic goods at purchaser prices"
      rdShr0(r)            "Initial share of R&D in government expenditures"
   ;

*  Do we have data for R&D costs

   $$ifthen.ifFileR_D exist "%dataFolder%/%BaseName%R_D.gdx"

      execute_load "%dataFolder%/%BaseName%R_D.gdx", VDRB, VDRP, VMRB, VMRP ;

   $$else.ifFileR_D

*     Assume same cost structure as for government expenditures

      gdpmp0(r) = sum(i, VDPP(i,r) + VMPP(i,r)
                +         VDGP(i,r) + VMGP(i,r)
                +         VDIP(i,r) + VMIP(i,r)
                +         VST(i,r)
                +  sum(d, VFOB(i,r,d)) - sum(s, VCIF(i,s,r))) ;
*     display gdpmp0 ; abort "Temp" ;

      rdShr0(r) = 0.01*KnowledgeData0(r,"rd0")*gdpmp0(r)
                / sum(i, VDGP(i,r) + VMGP(i,r)) ;

*     display rdShr0 ; abort "Temp" ;

      vdrb(i,r) = rdshr0(r)*vdgb(i,r) ;
      vdrp(i,r) = rdshr0(r)*vdgp(i,r) ;
      vmrb(i,r) = rdshr0(r)*vmgb(i,r) ;
      vmrp(i,r) = rdshr0(r)*vmgp(i,r) ;

   $$endif.ifFileR_D

*  Subtract R&D from government expenditures

   vdgb(i,r) = vdgb(i,r) - vdrb(i,r) ;
   vdgp(i,r) = vdgp(i,r) - vdrp(i,r) ;
   vmgb(i,r) = vmgb(i,r) - vmrb(i,r) ;
   vmgp(i,r) = vmgp(i,r) - vmrp(i,r) ;

*  display vdrb ;

*  Adjust energy/emissions tables

   Parameters

*     Energy

      nrgdr(i,r)          "R&D usage of domestic products, MTOE"
      nrgmr(i,r)          "R&D usage of domestic products, MTOE"

*     Carbon emission matrices

      mdr(i, r)           "Emissions from R&D of domestic product, Mt CO2"
      mmr(i, r)           "Emissions from R&D of imported product, Mt CO2"
   ;

   nrgdr(i,r) = vdgb(i,r)+vdrb(i,r) ;
   nrgdr(i,r)$nrgdr(i,r) = nrgdg(i,r)*(vdrb(i,r)/nrgdr(i,r)) ;
   nrgdg(i,r) = nrgdg(i,r) - nrgdr(i,r) ;

   nrgmr(i,r) = vmgb(i,r)+vmrb(i,r) ;
   nrgmr(i,r)$nrgmr(i,r) = nrgmg(i,r)*(vmrb(i,r)/nrgmr(i,r)) ;
   nrgmg(i,r) = nrgmg(i,r) - nrgmr(i,r) ;

   mdr(i,r) = nrgdg(i,r)+nrgdr(i,r) ;
   mdr(i,r)$mdr(i,r) = mdg(i,r)*(nrgdr(i,r)/mdr(i,r)) ;
   mdg(i,r) = mdg(i,r) - mdr(i,r) ;

   mmr(i,r) = nrgmg(i,r)+nrgmr(i,r) ;
   mmr(i,r)$mmr(i,r) = mmg(i,r)*(nrgmr(i,r)/mmr(i,r)) ;
   mmg(i,r) = mmg(i,r) - mmr(i,r) ;

$endif.R_D

$iftheni "%IFI_MODULE%" == "ON"

*  !!!! NEEDS TO BE REVIEWED/REVISED
* --------------------------------------------------------------------------------------------------
*
*  Initialize IFI module
*
* --------------------------------------------------------------------------------------------------

   Parameter
      VDDB(i, r)           "IFI purchases of domestic goods at basic prices"
      VDDP(i, r)           "IFI purchases of domestic goods at purchaser prices"
      VMDB(i, r)           "IFI purchases of imported goods at basic prices"
      VMDP(i, r)           "IFI purchases of domestic goods at purchaser prices"
      VIUWSD(i, r, s)      "Source of IFI import purchases at CIF prices"
      YFDWFP0(r)           "Initial WFP expenditures"
      YFDWFP(r)            "Data-base WFP expenditures"
      ddShr0(r)            "Initial share of IFI in government expenditures"
   ;

*  Do we have data for IFI costs

   $$ifthen exist "%dataFolder%/%BaseName%IFI.gdx"

      execute_load "%dataFolder%/%BaseName%IFI.gdx", VDDB, VDDP, VMDB, VMDP, VIUMSD, VIUWSD, YFDWFP0 ;
      YFDWFP(r) = sum(i, VDDP(i,r) + VMDP(i,r)) ;

*     Rescale

      VDDB(i,r)$YFDWFP(r) = VDDB(i,r)*YFDWFP0(r)/YFDWFP(r) ;
      VDDP(i,r)$YFDWFP(r) = VDDP(i,r)*YFDWFP0(r)/YFDWFP(r) ;
      VMDB(i,r)$YFDWFP(r) = VMDB(i,r)*YFDWFP0(r)/YFDWFP(r) ;
      VMDP(i,r)$YFDWFP(r) = VMDP(i,r)*YFDWFP0(r)/YFDWFP(r) ;
      VIUMSD(i,s,r)$YFDWFP(r) = VIUMSD(i,s,r)*YFDWFP0(r)/YFDWFP(r) ;
      VIUWSD(i,s,r)$YFDWFP(r) = VIUWSD(i,s,r)*YFDWFP0(r)/YFDWFP(r) ;
      ifiin0(r)  = inscale*YFDWFP0(r) ;

   $$else

*     Assume same cost structure as for government expenditures

      gdpmp0(r) = sum(i, VDPP(i,r) + VMPP(i,r)
                +        VDGP(i,r) + VMGP(i,r)
                +        VDIP(i,r) + VMIP(i,r)
                +        VST(i0,r)
                +  sum(d, VFOB(i,r,d)) - sum(s, VCIF(i,s,r))) ;

      ddShr0(r) = 0.01*IFIData0(r,"ifi0")*gdpmp0(r)
                / sum(i, VDGP(i,r) + VMGP(i,r)) ;

      if(0,
         display gdpmp0, ddShr0 ;
         abort "Temp" ;
      ) ;

      vmdb(i,r) = ddshr0(r)*vdgb(i,r) ;
      vmdp(i,r) = ddshr0(r)*vdgp(i,r) ;
      vddb(i,r) = ddshr0(r)*vmgb(i,r) ;
      vddp(i,r) = ddshr0(r)*vmgp(i,r) ;
      ifiin0(r) = inscale * sum(i, vddp(i,r) + vmdp(i,r)) ;

   $$endif

   ifiout0(r) = 0.01*IFIData0(r,"ifiOut0") * sum(d, ifiin0(d)) ;

*  Subtract IFI from government expenditures

   if(0,
      vdgb(i,r) = vdgb(i,r) - vddb(i,r) ;
      vdgp(i,r) = vdgp(i,r) - vddp(i,r) ;
      vmgb(i,r) = vmgb(i,r) - vmdb(i,r) ;
      vmgp(i,r) = vmgp(i,r) - vmdp(i,r) ;
   ) ;

*  display vdrb ;

*  Adjust energy/emissions tables

   Parameters

*     Energy

      nrgdd(i,r)           "IFI usage of domestic products, MTOE"
      nrgmd(i,r)           "IFI usage of domestic products, MTOE"

*     Carbon emission matrices

      mdd(i, r)            "Emissions from IFI of domestic product, Mt CO2"
      mmd(i, r)            "Emissions from IFI of imported product, Mt CO2"
   ;

   nrgdd(i,r) = vdgb(i,r)+vddb(i,r) ;
   nrgdd(i,r)$nrgdd(i,r) = nrgdg(i,r)*(vddb(i,r)/nrgdd(i,r)) ;
   if(0,
      nrgdg(i,r) = nrgdg(i,r) - nrgdd(i,r) ;
   ) ;

   nrgmd(i,r) = vmgb(i,r)+vmdb(i,r) ;
   nrgmd(i,r)$nrgmd(i,r) = nrgmg(i,r)*(vmdb(i,r)/nrgmd(i,r)) ;
   if(0,
      nrgmg(i,r) = nrgmg(i,r) - nrgmd(i,r) ;
   ) ;

   mdd(i,r) = nrgdg(i,r)+nrgdd(i,r) ;
   mdd(i,r)$mdd(i,r) = mdg(i,r)*(nrgdd(i,r)/mdd(i,r)) ;
   if(0,
      mdg(i,r) = mdg(i,r) - mdd(i,r) ;
   ) ;

   mmd(i,r) = nrgmg(i0,r)+nrgmd(i,r) ;
   mmd(i,r)$mmd(i,r) = mmg(i,r)*(nrgmd(i,r)/mmd(i,r)) ;
   if(0,
      mmg(i,r) = mmg(i,r) - mmd(i,r) ;
   ) ;

$endif

$iftheni "%DAMAGE_MODULE%" == "ON"
   $$include "%dataFolder%/%BaseName%DMG.gms"
$endif
