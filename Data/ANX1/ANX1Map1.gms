$onempty

$setGlobal aggStep aggPrimary

sets
   i  "Commodities"   /
         AGR          "Agriculture"
         FRS          "Forestry"
         COA          "Coal"
         OIL          "Oil"
         GAS          "Gas"
         OXT          "Minerals nec"
         EIT          "Vegetable oils and fats"
         XMN          "Dairy products"
         P_C          "Petroleum and coal products"
         ETD          "Electricity transmission"
         CLP          "Coal-fired power"
         OLP          "Oil-fired power"
         GSP          "Gas-fired power"
         NUC          "Nuclear power"
         HYD          "Hydro power"
         SOL          "Solar power"
         WND          "Wind power"
         XEL          "Other power"
         SRV          "Services"
      /

   m(i)  "Margin commodities"

   a  "Activities"   /
         set.i
      /

   r  "Regions" /
         USA          "United States"
         EUR          "Western Europe"
         XOE          "Other HIY OECD"
         CHN          "China"
         RUS          "Russia"
         OPC          "Major oil and gas exporters"
         XEA          "Rest of East Asia and Pacific"
         SAS          "South Asia"
         XLC          "Rest of Latin America & Caribbean"
         ROW          "Rest of the World"
       /

   fp  "Factors of production"  /
         NSK     "Unskilled labor"
         SKL     "Skilled labor"
         CAP     "Capital"
         LND     "Land"
         NRS     "Natural resources"
      /

   l(fp)  "Labor factors" /
         NSK     "Unskilled labor"
         SKL     "Skilled labor"
      /
   cap(fp) "Capital" /
         CAP     "Capital"
      /
   lnd(fp) "Land endowment" /
         LND     "Land"
      /
   nrs(fp) "Natural resources" /
         NRS     "Natural resources"
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
   AGR
/ ;
mapt(a) = not mapt(a) ;

set mapn(a) "Merge natl. res. and capital payments in the following sectors" /
   frs, coa, oil, gas, oxt
/ ;
mapn(a) = not mapn(a) ;

*  Commodity mapping
set mapi(i,comm) /
   AGR.PDR
   AGR.WHT
   AGR.GRO
   AGR.V_F
   AGR.OSD
   AGR.C_B
   AGR.PFB
   AGR.OCR
   AGR.CTL
   AGR.OAP
   AGR.RMK
   AGR.WOL
   FRS.FRS
   XMN.FSH
   COA.COA
   OIL.OIL
   GAS.GAS
   OXT.OXT
   XMN.CMT
   XMN.OMT
   XMN.VOL
   XMN.MIL
   XMN.PCR
   XMN.SGR
   XMN.OFD
   XMN.B_T
   XMN.TEX
   XMN.WAP
   XMN.LEA
   XMN.LUM
   EIT.PPP
   P_C.P_C
   EIT.CHM
   XMN.BPH
   EIT.RPP
   EIT.NMM
   EIT.I_S
   EIT.NFM
   XMN.FMP
   XMN.MVH
   XMN.OTN
   XMN.ELE
   XMN.EEQ
   XMN.OME
   XMN.OMF
   ETD.TND
   NUC.NUCLEARBL
   CLP.COALBL
   GSP.GASBL
   WND.WINDBL
   HYD.HYDROBL
   OLP.OILBL
   XEL.OTHERBL
   GSP.GASP
   HYD.HYDROP
   OLP.OILP
   SOL.SOLARP
   GAS.GDT
   SRV.WTR
   SRV.CNS
   SRV.TRD
   SRV.AFS
   SRV.OTP
   SRV.WTP
   SRV.ATP
   SRV.WHS
   SRV.CMN
   SRV.OFI
   SRV.INS
   SRV.RSA
   SRV.OBS
   SRV.ROS
   SRV.OSG
   SRV.EDU
   SRV.HHT
   SRV.DWE
/ ;

*  First mapping assumes diagonality, i.e., one-to-one mapping between a and i
set mapa(a,acts) ;
loop(sameas(a,i),
   loop((acts,comm)$(mapi(i,comm) and sameas(acts,comm)),
      mapa(a,acts) = yes ;
   ) ;
) ;

*  Regional mapping
set mapr(r,reg) /
   XOE.AUS
   XOE.NZL
   XEA.XOC
   CHN.CHN
   XEA.HKG
   XOE.JPN
   XOE.KOR
   XEA.MNG
   XEA.TWN
   XEA.XEA
   XEA.BRN
   XEA.KHM
   XEA.IDN
   XEA.LAO
   XEA.MYS
   XEA.PHL
   XEA.SGP
   XEA.THA
   XEA.VNM
   XEA.XSE
   SAS.BGD
   SAS.IND
   SAS.NPL
   SAS.PAK
   SAS.LKA
   SAS.XSA
   XOE.CAN
   USA.USA
   XLC.MEX
   XLC.XNA
   XLC.ARG
   XLC.BOL
   OPC.BRA
   XLC.CHL
   XLC.COL
   XLC.ECU
   XLC.PRY
   XLC.PER
   XLC.URY
   OPC.VEN
   XLC.XSM
   XLC.CRI
   XLC.GTM
   XLC.HND
   XLC.NIC
   XLC.PAN
   XLC.SLV
   XLC.XCA
   XLC.DOM
   XLC.JAM
   XLC.PRI
   XLC.TTO
   XLC.XCB
   EUR.AUT
   EUR.BEL
   EUR.CYP
   EUR.CZE
   EUR.DNK
   EUR.EST
   EUR.FIN
   EUR.FRA
   EUR.DEU
   EUR.GRC
   EUR.HUN
   EUR.IRL
   EUR.ITA
   EUR.LVA
   EUR.LTU
   EUR.LUX
   EUR.MLT
   EUR.NLD
   EUR.POL
   EUR.PRT
   EUR.SVK
   EUR.SVN
   EUR.ESP
   EUR.SWE
   EUR.GBR
   EUR.CHE
   EUR.NOR
   EUR.XEF
   ROW.ALB
   ROW.BGR
   ROW.BLR
   ROW.HRV
   ROW.ROU
   RUS.RUS
   ROW.UKR
   ROW.XEE
   ROW.XER
   OPC.KAZ
   ROW.KGZ
   ROW.TJK
   ROW.XSU
   ROW.ARM
   ROW.AZE
   ROW.GEO
   OPC.BHR
   OPC.IRN
   ROW.ISR
   ROW.JOR
   OPC.KWT
   OPC.OMN
   OPC.QAT
   OPC.SAU
   ROW.TUR
   OPC.ARE
   OPC.XWS
   ROW.EGY
   ROW.MAR
   ROW.TUN
   OPC.XNF
   ROW.BEN
   ROW.BFA
   ROW.CMR
   ROW.CIV
   ROW.GHA
   ROW.GIN
   OPC.NGA
   ROW.SEN
   ROW.TGO
   ROW.XWF
   ROW.XCF
   OPC.XAC
   ROW.ETH
   ROW.KEN
   ROW.MDG
   ROW.MWI
   ROW.MUS
   ROW.MOZ
   ROW.RWA
   ROW.TZA
   ROW.UGA
   ROW.ZMB
   ROW.ZWE
   ROW.XEC
   ROW.BWA
   ROW.NAM
   ROW.ZAF
   ROW.XSC
   ROW.XTW
/ ;

*  Factor mapping

set mapf(fp, endw) /
   NSK.ag_othlowsk
   NSK.service_shop
   NSK.clerks
   SKL.tech_aspros
   SKL.off_mgr_pros
   CAP.Capital
   LND.Land
   NRS.NatlRes
/ ;

*  Only used if the LU database exists

set AEZ  / AEZ1*AEZ18 / ;
set AEZ1 / AEZ1*AEZ18 / ;
set mapLU(aez1,aez) ; mapLU(aez1,aez)$sameas(aez1,aez) = yes ;
