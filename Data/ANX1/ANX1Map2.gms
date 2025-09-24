$onempty

$setGlobal aggStep aggSecondary

sets
   i  "Commodities"   /
         AGR-c       "Agriculture"
         FRS-c       "Forestry"
         COA-c       "Coal"
         OIL-c       "Oil"
         GAS-c       "Gas"
         OXT-c       "Minerals nec"
         EIT-c       "Vegetable oils and fats"
         XMN-c       "Dairy products"
         P_C-c       "Petroleum and coal products"
         ELY-c       "Electricity"
         SRV-c       "Services"
      /

   m(i)  "Margin commodities"

   a  "Activities"   /
         AGR-a       "Agriculture"
         FRS-a       "Forestry"
         COA-a       "Coal"
         OIL-a       "Oil"
         GAS-a       "Gas"
         OXT-a       "Minerals nec"
         EIT-a       "Vegetable oils and fats"
         XMN-a       "Dairy products"
         P_C-a       "Petroleum and coal products"
         ETD-a       "Electricity transmission"
         CLP-a       "Coal-fired power"
         OLP-a       "Oil-fired power"
         GSP-a       "Gas-fired power"
         NUC-a       "Nuclear power"
         HYD-a       "Hydro power"
         SOL-a       "Solar power"
         WND-a       "Wind power"
         XEL-a       "Other power"
         SRV-a       "Services"
      /

   r  "Regions" /
         USA         "United States"
         EUR         "Western Europe"
         XOE         "Other HIY OECD"
         CHN         "China"
         RUS         "Russia"
         OPC         "Major oil and gas exporters"
         XEA         "Rest of East Asia and Pacific"
         SAS         "South Asia"
         XLC         "Rest of Latin America & Caribbean"
         ROW         "Rest of the World"
       /

   fp  "Factors of production"  /
         NSK         "Unskilled labor"
         SKL         "Skilled labor"
         CAP         "Capital"
         LND         "Land"
         NRS         "Natural resources"
      /

   l(fp)  "Labor factors" /
         NSK      "Unskilled labor"
         SKL      "Skilled labor"
      /
   cap(fp) "Capital" /
         CAP      "Capital"
      /
   lnd(fp) "Land endowment" /
         LND      "Land"
      /
   nrs(fp) "Natural resources" /
         NRS      "Natural resources"
      /
;

Parameter
   etrae1(fp,r) "CET transformation elasticities for factor allocation"
;

*  Use the GTAP convention that CET elastities are entered as negative numbers

parameter etrae0(fp) "CET transformation elasticities for factor allocation" /
   NSK      inf
   SKL      inf
   CAP      inf
   LND     -1
   NRS     -0.001
/ ;

etrae1(fp,r) = etrae0(fp) ;

set
   fpf(fp)     "Sector specific factors"
   fps(fp)     "Sluggish factors"
   fpm(fp)     "Mobile factors"
;

fpf(fp)$(abs(etrae0(fp)) lt 0.01) = yes ;
fpm(fp)$(etrae0(fp) eq inf)       = yes ;
fps(fp)$(not fpf(fp) and not fpm(fp)) = yes ;

*  NEW -- MAKE ELASTICITIES

Parameter
   etraq1(a,r)       "MAKE CET Elasticity"
   esubq1(i,r)       "MAKE CES Elasticity"
;
etraq1(a,r) = -5 ;
esubq1(i,r) = inf ;

*  NEW -- EXPENDITURE ELASTICITIES

Parameter
   esubg1(r)         "Government expenditure CES elasticity"
   esubi1(r)         "Investment expenditure CES elasticity"
   esubs1(i)         "Transport margins CES elasticity"
;

esubg1(r) = 1 ;
esubi1(r) = 0 ;
esubs1(i) = 1 ;

set mapt(a) "Merge land and capital payments in the following sectors" /

/ ;

set mapn(a) "Merge natl. res. and capital payments in the following sectors" /

/ ;

*  Commodity mapping
set mapi(i,comm) /
   AGR-c.AGR
   FRS-c.FRS
   COA-c.COA
   OIL-c.OIL
   GAS-c.GAS
   OXT-c.OXT
   EIT-c.EIT
   XMN-c.XMN
   P_C-c.P_C
   ELY-c.ETD
   ELY-c.CLP
   ELY-c.OLP
   ELY-c.GSP
   ELY-c.NUC
   ELY-c.HYD
   ELY-c.SOL
   ELY-c.WND
   ELY-c.XEL
   SRV-c.SRV
/ ;

set mapa(a,acts) /
   AGR-a.AGR
   FRS-a.FRS
   COA-a.COA
   OIL-a.OIL
   GAS-a.GAS
   OXT-a.OXT
   EIT-a.EIT
   XMN-a.XMN
   P_C-a.P_C
   ETD-a.ETD
   CLP-a.CLP
   OLP-a.OLP
   GSP-a.GSP
   NUC-a.NUC
   HYD-a.HYD
   SOL-a.SOL
   WND-a.WND
   XEL-a.XEL
   SRV-a.SRV
/ ;

set mapr(r,reg) ; mapr(r,reg)$sameas(reg,r) = yes ;

set mapf(fp,endw) ; mapf(fp,endw)$sameas(endw, fp) = yes ;

*  Only used if the LU database exists

set AEZ  / AEZ1*AEZ18 / ;
set AEZ1 / AEZ1*AEZ18 / ;
set mapLU(aez1,aez) ; mapLU(aez1,aez)$sameas(aez1,aez) = yes ;
