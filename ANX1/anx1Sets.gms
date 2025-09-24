$onempty
*/ ---------------------------------------------------------------------------------------
*
*     Sets needed for the ENVISAGE model, i.e., not defined for the GTAP Model
*     Only sets that are aggregation dependent.
*     Non-aggregation dependent sets are definedin getData.gms
*
*/ ---------------------------------------------------------------------------------------

*   Subsets ul(l) and sl(l) included for backward compatibility
*  !!!! This should come from somewhere else--not part of GTAP

set ul(l) "Unskilled labor" /
   set.lab
/ ;

set sl(l) "Skilled labor" ; sl(l)$(not ul(l)) = yes ;

*  !!!! This should come from somewhere else--not part of GTAP
*  !!!! Solved with flexible nesting

set wb "Intermediate labor bundle(s)" /
   Single       "Single intermediate labor bundle"
/ ;

set maplab1(wb) "Mapping of intermediate labor demand bundle(s) to LAB1" /
   Single       "Single intermediate labor bundle"
/ ;

set mapl(wb,l) "Mapping of labor categories to intermedate demand bundle(s)" /
   Single   .nsk
   Single   .skl
/ ;

set lr(l) "Reference labor for skill premium" /
   skl          "Skilled labor"
/ ;

* >>>> MUST INSERT RESIDUAL REGION (ONLY ONE)

set rres(r) "Residual region" /
   USA          "United States"
/ ;

* >>>> MUST INSERT MUV REGIONS (ONE OR MORE)

set rmuv(r) "MUV regions" /
   CHN          "China"
   USA          "United States"
   EUR          "Western Europe"
   XOE          "Other HIY OECD"
/ ;

* >>>> MUST INSERT MUV COMMODITIES (ONE OR MORE)

set imuv(i) "MUV commodities" /
   EIT-c
   XMN-c
/ ;

set iedu(i) "Education sector(s)" /
   SRV-c
/ ;

set ihht(i) "Health sector(s)" /
   SRV-c
/ ;

set ia "Aggregate commodities for model output" /
   set.comm
   tagr-c       "Agriculture"
   tman-c       "Manufacturing"
   tsrv-c       "Services"
   toth-c       "Other"
   ttot-c       "Total"
/ ;

set mapia(ia,i) "Mapping for aggregate commodities" /
   tagr-c   .FRS-c
   tagr-c   .AGR-c
   tman-c   .P_C-c
   tman-c   .EIT-c
   tman-c   .XMN-c
   tsrv-c   .SRV-c
   tsrv-c   .ELY-c
   toth-c   .COA-c
   toth-c   .OIL-c
   toth-c   .GAS-c
   toth-c   .OXT-c
/ ;
mapia(ia,i)$sameas(ia,i) = yes ;
mapia("ttot-c",i) = yes ;

set iaa(ia) "Aggregate commodities only" ;
loop((i,ia)$(not sameas(i,ia)), iaa(ia) = yes ; ) ;

set aga "Aggregate activities for model output" /
   set.acts
   tagr-a       "Agriculture"
   tman-a       "Manufacturing"
   tsrv-a       "Services"
   toth-a       "Other"
   ttot-a       "Total"
/ ;

set mapaga(aga,a) "Mapping for aggregate activities" /
   tagr-a   .FRS-a
   tagr-a   .AGR-a
   tman-a   .P_C-a
   tman-a   .EIT-a
   tman-a   .XMN-a
   tsrv-a   .ETD-a
   tsrv-a   .CLP-a
   tsrv-a   .OLP-a
   tsrv-a   .GSP-a
   tsrv-a   .NUC-a
   tsrv-a   .HYD-a
   tsrv-a   .SOL-a
   tsrv-a   .WND-a
   tsrv-a   .XEL-a
   tsrv-a   .SRV-a
   toth-a   .COA-a
   toth-a   .OIL-a
   toth-a   .GAS-a
   toth-a   .OXT-a
/ ;
mapaga(aga,a)$sameas(aga,a) = yes ;
mapaga("ttot-a",a) = yes ;

set agaa(aga) "Aggregate activities only" ;
loop((a,aga)$(not sameas(a,aga)), agaa(aga) = yes ; ) ;

set ra "Aggregate regions for emission regimes and model output" /
   set.reg
   hic          "High-income countries"
   lmy          "Developing countries"
   wld          "World Total"
/ ;

set mapra(ra,r) "Mapping for aggregate regions" /
   hic      .USA
   hic      .EUR
   hic      .XOE
/ ;
mapra(ra,r)$sameas(ra,r) = yes ;
mapra("lmy",r)$(not mapra("hic",r)) = yes ;
mapra("wld",r) = yes ;

set rra(ra) "Aggregate regions only" ;
loop((r,ra)$(not sameas(r,ra)), rra(ra) = yes ; ) ;

set lagg "Aggregate labor for output" /
   set.lab
   tot          "Total labor"
/ ;

set maplagg(lagg,l) "Mapping for aggregate labor" ;
maplagg(lagg,l)$sameas(lagg,l) = yes ;
maplagg("tot",l) = yes ;

set nsk(l) "Unskilled types for labor growth assumptions" /
   nsk          "Unskilled labor"
/ ;

set skl(l)  "Skill types for labor growth assumptions" /
   skl          "Skilled labor"
/ ;

set acr(a) "Crop activities" /
/ ;

set alv(a) "Livestock activities" /
/ ;

set ax(a) "All other activities" /
   FRS-a        "Forestry"
   COA-a        "Coal"
   OIL-a        "Oil"
   GAS-a        "Gas"
   OXT-a        "Minerals nec"
   P_C-a        "Petroleum and coal products"
   AGR-a        "Agriculture"
   EIT-a        "Vegetable oils and fats"
   XMN-a        "Dairy products"
   ETD-a        "Electricity transmission"
   CLP-a        "Coal-fired power"
   OLP-a        "Oil-fired power"
   GSP-a        "Gas-fired power"
   NUC-a        "Nuclear power"
   HYD-a        "Hydro power"
   SOL-a        "Solar power"
   WND-a        "Wind power"
   XEL-a        "Other power"
   SRV-a        "Services"
/ ;

set agr(a) "Agricultural activities" /
   AGR-a        "Agriculture"
/ ;

set man(a) "Manufacturing activities" /
   EIT-a        "Vegetable oils and fats"
   XMN-a        "Dairy products"
/ ;

set srv(a) "Service activities" /
   FRS-a        "Forestry"
   COA-a        "Coal"
   OIL-a        "Oil"
   GAS-a        "Gas"
   OXT-a        "Minerals nec"
   P_C-a        "Petroleum and coal products"
   ETD-a        "Electricity transmission"
   CLP-a        "Coal-fired power"
   OLP-a        "Oil-fired power"
   GSP-a        "Gas-fired power"
   NUC-a        "Nuclear power"
   HYD-a        "Hydro power"
   SOL-a        "Solar power"
   WND-a        "Wind power"
   XEL-a        "Other power"
   SRV-a        "Services"
/ ;

set aenergy(a) "Energy activities" /
   COA-a        "Coal"
   OIL-a        "Oil"
   GAS-a        "Gas"
   P_C-a        "Petroleum and coal products"
   ETD-a        "Electricity transmission"
   CLP-a        "Coal-fired power"
   OLP-a        "Oil-fired power"
   GSP-a        "Gas-fired power"
   NUC-a        "Nuclear power"
   HYD-a        "Hydro power"
   SOL-a        "Solar power"
   WND-a        "Wind power"
   XEL-a        "Other power"
/ ;

set affl(a) "Fossil fuel activities" /
   COA-a        "Coal"
   OIL-a        "Oil"
   GAS-a        "Gas"
/ ;

set aw(a) "Water services activities" /
/ ;

set z "Labor market zones" /
   rur          "Agricultural sectors"
   urb          "Non-agricultural sectors"
   nsg          "Non-segmented labor markets"
/ ;

singleton set rur(z) "Rural zone" /
   rur          "Agricultural sectors"
/ ;

singleton set urb(z) "Urban zone" /
   urb          "Non-agricultural sectors"
/ ;

singleton set nsg(z) "Both zones" /
   nsg          "Non-segmented labor markets"
/ ;

set mapz(z,a) "Mapping of activities to zones" /
   rur.AGR-a
   urb.FRS-a
   urb.COA-a
   urb.OIL-a
   urb.GAS-a
   urb.OXT-a
   urb.P_C-a
   urb.EIT-a
   urb.XMN-a
   urb.ETD-a
   urb.CLP-a
   urb.OLP-a
   urb.GSP-a
   urb.NUC-a
   urb.HYD-a
   urb.SOL-a
   urb.WND-a
   urb.XEL-a
   urb.SRV-a
/ ;

mapz("nsg", a) = yes ;

set frt(i) "Fertilizer commodities" /
/ ;

set feed(i) "Feed commodities" /
/ ;

set iw(i) "Water services commodities" /
/ ;

set e(i) "Energy commodities" /
   COA-c        "Coal"
   OIL-c        "Oil"
   GAS-c        "Gas"
   P_C-c        "Petroleum and coal products"
   ELY-c        "Electricity"
/ ;

set elyc(i) "Electricity commodities" /
   ELY-c        "Electricity"
/ ;

set fuel(e) "Fuel commodities" /
   COA-c        "COA"
   OIL-c        "OIL"
   GAS-c        "GAS"
   P_C-c        "P_C"
/ ;

set k "Household commodities" /
   OXT-k        "Minerals nec"
   AGR-k        "Agriculture"
   EIT-k        "Energy intensive goods"
   XMN-k        "Other manufacturing"
   SRV-k        "Services"
   nrg-k        "Energy"
/ ;

set fud(k) "Household food commodities" /
   AGR-k        "Agriculture"
/ ;

set mapk(k,i) "Mapping from i to k" /
   OXT-k.FRS-c
   nrg-k.COA-c
   nrg-k.OIL-c
   nrg-k.GAS-c
   OXT-k.OXT-c
   nrg-k.P_C-c
   AGR-k.AGR-c
   EIT-k.EIT-c
   XMN-k.XMN-c
   SRV-k.SRV-c
   nrg-k.ELY-c
/ ;

set CPINDX "Categories of CPI indices" /
   tot        "Total price index"
/ ;

set mapCPI(cpindx,i) "Mapping from i to CPINDX" /
   tot    .FRS-c
   tot    .COA-c
   tot    .OIL-c
   tot    .GAS-c
   tot    .OXT-c
   tot    .P_C-c
   tot    .AGR-c
   tot    .EIT-c
   tot    .XMN-c
   tot    .SRV-c
   tot    .ELY-c
/ ;

set elya(a) "Power activities" /
   ETD-a        "Electricity transmission"
   CLP-a        "Coal-fired power"
   OLP-a        "Oil-fired power"
   GSP-a        "Gas-fired power"
   NUC-a        "Nuclear power"
   HYD-a        "Hydro power"
   SOL-a        "Solar power"
   WND-a        "Wind power"
   XEL-a        "Other power"
/ ;

set etd(a) "Electricity transmission and distribution activities" /
   ETD-a        "Electricity transmission"
/ ;

set primElya(a) "Primary power activities" /
   NUC-a        "NUC"
   HYD-a        "HYD"
   SOL-a        "SOL"
   WND-a        "WND"
   XEL-a        "XEL"
/ ;

set pb "Power bundles in power aggregation" /
   GasP         "Gas bundle"
   OilP         "Oil bundle"
   coap         "Coal bundle"
   nucp         "Nuclear"
   hydp         "Hydro"
   renp         "Renewables"
/ ;

set mappow(pb,elya) "Mapping of power activities to power bundles" /
   GasP     .GSP-a
   OilP     .OLP-a
   coap     .CLP-a
   nucp     .NUC-a
   hydp     .HYD-a
   renp     .SOL-a
   renp     .WND-a
   renp     .XEL-a
/ ;

set lb "Land bundles" /
   AGR          "Agriculture"
/ ;

set lb1(lb) "First land bundle" /
   AGR          "Agriculture"
/ ;

set maplb(lb,a) "Mapping of activities to land bundles" /
   AGR      .AGR-a
/ ;

set wbnd "Aggregate water markets" /
   N_A          "N_A"
/ ;

set wbnd1(wbnd) "Top level water markets" /
/ ;

set wbnd2(wbnd) "Second level water markets" /
/ ;

set wbndex(wbnd) "Second level water markets" /
/ ;

set mapw1(wbnd,wbnd) "Mapping of first level water bundles" /
/ ;

set mapw2(wbnd,a) "Mapping of second level water bundle" /
/ ;

set wbnda(wbnd) "Water bundles mapped one-to-one to activities" /
/ ;

set wbndi(wbnd) "Water bundles mapped to aggregate output" /
/ ;

set mape(NRG,e) "Mapping of energy commodities to energy bundles" /
   COA      .COA-c
   OIL      .OIL-c
   OIL      .P_C-c
   GAS      .GAS-c
   ELY      .ELY-c
/ ;

set mapnd1(i,a) "Mapping of commodities to ND1 bundle" ;
set mapnd2(i,a) "Mapping of commodities to ND2 bundle" / / ;

mapnd1(i,a)$(not mapnd2(i,a) and not e(i)) = yes ;

set rq(ra) "Regions submitted to an emissions cap" ;
rq(ra) = no ;

set aets "Agent specific ETS coalitions" /
   All        "ALL agents"
/ ;

$iftheni.modSets %ifModel% == 1
set mapETS(ra,aets,aa) "Mapping of agents to ETS coalitions" ;
mapETS(ra, "All", aa) = yes ;

sets es  "Emission scopes" /
            Scope1 "Direct emissions",
            Scope2 "Direct emissions plus electricity emissions",
            Scope3 "Direct + indirect emissions"
         /
; 

set mapScope(ra,i,es) "Scope per coalition" ;
mapScope(ra,i,"Scope2") = yes ;

Parameter emiLagFlag(ra) "Weight of lagged embodied emissions per coalition" ;
emiLagFlag(ra) = 0 ;

set educMap(r,l,ed) "Mapping of skills to education levels" /
   CHN      .nsk     .elev0
   CHN      .skl     .elev1
   CHN      .skl     .elev2
   XEA      .nsk     .elev0
   XEA      .skl     .elev1
   XEA      .skl     .elev2
   USA      .nsk     .elev0
   USA      .nsk     .elev1
   USA      .skl     .elev2
   RUS      .nsk     .elev0
   RUS      .skl     .elev1
   RUS      .skl     .elev2
   EUR      .nsk     .elev0
   EUR      .nsk     .elev1
   EUR      .skl     .elev2
   XOE      .nsk     .elev0
   XOE      .nsk     .elev1
   XOE      .skl     .elev2
   OPC      .nsk     .elev0
   OPC      .skl     .elev1
   OPC      .skl     .elev2
   SAS      .nsk     .elev0
   SAS      .skl     .elev1
   SAS      .skl     .elev2
   XLC      .nsk     .elev0
   XLC      .skl     .elev1
   XLC      .skl     .elev2
   ROW      .nsk     .elev0
   ROW      .skl     .elev1
   ROW      .skl     .elev2
/ ;

set sortOrder / sort1*sort75 / ;

*  !!!! We might be able to replace this with code

set mapOrder(sortOrder,is) /
sort1.AGR-a
sort2.FRS-a
sort3.COA-a
sort4.OIL-a
sort5.GAS-a
sort6.OXT-a
sort7.EIT-a
sort8.XMN-a
sort9.P_C-a
sort10.ETD-a
sort11.CLP-a
sort12.OLP-a
sort13.GSP-a
sort14.NUC-a
sort15.HYD-a
sort16.SOL-a
sort17.WND-a
sort18.XEL-a
sort19.SRV-a
sort20.AGR-c
sort21.FRS-c
sort22.COA-c
sort23.OIL-c
sort24.GAS-c
sort25.OXT-c
sort26.EIT-c
sort27.XMN-c
sort28.P_C-c
sort29.ELY-c
sort30.SRV-c
sort31.nsk
sort32.skl
sort33.cap
sort34.nrs
sort35.lnd
sort36.TRD
sort37.regY
sort38.hhd
sort39.gov
sort40.r_d
sort41.inv
sort49.deprY
sort50.tmg
sort51.itax
sort52.ptax
sort53.mtax
sort54.etax
sort55.vtax
sort56.ltax
sort57.ktax
sort58.rtax
sort59.vsub
sort60.wtax
sort61.dtax
sort62.ctax
sort63.ntmY
sort64.bop
sort65.tot
sort66.USA
sort67.EUR
sort68.XOE
sort69.CHN
sort70.RUS
sort71.OPC
sort72.XEA
sort73.SAS
sort74.XLC
sort75.ROW
/ ;
$endif.ModSets