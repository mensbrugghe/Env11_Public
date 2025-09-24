*  Declare log file

file   logFile / "%basename%Log.CSV" / ;
scalar simID, startTime ;
startTime = 10000*gyear(jstart)
          +   100*gmonth(jstart)
          +       gday(jstart)
          +       ghour(jstart)/100
          +       gminute(jstart)/10000
          +       gsecond(jstart)/1000000 ;
startTime = 1e6*startTime ;
execseed = 1e8*(frac(jnow));
simID = trunc(uniform(10000,1000000)) ;

Parameter solveStat(*,t) ;

$iftheni "%simType%" == "compStat"
   $$macro PUTYEAR(t) t.tl
$else
   $$macro PUTYEAR(t) years(t):4:0
$endif

*  DEFINE MACROS FOR VARIABLE SUBSTITUTION

*                             (()$IFSUB + ()$(not IFSUB))
$macro M_PP(r,a,i,t)          \
   ((p0(r,a,i)*p(r,a,i,t) * (1 + ptax(r,a,i,t))/pp0(r,a,i))$IFSUB + (pp(r,a,i,t))$(not IFSUB))

$macro M_PA(r,i,aa,t)         \
   (((1 + paTax(r,i,aa,t))*gamma_eda(r,i,aa)*pat(r,i,t)*(pat0(r,i)/pa0(r,i,aa)) \
   + sum(em, chiEmi(r,em,aa,t)*emir(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pa0(r,i,aa))) \
   $(ArmSpec(r,i) eq aggArm and IFSUB) \
   +  (pa(r,i,aa,t))$(ArmSpec(r,i) ne aggArm or (ArmSpec(r,i) eq aggArm and not IFSUB)))
$macro M_PD(r,i,aa,t)         \
   (((1 + pdTax(r,i,aa,t))*gamma_edd(r,i,aa)*pdt(r,i,t)*(pdt0(r,i)/pd0(r,i,aa)) \
   +  sum(em, chiEmi(r,em,aa,t)*emird(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pd0(r,i,aa)))$IFSUB \
   +  (pd(r,i,aa,t))$(not IFSUB))

$iftheni "%MRIO_MODULE%" == "ON"
$macro M_PM(r,i,aa,t)         \
   ((((1 + pmTax(r,i,aa,t))*gamma_edm(r,i,aa)*(pma(r,i,aa,t)*pma0(r,i,aa)/pm0(r,i,aa)) \
   +  sum(em, chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pm0(r,i,aa))) \
   $(ArmSpec(r,i) eq MRIOArm) \
   + ((1 + pmTax(r,i,aa,t))*gamma_edm(r,i,aa)*((pmt(r,i,t)*pmt0(r,i))/pm0(r,i,aa))  \
   +  sum(em, chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pm0(r,i,aa))) \
   $(ArmSpec(r,i) eq stdArm))$IFSUB \
   + (pm(r,i,aa,t))$(not IFSUB))
$else
$macro M_PM(r,i,aa,t)         \
   (((1 + pmTax(r,i,aa,t))*gamma_edm(r,i,aa)*((pmt(r,i,t)*pmt0(r,i))/pm0(r,i,aa))  \
   +  sum(em, chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pm0(r,i,aa)))$IFSUB \
   + (pm(r,i,aa,t))$(not IFSUB))
$endif

$macro M_PWE(s,i,d,t)        \
   (((1 + etax(s,i,d,t) + etaxi(s,i,t))*(pe(s,i,d,t)/1)*(pe0(s,i,d)/pwe0(s,i,d)))$IFSUB \
   + (pwe(s,i,d,t))$(not IFSUB))
$macro M_PWM(s,i,d,t)        \
   ((M_PWE(s,i,d,t)*(pwe0(s,i,d)/(lambdaw(s,i,d,t)*lambdax(s,i,d,t)*pwm0(s,i,d))) \
   +    tmarg(s,i,d,t)*M_PWMG(s,i,d,t)/(lambdaw(s,i,d,t)*lambdax(s,i,d,t)*pwm0(s,i,d)))$IFSUB \
   + (pwm(s,i,d,t))$(not IFSUB))

*  !!!! Question for Maksym: why scale by 1000 and is dependent on the model scale?
*  !!!! The old code read Emix0, scaled by 0.001 and then re-scaled by 1000
$macro M_EMIX(rq,s,i,d,t) (sum(es, \
      ((1-emiLagFlag(rq))*emiXscBaU(s,i,es,t) + emiLagFlag(rq)*emiXsc(s,i,es,tlag))$mapScope(rq,i,es) \
      + (0)$(not mapScope(rq,i,es))))

$macro M_SPCTAR(s,i,d,t) \
   (sum(rq$mapra(rq,d), M_EMIX(rq,s,i,d,t)*emiTaxX(rq,s,i,d,t)))

$macro M_PDM(s,i,d,t)        \
   (((1 + mtax(s,i,d,t) + ntmAVE(s,i,d,t))*M_PWM(s,i,d,t)*(pwm0(s,i,d)/pdm0(s,i,d)) \
   + M_SPCTAR(s,i,d,t)/pdm0(s,i,d))$IFSUB \
   + (pdm(s,i,d,t))$(not IFSUB))

$macro M_PDMA(s,i,r,aa,t)     \
   ((1 + mtaxa(s,i,r,aa,t))*M_PWM(s,i,r,t)*(pwm0(s,i,r)/pdma0(s,i,r,aa)) \
   + M_SPCTAR(s,i,r,t)/pdma0(s,i,r,aa))$IFSUB \
   + (pdma(s,i,r,aa,t))$(not IFSUB)

$macro M_XWMG(s,i,d,t)       \
   ((tmarg(s,i,d,t)*xw(s,i,d,t)*(xw0(s,i,d)/xwmg0(s,i,d)))$IFSUB + (xwmg(s,i,d,t))$(not IFSUB))
$macro M_XMGM(img,s,i,d,t)   \
   ((M_XWMG(s,i,d,t) / lambdamg(img,s,i,d,t))$IFSUB + (xmgm(img,s,i,d,t))$(not IFSUB))
$macro M_PWMG(s,i,d,t)       \
   ((sum(img, shr0_mgm(img,s,i,d)*ptmg(img,t) / lambdamg(img,s,i,d,t)))$IFSUB \
   + (pwmg(s,i,d,t))$(not IFSUB))

$macro M_PFTAX(r,f,a,t) \
   ((chiFtax(r,t)*ifMFtaxFlag(r,f,a) + (1-ifMFTaxFlag(r,f,a)))*pfTax(r,f,a,t) \
  + (alphaFtax(r,t)*ifAFtaxFlag(r,f,a)))

$macro M_PFP(r,f,a,t)         \
   (((1 + M_PFTAX(r,f,a,t))*pf(r,f,a,t)*(pf0(r,f,a)/pfp0(r,f,a)))$IFSUB \
   + (pfp(r,f,a,t))$(not IFSUB))

*  Macros to fix variable lags (used in iterloop.gms)

$macro mlag0(var)             var.fx(r,tsim-1) = var.l(r,tsim-1) ;
$macro mlag1(var,i__1)        var.fx(r,i__1,tsim-1) = var.l(r,i__1,tsim-1) ;
$macro mlag2(var,i__1, i__2)  var.fx(r,i__1,i__2,tsim-1) = var.l(r,i__1,i__2,tsim-1) ;

$macro m_phiInv(r,tlag) \
   (pfd0(r,inv)*pfd(r,inv,tlag)*(xfd0(r,inv)*xfd(r,inv,tlag) \
   -   depr(r,tlag)*kstock0(r)*kstock(r,tlag))/sum(s, pfd0(s,inv)*pfd(s,inv,tlag) \
   *(xfd0(s,inv)*xfd(s,inv,tlag) - depr(s,tlag)*kstock0(s)*kstock(s,tlag))))
$macro m_phiSav(r,tlag) \
   ((sum(h$savh0(r,h),savh0(r,h)*savh(r,h,tlag)) + savg(r,tlag))/sum(s, sum(h$savh0(s,h), savh0(s,h)*savh(s,h,tlag)) + savg(s,tlag)))

$ontext

*  DEFINE POSSIBLE FUNCTIONAL FORMS FOR LAND AND WATER MARKETS

   KELAS    "Constant elasticity supply function"
   LOGIST   "Logistic supply function"
   HYPERB   "Generalized hyperbola supply function"
   INFTY    "Infinitely elastic supply function"

*  DEFINE POSSIBLE FUNCTIONAL FORMS FOR HOUSEHOLD UTILITY

   CD       "Cobb-Douglas"
   LES      "Linear expenditure system"
   ELES     "Extended linear expenditure system"
   AIDADS   "An Implicitly Direct Additive Demand System"
   CDE      "Constant differences in elasticity"

*  DEFINE POSSIBLE FUNCTIONAL FORMS FOR Armington

   aggArm   "Aggregate level sourcing for domestic/imports and by source region"
   stdArm   "Agent level sourcing for domestic/imports and aggregate by source region"
   stdMRIO  "Agent level sourcing for domestic/imports and by source region"

$offtext

acronyms KELAS, LOGIST, HYPERB, INFTY, CD, LES, ELES, AIDADS, CDE,
         aggArm, stdArm, MRIOARM,
         capFlexGTAP, capFlexUSAGE, capFix, capRFix, capFlexINF,
         nocTax, noRecycle, Recycle, CapwRecycle,
         fullEmpl, resWageUE, MonashUE ;

sets
   rs(r)             "Region(s) to be included in simulation"
   sd(s,d)           "Active bilateral nodes"
   fixER(r)          "Regions with a fixed ER"
   fdg(fd)           "Final demand expenditures financed by the government"
   flexWage(r,l)     "Assumption on wage flexibility"
   flexCap(r)        "Assumption on rent flexibility"
*  Knowledge parameters
   ky                "Gamma lags"       / ky0*ky50 /
   gv                "Gamma parameters" / N, delta, lambda /
   knowFlag(r)       "Knowledge flag"
   agf(i)            "Agriculture and food commodities"
   ftfpFlag(r)       "Endogenous ftfp"
   ifARMACES(i)      "Assume Armington uses ACES for commodity 'i'"
   ifNRSTop(r,a)     "Flag for NRS demand: yes=top, no=bundled into KF"
   ifDamage(r)       "Flag to turn on damage functions"
   ifAdpy(r,fd)      "Flag set to 'yes' if agent 'fd' has adapation expenditures"
   mapMak(a,i)       "Mapping of a and i"
;

singleton sets
   vOld0(v)          "Old vintage"
;

vOld0(v)$vOld(v) = yes ;

rs(r)         = yes ;
fixER(r)      = no ;
knowFlag(r)   = no ;
flexWage(r,l) = yes ;
flexCap(r)    = yes ;
FTFPFlag(r)   = no ;
ifARMACES(i)  = no ;
ifNRSTop(r,a) = no ;

scalar lambdafLabEndog "Labor productivity endogeneity flag"   / 0 / ;
scalar lambdaKEndog    "Capital productivity endogeneity flag" / 0 / ;

$iftheni "%RD_MODULE%" == "ON"
   fdg(fd)$(gov(fd) or r_d(fd)) = yes ;
$else
   fdg(fd)$gov(fd) = yes ;
$endif

alias(r,rr) ;
alias(k, kp) ; alias(k, k1) ; alias(v,vp) ;
alias(ty,tt) ; alias(ky,kky) ;
alias(f,fp) ;
alias(t,tp) ;

set ixn(i)        "All non-energy commodities" ; ixn(i)$(not e(i)) = yes ;
scalar ifGbl      "Flag to determine if model is run in global mode" / 1 / ;
scalar ifNCO2     "Flag to determine if we have non-CO2 gases" ;
scalar savfFlag   "Flag determining capital account closure" ;
scalar NTMFlag    "Flag determining presence of NTMs" ;
scalar ifInitFlag "Flag determining whether a baseline was read in"  / 0 / ;
scalar startYear  "Year to which the sim should be initialized" ;
startYear = baseYear ;

Parameters

*  Production parameters

   sigmaxp(r,a,v)          "Substitution elasticity between production and non-CO2 GHG bundle"
   alpha_ghg(r,a,v,t)      "Share parameter for non-CO2 GHG bundle"
   alpha_xpn(r,a,v,t)      "Share parameter for output in production"
   shr0_ghg(r,a)           "Base year value share for non-CO2 GHG bundle"
   shr0_xpn(r,a)           "Base year value share for output in production"

   sigmaNRS(r,a,v)         "Substitution elasticity between NRS and other inputs"
   shr0_xpx(r,a)           "Base year value share for output excl NRS in production"

   sigmap(r,a,v)           "Substitution elasticity between ND1 and VA"
   alpha_nd1(r,a,v,t)      "Share parameter for ND1 bundle"
   alpha_va(r,a,v,t)       "Share parameter for VA bundle"
   shr0_nd1(r,a)           "Base year value share for ND1 bundle"
   shr0_va(r,a)            "Base year value share for VA bundle"

   sigmav(r,a,v)           "Substitution elasticity for VA bundle"
   sigmav1(r,a,v)          "Substitution elasticity for VA1 bundle"
   sigmav2(r,a,v)          "Substitution elasticity for VA2 bundle"

   alpha_lab1(r,a,v,t)     "Share parameter for LAB1 bundle"
   alpha_land(r,a,v,t)     "Share parameter for land"
   alpha_kef(r,a,v,t)      "Share parameter for KEF bundle"
   alpha_nd2(r,a,v,t)      "Share parameter for ND2 bundle"
   alpha_va1(r,a,v,t)      "Share parameter for VA1 bundle"
   alpha_va2(r,a,v,t)      "Share parameter for VA2 bundle"

   sigmalnd(r,a)           "CES elasticity for land demand by type"
   alpha_lnd(r,lnd,a,t)    "Share parameter for land demand by type"
   shr0_lnd(r,lnd,a)       "Base year value share for land by type"
   shrx0_lnd(r,lnd,a)      "Base year volume share for land by type"

   shr0_lab1(r,a)          "Base year value share for LAB1 bundle"
   shr0_land(r,a)          "Base year value share for land"
   shr0_kef(r,a)           "Base year value share for KEF bundle"
   shr0_nd2(r,a)           "Base year value share for ND2 bundle"
   shr0_va1(r,a)           "Base year value share for VA1 bundle"
   shr0_va2(r,a)           "Base year value share for VA2 bundle"

   sigmakef(r,a,v)         "Substitution elasticity between KF and XNRG"
   alpha_kf(r,a,v,t)       "Share parameter for KF bundle"
   alpha_nrg(r,a,v,t)      "Share parameter for NRG bundle"
   shr0_kf(r,a)            "Base year value share for KF bundle"
   shr0_nrg(r,a)           "Base year value share for NRG bundle"

   sigmakf(r,a,v)          "Substitution elasticity between KS and NRS"
   alpha_ksw(r,a,v,t)      "Share parameter for KSW bundle"
   alpha_nrs(r,a,v,t)      "Share parameter for NRS bundle"
   shr0_ksw(r,a)           "Base year value share for KSW bundle"
   shr0_nrs(r,a)           "Base year value share for NRS bundle"

   sigmakw(r,a,v)          "Substitution elasticity between KS and WAT"
   alpha_ks(r,a,v,t)       "Share parameter for KS bundle"
   alpha_wat(r,a,v,t)      "Share parameter for WAT bundle"
   shr0_ks(r,a)            "Base year value share for KS bundle"
   shr0_wat(r,a)           "Base year value share for WAT bundle"

   sigmak(r,a,v)           "Substitution elasticity between K and LAB2"
   alpha_k(r,a,v,t)        "Share parameter for capital"
   alpha_lab2(r,a,v,t)     "Share parameter for LAB2 bundle"
   shr0_k(r,a)             "Base year value share for K"
   shr0_lab2(r,a)          "Base year value share for LAB2 bundle"

   shr0_labb(r,wb,a,t)     "Base year value share for labor bundle wb"
   sigmal1(r,a)            "Labor substitution across skills of Type 1"
   sigmal2(r,a)            "Labor substitution across skills of Type 2"

   shr0_f(r,f,a,t)         "Base year value share for primary factors"

   sigmal(r,wb,a)          "Labor substitution across labor bundle wb"

   sigman1(r,a)            "Substitution elasticity across goods in ND1 bundle"
   sigman2(r,a)            "Substitution elasticity across goods in ND2 bundle"
   sigmawat(r,a)           "Substitution elasticity across water in XWAT bubdle"
   shr0_io(r,i,a,t)        "Base year value share for intermediate demand"
   alpha_io(r,i,a,t)       "Share parameter for intermediate demand"

   sigmae(r,a,v)           "Substitution elasticity between ELY and NELY bundles"
   shr0_nely(r,a)          "Base year value share for NELY bundle"
   shrx0_nely(r,a)         "Base year volume share for NELY bundle"
   shr0_eio(r,e,a)         "Base year value share for energy demand"
   shrx0_eio(r,e,a)        "Base year volume share for energy demand"
   shr0_NRGB(r,a,NRG)      "Base year value share for NRG bundles"
   shrx0_NRGB(r,a,NRG)     "Base year volume share for NRG bundles"
   sigmanely(r,a,v)        "Substitution elasticity between COA and OLG bundles"
   shr0_olg(r,a)           "Value share parameter for OLG bundle"
   shrx0_olg(r,a)          "Volume share parameter for OLG bundle"
   sigmaolg(r,a,v)         "Substitution elasticity between GAS and OIL bundles"
   sigmaNRG(r,a,NRG,v)     "Inter-fuel substitution elasticity within bottom-level nests"

   alpha_nely(r,a,v,t)     "Share parameter for NELY bundle"
   alpha_eio(r,e,a,v,t)    "Share parameter for energy demand"
   alpha_NRGB(r,a,NRG,v,t) "Share parameter for NRG bundles"
   alpha_olg(r,a,v,t)      "Share parameter for OLG bundle"

   omegas(r,a)             "Output transformation elasticity in make/use module"
   shr0_p(r,a,i)           "Base year value share for supply make/use module"
   lambdas(r,a,i,t)        "CET productivity parameter"

   sigmas(r,i)             "Output substitution elasticity in make/use module"
   alpha_s(r,a,i,t)        "Share parameter for demand make/use module"
   shr0_s(r,a,i)           "Base year value share for demand make/use module"

   shr0_pow(r,elyc)        "Base year value share for aggregate power"
   sigmael(r,elyc)         "Substitution between power and ETD"
   shr0_pb(r,pb,elyc)      "Base year value share for power bundles"
   sigmapow(r,elyc)        "Substitution across power bundles"
   sigmapb(r,pb,elyc)      "Substitution across power activities within power bundles"
   lambdapow(r,pb,elyc,t)  "Power efficiency parameters"
   lambdapb(r,elya,elyc,t) "Sub-power efficiency parameters"

*  Income parameters

   fdepr(r,t)              "Fiscal rate of depreciation"
   ydistf(r,t)             "Share of capital income flowing to global trust"
   chiTrust(r,t)           "Share of region r in global trust"
   chiRemit(s,l,r,t)       "Share of labor income in region r remitted to region rp"
   chiODAOut(r,t)          "GDP Share of ODA outflow"
   chiODAIn(r,t)           "Country r's share of total ODA flows"
   etaODA(r,t)             "Elasticity of ODA wrt to per capita income"
   chihNTM(s,d,t)          "Share of NTM revenue in s going to households in d"
   chigNTM(s,d,t)          "Share of NTM revenue in s going to households in d"

*  Demand parameters

   u0(r,h)                 "Scaling parameter for utility"
   Frisch(r,h,t)           "Frisch parameter"
   kron(k,kp)              "Kronecker's delta"
   shr0_cxnnrg(r,k,h)      "Base year value share for non-energy bundle in consumption"
   shr0_cxnrg(r,k,h)       "Base year value share for energy bundle in consumption"
   nu(r,k,h)               "Energy/non-energy substitution elasticity in consumption"

   shr0_c(r,i,k,h)         "Initial value shares in decomposition of non-energy and energy bundles"
   shrx0_c(r,i,k,h)        "Initial volume shares in decomposition of non-energy and energy bundles"
   lambdac(r,i,k,h,t)      "Commodity efficiency shifter in consumption"
   nunnrg(r,k,h)           "Substitution across goods in non-energy bundle"

   shr0_cnely(r,k,h,t)     "Base year value share of non-electric bundle in consumption"
   shrx0_cnely(r,k,h,t)    "Base year volume share of non-electric bundle in consumption"
   shr0_colg(r,k,h,t)      "Base year value share of OLG bundle in consumption"
   shrx0_colg(r,k,h,t)     "Base year volume share of OLG bundle in consumption"
   shr0_cNRG(r,k,h,NRG,t)  "Base year value shares  for NRG bundles"
   shrx0_cNRG(r,k,h,NRG,t) "Base year volume shares  for NRG bundles"
   alpha_cnely(r,k,h,t)    "Preference shifter for non-electric bundle in consumption"
   alpha_cNRG(r,k,h,NRG,t) "Preference shifter for energy bundles in consumption"
   nue(r,k,h)              "Electric/non-electric substitution in consumption"
   nunely(r,k,h)           "Coal/OLG substitution in consumption"
   nuolg(r,k,h)            "Substituion between oil & gas in consumption"
   nuNRG(r,k,h,NRG)        "Substitution within NRG bundles"

   shr0_ac(r,i,h)          "Base year value share for actual consumption in waste function"
   shr0_wc(r,i,h)          "Base year value share  for waste consumption share in waste function"
   lambdaac(r,i,h,t)       "Actual consumption preference shifter in ACES waste function"
   lambdawc(r,i,h,t)       "Waste consumption preference shifter in ACES waste function"
   sigmaac(r,i,h)          "ACES substitution elasticity in waste function"

   sigmafd(r,fd)           "Other final demand substitution elasticity"
   shr0_fd(r,i,fd,t)       "Base year value shares for other final demand"
   lambdafd(r,i,fd,t)      "Productivity in final demand activities"

*  Trade parameters

   ArmSpec(r,i)            "Type of Armington by importing region and sector"
   sigmamt(r,i)            "Top level Armington CES elasticity"
   alpha_dt(r,i,t)         "Domestic share parameter"
   alpha_mt(r,i,t)         "Import share parameter"
   shr0_dt(r,i)            "Initial domestic value share"
   shr0_mt(r,i)            "Initial import value share"
   shrx0_dt(r,i)           "Initial domestic volume share"
   shrx0_mt(r,i)           "Initial import volume share"

   sigmam(r,i,aa)          "Top level Armington elasticity with agent sourcing"
   alpha_d(r,i,aa,t)       "Domestic share parameter with agent sourcing"
   alpha_m(r,i,aa,t)       "Import share parameter with agent sourcing"
   shr0_d(r,i,aa)          "Initial domestic value share with agent sourcing"
   shr0_m(r,i,aa)          "Initial import value share with agent sourcing"
   shrx0_d(r,i,aa)         "Initial domestic volume share with agent sourcing"
   shrx0_m(r,i,aa)         "Initial import volume share with agent sourcing"

   sigmaw(r,i)             "Second level Armington CES elasticity"
   shr0_w(s,i,d)           "Initial value import share by source share"
   shrx0_w(s,i,d)          "Initial volume import share by source share"
   alpha_w(s,i,d,t)        "Import by source share parameter"
   lambdaw(s,i,d,t)        "Iceberg parameter for importers"
   lambdax(s,i,d,t)        "Iceberg parameter for exporters"

$iftheni "%MRIO_MODULE%" == "ON"
   sigmawa(r,i,aa)         "Agent-specific second level Armington CES elasticity"
   shr0_wa(s,i,d,aa,t)     "Agent-specific source share parameter by agent"
$endif

   omegax(r,i)             "Top level CET transformation elasticity"
   shr0_dx(r,i,t)          "CET domestic value share parameter"
   shr0_ex(r,i,t)          "CET export value share parameter"
   shrx0_dx(r,i,t)         "CET domestic volume share parameter"
   shrx0_ex(r,i,t)         "CET export volume share parameter"

   omegaw(r,i)             "Second level CET transformation elasticity"
   shr0_wx(s,i,d,t)        "Second level valueshare parameters"
   shrx0_wx(s,i,d,t)       "Second level volume share parameters"

*  Twist parameters

   ArmMShrt1(r,i)          "Lagged import share for top level national sourcing"
   ArmMShr1(r,i,aa)        "Lagged import share for top level agent sourcing"
   ArmMShr2(i,r)           "Import share from r's targetted countries"

*  Margin parameters

   shr0_mgm(img,s,i,d)     "Share of m in transporting from r to rp"
   sigmamg(img)            "CES substitution elasticity for sourcing tt services"
   shr0_xtmg(r,img,t)      "CES share parameters for sourcing tt services"
   lambdamg(img,s,i,d,t)   "Efficiency factor for tt services"

$iftheni "%DEPL_MODULE%" == "ON"

*  Depletion module parameters

   ptrend(r,a,t)           "Exogenous price trend for fossil fuels"
   omegard(r,a,pt,t)       "Discovery rate elasticity assumptions"
   dscRate0(r,a,pt)        "Discovery rate assumptions"
   extRate0(r,a,pt)        "Extraction rate assumptions"
   omegae(r,a,t)           "Extraction rate elasticity for oil & gas"

$endif

*  Factor supply parameters

   uez0(r,l,z)             "Initial level of unemployment by zone"
   resWage0(r,l,z)         "Initial level of reservation wage"
   ueMinz0(r,l,z)          "Initial level of minimum unemployment by zone"
   ueMinz(r,l,z,t)         "Minimum level of UE by zone"
   omegarwg(r,l,z)         "Elasticity of reservation wage wrt to growth"
   omegarwue(r,l,z)        "Elasticity of reservation wage wrt to UE"
   omegarwp(r,l,z)         "Elasticity of reservation wage wrt to CPI"
   migr0(r,l)              "Ratio of rural migration as a share of base year rural labor supply"
   chim(r,l,t)             "Migration function shifter"
   omegam(r,l)             "Migration elasticity"
   kronm(z)                "Set to -1 for rural and to +1 for urban"

   omegak(r)               "Capital CET elasticity in CS mode"
   shr0_kvs(r,a,v)         "Capital CET share parameters in CS mode"
   invElas(r,a)            "Supply elasticity of Old capital in declining sectors"

   chiLand(r,lnd,t)        "Total land supply shifter"
   etat(r,lnd)             "Total land supply elasticity"
   gammatl(r,lnd,t)        "Total land supply parameter"
   shr0_lb(r,lnd,lb,t)     "Share parameter for land bundles"
   shr0_nlb(r,lnd,t)       "Share parameter for intermediate land bundle"
   omegat(r,lnd)           "Top level land transformation elasticity"
   omeganlb(r,lnd)         "CET across land bundles (except lb1)"
   shr0_t(r,lnd,a,t)       "Land CET share parameters"
   omegalb(r,lnd,lb)       "CET across land within land bundles"

   etanrsx(r,a,lh)         "Kinked supply elasticities"
   chinrsp(r,a)            "Natural resource price adjustment factor"
   pwtrend(a,tt)           "Baseline price trends"
   pwshock(a,tt)           "Shock price trends"

   chih2o(r,t)             "Aggregate water supply shifter"
   etaw(r)                 "Aggregate water supply elasticity"
   gammatw(r,t)            "Aggregate water supply curvature parameter"
   shr0_1h2o(r,wbnd,t)     "Water allocation share parameter"
   omegaw1(r)              "Top level water allocation transformation elasticity"
   shr0_2h2o(r,wbnd,t)     "Water allocation share parameter"
   omegaw2(r,wbnd)         "Second level water allocation transformation elasticity"
   shr0_3h2o(r,a,t)        "Water allocation share parameter"
   ah2obnd(r,wbnd,t)       "Water allocation shift parameter"
   epsh2obnd(r,wbnd)       "Water bundle demand price elasticity"
   etah2obnd(r,wbnd)       "Water bundle demand scale elasticity"

*  Capital account closure parameters

   riskPrem(r,t)           "Regional risk premium"
   epsRoR(r,t)             "Sensitivity of rate-of-return expectation"
   savfBar(r,t)            "Exogenous foreign savings"

*  Parameters for emissions module

   emir(r,em,is,aa)             "Emissions per unit of consumption/output"
   emird(r,em,i,aa)             "Emissions per unit of domestic consumption"
   emirm(r,em,i,aa)             "Emissions per unit of imported consumption"
   emiX(s,i,t)                  "Emissions embodied in exports"
   part(r,em,i,aa)              "Level of participation: 0=none 1=full"
   gwp(r,em)                    "Global warming potential"
   avgEmiIntT(ra,emq,aets,t)    "Average emission intenstity"

*  Parameters for energy module

   phiNRG(r,fuel,aa)       "Combustion ratio for fuel demand"

*  Parameters for knowledge module

   kdepr(r,t)              "Depreciation rate of knowledge"
   valk(ky)                "Value of ky set index"
   gamPrm(r,gv)            "Gamma parameters for region r"
   gamma(r,ky)             "Gamma lags for region r"
   gammar(r,l,a,t)         "Knowledge-based  productivity shifter"
   epsr(r,l,a,t)           "Knowledge-based productivity elasticity"

$iftheni "%DAMAGE_MODULE%" == "ON"

*  Parameters for damage module

   dam_beta0_tfp(r,a,t)    "TFP damage intercept coefficient"
   dam_beta1_tfp(r,a,t)    "TFP damage linear coefficient"
   dam_beta2_tfp(r,a,t)    "TFP damage quadratic coefficient"
   dam_beta0_lab(r,l,a,t)  "Heat-related labor productivity damage intercept coefficient"
   dam_beta1_lab(r,l,a,t)  "Heat-related labor damage linear coefficient"
   dam_beta2_lab(r,l,a,t)  "Heat-related labor damage quadratic coefficient"
   dam_beta0_hht(r,l,a,t)  "Health-related labor productivity damage intercept coefficient"
   dam_beta1_hht(r,l,a,t)  "Health-related labor productivity damage linear coefficient"
   dam_beta2_hht(r,l,a,t)  "Health-related labor productivity damage quadratic coefficient"
   dam_beta0_nrg(r,k,h,t)  "Energy demand adjustment intercept coefficient"
   dam_beta1_nrg(r,k,h,t)  "Energy demand adjustment linear coefficient"
   dam_beta2_nrg(r,k,h,t)  "Energy demand adjustment quadratic coefficient"
   dam_beta0_lnd(r,lnd,t)  "Land supply adjustment intercept coefficient"
   dam_beta1_lnd(r,lnd,t)  "Land supply adjustment linear coefficient"
   dam_beta2_lnd(r,lnd,t)  "Land supply adjustment quadratic coefficient"
   dam_beta0_tou(r,i,t)    "Tourism export adjustment intercept coefficient"
   dam_beta1_tou(r,i,t)    "Tourism export adjustment linear coefficient"
   dam_beta2_tou(r,i,t)    "Tourism export adjustment quadratic coefficient"
   dam_beta0_cap(r,t)      "Capital stock adjustment intercept coefficient"
   dam_beta1_cap(r,t)      "Capital stock adjustment linear coefficient"
   dam_beta2_cap(r,t)      "Capital stock adjustment quadratic coefficient"

*  Parameters for adaptation module

   chi_adp_tfp(r,a,t)      "Shift parameter for 'tfp' adpaptation"
   chi_adp_lab(r,l,a,t)    "Shift parameter for 'lab' adpaptation"
   chi_adp_hht(r,l,a,t)    "Shift parameter for 'hht' adpaptation"
   chi_adp_nrg(r,k,h,t)    "Shift parameter for 'nrg' adpaptation"
   chi_adp_lnd(r,lnd,t)    "Shift parameter for 'lnd' adpaptation"
   chi_adp_tou(r,i,t)      "Shift parameter for 'tou' adpaptation"
   chi_adp_cap(r,t)        "Shift parameter for 'cap' adpaptation"

   rhodmg_tfp(r,t)         "TFP damage adaptation shifter elasticity"
   rhodmg_lab(r,t)         "Labor productivity damage adaptation shifter elasticity"
   rhodmg_hht(r,t)         "Health/labor damage adaptation shifter elasticity"
   rhodmg_nrg(r,t)         "Energy demand adaptation shifter elasticity"
   rhodmg_lnd(r,t)         "Health/labor damage adaptation shifter elasticity"
   rhodmg_tou(r,t)         "Health/labor damage adaptation shifter elasticity"
   rhodmg_cap(r,t)         "Capital stock damage adaptation shifter elasticity"

   shr0_adp(r,i,adp,t)     "Cost share of good 'i' in adaptation 'adp'"
   shr0_xdadp(r,i,adp)     "Domestic share of good 'i' in adaptation 'adp'"
   shr0_xmadp(r,i,adp)     "Import share of good 'i' in adaptation 'adp'"

   chi_adp_exp(r,fd,adp,t) "Cost of adapation 'adp' borne by agent 'fd'"

$endIf

*  Social welfare function weights

   epsw(t)                 "Social welfare elasticity"
   welfwgt(r,t)            "Weights for private consumption"
   welftwgt(r,t)           "Weights for private+public consumption"

*  Miscellaneous parameters

   work                    "Working scalar"
   tvol                    "Total volume working scalar"
   tprice                  "Total price working scalar"
   vol                     "Volume working scalar"
   price                   "Price working scalar"
   rwork(r)                "Regional working vector"
   swork(r,i)              "Regional and sectoral working matrix"
   dynPhase                "Phase-in paramters for recursive dynamics"
   chi(r,fd)               "Shift variable for PFD"
   chimuv                  "Shift variable for MUV"
   depr(r,t)               "Physical depreciation rate"
   chiKaps0(r)             "Base year ratio of normalized capital to capital stock"
   glAddShft(r,l,a,t)      "Additive shifter in labor productivity factor"
   glMltShft(r,l,a,t)      "Multiplicative shifter in labor productivity factor"
   popT(r,tranche,t)       "Population scenario"
   educ(r,l,t)             "Size of labor by education from SSP database"
   glabT(r,l,t)            "Targeted growth rates for labor by skill"
   rgdppcT(r,t)            "Real GDP per capita scenario"
   lfpr(r,l,tranche,t)     "Labor force participation rate by skill and age cohort"
   aeei(r,a,v,t)           "Energy efficiency improvement in production"
   aeeic(r,k,h,t)          "Energy efficiency improvement in household demand"
   emiRate(r,em,is,aa,t)   "Change in emissions rate"
   yexo(r,a,t)             "Exogenous improvement in yields"
   tteff(s,i,d,t)          "Exogenous improvement in intl. trade & transport margins"
   xatNRG(r,e)             "Base year energy absorption in MTOE"
   m_shr(r,i,s)            "Import shares by source"
   gamma_eda(r,i,aa)       "Energy price equalizer in domestic absorption"
   gamma_edd(r,i,aa)       "Energy price equalizer for domestic goods with agent sourcing"
   gamma_edm(r,i,aa)       "Energy price equalizer for import goods with agent sourcing"
   gamma_ew(s,i,d)         "Energy price equalizer in exports"
   gamma_esd(r,i)          "Energy price equalizer in domestic supply"
   gamma_ese(r,i)          "Energy price equalizer in export supply"
   aggLabShr(r,t)          "Aggregate share of labor in value added"
   glBaU(r,t)              "Reference labor productivity"
   gkBaU(r,t)              "Reference capital productivity"
   xfdBaU(r,fd,t)          "Reference absorption"
   ehBaU(r,k,h,t)          "Reference eh parameter"
   bhBaU(r,k,h,t)          "Reference bh parameter"
   wchiNRSBaU(a,t)         "Reference global shifter for NRS curve"
   chiNRSBaU(r,a,t)        "Reference regional shifter for NRS curve"
   chirwBaU(r,l,z,t)       "Reservation wage shifter"
   chiAPSBaU(r,h,t)        "Savings shifter"
   lambdafBaU(r,fp,a,t)    "Factor productivity parameter"
   lambdakBaU(r,a,v,t)     "Capital productivity parameter"

*  Activity flags

   xpFlag(r,a)             "Flag for output of activity 'a'"
   ghgFlag(r,a)            "Flag for non-CO2 GHG bundle"

   nd1Flag(r,a)            "Flag for ND1 bundle"
   nd2Flag(r,a)            "Flag for ND2 bundle"
   lab1Flag(r,a)           "Flag for lab1 bundle"
   lab2Flag(r,a)           "Flag for lab2 bundle"
   labbFlag(r,wb,a)        "Flag for 'wb' labor bundle"
   va1Flag(r,a)            "Flag for VA1 bundle"
   va2Flag(r,a)            "Flag for VA2 bundle"
   landdflag(r,a)          "Flag for LANDD bundle"
   kefFlag(r,a)            "Flag for KEF bundle"
   kfFlag(r,a)             "Flag for KF bundle"
   watFlag(r,a)            "Flag for water bundle"
   kFlag(r,a)              "Flag for capital"
   xnrgFlag(r,a)           "Flag for NRG bundle"
   xaNRGFlag(r,a,NRG)      "Flag for energy bundle bundle"
   xnelyFlag(r,a)          "Flag for NELY bundle"
   xolgFlag(r,a)           "Flag for OLG bundle"
   th2oFlag(r)             "Flag for aggregate water market"

   xfFlag(r,f,a)           "Flag for factors of production"
   xaFlag(r,i,aa)          "Flag for Armington demand by agent"
   xdFlag(r,i,aa)          "Flag for domestic demand by agent"
   xmFlag(r,i,aa)          "Flag for import demand by agent"
   xsFlag(r,i)             "Flag for domestically produced goods"

   xcFlag(r,k,h)           "Flag for household consumption"
   uFlag(r,h)              "Flag for household utility"
   xcnnrgFlag(r,k,h)       "Flag for non-energy bundle in consumption"
   xcnrgFlag(r,k,h)        "Flag for energy bundle in consumption"
   xcnelyFlag(r,k,h)       "Flag for non-electriciy bundle in consumption"
   xcolgFlag(r,k,h)        "Flag for OLG bundle in consumption"
   xacNRGFlag(r,k,h,NRG)   "Flag for NRG bundles in consumption"

   fdFlag(r,fd)            "Flag for FD expenditures"

   hWasteFlag(r,i,h)       "Flag for waste function in household consumption"

   xatFlag(r,i)            "Flag for aggregate Armington demand"
   xddFlag(r,i)            "Flag for XDD bundle"
   xmtFlag(r,i)            "Flag for XMT bundle"

   xwFlag(s,i,d)           "Flag for XW"
   xwaFlag(s,i,d,aa)       "Agent specific flag for XWA"
   xdtFlag(r,i)            "Flag for XDT bundle"
   xetFlag(r,i)            "Flag for XET bundle"
   tmgFlag(s,i,d)          "Flag for tt services"
   xttFlag(r,i)            "Flag for domestic tt supply"

   th2oFlag(r)             "Flag for aggregate water market"
   h2obndFlag(r,wbnd)      "Flag for water bundles"

   tlabFlag(r,l)           "Flag for aggregate labor"
   tlandFlag(r,lnd)        "Flag for aggregate land"

   ifMFTaxFlag(r,f,a)      "Flag used for endogenous multiplicator factor tax adjustment"
   ifAFTaxFlag(r,f,a)      "Flag used for endogenous additive factor tax adjustment"

   xnrsFlag(r,a)           "Kinked supply is active"

   ueFlag(r,l,z)           "Employment regime"
   ifRecycle(r,t)          "Type of carbon recycling"

*  ifEmiCap                "Any emissions cap regimes"
*  emFlag(em)              "Emission subject to regime"
*  ifEmiQuota(r)           "Regions subject to emissions quota regime"

*  Post-simulation parameters

   sam(r,is,js,t)          "Social accounting matrix"
   nrgBal(r,is,js,t)       "Energy balances"
;

*  Default for recycling -- no emission taxes

ifRecycle(r,t) = noCTax ;
if(MRIO eq 1,
   ArmSpec(r,i) = MRIOArm ;
else
   if(ArmFlag eq 0,
      ArmSpec(r,i) = aggArm ;
   else
      ArmSpec(r,i) = stdArm ;
   ) ;
) ;

scalar ifPhase / 0 / ;
dynPhase = 100 ;
scalar kink / 30 / ;

sets
   xpvFlag(r,a,v,t)     "Flag when output hits the minimum"
   pkFlag(r,a,v,t)      "Flag when pk hits the minimum"
   lsFlag(r,l,z)        "Flag for labor by zone"
   migrFlag(r,l)        "Migration flag"
   ifEmiETSCap(r,em,aa)

$iftheni "%DEPL_MODULE%" == "ON"
   ifDsc(r,a)              "Discovery flag"
   ifResPFlag(r,a)         "True for regions on reserve profile"
$endif

   ifdepl(r,a)             "Depletion flag"
;

*  Initial levels

Parameters
   px0(r,a)                "Producer price before tax"
   uc0(r,a)                "Unit cost of production by vintage pre-tax"
   pxv0(r,a)               "Unit cost of production by vintage tax/subsidy inclusive"

   xpn0(r,a)               "Production level exclusive of non-CO2 GHG bundle but including NRS"
   xpx0(r,a)               "Production level excluding GHG and NRS"
   xghg0(r,a)              "Non-CO2 GHG bundle associated with output"

   nd10(r,a)               "Demand for intermediate goods in ND1 bundle"
   va0(r,a)                "Demand for top level VA bundle"
   pxn0(r,a)               "Cost of production excl non-CO2 GHG bundle but including NRS"
   pxp0(r,a)               "Cost of production excl non-CO2 GHG bundle and NRS"

   pfp0(r,f,a)             "Price of factors tax inclusive"
   pf0(r,f,a)              "Market price of factors"
   xf0(r,f,a)              "Factor demand"

   lab10(r,a)              "Demand for 'unskilled' labor bundle"
   kef0(r,a)               "Demand for KEF bundle (capital+skill+energy+nrs)"
   nd20(r,a)               "Demand for intermediate goods in ND2 bundle"
   va10(r,a)               "Demand for VA1 bundle"
   va20(r,a)               "Demand for VA2 bundle"
   pva0(r,a)               "Price of VA bundle"
   pva10(r,a)              "Price of VA1 bundle"
   pva20(r,a)              "Price of VA2 bundle"

   landd0(r,a)             "LANDD bundle"
   plandd0(r,a)            "Price of LANDD bundle"
   planddNDX0(r,a)         "Price index of Landd bundle"

   kf0(r,a)                "Demand for KF bundle (capital+skill+nrs+water)"
   xnrg0(r,a)              "Demand for NRG bundle in production"
   pkef0(r,a)              "Price of KEF bundle"

   ksw0(r,a)               "Demand for KSW bundle (capital+skill+water)"
   pkf0(r,a)               "Price of KF bundle"

   ks0(r,a)                "Demand for KS bundle (capital+skill)"
   xwat0(r,a)              "Demand for WAT bundle"
   pksw0(r,a)              "Price of KSW bundle"

   kv0(r,a)                "Demand for K by vintage"
   lab20(r,a)              "Demand for 'skilled' labor bundle"
   pks0(r,a)               "Price of KS bundle"

   plab10(r,a)             "Price of 'unskilled' labor bundle"
   plab20(r,a)             "Price of 'skilled' labor bundle"

   labb0(r,wb,a)           "Demand for labor bundle 'wb'"
   plabb0(r,wb,a)          "Price of labor bundle 'wb'"

   pnd10(r,a)              "Price of ND1 bundle"
   pnd20(r,a)              "Price of ND2 bundle"
   pwat0(r,a)              "Price of water bundle"

   xaNRG0(r,a,NRG)         "Demand for bottome level energy bundles"
   xnely0(r,a)             "Demand for non-electric bundle"
   pnrg0(r,a)              "Price of energy bundle"
   pnrgNDX0(r,a)           "Composite price index of energy bundle"

   paNRG0(r,a,NRG)         "Price of energy bundles"
   paNRGNDX0(r,a,NRG)      "Composite price of energy bundles"
   pnely0(r,a)             "Price of NELY bundle"
   pnelyNDX0(r,a)          "Composite price of NELY bundle"

   xolg0(r,a)              "Demand for oil and gas bundle"
   polg0(r,a)              "Price of oil and gas bundle"
   polgNDX0(r,a)           "Composite price of oil and gas bundle"

   xa0(r,i,aa)             "Armington demand for goods"

   x0(r,a,i)               "Output of good 'i' produced by activity 'a'"
   p0(r,a,i)               "Price of good 'i' produced by activity 'a'--pre-tax"
   pp0(r,a,i)              "Price of good 'i' produced by activity 'a'--post-tax"
   xp0(r,a)                "Gross sectoral output of activity 'i'"
   ps0(r,i)                "Market price of domestically produced good 'i'"
   psNDX0(r,i)             "Composite price of domestically produced good 'i'"

   xpow0(r,elyc)           "Aggregate power"
   ppow0(r,elyc)           "Average price of aggregate power"
   ppowndx0(r,elyc)        "Price index of aggregate power"
   xpb0(r,pb,elyc)         "Power bundles"
   ppb0(r,pb,elyc)         "Average price of power bundles"
   ppbndx0(r,pb,elyc)      "Price index of power bundles"

   deprY0(r)               "Depreciation income"
   yqtf0(r)                "Outflow of capital income"
   trustY0                 "Aggregate foreign capital outflow"
   yqht0(r)                "Foreign capital income inflow"
   remit0(s,l,d)           "Labor remittances"
   odaOut0(r)              "Outward ODA"
   odaIn0(r)               "Inward ODA"
   odaGbl0                 "Global ODA"
   govTr0(s,d)             "Transfers from government s to household d"
   yh0(r)                  "Household income net of depreciation"
   yd0(r)                  "Disposable household income"

   supy0(r,h)              "Per capita supernumerary income"
   muc0(r,k,h)             "Marginal budget shares"
   mus0(r,h)               "Marginal propensity to save"
   zcons0(r,k,h)           "Consumption auxiliary variable"
   xc0(r,k,h)              "Household consumption of consumer good k"
   hshr0(r,k,h)            "Household budget shares"
   u0(r,h)                 "Utility level"

   xcnnrg0(r,k,h)          "Demand for non-energy bundle of consumer good k"
   xcnrg0(r,k,h)           "Demand for energy bundle of consumer good k"
   pc0(r,k,h)              "Price of consumer good k"
   pcnnrg0(r,k,h)          "Price of non-energy bundle of consumer good k"
   xcnely0(r,k,h)          "Demand for non-electric bundle of consumer good k"
   xcolg0(r,k,h)           "Demand for OLG bundle of consumer good k"
   xacNRG0(r,k,h,NRG)      "Demand for NRG bundle of consumer good k"
   pacNRG0(r,k,h,NRG)      "Price of NRG bundle of consumer good k"
   pacNRGNDX0(r,k,h,NRG)   "Composite price of NRG bundle of consumer good k"
   pcolg0(r,k,h)           "Price of OLG bundle of consumer good k"
   pcolgNDX0(r,k,h)        "Composite price of OLG bundle of consumer good k"
   pcnely0(r,k,h)          "Price of non-electric bundle of consumer good k"
   pcnelyNDX0(r,k,h)       "Composite price of non-electric bundle of consumer good k"
   pcnrg0(r,k,h)           "Price of energy of consumer good k"
   pcnrgNDX0(r,k,h)        "Composite price of energy of consumer good k"

   xaac0(r,i,h)            "Initial actual consumption"
   xawc0(r,i,h)            "Initial household waste"
   paacc0(r,i,h)           "Initial composite price of consumption"
   paac0(r,i,h)            "Initial price of actual consumption"
   pawc0(r,i,h)            "Initial price of waste"

   savh0(r,h)              "Private savings"
   aps0(r,h)               "Private savings rate out of total household income"
   chiaps0(r,h)            "Economy-wide shifter for household saving"

   ygov0(r,gy)             "Government revenues"
   ntmY0(r)                "NTM revenues"

   pfd0(r,fd)              "Final demand expenditure price index"
   yfd0(r,fd)              "Value of aggregate final demand expenditures"

   xat0(r,i)               "Aggregate Armington demand"
   xdt0(r,i)               "Domestic demand for domestic production /x xtt"
   xmt0(r,i)               "Aggregate import demand"
   pat0(r,i)               "Price of aggregate Armington good"
   patNDX0(r,i)            "Composite price of aggregate Armington good"
   xd0(r,i,aa)             "Domestic sales of domestic goods with agent sourcing"
   xm0(r,i,aa)             "Domestic sales of import goods with agent sourcing"
   pd0(r,i,aa)             "End user price of domestic goods with agent sourcing"
   pm0(r,i,aa)             "End user price of import goods with agent sourcing"
   pa0(r,i,aa)             "Price of Armington good at agents' price"
   paNDX0(r,i,aa)          "Composite price of Armington good at agents' price"

   xw0(s,i,d)              "Volume of bilateral trade"
   pmt0(r,i)               "Price of aggregate imports"
   pmtNDX0(r,i)            "Composite price of aggregate imports"

$iftheni "%MRIO_MODULE%" == "ON"

   xwa0(s,i,d,aa)          "Bilateral imports by agent"
   pdma0(s,i,d,aa)         "Domestic price of bilateral imports by agent"
   pma0(r,i,aa)            "Aggregate price of imports by agent"

$endif

   pdt0(r,i)               "Producer price of goods sold on domestic markets"
   xet0(r,i)               "Aggregate exports"
   xs0(r,i)                "Domestic production of good 'i'"
   pe0(s,i,d)              "Producer price of exports"
   pet0(r,i)               "Producer price of aggregate exports"
   petNDX0(r,i)            "Composite price of aggregate exports"
   pwe0(s,i,d)             "FOB price of exports"
   pwm0(s,i,d)             "CIF price of imports"
   pdm0(s,i,d)             "Tariff inclusive price of imports"

   xwmg0(s,i,d)            "Demand for tt services from r to rp"
   xmgm0(img,s,i,d)        "Demand for tt services from r to rp for service type m"
   pwmg0(s,i,d)            "Average price to transport good from r to rp"
   xtmg0(img)              "Total global demand for tt services m"
   xtt0(r,i)               "Supply of m by region r"
   ptmg0(img)              "The average global price of service m"

$iftheni "%DEPL_MODULE%" == "ON"

   cumExt0(r,a)            "Cumulative extraction from reserves"
   res0(r,a)               "Proven reserves"
   resp0(r,a)              "Potential reserves"
   ytdres0(r,a)            "Yet-to-discover reserves"
   xfPot0(r,a)             "Potential supply"
   extr0(r,a)              "Extraction"

$endif

$iftheni.FBS "%FBS_MODULE%" == "ON"
   calo0(r,i,srcr)               "Household consumption of calories by source region"
   nutr(r,i,ucat,sua,srcr,t)     "Nutrition accounts"
$endif.FBS

   ldz0(r,l,z)             "Labor demand by zone"
   awagez0(r,l,z)          "Average wage by zone"
   urbPrem0(r,l)           "Urban wage premium"
   resWage0(r,l,z)         "Reservation wage"
   chirw0(r,l,z)           "Reservation wage shifter"
   ewagez0(r,l,z)          "Equilibrium wage by zone"
   twage0(r,l)             "Equilibrium wage by skill"
   skillprem0(r,l)         "Skill premium relative to a reference wage"
   tls0(r)                 "Total labor supply"
*
*  migr0(r,l)              "Level of rural to urban migration"
*  migrMult0(r,l,z)        "Migration multiplier for multi-year time steps"
   lsz0(r,l,z)             "Labor supply by zone"
   ls0(r,l)                "Aggregate labor supply by skill"
*  gtlab0(r)               "Growth rate of total labor supply"
*  glab0(r,l)              "Growth of labor supply by skill"
*  glabz0(r,l,z)           "Growth of labor supply by skill and zone"
*  wPrem0(r,l,a)           "Wage premium relative to equilibrium wage"

   pk0(r,a)                "Market price of capital by vintage and activity"
   trent0(r)               "Aggregate return to capital"
   rtrent0(r)              "Aggregate real return to capital"

   kxRat0(r,a)             "Capital output ratio by sector"
   rrat0(r,a)              "Ratio of return to Old wrt to New capital"
   k00(r,a)                "Beginning of period installed capital"
   xpv0(r,a)               "Gross sectoral output by vintage"

   arent0(r)               "Average return to capital"

   tland0(r,lnd)           "Aggregate land supply"
   ptland0(r,lnd)          "Aggregate price index of land"
   ptlandndx0(r,lnd)       "Price index of aggregate land"
*  landMax0(r,lnd)         "Maximum available land"
   xlb0(r,lnd,lb)          "Land bundles"
   plb0(r,lnd,lb)          "Average price of land bundles"
   plbndx0(r,lnd,lb)       "Price index of land bundles"
   xnlb0(r,lnd)            "Intermediate land bundle"
   pnlb0(r,lnd)            "Price of intermediate land bundle"
   pnlbndx0(r,lnd)         "Price index of intermediate land bundle"

   xfNot0(r,a)             "Notional supply of natural resources"
   xfs0(r,f,a)             "Actual supply of natural resources and other factors"

   th2o0(r)                "Aggregate water supply"
*  h2oMax0(r)              "Maximum available water supply"
   th2om0(r)               "Marketed water supply"
   h2obnd0(r,wbnd)         "Aggregate water bundles"
   pth2ondx0(r)            "Aggregate water price index"
   pth2o0(r)               "Aggregate market price of water"
   ph2obnd0(r,wbnd)        "Price of aggregate water bundles"
   ph2obndndx0(r,wbnd)     "Price index of aggregate water bundles"

   pkp0(r,a)               "Price of capital by vintage and activity tax inclusive"
*
   savg0(r)                "Public savings"
*
*  Closure variables
*
   rsg0(r)                 "Real government savings"

   rfdshr0(r,fd)           "Volume share of final demand in real GDP"
   nfdshr0(r,fd)           "Value share of final demand in nominal GDP"

   xfd0(r,fd)              "Volume of aggregate final demand expenditures"

   kstocke0(r)             "Anticipated capital stock"
   ror0(r)                 "Net aggregate rate of return to capital"
   rorc0(r)                "Cost adjusted rate of return to capital"
   rore0(r)                "Expected rate of return to capital"
   rorg0                   "Average expected global rate of return to capital"

   cpi0(r,h,cpindx)        "Consumer price index"
   pfact0(r)               "Factor price index"
   pwfact0                 "World factor price index"
   savf0(r)                "Foreign savings"
   savfRat0(r)             "Foreign savings as a share of GDP"
   pmuv0                   "Export price index of manufactured goods from high-income countries"
   pwsav0                  "Global price of investment good"
   pwgdp0                  "Global gdp deflator"
   pnum0                   "Model numéraire"
   pw0(a)                  "World price of activity a"
*
*  Macro variables
*
   cons0(r)                "Aggregate private consumption"
   pcons0(r)               "Aggregate CPI"
   gdpmp0(r)               "Nominal GDP at market price"
   rgdpmp0(r)              "Real GDP at market price"
   pgdpmp0(r)              "GDP at market price expenditure deflator"
   rgdppc0(r)              "Real GDP at market price per capita"
*  grrgdppc0(r)            "Growth rate of real GDP per capita"
*  gl0(r)                  "Economy-wide labor productivity growth"
   klrat0(r)               "Capital labor ratio in efficiency units"
*
*  Emission variables
*
   emi0(r,em,is,aa)        "Emissions by region and driver"
   ProcEmi0(r,em,a)        "Process emissions by region and driver"
   PCarb0(r,em,a)          "Price of GHG emissions net of carbon tax"
   emiTot0(r,em)           "Total country emissions"
   emiGBL0(em)             "Global emissions"
   
   EMIXSC(r,i,es,t)        "Kg CO2 emissions per $1 of exports/fin cons (by scope)"
   EMIXSCBaU(s,i,es,t)     "BaU Kg CO2 emissions per $1 of exports/fin cons (by scope)"
   EMITRD(s,i,d,es,t)      "CO2 emissions embodied into trade, Million metric tons of CO2-eq (by scope)"

$iftheni "%CLIM_MODULE%" == "ON"
*  Climate module variables

   EmiOthInd0              "Other industrial CO2 emissions"
   EmiCO20                 "Total CO2 emissions (GtCO2 per year)"
   CUMEmiIND0              "Cumulative industrial carbon emissions (GTC)"
   CUMEmi0                 "Total cumulative carbon emissions (GtC)"
   CRES0(b)                "Carbon reservoirs"
   MAT0                    "Carbon concentration increase in atmosphere (GtC from 1750)"
   FORC0(em)               "Radiative forcing"
   temp0(tb)               "Temperature change"
   delTemp0(r)             "Change in temperature at regional level"
$endif

   dam_tfp0(r,a)           "TFP damage parameter"
   dam_lab0(r,l,a)         "Labor productivity damage parameter"
   dam_hht0(r,l,a)         "Health-related labor productivity damage parameter"
   dam_nrg0(r,k,h)         "Household energy demand damage parameter"
   dam_lnd0(r,lnd)         "Land supply damage parameter"
   dam_tou0(r,i)           "Tourism exports damage parameter"
   dam_cap0(r)             "Capital stock damage parameter"

   yfdexpadp0(r,fd)        "Expenditure on adapation by agent 'a'"

$iftheni "%DAMAGE_MODULE%" == "ON"

*  Damage module

   dam_shft_tfp0(r,a)      "TFP damage shift parameter"
   dam_shft_lab0(r,l,a)    "Labor productivity damage shift parameter"
   dam_shft_hht0(r,l,a)    "Health-related labor productivity damage shift parameter"
   dam_shft_nrg0(r,k,h)    "Household energy demand damage shift parameter"
   dam_shft_lnd0(r,lnd)    "Land supply damage shift parameter"
   dam_shft_tou0(r,i)      "Tourism exports damage shift parameter"
   dam_shft_cap0(r)        "Capital stock damage shift parameter"

$endif

*  Normally exogenous emission variables
*
*  emiOth0(r,em)           "Emissions from other sources"
*  emiOthGbl0(em)          "Other global emissions"
*  chiemi0(em)             "Global shifter in emissions"
*
*  Carbon tax policy variables
*
*  emiTax0(r,em)           "Emissions tax"
*  emiCap0(ra,em)          "Emissions cap by aggregate region"
*  emiRegTax0(ra,em)       "Regionwide emissions tax"
*  emiQuota0(r,em)         "Quota allocation"
*  emiQuotaY0(r,em)        "Income from quota rights"
*  chiCap0(em)             "Emissions cap shifter"
*
*  Normally exogenous variables
*
   kstock0(r)              "Non-normalized capital stock"
   tkaps0(r)               "Total normalized stock of capital"

   kn0(r)                  "Initial stock of knowledge"
   rd0(r)                  "Initial expenditures on R&D"
   pop0(r)                 "Population"

   psave0(r)               "Price of savings"
   ev0(r,h)                "Initial EV"
   evf0(r,fd)              "Initial EV for final demand"
   evs0(r)                 "Initial EV for savings"
   sw0                     "Initial level for social welfare"
   swt0                    "Initial level for total social welfare"
   swt20                   "Initial level for second total social welfare"

*
*  Currently non explained variables
*
   pxghg0(r,a)             "Price of non-CO2 GHG gas bundle"
*  pim0(r,a)               "Markup over marginal cost of production"
*
*  Dynamic variables
*
*  axghg0(r,a,v)           "Uniform shifter in production bundle"
*  lambdaxp0(r,a,v)        "Output shifter in production bundle"
*  lambdaghg0(r,a,v)       "GHG shifter in production bundle"
*
*  lambdak0(r,a,v)         "Capital efficiency shifter"
*  chiglab0(r,l)           "Skill bias productivity shifter"
*  lambdah2obnd0(r,wbnd)   "Water efficiency shifter in water bundle use"
*  lambdaio0(r,i,a)        "Efficiency shifter in intermediate demand"
*  lambdae0(r,e,a,v)       "Energy efficiency shifter in production"
*  lambdace0(r,e,k,h)      "Energy efficiency shifter in consumption"
*
*
   invGFact0(r)            "Capital accumulation auxiliary variable"
*
*  Policy variables
*
*  landtax0(r,a)           "Land tax"
   uctax0(r,a)             "Tax/subsidy on unit cost of production"
   kappaf0(r,f,a)          "Income tax on factor income"
   kappah0(r)              "Direct tax rate"
   pftax0(r,f,a)           "Tax on primary factors"
   paTax0(r,i,aa)          "Sales tax on Armington consumption"
   pdTax0(r,i,aa)          "Sales tax on consumption of domestically produced goods"
   pmTax0(r,i,aa)          "Sales tax on consumption of imported goods"
   ptax0(r,a,i)            "Output tax/subsidy"

   etax0(s,i,d)            "Export tax/subsidies"
   tmarg0(s,i,d)           "FOB/CIF price wedge"
   mtax0(s,i,d)            "Import tax/subsidies"
   ntmAVE0(s,i,d)          "Non-tariff measure tariff equivalent"
   mtaxa0(s,i,d,aa)        "Agent-specific import tax rate"
   SPCTAR(s,i,d,t)         "Specific tariff--used for CBAM"

   landAss(r)              "Land assumption"
;

variables
   px(r,a,t)               "Producer price before tax"
   uc(r,a,v,t)             "Unit cost of production by vintage pre-tax"
   pxv(r,a,v,t)            "Unit cost of production by vintage tax/subsidy inclusive"

   xpn(r,a,v,t)            "Production level exclusive of non-CO2 GHG bundle but including NRS"
   xpx(r,a,v,t)            "Production level exclusive of non-CO2 GHG bundle and NRS"
   xghg(r,a,v,t)           "Non-CO2 GHG bundle associated with output"

   nd1(r,a,t)              "Demand for intermediate goods in ND1 bundle"
   va(r,a,v,t)             "Demand for top level VA bundle"
   pxn(r,a,v,t)            "Cost of production excl non-CO2 GHG bundle but including NRS"
   pxp(r,a,v,t)            "Cost of production excl non-CO2 GHG bundle excluding NRS"
   tfp(r,a,v,t)            "Total factor productivity"
   ftfp(r,a,v,t)           "Total factor productivity--factors only"
   etfp(r,t)               "Economy-wide tfp factor"

   lab1(r,a,t)             "Demand for 'unskilled' labor bundle"
   kef(r,a,v,t)            "Demand for KEF bundle (capital+skill+energy+nrs)"
   nd2(r,a,t)              "Demand for intermediate goods in ND2 bundle"
   va1(r,a,v,t)            "Demand for VA1 bundle"
   va2(r,a,v,t)            "Demand for VA2 bundle"
   pva(r,a,v,t)            "Price of VA bundle"
   pva1(r,a,v,t)           "Price of VA1 bundle"
   pva2(r,a,v,t)           "Price of VA2 bundle"

   LANDD(r,a,t)            "Demand for LANDD bundle"
   PLANDD(r,a,t)           "Price of LANDD bundle"
   PLANDDNDX(r,a,t)        "Price index of LANDD bundle"

   kf(r,a,v,t)             "Demand for KF bundle (capital+skill+nrs+water)"
   xnrg(r,a,v,t)           "Demand for NRG bundle in production"
   pkef(r,a,v,t)           "Price of KEF bundle"

   ksw(r,a,v,t)            "Demand for KSW bundle (capital+skill+water)"
   pkf(r,a,v,t)            "Price of KF bundle"

   ks(r,a,v,t)             "Demand for KS bundle (capital+skill)"
   xwat(r,a,t)             "Demand for WAT bundle"
   pksw(r,a,v,t)           "Price of KSW bundle"

   kv(r,a,v,t)             "Demand for K by vintage"
   lab2(r,a,t)             "Demand for 'skilled' labor bundle"
   pks(r,a,v,t)            "Price of KS bundle"

   xf(r,f,a,t)             "Demand for primary factors"

   labb(r,wb,a,t)          "Demand for labor bundle 'wb'"
   plab1(r,a,t)            "Price of 'unskilled' labor bundle"
   plab2(r,a,t)            "Price of 'skilled' labor bundle"
   plabb(r,wb,a,t)         "Price of labor bundle 'wb'"

   pnd1(r,a,t)             "Price of ND1 bundle"
   pnd2(r,a,t)             "Price of ND2 bundle"
   pwat(r,a,t)             "Price of water bundle"

   xaNRG(r,a,NRG,v,t)      "Demand for bottome level energy bundles"
   xnely(r,a,v,t)          "Demand for non-electric bundle"
   pnrg(r,a,v,t)           "Average price of energy bundle"
   pnrgNDX(r,a,v,t)        "Composite price of energy bundle"

   paNRG(r,a,NRG,v,t)      "Price of energy bundles"
   paNRGNDX(r,a,NRG,v,t)   "Composite price of energy bundles"
   pnely(r,a,v,t)          "Price of NELY bundle"
   pnelyNDX(r,a,v,t)       "Composite price of NELY bundle"

   xolg(r,a,v,t)           "Demand for oil and gas bundle"
   polg(r,a,v,t)           "Price of oil and gas bundle"
   polgNDX(r,a,v,t)        "Composite price of oil and gas bundle"

   xa(r,i,aa,t)            "Armington demand for goods"
   xd(r,i,aa,t)            "Domestic demand for domestic goods"
   xm(r,i,aa,t)            "Domestic demand for import goods"

   pd(r,i,aa,t)            "User price of domestically produced goods"
   pm(r,i,aa,t)            "User price of imported goods"

   x(r,a,i,t)              "Output of good 'i' produced by activity 'a'"
   p(r,a,i,t)              "Price of good 'i' produced by activity 'a'--pre-tax"
   pp(r,a,i,t)             "Price of good 'i' produced by activity 'a'--post-tax"
   xp(r,a,t)               "Gross sectoral output of activity 'i'"
   ps(r,i,t)               "Market price of domestically produced good 'i'"
   psNDX(r,i,t)            "Composite market price of domestically produced good 'i'"

   xpow(r,elyc,t)          "Aggregate power"
   ppow(r,elyc,t)          "Average price of aggregate power"
   ppowndx(r,elyc,t)       "Price index of aggregate power"
   xpb(r,pb,elyc,t)        "Power bundles"
   ppb(r,pb,elyc,t)        "Average price of power bundles"
   ppbndx(r,pb,elyc,t)     "Price index of power bundles"

   deprY(r,t)              "Depreciation income"
   yqtf(r,t)               "Outflow of capital income"
   trustY(t)               "Aggregate foreign capital outflow"
   yqht(r,t)               "Foreign capital income inflow"
   remit(s,l,r,t)          "Remittances to region s from region r for skill type l"
   odaOut(r,t)             "Outward ODA"
   odaIn(r,t)              "Inward ODA"
   odaGbl(t)               "Global ODA"
   govTr(s,d,t)            "Government transfers from s to households in d"
   itransfers(r,t)         "Government to government transfers"
   yh(r,t)                 "Household income net of depreciation"
   yd(r,t)                 "Disposable household income"

   supy(r,h,t)             "Per capita supernumerary income"
   xc(r,k,h,t)             "Household consumption of consumer good k"
   hshr(r,k,h,t)           "Household budget shares"
   zcons(r,k,h,t)          "Auxiliary consumption variable for CDE"
   u(r,h,t)                "Utility level"

   xcnnrg(r,k,h,t)         "Demand for non-energy bundle of consumer good k"
   xcnrg(r,k,h,t)          "Demand for energy bundle of consumer good k"
   pc(r,k,h,t)             "Price of consumer good k"
   pcnnrg(r,k,h,t)         "Price of non-energy bundle of consumer good k"
   xcnely(r,k,h,t)         "Demand for non-electric bundle of consumer good k"
   xcolg(r,k,h,t)          "Demand for OLG bundle of consumer good k"
   xacNRG(r,k,h,NRG,t)     "Demand for NRG bundle of consumer good k"
   pacNRG(r,k,h,NRG,t)     "Price of NRG bundle of consumer good k"
   pacNRGNDX(r,k,h,NRG,t)  "Compsote price of NRG bundle of consumer good k"
   pcolg(r,k,h,t)          "Price of OLG bundle of consumer good k"
   pcolgNDX(r,k,h,t)       "Composite price of OLG bundle of consumer good k"
   pcnely(r,k,h,t)         "Price of non-electric bundle of consumer good k"
   pcnelyNDX(r,k,h,t)      "Composite price of non-electric bundle of consumer good k"
   pcnrg(r,k,h,t)          "Price of energy of consumer good k"
   pcnrgNDX(r,k,h,t)       "Composite price of energy of consumer good k"

   xaac(r,i,h,t)           "Actual consumption"
   xawc(r,i,h,t)           "Household waste"
   paacc(r,i,h,t)          "Composite price of household consumption"
   paac(r,i,h,t)           "Price of actual consumption"
   pawc(r,i,h,t)           "Price of household waste"
   pah(r,i,h,t)            "Household demand prices incl. of waste taxes"

   savh(r,h,t)             "Private savings"
   aps(r,h,t)              "Private savings rate out of total household income"
   chiaps(r,h,t)           "Economy-wide shifter for household saving"
   chiSavf(r,t)            "Shifter on exogenous foreign saving"

   ygov(r,gy,t)            "Government revenues"
   ntmY(r,t)               "NTM revenues"

   pfd(r,fd,t)             "Final demand expenditure price index"
   yfd(r,fd,t)             "Value of aggregate final demand expenditures"

   xat(r,i,t)              "Aggregate Armington demand"
   xdt(r,i,t)              "Domestic demand for domestic production /x xtt"
   xmt(r,i,t)              "Aggregate import demand"
   pat(r,i,t)              "Price of aggregate Armington good"
   patNDX(r,i,t)           "Composite price of aggregate Armington good"
   pa(r,i,aa,t)            "Price of Armington good at agents' price"
   paNDX(r,i,aa,t)         "Composite price of Armington good at agents' price"

   xw(s,i,d,t)             "Volume of bilateral trade"
   pmt(r,i,t)              "Price of aggregate imports"
   pmtNDX(r,i,t)           "Composite price of aggregate imports"

$iftheni "%MRIO_MODULE%" == "ON"
   xwa(s,i,d,aa,t)         "Agent-specific bilateral trade"
   pdma(s,i,d,aa,t)        "Agent-specific price of bilateral imports, tariff-inclusive"
   pma(r,i,aa,t)           "Agent-specific price of aggregate imports"
$endif

   pdt(r,i,t)              "Producer price of goods sold on domestic markets"
   xet(r,i,t)              "Aggregate exports"
   xs(r,i,t)               "Domestic production of good 'i'"
   pe(s,i,d,t)             "Producer price of exports"
   pet(r,i,t)              "Producer price of aggregate exports"
   petNDX(r,i,t)           "Composite price of aggregate exports"
   pwe(s,i,d,t)            "FOB price of exports"
   pwm(s,i,d,t)            "CIF price of imports"
   pdm(s,i,d,t)            "End-user price of imports"

   xwmg(s,i,s,t)           "Demand for tt services from r to rp"
   xmgm(img,s,i,d,t)       "Demand for tt services from r to rp for service type m"
   pwmg(s,i,d,t)           "Average price to transport good from r to rp"
   xtmg(img,t)             "Total global demand for tt services m"
   xtt(r,i,t)              "Supply of m by region r"
   ptmg(img,t)             "The average global price of service m"

$iftheni "%DEPL_MODULE%" == "ON"

*  Depletion module variables

   prat(r,a,t)             "Ratio of actual producer price wrt to exogenous price trend"
   omegar(r,a,t)           "Elasticity of discovery/extraction rate wrt to price ratio"
   dscRate(r,a,t)          "Discovery rate (for oil and gas only)"
   extRate(r,a,t)          "Extraction rate from proven reserves"
   chiExtRate(r,a,t)       "Extraction rate shifter"
   chiDscRate(r,a,t)       "Discovery rate shifter"
   cumExt(r,a,t)           "Cumulative extraction from reserves"
   res(r,a,t)              "Proven reserves"
   resp(r,a,t)             "Potential reserves"
   ytdres(r,a,t)           "Yet-to-discover reserves"
   resgap(r,a,t)           "Gap between actual and potential reserves"
   xfPot(r,a,t)            "Potential supply"
   extr(r,a,t)             "Extraction"

$endif

   pf(r,f,a,t)             "Price of primary factors"
   pfp(r,f,a,t)            "Price of primary factors tax inclusive"

   ldz(r,l,z,t)            "Labor demand by zone"
   awagez(r,l,z,t)         "Average wage by zone"
   urbPrem(r,l,t)          "Urban wage premium"
   resWage(r,l,z,t)        "Reservation wage"
   chirw(r,l,z,t)          "Reservation wage shifter"
   ewagez(r,l,z,t)         "Equilibrium wage by zone"
   twage(r,l,t)            "Equilibrium wage by skill"
   skillprem(r,l,t)        "Skill premium relative to a reference wage"
   tls(r,t)                "Total labor supply"

   migr(r,l,t)             "Level of rural to urban migration"
   migrMult(r,l,z,t)       "Migration multiplier for multi-year time steps"
   lsz(r,l,z,t)            "Labor supply by zone"
   ls(r,l,t)               "Aggregate labor supply by skill"
   gtlab(r,t)              "Growth rate of total labor supply"
   glab(r,l,t)             "Growth of labor supply by skill"
   glabz(r,l,z,t)          "Growth of labor supply by skill and zone"
   wPrem(r,l,a,t)          "Wage premium relative to equilibrium wage"

   pk(r,a,v,t)             "Market price of capital by vintage and activity"
   trent(r,t)              "Aggregate return to capital"
   rtrent(r,t)             "Aggregate real return to capital"

   k0(r,a,t)               "Installed capital at beginning of period"
   kslo(r,a,t)             "Supply of old capital"
   kshi(r,a,t)             "Supply of new capital"
   kxRat(r,a,v,t)          "Capital output ratio by sector"
   rrat(r,a,t)             "Ratio of return to Old wrt to New capital"

   xpv(r,a,v,t)            "Gross sectoral output by vintage"

   arent(r,t)              "Average return to capital"

   tland(r,lnd,t)          "Aggregate land supply"
   ptland(r,lnd,t)         "Aggregate price index of land"
   ptlandndx(r,lnd,t)      "Price index of aggregate land"
   landMax(r,lnd,t)        "Maximum available land"
   xlb(r,lnd,lb,t)         "Land bundles"
   plb(r,lnd,lb,t)         "Average price of land bundles"
   plbndx(r,lnd,lb,t)      "Price index of land bundles"
   xnlb(r,lnd,t)           "Intermediate land bundle"
   pnlb(r,lnd,t)           "Price of intermediate land bundle"
   pnlbndx(r,lnd,t)        "Price index of intermediate land bundle"

   etanrs(r,a,t)           "Supply elasticity of natural resource"
   chinrs(r,a,t)           "Natural resource supply shifter"
   wchinrs(a,t)            "Global natural resource supply shifter"

   xfNot(r,a,t)            "Notional supply of natural resources"
   xfGap(r,a,t)            "Gap between notional supply and reserve profile"
   xfs(r,f,a,t)            "Actual supply of natural resources and other factors"

   th2o(r,t)               "Aggregate water supply"
   h2oMax(r,t)             "Maximum available water supply"
   th2om(r,t)              "Marketed water supply"
   h2obnd(r,wbnd,t)        "Aggregate water bundles"
   pth2ondx(r,t)           "Aggregate water price index"
   pth2o(r,t)              "Aggregate market price of water"
   ph2obnd(r,wbnd,t)       "Price of aggregate water bundles"
   ph2obndndx(r,wbnd,t)    "Price index of aggregate water bundles"

   pkp(r,a,v,t)            "Price of capital by vintage and activity tax inclusive"

   cpi(r,h,cpindx,t)       "Consumer price index"
   pfact(r,t)              "Average price of factors, i.e. real exchange rate"
   pwfact(t)               "Global factor price index"

   savg(r,t)               "Public savings"

*  Closure variables

   rsg(r,t)                "Real government savings"

   rfdshr(r,fd,t)          "Volume share of final demand expenditure in real GDP"
   nfdshr(r,fd,t)          "Value share of final demand expenditure in nominal GDP"

   kappaf(r,f,a,t)         "Income tax on factor income"
   kappah(r,t)             "Direct tax rate"
   xfd(r,fd,t)             "Volume of aggregate final demand expenditures"

   kstocke(r,t)            "Anticipated capital stock"
   ror(r,t)                "Net aggregate rate of return to capital"
   rorc(r,t)               "Cost adjusted rate of return to capital"
   rore(r,t)               "Expected rate of return to capital"
   devRoR(r,t)             "Change in rate of return"
   grK(r,t)                "Anticipated growth of the capital stock"
   rord(r,t)               "Deviations from the normal rate of return"
   savf(r,t)               "Foreign savings"
   savfRat(r,t)            "Foreign savings as a share of GDP"
   rorg(t)                 "Average expected global rate of return to capital"

   pmuv(t)                 "Export price index of manufactured goods from high-income countries"
   pwsav(t)                "Global price of investment good"
   pwgdp(t)                "Global gdp deflator"
   pnum(t)                 "Model numéraire"
   pw(a,t)                 "World price of activity a"
   walras(t)               "Value of Walras"

*  Macro variables

   cons(r,t)               "Aggregate consumption"
   pcons(r,t)              "Aggregate CPI"
   gdpmp(r,t)              "Nominal GDP at market price"
   rgdpmp(r,t)             "Real GDP at market price"
   pgdpmp(r,t)             "GDP at market price expenditure deflator"
   rgdppc(r,t)             "Real GDP at market price per capita"
   grrgdppc(r,t)           "Growth rate of real GDP per capita"
   gl(r,t)                 "Economy-wide labor productivity growth"
   klrat(r,t)              "Capital labor ratio in efficiency units"

*  Emission variables

   emi(r,em,is,aa,t)       "Emissions by region and driver"
   ProcEmi(r,em,a,t)       "Process emissions by region and driver"
   PCarb(r,em,a,t)         "Price of GHG emissions net of carbon tax"
   emiTot(r,em,t)          "Total country emissions"
   emiGBL(em,t)            "Global emissions"

*  Normally exogenous emission variables

   emiOth(r,em,t)          "Emissions from other sources"
   emiOthGbl(em,t)         "Other global emissions"
   chiemi(r,em,aa,t)       "Global shifter in emissions"

$iftheni "%CLIM_MODULE%" == "ON"

   EmiCO2(t)               "Total CO2 emissions (GtCO2 per year)"
   EmiOTHIND(t)            "Other industrial emissions (GtCO2 per year)"
   CUMEMIIND(t)            "Cumulative industrial carbon emissions (GTC)"
   CUMEmi(t)               "Total cumulative carbon emissions (GtC)"
   alpha(t)                "Carbon cycle calibration parameter"
   CRes(b,t)               "Carbon reservoir"
   MAT(t)                  "Carbon concentration increase in atmosphere (GtC from 1750)"
   FORC(em,t)              "Increase in radiative forcing (watts per m2 from 1900)"
   TEMP(tb, tt)            "Increase in temperature for both boxes"
   delTemp(r,t)            "Regional change in temperature"

*  Normally exogenous climate module variables

   ForcOth(t)              "Exogenous forcing for other greenhouse gases"
   EmiLand(t)              "Emissions from deforestation"
   CumEmiLand(t)           "Cumulative from land"

$endif

   dam_tfp(r,a,t)          "TFP damage parameter"
   dam_lab(r,l,a,t)        "Labor productivity damage parameter"
   dam_hht(r,l,a,t)        "Health-related labor productivity damage parameter"
   dam_nrg(r,k,h,t)        "Household energy demand damage parameter"
   dam_lnd(r,lnd,t)        "Land supply damage parameter"
   dam_tou(r,i,t)          "Tourism exports damage parameter"
   dam_cap(r,t)            "Capital stock damage parameter"

   yfdexpadp(r,fd,t)       "Expenditure on adapation by agent 'a'"

$iftheni "%DAMAGE_MODULE%" == "ON"

   adpShr(r,adp,t)         "Share of final demand expenditure on adaptation expenditures"
   xfdAdp_tot(r,t)         "Total adaptation expenditures"

   dam_shft_tfp(r,a,t)     "TFP damage shift parameter"
   dam_shft_lab(r,l,a,t)   "Labor productivity damage shift parameter"
   dam_shft_hht(r,l,a,t)   "Health-related labor productivity damage shift parameter"
   dam_shft_nrg(r,k,h,t)   "Household energy demand damage shift parameter"
   dam_shft_lnd(r,lnd,t)   "Land supply damage shift parameter"
   dam_shft_tou(r,i,t)     "Tourism exports damage shift parameter"
   dam_shft_cap(r,t)       "Capital stock damage shift parameter"

$endif

*  Carbon tax policy variables

*  emiTax(r,em,aa,t)       "Emissions tax"
*  emiCap(ra,em,t)         "Emissions cap by aggregate region"
*  emiRegTax(ra,em,t)      "Regionwide emissions tax"
*  emiQuota(r,em,t)        "Quota allocation"
*  emiQuotaY(r,em,t)       "Income from quota rights"

   emiTotETS(ra,r,emq,aets,t) "Emissions by group of agents"
   emiCap(ra,emq,aets,t)      "ETS emission caps by coalition"
   emiCTax(ra,emq,aets,t)     "Coalition emission tax for ETS sectors"
   emiTax(r,em,aa,t)          "Regional emission tax for ETS sectors"
   emiTaxX(ra,s,i,d,t)        "Tax on embodied imported emissions"
   emiQuota(r,emq,aets,t)     "Regional quota"
   emiQuotaY(r,emq,aets,t)    "Regional quota income"

*  Normally exogenous variables

   kstock(r,t)             "Non-normalized capital stock"
   tkaps(r,t)              "Total normalized stock of capital"

   kn(r,tt)                "Knowledge stock (defined over tt)"
   rd(r,tt)                "R&D expenditures (defined over tt)"

   pop(r,t)                "Population"

*  Calibrated parameters

   gammac(r,k,h,t)         "Subsistence minima"
   muc(r,k,h,t)            "Marginal propensity to consume"
   mus(r,h,t)              "Marginal propensity to save"
   betac(r,h,t)            "Consumption shifter"
   aad(r,h,t)              "AIDADS utility shifter"
   alphaad(r,k,h,t)        "AIDADS MBS linear shifter"
   betaad(r,k,h,t)         "AIDADS MBS slope term"
   omegaad(r,h)            "Auxiliary AIDADS parameter for elasticities"
   etah(r,k,h,t)           "Income elasticities"
   epsh(r,k,kp,h,t)        "Own- and cross-price elasticities"
   alphah(r,k,h,t)         "CDE share parameter"
   eh(r,k,h,t)             "CDE expansion parameter"
   bh(r,k,h,t)             "CDE substitution parameter"

*  Currently non explained variables

   pxghg(r,a,v,t)          "Price of non-CO2 GHG gas bundle"
   uez(r,l,z,t)            "Unemployment rate by zone"

*  Dynamic variables

   axghg(r,a,v,t)          "Uniform shifter in production bundle"
   lambdaxp(r,a,v,t)       "Output shifter in production bundle"
   lambdaghg(r,a,v,t)      "GHG shifter in production bundle"

   lambdaf(r,f,a,t)        "Productivity parameter for primary factors"
   pik(r,l,a,t)            "Knowledge-based biased productivity parameter"

   lambdak(r,a,v,t)        "Capital efficiency shifter"
   capu(r,a,v,t)           "Capacity utilization level"
   caput(r,t)              "Total capital capacity utilization"
   chiglab(r,l,t)          "Skill bias productivity shifter"
   lambdah2obnd(r,wbnd,t)  "Water efficiency shifter in water bundle use"
   lambdaio(r,i,a,t)       "Efficiency shifter in intermediate demand"
   lambdanrgp(r,a,v,t)     "Total energy efficiency shifter in production"
   lambdae(r,e,a,v,t)      "Energy efficiency shifter in production"
   lambdanrgc(r,k,h,t)     "Total energy efficiency shifter in private consumption"
   lambdace(r,e,k,h,t)     "Energy efficiency shifter in consumption"

   invGFact(r,t)           "Capital accumulation auxiliary variable"

*  Policy variables

   ptax(r,a,i,t)           "Output tax/subsidy"
   pftax(r,f,a,t)          "Tax on primary factors"
   chiFtax(r,t)            "Multiplifactor factor on factor tax"
   alphaFtax(r,t)          "Additive factor on factor tax"
   uctax(r,a,v,t)          "Tax/subsidy on unit cost of production"
   paTax(r,i,aa,t)         "Sales tax on Armington consumption"
   pdtax(r,i,aa,t)         "Sales tax on domestically produced goods"
   pmtax(r,i,aa,t)         "Sales tax on imported goods"

   etax(s,i,d,t)           "Export tax/subsidies"
   etaxi(r,i,t)            "Export commodity tax uniform across destinations"
   tmarg(s,i,d,t)          "FOB/CIF price wedge"
   mtax(s,i,d,t)           "Import tax/subsidies"
   ntmAVE(s,i,d,t)         "Non-tariff measure tariff equivalent"
   mtaxa(s,i,d,aa,t)       "Agent-specific import tax rate"

   wtaxh(r,i,h,t)          "Ad valorem tax on waste"
   wtaxhx(r,i,h,t)         "Excise tax on waste"

*  Post-simulation variables
   chisave(t)              "Price of saving adjustment factor"
   psave(r,t)              "Price of savings"
   ev(r,h,t)               "Equivalent income at base year prices"
   evf(r,fd,t)             "Final demand expenditure function"
   evs(r,t)                "Equivalent variation of savings"
   sw(t)                   "Social welfare function--private consumption"
   swt(t)                  "Social welfare function--private and public consumption"
   swt2(t)                 "Social welfare function--private and public consumption+savings"

   obj                     "Objective function"
;

equations
   pxeq(r,a,t)                "Producer price before tax"
   uceq(r,a,v,t)              "Unit cost of production by vintage pre-tax"
   pxveq(r,a,v,t)             "Unit cost of production by vintage tax/subsidy inclusive"

   xpneq(r,a,v,t)             "Production level exclusive of non-CO2 GHG bundle"
   xghgeq(r,a,v,t)            "Non-CO2 GHG bundle associated with output"

   xpxeq(r,a,v,t)             "Production level exclusive of non-CO2 GHG bundle and NRS"
   pxpeq(r,a,v,t)             "Price of production exclusive of non-CO2 GHG bundle and NRS"

   nd1eq(r,a,t)               "Demand for intermediate goods in ND1 bundle"
   vaeq(r,a,v,t)              "Demand for top level VA bundle"
   pxneq(r,a,v,t)             "Cost of production excl non-CO2 GHG bundle and NRS"

   lab1eq(r,a,t)              "Demand for Type 1 labor bundle"
   kefeq(r,a,v,t)             "Demand for KEF bundle (capital+skill+energy+nrs)"
   nd2eq(r,a,t)               "Demand for intermediate goods in ND2 bundle"
   va1eq(r,a,v,t)             "Demand for VA1 bundle"
   va2eq(r,a,v,t)             "Demand for VA2 bundle"
   pvaeq(r,a,v,t)             "Price of VA bundle"
   pva1eq(r,a,v,t)            "Price of VA1 bundle"
   pva2eq(r,a,v,t)            "Price of VA2 bundle"

   landdeq(r,a,t)             "Demand for LANDD bundle"
   lndeq(r,lnd,a,t)           "Demand for land by type"
   planddeq(r,a,t)            "Price of LANDD bundle"
   planddndxeq(r,a,t)         "Price index of landd bundle"

   kfeq(r,a,v,t)              "Demand for KF bundle (capital+skill+nrs)"
   xnrgeq(r,a,v,t)            "Demand for NRG bundle in production"
   pkefeq(r,a,v,t)            "Price of KEF bundle"

   ksweq(r,a,v,t)             "Demand for KSW bundle (capital+skill+water)"
   xnrseq(r,fp,a,t)           "Demand for NRS factor"
   pkfeq(r,a,v,t)             "Price of KF bundle"

   kseq(r,a,v,t)              "Demand for KS bundle (capital+skill)"
   xwateq(r,a,t)              "Demand for water bundle"
   pksweq(r,a,v,t)            "Price of KSW bundle"
   h2oeq(r,fp,a,t)            "Demand for water factor"

   kveq(r,a,v,t)              "Demand for K by vintage"
   lab2eq(r,a,t)              "Demand for Type 2 labor bundle"
   pkseq(r,a,v,t)             "Price of KS bundle"

   labbeq(r,wb,a,t)           "First level disaggregation of labor bundles"
   plab1eq(r,a,t)             "Price of 'unskilled' labor bundle"
   plab2eq(r,a,t)             "Price of 'skilled' labor bundle"

   ldeq(r,l,a,t)              "Demand for labor by skill and activity"
   plabbeq(r,wb,a,t)          "Price of labor bundles"

   xapeq(r,i,a,t)             "Armington demand for intermediate goods"
   pnd1eq(r,a,t)              "Price of ND1 bundle"
   pnd2eq(r,a,t)              "Price of ND2 bundle"
   pwateq(r,a,t)              "Price of water bundle"

   xnelyeq(r,a,v,t)           "Demand for non-electric bundle"
   xolgeq(r,a,v,t)            "Demand for OLG bundle"
   xaNRGeq(r,a,NRG,v,t)       "Demand for bottom-level energy bundle"
   xaeeq(r,e,a,t)             "Decomposition of energy bundle with single nest"

   paNRGeq(r,a,NRG,v,t)       "Price of NRG bundles"
   paNRGNDXeq(r,a,NRG,v,t)    "Composite price of NRG bundles"
   polgeq(r,a,v,t)            "Price of OLG bundle"
   polgNDXeq(r,a,v,t)         "Composite price of OLG bundle"
   pnelyeq(r,a,v,t)           "Price of ELY bundle"
   pnelyNDXeq(r,a,v,t)        "Composite price of ELY bundle"
   pnrgeq(r,a,v,t)            "Average price of energy bundle"
   pnrgNDXeq(r,a,v,t)         "Composite price of energy bundle"

   peq(r,a,i,t)               "Production of good 'i' by activity 'a'"
   xpeq(r,a,t)                "Gross production of activity 'a'"
   ppeq(r,a,i,t)              "Price of good 'i' supplied by activity 'a'--post tax"
   xeq(r,a,i,t)               "Demand of good 'i' supplied by activity 'a'"
   pseq(r,i,t)                "Market price of domestically produced good 'i'"

   xetdeq(r,etd,elyc,t)       "Demand for electricity transmission and distribution services"
   xpoweq(r,elyc,t)           "Demand for aggregate power"
   pselyeq(r,elyc,t)          "Market price of electricity, incl. of ETD"
   xpbeq(r,pb,elyc,t)         "Demand for power bundles"
   ppowndxeq(r,elyc,t)        "Price index for aggregate power"
   ppoweq(r,elyc,t)           "Average price of aggregate power"
   xbndeq(r,elya,elyc,t)      "Demand for power activity elya"
   ppbndxeq(r,pb,elyc,t)      "Price index for power bundles"
   ppbeq(r,pb,elyc,t)         "Average price of power bundles"

   deprYeq(r,t)               "Depreciation income"
   ntmYeq(r,t)                "NTM revenues"
   yqtfeq(r,t)                "Outflow of capital income"
   trustYeq(t)                "Total capital income outflows"
   yqhteq(r,t)                "Foreign capital income inflows"
   odaouteq(r,t)              "Outward ODA"
   odaineq(r,t)               "Inward ODA"
   odagbleq(t)                "Global ODA"
   remiteq(s,l,r,t)           "Remittance outflow to region s from region r for labor skill l"
   yheq(r,t)                  "Household income net of depreciation"
   ydeq(r,t)                  "Household disposable income"

   ygoveq(r,gy,t)             "Government revenues"
   yfdInveq(r,t)              "Investment balance"

   supyeq(r,h,t)              "Per capita supernumerary income for ELES"
   zconseq(r,k,h,t)           "Auxiliary consumption variable for CDE"
   muceq(r,k,h,t)             "Marginal budger shares for AIDADS"
   xceq(r,k,h,t)              "Aggregate private consumption by sector in k commodity space"
   hshreq(r,k,h,t)            "Household budget shares"
   ueq(r,h,t)                 "Household utility"

   xcnnrgeq(r,k,h,t)          "Consumer demand for non-energy bundle"
   xcnrgeq(r,k,h,t)           "Consumer demand for energy bundle"
   pceq(r,k,h,t)              "Consumer price for good k"
   xacnnrgeq(r,i,h,t)         "Demand for non-energy commodities in consumption"
   pcnnrgeq(r,k,h,t)          "Price of non-energy bundle in consumption"
   xcnelyeq(r,k,h,t)          "Demand for non-electric bundle in consumption"
   xcolgeq(r,k,h,t)           "Demand for OLG bundle in consumption"
   xacNRGeq(r,k,h,NRG,t)      "Demand for NRG bundles in consumption"
   xaceeq(r,e,h,t)            "Demand for energy commodities in consumption"
   pacNRGeq(r,k,h,NRG,t)      "Price of NRG bundles in consumption"
   pacNRGNDXeq(r,k,h,NRG,t)   "Composite price of NRG bundles in consumption"
   pcolgeq(r,k,h,t)           "Price of OLG bundle in consumption"
   pcolgNDXeq(r,k,h,t)        "Composite price of OLG bundle in consumption"
   pcnelyeq(r,k,h,t)          "Price of non-electric bundle in consumption"
   pcnelyNDXeq(r,k,h,t)       "Composite price of non-electric bundle in consumption"
   pcnrgeq(r,k,h,t)           "Price of energy bundle in consumption"
   pcnrgNDXeq(r,k,h,t)        "Composite price of energy bundle in consumption"

   xaaceq(r,i,h,t)            "Actual consumption"
   xawceq(r,i,h,t)            "Household waste"
   paacceq(r,i,h,t)           "Composite price of household consumption"
   paaceq(r,i,h,t)            "Price of actual consumption"
   pawceq(r,i,h,t)            "Price of waste"
   paheq(r,i,h,t)             "Household demand prices incl. of waste taxes"

   savhELESeq(r,h,t)          "Private savings equation for ELES"
   savheq(r,h,t)              "Aggregate household saving for non-ELES or aps for ELES"

   xafeq(r,i,fdc,t)           "Other final demand for Armington good"
   pfdfeq(r,fdc,t)            "Other final demand expenditure price index"
   yfdeq(r,fd,t)              "Aggregate value of final demand expenditure"

   xateq(r,i,t)               "Total Armington demand by commodity"
   xdteq(r,i,t)               "Domestic demand for domestic production /x xtt"
   xmteq(r,i,t)               "Aggregate import demand"
   pateq(r,i,t)               "Price of aggregate Armington good"
   patNDXeq(r,i,t)            "Composite price of aggregate Armington good"
   paeq(r,i,aa,t)             "Agent price of Armington good"
   paNDXeq(r,i,aa,t)          "Composite Agent price of Armington good"

   xdeq(r,i,aa,t)             "Demand for domestic goods"
   xmeq(r,i,aa,t)             "Demand for imported goods"
   pdeq(r,i,aa,t)             "End user price of domestic goods"
   pmeq(r,i,aa,t)             "End user price of imported goods"

   xwdMRIOeq(s,i,d,t)         "Import demand by region d from region s with MRIO specification"
   xwdeq(s,i,d,t)             "Demand for imports by region d sourced in region s"
   pmteq(r,i,t)               "Price of aggregate imports"
   pmtNDXeq(r,i,t)            "Composite price of aggregate imports"

$iftheni "%MRIO_MODULE%" == "ON"

   xwaeq(s,i,d,aa,t)          "Agent-specific demand for bilateral exports"
   pdmaeq(s,i,d,aa,t)         "Agent-specific price of bilateral exports"
   pmaeq(r,i,aa,t)            "Agent-specific price of aggregate imports"

$endif

   pdteq(r,i,t)               "Supply of domestic goods"
   xeteq(r,i,t)               "Aggregate export supply"
   xseq(r,i,t)                "Total domestic supply"
   psNDXeq(r,i,t)             "Composite supply price"
   xwseq(s,i,d,t)             "Supply of exports from r to rp"
   peteq(r,i,t)               "Aggregate price of exports"
   petNDXeq(r,i,t)            "Composite price of exports"
   pweeq(s,i,d,t)             "FOB price of exports"
   pwmeq(s,i,d,t)             "CIF price of imports"
   pdmeq(s,i,d,t)             "Tariff inclusive price of imports"

   xwmgeq(s,i,d,t)            "Demand for tt services from r to rp"
   xmgmeq(img,s,i,d,t)        "Demand for tt services from r to rp for service type m"
   pwmgeq(s,i,d,t)            "Average price to transport good from r to rp"
   xtmgeq(img,t)              "Total global demand for tt services m"
   xtteq(r,img,t)             "Supply of m by region r"
   ptmgeq(img,t)              "The average global price of service m"

$iftheni "%DEPL_MODULE%" == "ON"

*  Depletion equations

   prateq(r,a,t)              "Growth in producer price relative to trend"
   omegareq(r,a,t)            "Discovery elas for oil and gas, extraction elas for coal"
   dscRateeq(r,a,t)           "Discovery rate for oil and gas"
   extRateeq(r,a,t)           "Extraction rate equation for fossil fuels"
   cumExteq(r,a,t)            "Extraction between two time periods"
   reseq(r,a,t)               "Actual reserve level based on actual extraction"
   respeq(r,a,t)              "Reserve level if on reserve profile"
   ytdreseq(r,a,t)            "Yet to discover reserves"
   resGapeq(r,a,t)            "Gap between actual reserves and reserve potential"
   xfPoteq(r,a,t)             "Potential supply"
   extreq(r,a,t)              "Extraction level"

$endif

   ldzeq(r,l,z,t)             "Labor demand by zone equation"
   awagezeq(r,l,z,t)          "Average wage by zone"
   urbPremeq(r,l,t)           "Urban wage premium"
   resWageeq(r,l,z,t)         "Reservation wage equation"
   uezeq(r,l,z,t)             "Definition of unemployment"
   ewagezeq(r,l,z,t)          "Market clearing wage by zone"
   wageeq(r,l,a,t)            "Equilibrium condition for labor in sector 'a'"
   twageeq(r,l,t)             "Average market clearing wage"
   skillpremeq(r,l,t)         "Skill premium relative to the reference wage"
   wageeq(r,l,a,t)            "Sectoral wage level"
   lseq(r,l,t)                "Aggregate labor supply by skill"
   tlseq(r,t)                 "Total labor supply"

   kvseq(r,a,v,t)             "Sectoral capital supply in comp. stat. specification"
   pkeq(r,a,v,t)              "Sectoral return to capital"
   trenteq(r,t)               "Aggregate return to capital"
   rtrenteq(r,t)              "Aggregate real return to capital"

   k0eq(r,a,t)                "Beginning of period installed capital"
   ksloeq(r,a,t)              "Supply of old capital"
   rrateq(r,a,t)              "Supply of new capital"
   ksloinfeq(r,a,t)           "Supply of old capital with infinite elasticity"
   rratinfeq(r,a,t)           "Supply of new capital with infinite elasticity"
   kshieq(r,a,t)              "Relative rate of return between Old and New capital"
   kxRateq(r,a,v,t)           "Capital output ratio"
   xpveq(r,a,v,t)             "Allocation between old and new capital"

   capeq(r,fp,a,t)            "Total capital demand by activity"
   pcapeq(r,fp,a,t)           "Average capital remuneration by activity"

   arenteq(r,t)               "Average return to capital"

   tlandeq(r,lnd,t)           "Total land supply equation"
   xlb1eq(r,lnd,lb,t)         "Supply of first land bundle"
   xnlbeq(r,lnd,t)            "Supply of intermediate land bundle"
   ptlandndxeq(r,lnd,t)       "Price index of aggregate land"
   ptlandeq(r,lnd,t)          "Aggregate price index of land"
   xlbneq(r,lnd,lb,t)         "Supply of other land bundles"
   pnlbndxeq(r,lnd,t)         "Price index of intermediate land bundle"
   pnlbeq(r,lnd,t)            "Average price of intermediate land bundle"
   plandeq(r,lnd,a,t)         "Price of land by sector"
   plbndxeq(r,lnd,lb,t)       "Price index of land bundles"
   plbeq(r,lnd,lb,t)          "Average price of land bundles"

   etanrseq(r,a,t)            "Natural resource supply elasticity"
   xfnoteq(r,fp,a,t)          "Notional supply of natural resource"
   xfGapeq(r,a,t)             "Gap between notional and actual supply"
   xfsnrseq(r,fp,a,t)         "Actual supply"
   pfnrseq(r,fp,a,t)          "Equilibrium condition"

   th2oeq(r,t)                "Aggregate water supply"
   h2obndeq(r,wbnd,t)         "Supply of water bundles"
   pth2ondxeq(r,t)            "Aggregate water price index"
   pth2oeq(r,t)               "Aggregate price of water"
   th2omeq(r,t)               "Market water supply"
   ph2obndndxeq(r,wbnd,t)     "Price index of water bundles"
   ph2obndeq(r,wbnd,t)        "Price of water bundles"
   ph2oeq(r,fp,a,t)           "Supply of water to activities--determines market price"

   pfpeq(r,f,a,t)             "Producer cost of factors"
   pkpeq(r,a,v,t)             "Producer cost of capital"

   savgeq(r,t)                "Nominal government savings"
   rsgeq(r,t)                 "Real government savings"

   rfdshreq(r,fd,t)           "Volume share of final demand expenditure in real GDP"
   nfdshreq(r,fd,t)           "Value share of final demand expenditure in nominal GDP"

   kstockeeq(r,t)             "Anticipated end-of-period capital stock"
   roreq(r,t)                 "Net aggregate rate of return to capital"
   devRoReq(r,t)              "Change in rate of return"
   grKeq(r,t)                 "Anticipated growth of the capital stock"
   rorceq(r,t)                "Cost adjusted rate of return to capital"
   roreeq(r,t)                "Expected rate of return to capital"
   savfeq(r,t)                "Capital account closure"
   savfRateq(r,t)             "Foreign saving as a share of GDP"
   rorgeq(t)                  "Average global rate of return"

   pfdheq(r,h,t)              "Price consumption expenditure deflator"
   xfdheq(r,h,t)              "Nominal household expenditure"
   conseq(r,t)                "Nominal aggregate private consumption"
   pconseq(r,t)               "Aggregate CPI"
   gdpmpeq(r,t)               "Nominal GDP at market prices"
   rgdpmpeq(r,t)              "Real GDP at market prices"
   pgdpmpeq(r,t)              "GDP at market price deflator"
   rgdppceq(r,t)              "Real GDP per capita"
   grrgdppceq(r,t)            "Growth of real GDP per capita"
   klrateq(r,t)               "Capital labor ratio in efficiency units"

   pmuveq(t)                  "Export price index of manufactured goods from high-income countries"
   cpieq(r,h,cpindx,t)        "CPI equation"
   pfacteq(r,t)               "Factor price index"
   pwfacteq(t)                "Global factor price index"
   pwgdpeq(t)                 "World GDP deflator"
   pwsaveq(t)                 "Global price of investment good"
   pnumeq(t)                  "Model numéraire"
   pweq(a,t)                  "World price of activity a"

   walraseq(t)                "Walras' Law"

   emiieq(r,em,i,aa,t)        "Consumption based emissions"
   emifeq(r,em,fp,a,t)        "Factor-use based emissions"
   emixeq(r,em,is,a,t)        "Output based emissions"
   emiToteq(r,em,t)           "Total regional emissions"
   emiGbleq(em,t)             "Total global emissions"

$iftheni "%CLIM_MODULE%" == "ON"
*  Emissions
   EmiCO2EQ(t)                "Total CO2 emissions equation"
   CUMEmiINDEQ(t)             "Cumulative industrial carbon emissions"
   CUMEmiEQ(t)                "Cumulative total carbon emissions"

*  Carbon cycle, forcing and temperature

   MATEQ(t)                   "Atmospheric concentration equation"
   alphaeq(t)                 "Decay parameter adjustment"
   CReseq(b,t)                "Carbon reservoir"
   FORCEQ(t)                  "Radiative forcing equation"
   TEMPEQ(tb,tt,t)            "Increase in temperature for both boxes"
   delTempeq(r,t)             "Downscaling of temperature change to region"
$endif

$iftheni "%DAMAGE_MODULE%" == "ON"

*  Damages module

   dam_tfpeq(r,a,t)           "TFP damage equation"
   dam_labeq(r,l,a,t)         "Damage adjustment to labor productivity"
   dam_hhteq(r,l,a,t)         "Damage adjustment to health-related labor productivity"
   dam_nrgeq(r,k,h,t)         "Damage adjustment to household energy demand"
   dam_lndeq(r,lnd,t)         "Damage adjustment to land supply"
   dam_toueq(r,i,t)           "Damage adjustment to tourism exports"
   dam_capeq(r,t)             "Damage adjustment to capital stock"

*  Adaptation module

   xfdadpeq(r,adp,t)          "Adaptation expenditure by final demand agent"
   xfdAdp_toteq(r,t)          "Total adaptation expenditures"
   dam_shft_tfpeq(r,a,t)      "Adaptation shifter for TFP damage function"
   dam_shft_labeq(r,l,a,t)    "Adaptation shifter for labor productivity damage function"
   dam_shft_hhteq(r,l,a,t)    "Adaptation shifter for health productivity damage function"
   dam_shft_nrgeq(r,k,h,t)    "Adaptation shifter for energy demand damage function"
   dam_shft_lndeq(r,lnd,t)    "Adaptation shifter for land supply damage function"
   dam_shft_toueq(r,i,t)      "Adaptation shifter for tourism exports damage function"
   dam_shft_capeq(r,t)        "Adaptation shifter for capital stock damage function"

   yfdexpadpeq(r,fd,t)        "Expenditure on adapation by agent 'a'"
$endif

$iftheni.FBS "%FBS_MODULE%" == "ON"
   calo(r,i,srcr,t)           "Household consumption of calories by source region"
$endif.FBS

*  emiCapeq(ra,em,t)          "Emission constraint equation"
*  emiTaxeq(r,em,aa,t)        "Setting of emissions tax"
*  emiQuotaYeq(r,em,t)        "Emissions quota income"

   migreq(r,l,t)              "Migration equation"
   migrmulteq(r,l,z,t)        "Migration multiplier equation"
   lszeq(r,l,z,t)             "Labor supply by zone"
   glabeq(r,l,t)              "Aggregate labor growth rate by skill"
   invGFacteq(r,t)            "Investment factor used for dynamic module"
   kstockeq(r,t)              "Capital accumulation equation"
   tkapseq(r,t)               "Capital normalization formula"

*  Knowledge module
   kneq(r,ty,t)               "Knowledge stock -- calculated annually"
   rdeq(r,ty,t)               "R&D expenditures -- calculated annually"
   pikeq(r,l,a,t)             "Knowledge influenced productivity factor"

   lambdafeq(r,l,a,t)         "Labor productivity factor"

   chisaveeq(t)               "Price of saving adjustment factor"
   psaveeq(r,t)               "Price of savings"
   eveq(r,h,t)                "Equivalent income at base year prices"
   evfeq(r,fdc,t)             "Expenditure function for other final demand"
   evseq(r,t)                 "Equivalent variation for savings"
   sweq(t)                    "Social welfare function--private consumption"
   swteq(t)                   "Social welfare function--private + public consumption"
   swt2eq(t)                  "Social welfare function--private + public consumption + savings"

   objeq                      "Objective function"
;

* --------------------------------------------------------------------------------------------------
*
*  PRODUCTION BLOCK
*
* --------------------------------------------------------------------------------------------------

Variable
   emiRebate(r,a,t)        "Rebated emission costs"
;

Equation
   emiRebateeq(r,a,t)      "Rebated emission costs"
;

set
   emiRebateFlag(r,a,t)    "Set to true to rebate emission costs"
   emiRebateExog(r,a,t)    "Rebatable emissions are exogenous"
;

Parameter
   chiRebate(r,em,i,a,t)   "Percentage of rebate wrt to emissions"
   emiRebateX(r,em,i,a,t)  "Rebated emissions of exogenous"
;

$macro m_EMIREBATE(r,em,i,a,t) \
   ((emi(r,em,i,a,t)*emi0(r,em,i,a))$(not emiRebateExog(r,a,t)) \
   + emiRebateX(r,em,i,a,t)$emiRebateExog(r,a,t))

emiRebateeq(r,a,t)$(ts(t) and rs(r) and emiRebateFlag(r,a,t))..
   emiRebate(r,a,t) =e= sum((em,i)$chiRebate(r,em,i,a,t),
      chiRebate(r,em,i,a,t)*emiTax(r,em,a,t)*m_EMIREBATE(r,em,i,a,t)) ;

*  Aggregate unit cost

pxeq(r,a,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   px(r,a,t)*xp(r,a,t) =e= ((pxv0(r,a)*xpv0(r,a))*sum(v, pxv(r,a,v,t)*xpv(r,a,v,t))
                        -   emiRebate(r,a,t))/(px0(r,a)*xp0(r,a)) ;

* px.lo(r,a,t) = 0.001 ;

*  Post-tax unit cost by vintage

pxveq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   pxv(r,a,v,t) =e= (uc0(r,a)/pxv0(r,a))*uc(r,a,v,t)*(1 + uctax(r,a,v,t)) ;

pxv.lo(r,a,v,t) = 0.001 ;

$ontext
   Top level nest -- CES of output (XPN) and non-CO2 GHG (XGHG)

   uc is the unit or marginal cost of production pre-tax
$offtext

*  Production by vintage excl. non-CO2 GHG

xpneq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   xpn(r,a,v,t) =e= alpha_xpn(r,a,v,t)*xpv(r,a,v,t)
                 *  ((((axghg(r,a,v,t)*lambdaxp(r,a,v,t))**(sigmaxp(r,a,v)-1))
                 *    ((uc(r,a,v,t)/pxn(r,a,v,t))**sigmaxp(r,a,v)))$(sigmaxp(r,a,v) ne 0)
                 +   ((1/(axghg(r,a,v,t)*lambdaxp(r,a,v,t))))$(sigmaxp(r,a,v) eq 0))
                 ;

*  'Demand' for non-CO2 GHG

xghgeq(r,a,v,t)$(ts(t) and rs(r) and ghgFlag(r,a))..

   xghg(r,a,v,t) =e= alpha_ghg(r,a,v,t)*xpv(r,a,v,t)
                 *  ((((axghg(r,a,v,t)*lambdaghg(r,a,v,t))**(sigmaxp(r,a,v)-1))
                 *   ((uc(r,a,v,t)/pxghg(r,a,v,t))**sigmaxp(r,a,v)))$(sigmaxp(r,a,v) ne 0)
                 +  ((1/(axghg(r,a,v,t)*lambdaghg(r,a,v,t))))$(sigmaxp(r,a,v) eq 0))
                 ;

*  Pre-tax unit cost by vintage

uceq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   axghg(r,a,v,t)*uc(r,a,v,t)
      =e= ((alpha_ghg(r,a,v,t)*shr0_ghg(r,a)*(pxghg(r,a,v,t)/lambdaghg(r,a,v,t))**(1-sigmaxp(r,a,v))
       +    alpha_xpn(r,a,v,t)*shr0_xpn(r,a)*(pxn(r,a,v,t)/lambdaxp(r,a,v,t))**(1-sigmaxp(r,a,v)))
       **(1/(1-sigmaxp(r,a,v))))
       $(sigmaxp(r,a,v) ne 0)
       + ((alpha_ghg(r,a,v,t)*shr0_ghg(r,a)*(pxghg(r,a,v,t)/lambdaghg(r,a,v,t))
       +    alpha_xpn(r,a,v,t)*shr0_xpn(r,a)*(pxn(r,a,v,t)/lambdaxp(r,a,v,t))))
       $(sigmaxp(r,a,v) eq 0)
       ;

uc.lo(r,a,v,t) = 0.001 ;

Equations
   procEmieq(r,ghg,a,t)
   pxghgeq(r,a,v,t)
;

Parameters
   shr0_procEmi(r,ghg,a)
   alpha_procEmi(r,ghg,a,v,t)
   lambdaprocEmi(r,ghg,a,v,t)
   sigmaProcEmi(r,a,v)
;

Variables
   procEmiTax(r,ghg,a,t)
;

Sets
   procEmiFlag(r,em,a)
;

procEmiTax.fx(r,ghg,a,t) = 0 ;

procEmieq(r,ghg,a,t)$(ts(t) and rs(r) and procEmiFlag(r,ghg,a))..
   procEmi(r,ghg,a,t)
      =e= sum(v, alpha_procEmi(r,ghg,a,v,t)*xghg(r,a,v,t)
       *         (lambdaprocEmi(r,ghg,a,v,t)**(sigmaProcEmi(r,a,v)-1))
       *         (pxghg(r,a,v,t)/((pnum(t)*pCarb(r,ghg,a,t) + procEmiTax(r,ghg,a,t)/pCarb0(r,ghg,a))))**sigmaProcEmi(r,a,v))
       ;

pxghgeq(r,a,v,t)$(ts(t) and rs(r) and ghgFlag(r,a))..
   pxghg(r,a,v,t) =e= (sum(ghg, alpha_procEmi(r,ghg,a,v,t)*shr0_procEmi(r,ghg,a)
                   *        ((pnum(t)*pCarb(r,ghg,a,t) + procEmiTax(r,ghg,a,t)/pCarb0(r,ghg,a))/lambdaprocEmi(r,ghg,a,v,t))
                   **(1 - sigmaProcEmi(r,a,v)))**(1/(1 - sigmaProcEmi(r,a,v))))
                   $(sigmaProcEmi(r,a,v))
                   + (sum(ghg, alpha_procEmi(r,ghg,a,v,t)*shr0_procEmi(r,ghg,a)
                   *        ((pnum(t)*pCarb(r,ghg,a,t) + procEmiTax(r,ghg,a,t)/pCarb0(r,ghg,a))/lambdaprocEmi(r,ghg,a,v,t))))
                   $(sigmaProcEmi(r,a,v) eq 0);

$ontext
   9-NOV-2020
   Optionally move NRS to top nest
$offtext

xpxeq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   xpx(r,a,v,t) =e= (xpn(r,a,v,t)
                 *  ((pxn(r,a,v,t)/pxp(r,a,v,t))$(sigmanrs(r,a,v) ne 0)
                 +   (1)$(sigmanrs(r,a,v) eq 0)))$ifNRSTop(r,a)
                 +  xpn(r,a,v,t)$(not ifNRSTop(r,a))
                 ;

pxneq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   pxn(r,a,v,t) =e= (((shr0_xpx(r,a)*pxp(r,a,v,t)**(1 - sigmanrs(r,a,v))
                 +    sum(nrs, shr0_nrs(r,a)*alpha_nrs(r,a,v,t)
                 *      (M_PFP(r,nrs,a,t)/lambdaf(r,nrs,a,t))**(1-sigmanrs(r,a,v))))
                 **  (1/(1 - sigmanrs(r,a,v))))
                 $(sigmanrs(r,a,v))
                 +   ((shr0_xpx(r,a)*pxp(r,a,v,t)
                 +    sum(nrs, shr0_nrs(r,a)*alpha_nrs(r,a,v,t)
                 *      (M_PFP(r,nrs,a,t)/lambdaf(r,nrs,a,t)))))
                 $(sigmanrs(r,a,v) eq 0))
                 $ifNRSTop(r,a)

                 +  (pxp(r,a,v,t))
                 $(not ifNRSTop(r,a))
                 ;

$ontext
   Second level nest -- CES of non-specific inputs (ND1) and all other inputs (VA)

   In crops:             ND1 excludes energy and fertilizers (that are part of VA)
   In livestock:         ND1 excludes energy and feed (that are part of VA)
   In all other sectors: ND1 excludes energy (that is part of VA)
$offtext

nd1eq(r,a,t)$(ts(t) and rs(r) and nd1Flag(r,a))..
   nd1(r,a,t) =e= sum(v, alpha_nd1(r,a,v,t)*xpx(r,a,v,t)
               *         ((dam_tfp(r,a,t)*tfp(r,a,v,t))**(sigmap(r,a,v) - 1))
               *         (((pxp(r,a,v,t)/pnd1(r,a,t))**sigmap(r,a,v))$(sigmap(r,a,v) ne 0)
               +          (1)$(sigmap(r,a,v) eq 0)))
               ;

vaeq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   va(r,a,v,t) =e= alpha_va(r,a,v,t)*xpx(r,a,v,t)
               *   ((dam_tfp(r,a,t)*tfp(r,a,v,t))**(sigmap(r,a,v) - 1))
                *    (((pxp(r,a,v,t)/pva(r,a,v,t))**sigmap(r,a,v))$(sigmap(r,a,v) ne 0)
                +     (1)$(sigmap(r,a,v) eq 0))
                ;

pxpeq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   pxp(r,a,v,t) =e= ((alpha_nd1(r,a,v,t)*shr0_nd1(r,a)
                 *   (pnd1(r,a,t)/(dam_tfp(r,a,t)*tfp(r,a,v,t)))**(1-sigmap(r,a,v))
                 +    alpha_va(r,a,v,t)*shr0_va(r,a)
                 *   (pva(r,a,v,t)/(dam_tfp(r,a,t)*tfp(r,a,v,t)))**(1-sigmap(r,a,v)))
                 **(1/(1-sigmap(r,a,v))))
                 $(sigmap(r,a,v) ne 0)
                 +  (alpha_nd1(r,a,v,t)*shr0_nd1(r,a)
                 *  (pnd1(r,a,t)/(dam_tfp(r,a,t)*tfp(r,a,v,t)))
                 +   alpha_va(r,a,v,t)*shr0_va(r,a)
                 *   (pva(r,a,v,t)/(dam_tfp(r,a,t)*tfp(r,a,v,t))))
                 $(sigmap(r,a,v) eq 0)
                 ;

pxp.lo(r,a,v,t) = 0.001 ;

$ontext
   Middle nests -- VA
      In crops: VA is CES aggregation of LAB1 and VA1
      In livestock: VA is CES aggregation of VA1 and VA2
      In all other sectors: VA is CES aggregation of LAB1 and VA1

   VA1
      In crops: VA1 is CES aggregation of ND2 (fertilizers) and VA2
      In livestock: VA1 is aggregation of LAB1 and KEF
      In all other sectors: VA1 is aggregation of land and KEF

   VA2
      In crops: VA2 is CES aggregation of land and KEF
      In livestock: VA2 is CES aggregation of land and ND2 (feed)
      In all other sectors: There is no VA2
$offtext

*  Demand for unskilled labor bundle

lab1eq(r,a,t)$(ts(t) and rs(r) and lab1Flag(r,a))..
   lab1(r,a,t)
      =e= (sum(v, alpha_lab1(r,a,v,t)*va(r,a,v,t)*(ftfp(r,a,v,t)**(sigmav(r,a,v) - 1))
       *    (((pva(r,a,v,t)/plab1(r,a,t))**sigmav(r,a,v))$(sigmav(r,a,v) ne 0)
       +     (1)$(sigmav(r,a,v) eq 0))))$acr(a)


       +  (sum(v, alpha_lab1(r,a,v,t)*va1(r,a,v,t)
       *    (((pva1(r,a,v,t)/plab1(r,a,t))**sigmav1(r,a,v))$(sigmav1(r,a,v) ne 0)
       +     (1)$(sigmav1(r,a,v) eq 0))))$alv(a)

       +  (sum(v, alpha_lab1(r,a,v,t)*va(r,a,v,t)*(ftfp(r,a,v,t)**(sigmav(r,a,v) - 1))
       *    (((pva(r,a,v,t)/plab1(r,a,t))**sigmav(r,a,v))$(sigmav(r,a,v) ne 0)
       +     (1)$(sigmav(r,a,v) eq 0))))$ax(a)

       ;

*  Demand for KEF bundle

KEFeq(r,a,v,t)$(ts(t) and rs(r) and kefFlag(r,a))..
   kef(r,a,v,t)
      =e= (alpha_kef(r,a,v,t)*va2(r,a,v,t)
       *    (((pva2(r,a,v,t)/pkef(r,a,v,t))**sigmav2(r,a,v))$(sigmav2(r,a,v) ne 0)
       +     (1)$(sigmav2(r,a,v) eq 0)))$acr(a)

       +  (alpha_kef(r,a,v,t)*va1(r,a,v,t)
       *    (((pva1(r,a,v,t)/pkef(r,a,v,t))**sigmav1(r,a,v))$(sigmav1(r,a,v) ne 0)
       +     (1)$(sigmav1(r,a,v) eq 0)))$alv(a)

       +  (alpha_kef(r,a,v,t)*va1(r,a,v,t)
       *    (((pva1(r,a,v,t)/pkef(r,a,v,t))**sigmav1(r,a,v))$(sigmav1(r,a,v) ne 0)
       +     (1)$(sigmav1(r,a,v) eq 0)))$ax(a)
       ;

*  Demand for ND2 bundle (does not exist for other activities)

nd2eq(r,a,t)$(ts(t) and rs(r) and nd2Flag(r,a))..
   nd2(r,a,t)
      =e= (sum(v, alpha_nd1(r,a,v,t)*va1(r,a,v,t)
       *    (((pva1(r,a,v,t)/pnd2(r,a,t))**sigmav1(r,a,v))$(sigmav1(r,a,v) ne 0)
       +     (1)$(sigmav1(r,a,v) eq 0))))$acr(a)

       +  (sum(v, alpha_nd1(r,a,v,t)*va2(r,a,v,t)
       *    (((pva2(r,a,v,t)/pnd2(r,a,t))**sigmav2(r,a,v))$(sigmav2(r,a,v) ne 0)
       +     (1)$(sigmav2(r,a,v) eq 0))))$alv(a)
       ;

*  Demand for VA1 bundle

va1eq(r,a,v,t)$(ts(t) and rs(r) and va1Flag(r,a))..
   va1(r,a,v,t)
     =e= (alpha_va1(r,a,v,t)*va(r,a,v,t)*(ftfp(r,a,v,t)**(sigmav(r,a,v) - 1))
      *     (((pva(r,a,v,t)/pva1(r,a,v,t))**sigmav(r,a,v))$(sigmav(r,a,v) ne 0)
      +      (1)$(sigmav(r,a,v) eq 0)))$acr(a)

      +  (alpha_va1(r,a,v,t)*va(r,a,v,t)*(ftfp(r,a,v,t)**(sigmav(r,a,v) - 1))
      *     (((pva(r,a,v,t)/pva1(r,a,v,t))**sigmav(r,a,v))$(sigmav(r,a,v) ne 0)
      +      (1)$(sigmav(r,a,v) eq 0)))$alv(a)

      +  (alpha_va1(r,a,v,t)*va(r,a,v,t)*(ftfp(r,a,v,t)**(sigmav(r,a,v) - 1))
      *     (((pva(r,a,v,t)/pva1(r,a,v,t))**sigmav(r,a,v))$(sigmav(r,a,v) ne 0)
      +      (1)$(sigmav(r,a,v) eq 0)))$ax(a)
      ;

*  Demand for VA2 bundle (does not exist for other activities)

va2eq(r,a,v,t)$(ts(t) and rs(r) and va2Flag(r,a))..
   va2(r,a,v,t)
      =e= (alpha_va2(r,a,v,t)*va1(r,a,v,t)
       *    (((pva1(r,a,v,t)/pva2(r,a,v,t))**sigmav1(r,a,v))$(sigmav1(r,a,v) ne 0)
       +     (1)$(sigmav1(r,a,v) eq 0)))$acr(a)

       +   (alpha_va2(r,a,v,t)*va(r,a,v,t)*(ftfp(r,a,v,t)**(sigmav(r,a,v) - 1))
       *    (((pva(r,a,v,t)/pva2(r,a,v,t))**sigmav(r,a,v))$(sigmav(r,a,v) ne 0)
       +     (1)$(sigmav(r,a,v) eq 0)))$alv(a)
       ;

*  Modified:
*  20-APR-2022
*  DvdM
*  Introduced a land bundle to take into account AEZ's

*  Demand for the land bundle

landdeq(r,a,t)$(ts(t) and rs(r) and landdFlag(r,a))..
   landd(r,a,t)
      =e= (sum(v, alpha_land(r,a,v,t)*va2(r,a,v,t)
       *    (pva2(r,a,v,t)/plandd(r,a,t))**sigmav2(r,a,v)))
       $(acr(a) or alv(a))

       +  (sum(v, alpha_land(r,a,v,t)*va1(r,a,v,t)
       *    (pva1(r,a,v,t)/plandd(r,a,t))**sigmav1(r,a,v)))
       $ax(a)
       ;

*  Disaggregate land bundle by land type (w/ or w/o ACES)

lndeq(r,lnd,a,t)$(ts(t) and rs(r) and xfFlag(r,lnd,a))..
   xf(r,lnd,a,t)
      =e= alpha_lnd(r,lnd,a,t)*landd(r,a,t)
       *    (((lambdaf(r,lnd,a,t)**(sigmalnd(r,a)-1))$ifLandCET
       +      (lambdaf(r,lnd,a,t)**(-sigmalnd(r,a)))$(not ifLandCET))
       *       (((plandd(r,a,t)$ifLandCET + planddNDX(r,a,t)$(not ifLandCET))
       /       M_PFP(r,lnd,a,t))**sigmalnd(r,a)))$(sigmalnd(r,a) ne 0)
       +    ((1/lambdaf(r,lnd,a,t)))$(sigmalnd(r,a) eq 0) ;

*  Aggregate land price

planddeq(r,a,t)$(ts(t) and rs(r) and landdFlag(r,a))..
   0 =e= (plandd(r,a,t) - (sum(lnd, alpha_lnd(r,lnd,a,t)*shr0_lnd(r,lnd,a)
      *     (M_PFP(r,lnd,a,t)/lambdaf(r,lnd,a,t))**(1-sigmalnd(r,a))))**(1/(1-sigmalnd(r,a))))
      $(ifLandCET and sigmalnd(r,a))

      +  (plandd(r,a,t) - sum(lnd, alpha_lnd(r,lnd,a,t)*shr0_lnd(r,lnd,a)
      *     (M_PFP(r,lnd,a,t)/lambdaf(r,lnd,a,t))))
      $(ifLandCET and sigmalnd(r,a) eq 0)

      + (plandd(r,a,t)*landd(r,a,t) - sum(lnd, shr0_lnd(r,lnd,a)*M_PFP(r,lnd,a,t)*xf(r,lnd,a,t)))
      $(not ifLandCET)
      ;

*  Land price index (for ACES)

planddNDXeq(r,a,t)$(ts(t) and rs(r) and landdFlag(r,a) and (not ifLandCET))..
   planddNDX(r,a,t) =e= sum(lnd, alpha_lnd(r,lnd,a,t)*shrx0_lnd(r,lnd,a)
                     *     (M_PFP(r,lnd,a,t)*lambdaf(r,lnd,a,t))**(-sigmalnd(r,a)))**(-1/sigmalnd(r,a)) ;

*  BUNDLE PRICES

*  Price of top-level value added bundle (VA)

pvaeq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   pva(r,a,v,t)
      =e= (((alpha_lab1(r,a,v,t)*shr0_lab1(r,a)*(plab1(r,a,t)/ftfp(r,a,v,t))**(1-sigmav(r,a,v))
       +     alpha_va1(r,a,v,t)*shr0_va1(r,a)*(pva1(r,a,v,t)/ftfp(r,a,v,t))**(1-sigmav(r,a,v)))
       **(1/(1-sigmav(r,a,v))))
       $(sigmav(r,a,v) ne 0)
       +   (alpha_lab1(r,a,v,t)*shr0_lab1(r,a)*(plab1(r,a,t)/ftfp(r,a,v,t))
       +    alpha_va1(r,a,v,t)*shr0_va1(r,a)*(pva1(r,a,v,t))/ftfp(r,a,v,t))
       $(sigmav(r,a,v) eq 0))
       $(acr(a) or ax(a))

       +  (((alpha_va2(r,a,v,t)*shr0_va2(r,a)*(pva2(r,a,v,t)/ftfp(r,a,v,t))**(1-sigmav(r,a,v))
       +     alpha_va1(r,a,v,t)*shr0_va1(r,a)*(pva1(r,a,v,t)/ftfp(r,a,v,t))**(1-sigmav(r,a,v)))
       **(1/(1-sigmav(r,a,v))))
       $(sigmav(r,a,v) ne 0)
       +   (alpha_va2(r,a,v,t)*shr0_va2(r,a)*(pva2(r,a,v,t)/ftfp(r,a,v,t))
       +    alpha_va1(r,a,v,t)*shr0_va1(r,a)*(pva1(r,a,v,t)/ftfp(r,a,v,t)))
       $(sigmav(r,a,v) eq 0))
       $alv(a)
       ;

pva.lo(r,a,v,t) = 0.001 ;

*  Price of mid-level value added bundle (VA1)

pva1eq(r,a,v,t)$(ts(t) and rs(r) and va1Flag(r,a))..
   pva1(r,a,v,t)
      =e= (((alpha_nd2(r,a,v,t)*shr0_nd2(r,a)*pnd2(r,a,t)**(1-sigmav1(r,a,v))
       +     alpha_va2(r,a,v,t)*shr0_va2(r,a)*pva2(r,a,v,t)**(1-sigmav1(r,a,v)))
       **(1/(1-sigmav1(r,a,v))))$(sigmav1(r,a,v) ne 0)
       +  (alpha_nd2(r,a,v,t)*shr0_nd2(r,a)*pnd2(r,a,t)
       +   alpha_va2(r,a,v,t)*shr0_va2(r,a)*pva2(r,a,v,t))$(sigmav1(r,a,v) eq 0))
       $acr(a)

       + (((alpha_lab1(r,a,v,t)*shr0_lab1(r,a)*plab1(r,a,t)**(1-sigmav1(r,a,v))
       +    alpha_kef(r,a,v,t)*shr0_kef(r,a)*pkef(r,a,v,t)**(1-sigmav1(r,a,v)))
       **(1/(1-sigmav1(r,a,v))))$(sigmav1(r,a,v) ne 0)
       +  (alpha_lab1(r,a,v,t)*shr0_lab1(r,a)*plab1(r,a,t)
       +   alpha_kef(r,a,v,t)*shr0_kef(r,a)*pkef(r,a,v,t))$(sigmav1(r,a,v) eq 0))
       $alv(a)


       + (((alpha_land(r,a,v,t)*shr0_land(r,a)*plandd(r,a,t)**(1-sigmav1(r,a,v))
       +    alpha_kef(r,a,v,t)*shr0_kef(r,a)*pkef(r,a,v,t)**(1-sigmav1(r,a,v)))
       **(1/(1-sigmav1(r,a,v))))$(sigmav1(r,a,v) ne 0)
       +  (alpha_land(r,a,v,t)*shr0_land(r,a)*plandd(r,a,t)
       +   alpha_kef(r,a,v,t)*shr0_kef(r,a)*pkef(r,a,v,t))$(sigmav1(r,a,v) eq 0))
       $ax(a)
       ;

pva1.lo(r,a,v,t) = 0.001 ;

*  Price of mid-level value added bundle (VA2)

pva2eq(r,a,v,t)$(ts(t) and rs(r) and va2Flag(r,a))..
   pva2(r,a,v,t)
      =e= (((alpha_land(r,a,v,t)*shr0_land(r,a)*plandd(r,a,t)**(1-sigmav2(r,a,v))
       +     alpha_kef(r,a,v,t)*shr0_kef(r,a)*pkef(r,a,v,t)**(1-sigmav2(r,a,v)))
       **(1/(1-sigmav2(r,a,v))))$(sigmav2(r,a,v) ne 0)
       +   (alpha_land(r,a,v,t)*shr0_land(r,a)*plandd(r,a,t)
       +    alpha_kef(r,a,v,t)*shr0_kef(r,a)*pkef(r,a,v,t))$(sigmav2(r,a,v) eq 0))
       $acr(a)

       + (((alpha_land(r,a,v,t)*shr0_land(r,a)*plandd(r,a,t)**(1-sigmav2(r,a,v))
       +    alpha_nd2(r,a,v,t)*shr0_nd2(r,a)*pnd2(r,a,t)**(1-sigmav2(r,a,v)))
       **(1/(1-sigmav2(r,a,v))))$(sigmav2(r,a,v) ne 0)
       +  (alpha_land(r,a,v,t)*shr0_land(r,a)*plandd(r,a,t)
       +   alpha_nd2(r,a,v,t)*shr0_nd2(r,a)*pnd2(r,a,t))$(sigmav2(r,a,v) eq 0))
       $alv(a)
       ;

pva2.lo(r,a,v,t) = 0.001 ;

*  KEF disaggregation

kfeq(r,a,v,t)$(ts(t) and rs(r) and kfFlag(r,a))..
   kf(r,a,v,t)
      =e= alpha_kf(r,a,v,t)*kef(r,a,v,t)
       *    (((pkef(r,a,v,t)/pkf(r,a,v,t))**sigmakef(r,a,v))$(sigmakef(r,a,v) ne 0)
       +     (1)$(sigmakef(r,a,v) eq 0))
       ;

xnrgeq(r,a,v,t)$(ts(t) and rs(r) and xnrgFlag(r,a))..
   xnrg(r,a,v,t)
      =e= alpha_nrg(r,a,v,t)*kef(r,a,v,t)
       *    (lambdanrgp(r,a,v,t)**(sigmakef(r,a,v)-1))
       *    (((pkef(r,a,v,t)/pnrg(r,a,v,t))**sigmakef(r,a,v))$(sigmakef(r,a,v) ne 0)
       +     (1)$(sigmakef(r,a,v) eq 0))
       ;

pkefeq(r,a,v,t)$(ts(t) and rs(r) and kefFlag(r,a))..
   pkef(r,a,v,t)
      =e= ((alpha_kf(r,a,v,t)*shr0_kf(r,a)*pkf(r,a,v,t)**(1-sigmakef(r,a,v))
       +    alpha_nrg(r,a,v,t)*shr0_nrg(r,a)
       *       (pnrg(r,a,v,t)/lambdanrgp(r,a,v,t))**(1-sigmakef(r,a,v)))
       **(1/(1-sigmakef(r,a,v))))
       $(sigmakef(r,a,v) ne 0)

       +  (alpha_kf(r,a,v,t)*shr0_kf(r,a)*pkf(r,a,v,t)
       +   alpha_nrg(r,a,v,t)*shr0_nrg(r,a)*(pnrg(r,a,v,t)/lambdanrgp(r,a,v,t)))
       $(sigmakef(r,a,v) eq 0)
       ;

pkef.lo(r,a,v,t) = 0.001 ;

*  KF disaggregation

ksweq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a))..
   ksw(r,a,v,t)
      =e= (alpha_ksw(r,a,v,t)*kf(r,a,v,t)
       *    (((pkf(r,a,v,t)/pksw(r,a,v,t))**sigmakf(r,a,v))$(sigmakf(r,a,v) ne 0)
       +     (1)$(sigmakf(r,a,v) eq 0)))$(not ifNRSTop(r,a))
       +  (kf(r,a,v,t))$ifNRSTop(r,a)
       ;

xnrseq(r,nrs,a,t)$(ts(t) and rs(r) and xfFlag(r,nrs,a))..
   xf(r,nrs,a,t)
      =e= (sum(v, alpha_nrs(r,a,v,t)*kf(r,a,v,t)
       *    (((lambdaf(r,nrs,a,t)**(sigmakf(r,a,v)-1))
       *      (pkf(r,a,v,t)/M_PFP(r,nrs,a,t))**sigmakf(r,a,v))$(sigmakf(r,a,v) ne 0)
       +     ((1/lambdaf(r,nrs,a,t)))$(sigmakf(r,a,v) eq 0))))
       $(not ifNRSTop(r,a))
       +  (sum(v, alpha_nrs(r,a,v,t)*xpn(r,a,v,t)
       *    (((lambdaf(r,nrs,a,t)**(sigmaNRS(r,a,v)-1))
       *      (pxn(r,a,v,t)/M_PFP(r,nrs,a,t))**sigmaNRS(r,a,v))$(sigmaNRS(r,a,v) ne 0)
       +     ((1/lambdaf(r,nrs,a,t)))$(sigmaNRS(r,a,v) eq 0))))
       $ifNRSTop(r,a)
       ;

pkfeq(r,a,v,t)$(ts(t) and rs(r) and kfFlag(r,a))..
   pkf(r,a,v,t)
      =e= (((alpha_ksw(r,a,v,t)*shr0_ksw(r,a)*pksw(r,a,v,t)**(1-sigmakf(r,a,v))
       +   sum(nrs, alpha_nrs(r,a,v,t)*shr0_nrs(r,a)*(M_PFP(r,nrs,a,t)/lambdaf(r,nrs,a,t))
       **     (1-sigmakf(r,a,v))))**(1/(1-sigmakf(r,a,v))))
       $(sigmakf(r,a,v) ne 0)

       +  (alpha_ksw(r,a,v,t)*shr0_ksw(r,a)*pksw(r,a,v,t)
       +   sum(nrs, alpha_nrs(r,a,v,t)*shr0_nrs(r,a)*M_PFP(r,nrs,a,t)/lambdaf(r,nrs,a,t)))
       $(sigmakf(r,a,v) eq 0))$(not ifNRSTop(r,a))

       + (pksw(r,a,v,t))$ifNRSTop(r,a)
       ;

pkf.lo(r,a,v,t) = 0.001 ;

*  KSW disaggregation

kseq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a))..
   ks(r,a,v,t)
      =e= alpha_ks(r,a,v,t)*ksw(r,a,v,t)
       *    (((pksw(r,a,v,t)/pks(r,a,v,t))**sigmakw(r,a,v))$(sigmakw(r,a,v) ne 0)
       +     (1)$(sigmakw(r,a,v) eq 0))
       ;

xwateq(r,a,t)$(ts(t) and rs(r) and watFlag(r,a))..
   xwat(r,a,t)
      =e= sum(v, alpha_wat(r,a,v,t)*ksw(r,a,v,t)
       *          (((pksw(r,a,v,t)/pwat(r,a,t))**sigmakw(r,a,v))$(sigmakw(r,a,v) ne 0)
       +           (1)$(sigmakw(r,a,v) eq 0))) ;

pksweq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a))..
   pksw(r,a,v,t)
      =e= ((alpha_ks(r,a,v,t)*shr0_ks(r,a)*pks(r,a,v,t)**(1-sigmakw(r,a,v))
       +    alpha_wat(r,a,v,t)*shr0_wat(r,a)*pwat(r,a,t)**(1-sigmakw(r,a,v)))
       **(1/(1-sigmakw(r,a,v))))$(sigmakw(r,a,v) ne 0)

       +  (alpha_ks(r,a,v,t)*shr0_ks(r,a)*pks(r,a,v,t)
       +   alpha_wat(r,a,v,t)*shr0_wat(r,a)*pwat(r,a,t))$(sigmakw(r,a,v) eq 0)
       ;

pksw.lo(r,a,v,t) = 0.001 ;

*  Demand for the water factor

h2oeq(r,wat,a,t)$(ts(t) and rs(r) and xfFlag(r,wat,a))..
   xf(r,wat,a,t)
      =e= xwat(r,a,t)
       *  (((lambdaf(r,wat,a,t)**(sigmawat(r,a)-1))
       *    (pwat(r,a,t)/M_PFP(r,wat,a,t))**sigmawat(r,a))$(sigmawat(r,a) ne 0)
       +   (1/lambdaf(r,wat,a,t))$(sigmawat(r,a) eq 0))
       ;

*  KS disaggregation

kveq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a))..
   capu(r,a,v,t)*kv(r,a,v,t)
               =e= alpha_k(r,a,v,t)*ks(r,a,v,t)
                *    (((lambdak(r,a,v,t)**(sigmak(r,a,v)-1))
                *      (pks(r,a,v,t)/pkp(r,a,v,t))**sigmak(r,a,v))$(sigmak(r,a,v) ne 0)
                +     (1/lambdak(r,a,v,t))$(sigmak(r,a,v) eq 0))
                ;

kv.lo(r,a,v,t) = 0 ;

lab2eq(r,a,t)$(ts(t) and rs(r) and lab2Flag(r,a))..
   lab2(r,a,t)
      =e= sum(v, alpha_lab2(r,a,v,t)*ks(r,a,v,t)
       *          (((pks(r,a,v,t)/plab2(r,a,t))**sigmak(r,a,v))$(sigmak(r,a,v) ne 0)
       +           (1)$(sigmak(r,a,v) eq 0)))
       ;

pkseq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a))..
   pks(r,a,v,t) =e= ((alpha_k(r,a,v,t)*shr0_k(r,a)
                 *      (pkp(r,a,v,t)/lambdak(r,a,v,t))**(1-sigmak(r,a,v))
                 +    alpha_lab2(r,a,v,t)*shr0_lab2(r,a)
                 *      plab2(r,a,t)**(1-sigmak(r,a,v)))
                 **(1/(1-sigmak(r,a,v))))$(sigmak(r,a,v) ne 0)

                 +  ((alpha_k(r,a,v,t)*shr0_k(r,a)*pkp(r,a,v,t)/lambdak(r,a,v,t)
                 +    alpha_lab2(r,a,v,t)*shr0_lab2(r,a)*plab2(r,a,t)))$(sigmak(r,a,v) eq 0)
                 ;

pks.lo(r,a,v,t) = 0.001 ;

*  Top level labor disaggregation

labbeq(r,wb,a,t)$(ts(t) and rs(r) and labbFlag(r,wb,a))..
   labb(r,wb,a,t) =e= ((lab1(r,a,t)*(plab1(r,a,t)/plabb(r,wb,a,t))**sigmal1(r,a))
                   $(sigmal1(r,a) ne 0)
                   +   (lab1(r,a,t))
                   $(sigmal1(r,a) eq 0))
                   $maplab1(wb)

                   +  ((lab2(r,a,t)*(plab2(r,a,t)/plabb(r,wb,a,t))**sigmal2(r,a))
                   $(sigmal2(r,a) ne 0)
                   +   (lab2(r,a,t))
                   $(sigmal2(r,a) eq 0))
                   $(not maplab1(wb))
                   ;

plab1eq(r,a,t)$(ts(t) and rs(r) and lab1Flag(r,a))..
   plab1(r,a,t) =e= ((sum(wb$maplab1(wb), shr0_labb(r,wb,a,t)
                 *      plabb(r,wb,a,t)**(1-sigmal1(r,a))))**(1/(1-sigmal1(r,a))))
                 $(sigmal1(r,a) ne 0)

                 +  (sum(wb$maplab1(wb), shr0_labb(r,wb,a,t) * plabb(r,wb,a,t)))
                 $(sigmal1(r,a) eq 0)
                 ;

plab2eq(r,a,t)$(ts(t) and rs(r) and lab2Flag(r,a))..
   plab2(r,a,t) =e= ((sum(wb$(not maplab1(wb)), shr0_labb(r,wb,a,t)
                 *      plabb(r,wb,a,t)**(1-sigmal2(r,a))))**(1/(1-sigmal2(r,a))))
                 $(sigmal2(r,a) ne 0)

                 +  (sum(wb$(not maplab1(wb)), shr0_labb(r,wb,a,t) * plabb(r,wb,a,t)))
                 $(sigmal2(r,a) eq 0)
                 ;

plab1.lo(r,a,t) = 0.001 ;
plab2.lo(r,a,t) = 0.001 ;

*  Demand for labor by type l

ldeq(r,l,a,t)$(ts(t) and rs(r) and xfFlag(r,l,a))..
   xf(r,l,a,t)
      =e= sum(mapl(wb,l), (labb(r,wb,a,t)*(lambdaf(r,l,a,t)**(sigmal(r,wb,a)-1))
       *    (plabb(r,wb,a,t)/M_PFP(r,l,a,t))**sigmal(r,wb,a))
       $(sigmal(r,wb,a) ne 0)

       +   (labb(r,wb,a,t)/lambdaf(r,l,a,t))
       $(sigmal(r,wb,a) eq 0))
       ;

plabbeq(r,wb,a,t)$(ts(t) and rs(r) and labbFlag(r,wb,a))..
$ontext
   plabb(r,wb,a,t) =e= ((sum(mapl(wb,l), shr0_f(r,l,a,t)
                    *      (M_PFP(r,l,a,t)/lambdaf(r,l,a,t))**(1-sigmal(r,wb,a))))
                    **(1/(1-sigmal(r,wb,a))))
                    $(sigmal(r,wb,a) ne 0)

                    +  (sum(mapl(wb,l), shr0_f(r,l,a,t)*(M_PFP(r,l,a,t)/lambdaf(r,l,a,t))))
                    $(sigmal(r,wb,a) eq 0)
$offtext
   0 =e= (plabb(r,wb,a,t) - sum(mapl(wb,l), shr0_f(r,l,a,t)
                    * (M_PFP(r,l,a,t)/lambdaf(r,l,a,t))**(1-sigmal(r,wb,a)))**(1/(1-sigmal(r,wb,a))))
      $(sigmal(r,wb,a) ne 0)

      +  (plabb(r,wb,a,t) - sum(mapl(wb,l), shr0_f(r,l,a,t)*(M_PFP(r,l,a,t)/lambdaf(r,l,a,t))))
      $(sigmal(r,wb,a) eq 0)
      ;

plabb.lo(r,wb,a,t) = 0.001 ;

*  ND1 & ND2 disaggregation

xapeq(r,i,a,t)$(ts(t) and rs(r) and xaFlag(r,i,a) and (mapnd1(i,a) or mapnd2(i,a) or iw(i)))..
   xa(r,i,a,t) =e= ((alpha_io(r,i,a,t)*(lambdaio(r,i,a,t)**(sigman1(r,a)-1))
                *    nd1(r,a,t)*(pnd1(r,a,t)/M_PA(r,i,a,t))**sigman1(r,a))
                $(sigman1(r,a) ne 0)
                +   (alpha_io(r,i,a,t)*nd1(r,a,t)/lambdaio(r,i,a,t))
                $(sigman1(r,a) eq 0))
                $mapnd1(i,a)

                +  ((alpha_io(r,i,a,t)*(lambdaio(r,i,a,t)**(sigman2(r,a)-1))
                *    alpha_io(r,i,a,t)*nd2(r,a,t)*(pnd2(r,a,t)/M_PA(r,i,a,t))**sigman2(r,a))
                $(sigman2(r,a) ne 0)
                +   (nd2(r,a,t)/lambdaio(r,i,a,t))
                $(sigman2(r,a) eq 0))
                $mapnd2(i,a)

                +  ((alpha_io(r,i,a,t)*(lambdaio(r,i,a,t)**(sigmawat(r,a)-1))
                *    xwat(r,a,t)*(pwat(r,a,t)/M_PA(r,i,a,t))**sigmawat(r,a))$(sigmawat(r,a) ne 0)
                +   (alpha_io(r,i,a,t)*xwat(r,a,t)/lambdaio(r,i,a,t))$(sigmawat(r,a) eq 0))
                $iw(i)
                ;

pnd1eq(r,a,t)$(ts(t) and rs(r) and nd1Flag(r,a))..
   pnd1(r,a,t) =e= ((sum(i$mapnd1(i,a), alpha_io(r,i,a,t)*shr0_io(r,i,a,t)
                *     (M_PA(r,i,a,t)/lambdaio(r,i,a,t))**(1-sigman1(r,a))))**(1/(1-sigman1(r,a))))
                $(sigman1(r,a) ne 0)

                +  (sum(i$mapnd1(i,a), alpha_io(r,i,a,t)*shr0_io(r,i,a,t)
                *    (M_PA(r,i,a,t)/lambdaio(r,i,a,t))))
                $(sigman1(r,a) eq 0)
                ;

pnd2eq(r,a,t)$(ts(t) and rs(r) and nd2Flag(r,a))..
   pnd2(r,a,t) =e= ((sum(i$mapnd2(i,a), alpha_io(r,i,a,t)*shr0_io(r,i,a,t)
                *     (M_PA(r,i,a,t)/lambdaio(r,i,a,t))**(1-sigman2(r,a))))**(1/(1-sigman2(r,a))))
                $(sigman2(r,a) ne 0)

                +  (sum(i$mapnd2(i,a), alpha_io(r,i,a,t)*shr0_io(r,i,a,t)
                *    (M_PA(r,i,a,t)/lambdaio(r,i,a,t))))
                $(sigman2(r,a) eq 0)
                ;

pwateq(r,a,t)$(ts(t) and rs(r) and watFlag(r,a))..
   pwat(r,a,t)
      =e= ((sum(i$iw(i), alpha_io(r,i,a,t)*shr0_io(r,i,a,t)
       *    (M_PA(r,i,a,t)/lambdaio(r,i,a,t))**(1-sigmawat(r,a)))
       +    sum(wat, shr0_f(r,wat,a,t)*(M_PFP(r,wat,a,t)/lambdaf(r,wat,a,t))**(1-sigmawat(r,a))))
       **(1/(1-sigmawat(r,a))))
       $(sigmawat(r,a) ne 0)

       +  (sum(i$iw(i), alpha_io(r,i,a,t)*shr0_io(r,i,a,t)*M_PA(r,i,a,t)/lambdaio(r,i,a,t))
       +   sum(wat, shr0_f(r,wat,a,t)*M_PFP(r,wat,a,t)/lambdaf(r,wat,a,t)))
       $(sigmawat(r,a) eq 0)
      ;

pnd1.lo(r,a,t) = 0.001 ;
pnd2.lo(r,a,t) = 0.001 ;
pwat.lo(r,a,t) = 0.001 ;

*  NRG bundle disaggregation -- single and multiple nests

xnelyeq(r,a,v,t)$(ts(t) and rs(r) and xnelyFlag(r,a) and ifNRGNest)..
   xnely(r,a,v,t)
      =e= alpha_nely(r,a,v,t)*xnrg(r,a,v,t)
       *    (((pnrgNDX(r,a,v,t)/pnely(r,a,v,t))**sigmae(r,a,v))$(sigmae(r,a,v) ne 0 and ifNRGACES)
       +     ((pnrg(r,a,v,t)/pnely(r,a,v,t))**sigmae(r,a,v))$(sigmae(r,a,v) ne 0 and not ifNRGACES)
       +     (1)$(sigmae(r,a,v) eq 0))
       ;

xolgeq(r,a,v,t)$(ts(t) and rs(r) and xolgFlag(r,a) and ifNRGNest)..
   xolg(r,a,v,t)
      =e= alpha_olg(r,a,v,t)*xnely(r,a,v,t)
       *    (((pnelyNDX(r,a,v,t)/polg(r,a,v,t))**sigmanely(r,a,v))
       $(sigmanely(r,a,v) ne 0 and ifNRGACES)
       +     ((pnely(r,a,v,t)/polg(r,a,v,t))**sigmanely(r,a,v))
       $(sigmanely(r,a,v) ne 0 and not ifNRGACES)
       +     (1)$(sigmanely(r,a,v) eq 0))
       ;

xaNRGeq(r,a,NRG,v,t)$(ts(t) and rs(r) and xaNRGFlag(r,a,NRG) and ifNRGNest)..
   xaNRG(r,a,NRG,v,t)
       =e= (alpha_NRGB(r,a,NRG,v,t)*xnrg(r,a,v,t)
        *      (((pnrgNDX(r,a,v,t)/paNRG(r,a,NRG,v,t))**sigmae(r,a,v))
        $(sigmae(r,a,v) ne 0 and ifNRGACES)
        +       ((pnrg(r,a,v,t)/paNRG(r,a,NRG,v,t))**sigmae(r,a,v))
        $(sigmae(r,a,v) ne 0 and not ifNRGACES)
        +       (1)$(sigmae(r,a,v) eq 0)))
        $ely(nrg)

        +  (alpha_NRGB(r,a,NRG,v,t)*xnely(r,a,v,t)
        *      (((pnelyNDX(r,a,v,t)/paNRG(r,a,NRG,v,t))**sigmanely(r,a,v))
        $(sigmanely(r,a,v) ne 0 and ifNRGACES)
        +       ((pnely(r,a,v,t)/paNRG(r,a,NRG,v,t))**sigmanely(r,a,v))
        $(sigmanely(r,a,v) ne 0 and not ifNRGACES)
        +       (1)$(sigmanely(r,a,v) eq 0)))
        $coa(nrg)

        +  (alpha_NRGB(r,a,NRG,v,t)*xolg(r,a,v,t)
        *      (((polgNDX(r,a,v,t)/paNRG(r,a,NRG,v,t))**sigmaolg(r,a,v))
        $(sigmaolg(r,a,v) ne 0 and ifNRGACES)
        +       ((polg(r,a,v,t)/paNRG(r,a,NRG,v,t))**sigmaolg(r,a,v))
        $(sigmaolg(r,a,v) ne 0 and not ifNRGACES)
        +       (1)$(sigmaolg(r,a,v) eq 0)))
        $(oil(nrg) or gas(nrg))

        ;

*  Macro for XA demand by vintage with a single-level energy nest

$macro m_XAVACESSN(r,e,a,v,t) \
      (alpha_eio(r,e,a,v,t)*xnrg(r,a,v,t) \
   *    (((pnrgNDX(r,a,v,t)/(lambdae(r,e,a,v,t)*M_PA(r,e,a,t)))**sigmae(r,a,v)) \
   $(sigmae(r,a,v) ne 0) \
   +     (1)$(sigmae(r,a,v) eq 0)))

*  Macro for XA demand by vintage with nested energy

$macro m_XAVACESMN(r,e,a,v,t) \
      (alpha_eio(r,e,a,v,t)*xaNRG(r,a,NRG,v,t) \
   *    (((paNRGNDX(r,a,NRG,v,t)/(lambdae(r,e,a,v,t)*M_PA(r,e,a,t)))**sigmaNRG(r,a,NRG,v))\
   $(sigmaNRG(r,a,NRG,v) ne 0) \
   +     (1)$(sigmaNRG(r,a,NRG,v) eq 0)))

xaeeq(r,e,a,t)$(ts(t) and rs(r) and xaFlag(r,e,a))..
   xa(r,e,a,t) =e=

*  Single nest with normal CES (XA = CES(XNRG))

                   (sum(v, alpha_eio(r,e,a,v,t)*xnrg(r,a,v,t)
                *    (((lambdae(r,e,a,v,t)**(sigmae(r,a,v)-1))
                *       (pnrg(r,a,v,t)/M_PA(r,e,a,t))**sigmae(r,a,v))$(sigmae(r,a,v) ne 0)
                +     (1/lambdae(r,e,a,v,t))$(sigmae(r,a,v) eq 0))))
                $(not ifNRGNest and not ifNRGACES)

*  Single nest with ACES (XA = ACES(XNRG))

                +  (sum(v, m_XAVACESSN(r,e,a,v,t)))
                $(not ifNRGNest and ifNRGACES)

*  Bottom nest with normal CES (XA = CES(xaNRG))

                +  (sum(v, sum(NRG$mape(NRG,e), alpha_eio(r,e,a,v,t)*xaNRG(r,a,NRG,v,t)
                *    (((lambdae(r,e,a,v,t)**(sigmaNRG(r,a,NRG,v)-1))
                *       (paNRG(r,a,NRG,v,t)/M_PA(r,e,a,t))**sigmaNRG(r,a,NRG,v))
                $(sigmaNRG(r,a,NRG,v) ne 0)
                +     (1/lambdae(r,e,a,v,t))
                $(sigmaNRG(r,a,NRG,v) eq 0)))))
                $(ifNRGNest and not ifNRGACES)

*  Bottom nest with ACES (XA = ACES(xaNRG))

                +  (sum(v, sum(NRG$mape(NRG,e), m_XAVACESMN(r,e,a,v,t))))
                $(ifNRGNest and ifNRGACES)
                ;

*  Composite price of energy bundles

paNRGNDXeq(r,a,NRG,v,t)$(ts(t) and rs(r) and xaNRGFlag(r,a,NRG) and ifNRGACES
      and ifNRGNest and sigmaNRG(r,a,NRG,v))..

   paNRGNDX(r,a,NRG,v,t) =e= sum(e$mape(NRG,e), alpha_eio(r,e,a,v,t)*shrx0_eio(r,e,a)
         * (lambdae(r,e,a,v,t)*M_PA(r,e,a,t))**(-sigmaNRG(r,a,NRG,v)))**(-1/sigmaNRG(r,a,NRG,v)) ;

*  Price of energy bundles

paNRGeq(r,a,NRG,v,t)$(ts(t) and rs(r) and xaNRGFlag(r,a,NRG) and ifNRGNest)..
  0 =e=

*  Normal CES with sigma <> 0, PANRG = CESP(PA(e))

         (paNRG(r,a,NRG,v,t) - sum(e$mape(NRG,e), alpha_eio(r,e,a,v,t)*shr0_eio(r,e,a)
       *       (M_PA(r,e,a,t)/lambdae(r,e,a,v,t))**(1-sigmaNRG(r,a,NRG,v)))
       **(1/(1-sigmaNRG(r,a,NRG,v))))
       $(not ifNRGACES and sigmaNRG(r,a,NRG,v) ne 0)

*  Normal CES with sigma = 0, PANRG = CESP(PA(e))

       +  (paNRG(r,a,NRG,v,t) - sum(e$mape(NRG,e),alpha_eio(r,e,a,v,t)*shr0_eio(r,e,a)
       *                      (M_PA(r,e,a,t)/lambdae(r,e,a,v,t))))
       $(not ifNRGACES and sigmaNRG(r,a,NRG,v) eq 0)

*  ACES PANRG = AVGPRICE(PA(e))

       +  (paNRG(r,a,NRG,v,t) - ((paNRGNDX(r,a,NRG,v,t)**sigmaNRG(r,a,NRG,v))$sigmaNRG(r,a,NRG,v)
       +    1$(sigmaNRG(r,a,NRG,v) eq 0))
       *       sum(e$mape(NRG,e), alpha_eio(r,e,a,v,t)*shr0_eio(r,e,a)
       *          (((lambdae(r,e,a,v,t)**(-sigmaNRG(r,a,NRG,v)))
       *          M_PA(r,e,a,t)**(1 - sigmaNRG(r,a,NRG,v)))$sigmaNRG(r,a,NRG,V)
       +           (M_PA(r,e,a,t))$(sigmaNRG(r,a,NRG,V) eq  0))))
       $(ifNRGACES)
       ;

paNRG.lo(r,a,NRG,v,t) = 0.001 ;

*  Composite price of OLG bundle ifACES

polgNDXeq(r,a,v,t)$(ts(t) and rs(r) and xolgFlag(r,a)
      and ifNRGACES and ifNRGNEST and sigmaolg(r,a,v))..

   polgNDX(r,a,v,t) =e=

*  ACES (PNDX = ACESNDX(PA("GAS"), PA("OIL")))

         (alpha_NRGB(r,a,"GAS",v,t)*shrx0_NRGB(r,a,"GAS")
       *    paNRG(r,a,"GAS",v,t)**(-sigmaolg(r,a,v))
       +  alpha_NRGB(r,a,"OIL",v,t)*shrx0_NRGB(r,a,"OIL")
       *    paNRG(r,a,"OIL",v,t)**(-sigmaolg(r,a,v)))**(1/(-sigmaolg(r,a,v)))
       ;

*  Price of OLG bundle

polgeq(r,a,v,t)$(ts(t) and rs(r) and xolgFlag(r,a) and ifNRGNest)..
  0 =e=

*  Normal CES, sigma<>0 (POLG = CESNDX(PA("GAS"), PA("OIL")))

         (polg(r,a,v,t) - (alpha_NRGB(r,a,"GAS",v,t)*shr0_NRGB(r,a,"GAS")
       *       paNRG(r,a,"GAS",v,t)**(1-sigmaolg(r,a,v))
       +    alpha_NRGB(r,a,"OIL",v,t)*shr0_NRGB(r,a,"OIL")
       *       paNRG(r,a,"OIL",v,t)**(1-sigmaolg(r,a,v)))
       **(1/(1-sigmaolg(r,a,v))))
       $(not ifNRGACES and sigmaolg(r,a,v) ne 0)

*  Normal CES, sigma=0 (POLG = CESNDX(PA("GAS"), PA("OIL")))

       +  (polg(r,a,v,t) - (alpha_NRGB(r,a,"GAS",v,t)*shr0_NRGB(r,a,"GAS")*paNRG(r,a,"GAS",v,t)
       +   alpha_NRGB(r,a,"OIL",v,t)*shr0_NRGB(r,a,"OIL")*paNRG(r,a,"OIL",v,t)))
       $(not ifNRGACES and sigmaolg(r,a,v) eq 0)

*  ACES (POLG = AVGPRICE(PA("GAS"), PA("COA")))

       + (polg(r,a,v,t) - ((polgNDX(r,a,v,t)**sigmaolg(r,a,v))$sigmaolg(r,a,v)
       + 1$(sigmaolg(r,a,v) eq 0))
       *    (alpha_NRGB(r,a,"GAS",v,t)*shr0_NRGB(r,a,"GAS")
       *       paNRG(r,a,"GAS",v,t)**(1 - sigmaolg(r,a,v))
       +     alpha_NRGB(r,a,"OIL",v,t)*shr0_NRGB(r,a,"OIL")
       *       paNRG(r,a,"OIL",v,t)**(1 - sigmaolg(r,a,v))))
       $(ifNRGACES)
       ;

polg.lo(r,a,v,t) = 0.001 ;

*  Composite price of NELY bundle ifACES

pnelyNDXeq(r,a,v,t)$(ts(t) and rs(r) and xnelyFlag(r,a)
   and ifNRGACES and ifNRGNEST and sigmanely(r,a,v))..

   pnelyNDX(r,a,v,t) =e=

*  ACES (PNDX = ACESNDX(PA("COA"), POLG))

         (alpha_NRGB(r,a,"COA",v,t)*shrx0_NRGB(r,a,"COA")
       *    paNRG(r,a,"COA",v,t)**(-sigmanely(r,a,v))
       +  alpha_olg(r,a,v,t)*shrx0_olg(r,a)
       *    polg(r,a,v,t)**(-sigmanely(r,a,v)))**(1/(-sigmanely(r,a,v)))
       ;

pnelyeq(r,a,v,t)$(ts(t) and rs(r) and xnelyFlag(r,a) and ifNRGNest)..
  0 =e=

*  Normal CES, sigma<>0 (PNELY = CESNDX(PA("COA", POLG))

          (pnely(r,a,v,t) - (alpha_NRGB(r,a,"COA",v,t)*shr0_NRGB(r,a,"COA")
       *       paNRG(r,a,"COA",v,t)**(1-sigmanely(r,a,v))
       +    alpha_olg(r,a,v,t)*shr0_OLG(r,a)
       *       polg(r,a,v,t)**(1-sigmanely(r,a,v)))**(1/(1-sigmanely(r,a,v))))
       $(not ifNRGACES and sigmanely(r,a,v) ne 0)

*  Normal CES, sigma=0 (PNELY = CESNDX(PA("COA", POLG))

       +  (pnely(r,a,v,t) - (alpha_NRGB(r,a,"COA",v,t)*shr0_NRGB(r,a,"COA")*paNRG(r,a,"COA",v,t)
       +   alpha_olg(r,a,v,t)*shr0_OLG(r,a)*polg(r,a,v,t)))
       $(not ifNRGACES and sigmanely(r,a,v) eq 0)

*  ACES (PNELY = AVGPRICE(PA("COA", POLG))

       + (pnely(r,a,v,t) - ((pnelyNDX(r,a,v,t)**sigmanely(r,a,v))$sigmanely(r,a,v)
       + 1$(sigmanely(r,a,v) eq 0))
       *    (alpha_NRGB(r,a,"COA",v,t)*shr0_NRGB(r,a,"COA")
       *       paNRG(r,a,"COA",v,t)**(1 - sigmanely(r,a,v))
       +     alpha_olg(r,a,v,t)*shr0_olg(r,a)*polg(r,a,v,t)**(1 - sigmanely(r,a,v))))
       $(ifNRGACES)
       ;

pnely.lo(r,a,v,t) = 0.001 ;

pnrgNDXeq(r,a,v,t)$(ts(t) and rs(r) and xnrgFlag(r,a) and ifNRGACES and sigmae(r,a,v))..
   pnrgNDX(r,a,v,t)

*  Single nest with ACES (PNDX = ACESNDX(PA))

      =e= (((sum(e, alpha_eio(r,e,a,v,t)*shrx0_eio(r,e,a)
       *        (M_PA(r,e,a,t)*lambdae(r,e,a,v,t))**(-sigmae(r,a,v))))**(1/(-sigmae(r,a,v)))))
       $(not ifNRGNest)

*  Nested energy with ACES (PNDX = ACESNDX(PA("ELY"), PNELY))

       +  ((alpha_NRGB(r,a,"ELY",v,t)*shrx0_NRGB(r,a,"ELY")
       *       paNRG(r,a,"ELY",v,t)**(-sigmae(r,a,v))
       +     alpha_nely(r,a,v,t)*shrx0_nely(r,a)
       *       pnely(r,a,v,t)**(-sigmae(r,a,v)))**(1/(-sigmae(r,a,v))))
       $(ifNRGNEST)
       ;

pnrgeq(r,a,v,t)$(ts(t) and rs(r) and xnrgFlag(r,a))..


*  Single nest normal CES, sigma<>0 (PNRG = CESNDX(PA))

    0 =e= (pnrg(r,a,v,t) - sum(e, alpha_eio(r,e,a,v,t)*shr0_eio(r,e,a)
       *        (M_PA(r,e,a,t)/lambdae(r,e,a,v,t))**(1-sigmae(r,a,v)))**(1/(1-sigmae(r,a,v))))
       $(sigmae(r,a,v) and not ifNRGACES and not ifNRGNEST)

*  Single nest normal CES, sigma=0 (PNRG = CESNDX(PA))

       + (pnrg(r,a,v,t) - sum(e, alpha_eio(r,e,a,v,t)*shr0_eio(r,e,a)
       *    (M_PA(r,e,a,t)/lambdae(r,e,a,v,t))))
       $(sigmae(r,a,v) eq 0 and not ifNRGACES and not ifNRGNEST)

*  Single nest ACES, (PNRG = AVGPRICE(PA))

       + (pnrg(r,a,v,t) - ((pnrgNDX(r,a,v,t)**sigmae(r,a,v))$sigmae(r,a,v) + 1$(not sigmae(r,a,v)))
       *    sum(e, alpha_eio(r,e,a,v,t)*shr0_eio(r,e,a)
       *          (lambdae(r,e,a,v,t)**(-sigmae(r,a,v)))*(M_PA(r,e,a,t)**(1-sigmae(r,a,v)))))
       $(ifNRGACES and not ifNRGNest)

*  Top nest normal CES, sigma<>0 (PNRG = CESNDX(PA("ELY", PNELY))

       + (pnrg(r,a,v,t) - (alpha_NRGB(r,a,"ELY",v,t)*shr0_NRGB(r,a,"ELY")
       *       paNRG(r,a,"ELY",v,t)**(1-sigmae(r,a,v))
       +     alpha_nely(r,a,v,t)*shr0_nely(r,a)
       *       pnely(r,a,v,t)**(1-sigmae(r,a,v)))**(1/(1-sigmae(r,a,v))))
       $(sigmae(r,a,v) and not ifNRGACES and ifNRGNEST)

*  Top nest normal CES, sigma=0 (PNRG = CESNDX(PA("ELY", PNELY))

       + (pnrg(r,a,v,t) - (alpha_NRGB(r,a,"ELY",v,t)*shr0_NRGB(r,a,"ELY")*paNRG(r,a,"ELY",v,t)
       +    alpha_nely(r,a,v,t)*shr0_nely(r,a)*pnely(r,a,v,t)))
       $(sigmae(r,a,v) eq 0 and not ifNRGACES and ifNRGNEST)

*  Top nest ACES (PNRG = AVGPRICE(PA("ELY", PNELY))

       + (pnrg(r,a,v,t) - ((pnrgNDX(r,a,v,t)**sigmae(r,a,v))$sigmae(r,a,v) + 1$(not sigmae(r,a,v)))
       *    (alpha_NRGB(r,a,"ELY",v,t)*shr0_NRGB(r,a,"ELY")
       *       (paNRG(r,a,"ELY",v,t)**(1-sigmae(r,a,v)))
       +     alpha_nely(r,a,v,t)*shr0_nely(r,a)*(pnely(r,a,v,t)**(1-sigmae(r,a,v)))))
       $(ifNRGACES and ifNRGNEST)
       ;

pnrg.lo(r,a,v,t) = 0.001 ;

* --------------------------------------------------------------------------------------------------
*
*  DOMESTIC SUPPLY BLOCK -- commodity make and use matrix
*
* --------------------------------------------------------------------------------------------------

*  Each activity 'a' can produce one or more commodities 'i'

peq(r,a,i,t)$(ts(t) and rs(r) and shr0_p(r,a,i) ne 0)..
   0 =e= (x(r,a,i,t) - (xp(r,a,t)/lambdas(r,a,i,t))
      *                (p(r,a,i,t)/(lambdas(r,a,i,t)*px(r,a,t)))**omegas(r,a))
      $(omegas(r,a) ne 0 and omegas(r,a) ne inf)

      +  (x(r,a,i,t) - xp(r,a,t)/lambdas(r,a,i,t))
      $(omegas(r,a) eq 0)

      +  (p(r,a,i,t) - px(r,a,t)*lambdas(r,a,i,t))
      $(omegas(r,a) eq inf)
      ;
p.lo(r,a,i,t) = 0.001 ;

xpeq(r,a,t)$(ts(t) and rs(r) and xpFlag(r,a))..
   0 =e= (px(r,a,t) - sum(i$shr0_p(r,a,i), shr0_p(r,a,i)
      *     (p(r,a,i,t)/lambdas(r,a,i,t))**(1+omegas(r,a)))**(1/(1+omegas(r,a))))
      $(omegas(r,a) ne 0 and omegas(r,a) ne inf)
      +  (px(r,a,t) - sum(i$shr0_p(r,a,i), shr0_p(r,a,i)*(p(r,a,i,t)/lambdas(r,a,i,t))))
      $(omegas(r,a) eq 0)
      +  (xp(r,a,t) - sum(i$shr0_p(r,a,i), ((p0(r,a,i)*x0(r,a,i)/(px0(r,a)*xp0(r,a))))
                            *    lambdas(r,a,i,t)*x(r,a,i,t)))
      $(omegas(r,a) eq inf)
      ;

ppeq(r,a,i,t)$(ts(t) and rs(r) and shr0_p(r,a,i) ne 0 and not IFSUB)..
   pp(r,a,i,t) =e= (1 + ptax(r,a,i,t))*p(r,a,i,t)*(p0(r,a,i)/pp0(r,a,i)) ;

pp.lo(r,a,i,t) = 0.001 ;

*  Domestic supply of good 'i' can be purchased from one or more activities 'a'

*
*  Specification for standard single nested CES
*

xeq(r,a,i,t)$(ts(t) and rs(r) and shr0_s(r,a,i) ne 0 and (not (IFPOWER and elya(a))))..
   0 =e= (x(r,a,i,t) - xs(r,i,t)*(ps(r,i,t)/M_PP(r,a,i,t))**sigmas(r,i))
      $(sigmas(r,i) ne 0 and sigmas(r,i) ne inf)

      + (x(r,a,i,t) - xs(r,i,t))
      $(sigmas(r,i) eq 0)

      +  (M_PP(r,a,i,t) - (ps0(r,i)/pp0(r,a,i))*ps(r,i,t))
      $(sigmas(r,i) eq inf) ;


pseq(r,i,t)$(ts(t) and rs(r) and xsFlag(r,i) and (not (IFPOWER and elyc(i))))..
   ps(r,i,t)*xs(r,i,t) =e=
      sum(a$shr0_s(r,a,i), ((pp0(r,a,i)/ps0(r,i))*(x0(r,a,i)/xs0(r,i)))
         * M_PP(r,a,i,t)*x(r,a,i,t)) ;

ps.lo(r,i,t) = 0.001 ;

$ontext

   Electricity aggregation

                  XS(ELY)
                   /\
                  /  \
                 /    \
                /      \
              ETD     POWER
                       /|\
                      / | \
                     /  |  \
                    /   |   \
                  Power bundles
                  /|\       /|\
                 / | \     / | \
                /  |  \   /  |  \
                   X         X

$offtext

*  Demand for etd -- electricity and distribution

xetdeq(r,etd,elyc,t)$(ts(t) and rs(r) and shr0_s(r,etd,elyc) and IFPOWER)..
   x(r,etd,elyc,t) =e= (xs(r,elyc,t)*(ps(r,elyc,t)/M_PP(r,etd,elyc,t))**sigmael(r,elyc))
                    $(sigmael(r,elyc) ne 0)

                    + (xs(r,elyc,t))
                    $(sigmael(r,elyc) eq 0)
                    ;

*  Demand for power

xpoweq(r,elyc,t)$(ts(t) and rs(r) and shr0_pow(r,elyc) and IFPOWER)..
   xpow(r,elyc,t) =e= (xs(r,elyc,t)*(ps(r,elyc,t)/ppow(r,elyc,t))**sigmael(r,elyc))
                   $(sigmael(r,elyc) ne 0)

                   +  (xs(r,elyc,t))
                   $(sigmael(r,elyc) eq 0)
                   ;

*  Aggregate price of electricity supply

pselyeq(r,elyc,t)$(ts(t) and rs(r) and xsFlag(r,elyc) and IFPOWER)..
   ps(r,elyc,t) =e= ((sum(etd, shr0_s(r,etd,elyc)*M_PP(r,etd,elyc,t)**(1-sigmael(r,elyc)))
                 +             shr0_pow(r,elyc)*ppow(r,elyc,t)**(1-sigmael(r,elyc)))
                 **(1/(1-sigmael(r,elyc))))
                 $(sigmael(r,elyc) ne 0)

                 +  (sum(etd, shr0_s(r,etd,elyc)*M_PP(r,etd,elyc,t))
                 +            shr0_pow(r,elyc)*ppow(r,elyc,t))
                 $(sigmael(r,elyc) eq 0)
                 ;

*  Demand for power bundles

Variables
   phtaxpb(r,pb,elyc,t)       "Phantom tax on power bundle"
   phtaxpbY(r,t)              "Revenues from phantom tax on power bundle"
   chiphpb(r,t)               "Tax shifter for non-targetted bundles"
;

Sets
   phTaxpbFlag(r)             "Flag implementing phantom tax on power bundle"
   iphpb(r,pb)                "Targetted bundles"
;

Equations
   phTaxpbYeq(r,t)            "Taxes collected from phantom tax on power bundle"
   phTaxpbeq(r,pb,elyc,t)     "Phantom tax on power bundle"
;

xpbeq(r,pb,elyc,t)$(ts(t) and rs(r) and shr0_pb(r,pb,elyc) and IFPOWER)..
   xpb(r,pb,elyc,t)
      =e= (lambdapow(r,pb,elyc,t)**(-sigmapow(r,elyc)))
       *   xpow(r,elyc,t)*(ppowndx(r,elyc,t)/(ppb(r,pb,elyc,t)*(1+phtaxpb(r,pb,elyc,t))))
       **sigmapow(r,elyc) ;

*  Price index for power

ppowndxeq(r,elyc,t)$(ts(t) and rs(r) and shr0_pow(r,elyc) and IFPOWER)..
   ppowndx(r,elyc,t)**(-sigmapow(r,elyc))
      =e= sum(pb$shr0_pb(r,pb,elyc), shr0_pb(r,pb,elyc)
       *       (ppb(r,pb,elyc,t)*(1+phtaxpb(r,pb,elyc,t))
       *          lambdapow(r,pb,elyc,t))**(-sigmapow(r,elyc))) ;

*  Average price of power

ppoweq(r,elyc,t)$(ts(t) and rs(r) and shr0_pow(r,elyc) and IFPOWER)..
   ppow(r,elyc,t)*xpow(r,elyc,t)
      =e= sum(pb$shr0_pb(r,pb,elyc), (ppb0(r,pb,elyc)*xpb0(r,pb,elyc)/(ppow0(r,elyc)*xpow0(r,elyc)))
       *    (ppb(r,pb,elyc,t)*(1+phtaxpb(r,pb,elyc,t)))*xpb(r,pb,elyc,t)) ;

phtaxpbYeq(r,t)$(ts(t) and rs(r) and phtaxpbFlag(r))..
   phtaxpbY(r,t) =e= sum((pb,elyc), phtaxpb(r,pb,elyc,t)*ppb(r,pb,elyc,t)*xpb(r,pb,elyc,t)
                  *     (ppb0(r,pb,elyc)*xpb0(r,pb,elyc))) ;

phtaxpbeq(r,pb,elyc,t)$(ts(t) and rs(r) and (not iphpb(r,pb)) and phtaxpbFlag(r))..
   phtaxpb(r,pb,elyc,t) =e= chiphpb(r,t) ;

ppowndx.lo(r,elyc,t) = 0.001 ;
ppow.lo(r,elyc,t) = 0.001 ;

*  Decomposition of power bundles

xbndeq(r,elya,elyc,t)$(ts(t) and rs(r) and (not etd(elya)) and shr0_s(r,elya,elyc) and IFPOWER)..
   x(r,elya,elyc,t)
      =e= sum(pb$mappow(pb,elya), alpha_s(r,elya,elyc,t)*(lambdapb(r,elya,elyc,t)**(-sigmapb(r,pb,elyc)))
       *     xpb(r,pb,elyc,t)*(ppbndx(r,pb,elyc,t)/M_PP(r,elya,elyc,t))**sigmapb(r,pb,elyc)) ;

*  Price index for power bundles

ppbndxeq(r,pb,elyc,t)$(ts(t) and rs(r) and shr0_pb(r,pb,elyc) and IFPOWER)..
   ppbndx(r,pb,elyc,t)
      =e= sum(elya$(mappow(pb,elya) and shr0_s(r,elya,elyc)), shr0_s(r,elya,elyc)*alpha_s(r,elya,elyc,t)
       *       (M_PP(r,elya,elyc,t)*lambdapb(r,elya,elyc,t))**(-sigmapb(r,pb,elyc)))
       **(-1/sigmapb(r,pb,elyc)) ;

*  Average price for power bundles

ppbeq(r,pb,elyc,t)$(ts(t) and rs(r) and shr0_pb(r,pb,elyc) and IFPOWER)..
   ppb(r,pb,elyc,t)*xpb(r,pb,elyc,t)
      =e= sum(elya$(mappow(pb,elya) and shr0_s(r,elya,elyc)), M_PP(r,elya,elyc,t)*x(r,elya,elyc,t)
       *    (x0(r,elya,elyc)*pp0(r,elya,elyc)/(ppb0(r,pb,elyc)*xpb0(r,pb,elyc)))) ;

ppbndx.lo(r,pb,elyc,t) = 0.001 ;
ppb.lo(r,pb,elyc,t) = 0.001 ;

* --------------------------------------------------------------------------------------------------
*
*  INCOME BLOCK
*
* --------------------------------------------------------------------------------------------------

*  Depreciation allowance

deprYeq(r,t)$(ts(t) and rs(r) and deprY0(r))..
   deprY(r,t) =e= sum(inv, (pfd0(r, inv)*kstock0(r)/deprY0(r))
               *        fdepr(r,t)*pfd(r, inv, t)*kstock(r,t)) ;

*  Revenues from NTM AVE

ntmYeq(r,t)$(ts(t) and rs(r) and NTMFlag)..
   ntmY0(r)*ntmY(r,t)
      =e= sum((s,i), pwm0(s,i,r)*xw0(s,i,r)
       *       ntmAVE(s,i,r,t)*M_PWM(s,i,r,t)*lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw(s,i,r,t)) ;

*  Outflow of capital income

yqtfeq(r,t)$(rs(r) and ts(t) and yqtf0(r))..
   yqtf(r,t) =e= ydistf(r,t)
      * sum((a,cap), pf0(r,cap,a)*xf0(r,cap,a)*(1 - kappaf(r,cap,a,t))*pf(r,cap,a,t)*xf(r,cap,a,t))
      / yqtf0(r) ;

*  Total outflows of capital income

trustYeq(t)$(ts(t) and trustY0 and ifGbl)..
   trustY(t) =e= sum(r, (yqtf0(r)/trustY0)*yqtf(r,t)) ;

*  Inflow of capital income

yqhteq(r,t)$(rs(r) and ts(t) and yqht0(r))..
   yqht(r,t) =e= chiTrust(r,t)*(trustY0/yqht0(r))*trustY(t) ;

*  Remittance outflows
*  !!!! Might want to do this after-tax

remiteq(s,l,r,t)$(rs(r) and ts(t) and remit0(s,l,r))..
   remit(s,l,r,t) =e= (chiRemit(s,l,r,t)/remit0(s,l,r))
                   *   sum(a, (pf0(r,l,a)*xf0(r,l,a)
                   *      (1-kappaf(r,l,a,t))*pf(r,l,a,t)*xf(r,l,a,t))) ;

*  ODA outflows

ODAOuteq(r,t)$(rs(r) and ts(t) and ODAOut0(r))..
   ODAOut(r,t) =e= chiODAOut(r,t)*GDPMP(r,t)*(GDPMP0(r)/ODAOut0(r))*rgdppc(r,t)**etaODA(r,t) ;

*  Total ODA

ODAGbleq(t)$(ts(t) and ODAGbl0)..
   ODAGbl(t) =e= sum(r, ODAOut(r,t)*ODAOut0(r))/ODAGbl0 ;

*  ODA inflows

ODAIneq(r,t)$(rs(r) and ts(t) and ODAIn0(r))..
   ODAIn(r,t) =e= chiODAIn(r,t)*(ODAGbl0/ODAIn0(r))*ODAGbl(t) ;

*  3-Jun-2025: tourism revenues

Variables
   tour_rev(r,t)        "Tourism revenues"
   tour_revx(r,t)       "Targettted tourism revenues"
   tour_shft(t)         "Shifter for tourism revenues"
;

Parameters
   tour_rev0(r)         "Tourism revenues"
   tour_revx0(r)        "Targettted tourism revenues"
   phi_tour(r)          "Slack region(s)"
   tour_impact(r,tt)    "Tourism revenues as a share of GDP"
;

Equations
   tour_reveq(r,t)      "Tourism revenues"
   tour_revxeq(r,t)     "Targetted tourism revenues"
   tour_shfteq(t)       "Tourism revenues shift equation"
;

scalar ifTour_rev "Tourism revenue flag" / 0 / ;

tour_rev0(r)      = 1 ;
tour_rev.fx(r,t)  = 0 ;
tour_revx.fx(r,t) = 0 ;
tour_shft.fx(t)   = 0 ;
tour_impact(r,t)  = 0 ;
phi_tour(r)       = 1 ;

tour_reveq(r,t)$(ts(t) and rs(r) and ifTour_rev)..
   tour_rev(r,t)*tour_rev0(r) =e= tour_revx(r,t)*tour_rev0(r) + phi_tour(r)*tour_shft(t) ;

tour_revxeq(r,t)$(ts(t) and rs(r) and ifTour_rev)..
   tour_revx(r,t)*tour_rev0(r) =e= tour_impact(r,t)*gdpmp(r,t)*gdpmp0(r) ;

tour_shfteq(t)$(ts(t) and ifGbl and ifTour_rev)..
   sum(r, tour_rev(r,t)*tour_rev0(r)) =e= 0 ;

*  Household income

yheq(r,t)$(ts(t) and rs(r))..
   yh(r,t) =e= sum((f,a)$xfFlag(r,f,a), (1-kappaf(r,f,a,t))
            *              pf(r,f,a,t)*xf(r,f,a,t)*(pf0(r,f,a)*xf0(r,f,a)/yh0(r)))
            +  ((yqht0(r)/yh0(r))*yqht(r,t) - (yqtf0(r)/yh0(r))*yqtf(r,t))
            +  (sum((l,d), (remit0(r,l,d)/yh0(r))*remit(r,l,d,t)
            -               (remit0(d,l,r)/yh0(r))*remit(d,l,r,t)))
            - deprY0(r)*deprY(r,t)/yh0(r)
            + sum(s, chihNTM(s,r,t)*ntmY0(s)*ntmY(s,t))
            + sum(s, govTr0(s,r)*govTr(s,r,t)*pnum(t)/yh0(r))
            + tour_rev(r,t)*(tour_rev0(r)/yh0(r)) ;
            ;

ydeq(r,t)$(ts(t) and rs(r))..
   yd(r,t) =e= (1 - kappah(r,t))*yh(r,t)*(yh0(r)/yd0(r)) ;

*  Household saving for ELES

savhELESeq(r,h,t)$(ts(t) and rs(r) and %utility% = ELES)..
   savh(r,h,t) =e= yd(r,t)*(yd0(r)/savh0(r,h))
                -    sum(k, pc(r,k,h,t)*xc(r,k,h,t)*(pc0(r,k,h)*xc0(r,k,h)/savh0(r,h))) ;

Parameters
   alphas(r,h,t)     "Persistence parameter in savings rate"
;

Equations
   apseq(r,h,t)      "Savings rate equation"
;

alphas(r,h,t) = 0 ;

apseq(r,h,t)$(ts(t) and rs(r) and %utility% ne ELES)..
   aps(r,h,t) =e= alphas(r,h,t)*aps(r,h,tLag)
               +     (chiaps(r,h,t)/aps0(r,h))*(trent(r,t)/pgdpmp(r,t))**etaaps(r,h) ;

$ontext
*  Alternative formulation
   aps(r,h,t) =e= alphas(r,h,t)*aps(r,h,tLag)
               +  etaaps(r,h)*(trent(r,t)/pgdpmp(r,t))*(trent0(r)/(pgdpmp0(r)*aps0(r,h)))
               +  chiaps(r,h,t)/aps0(r,h) ;
$offtext

*  Household saving for non-ELES, or aps for ELES

savheq(r,h,t)$(ts(t) and rs(r))..
   savh(r,h,t) =e= aps(r,h,t)*yd(r,t)*(aps0(r,h)*yd0(r)/savh0(r,h)) ;

Variable
   yc(r,h,t)      "Household expenditures on goods and services"
;

Parameter
   yc0(r,h)       "Initial household expenditures on goods and services"
;

Equation
   yceq(r,h,t)    "Household expenditures on goods and services"
;

yceq(r,h,t)$(ts(t) and rs(r))..
   yc(r,h,t) =e= yd(r,t)*yd0(r)/yc0(r,h)
              -   savh(r,h,t)*savh0(r,h)/yc0(r,h)
              -   yfdexpadp(r,h,t)
              ;

yc.lo(r,h,t) = 0.001 ;

*  Government income

ygoveq(r,gy,t)$(ts(t) and rs(r) and ygov0(r,gy))..
   ygov(r,gy,t) =e=

*  Output tax

      (sum((a,i), ptax(r,a,i,t)*p(r,a,i,t)*x(r,a,i,t)*(p0(r,a,i)*x0(r,a,i)))/ygov0(r,gy)
   +   sum((a,v), uctax(r,a,v,t)*uc(r,a,v,t)*xpv(r,a,v,t)*(uc0(r,a)*xpv0(r,a)))/ygov0(r,gy))$ptx(gy)

*  Factor use tax

   +  (sum((f,a)$xfFlag(r,f,a),
         M_PFTAX(r,f,a,t)*pf(r,f,a,t)*xf(r,f,a,t)*(pf0(r,f,a)*xf0(r,f,a)/ygov0(r,gy))))$vtx(gy)

*  Sales tax

   +  (sum((i,aa)$(xaFlag(r,i,aa) and ArmSpec(r,i) eq aggArm),
            paTax(r,i,aa,t)*gamma_eda(r,i,aa)*pat(r,i,t)*xa(r,i,aa,t)
         *  (pat0(r,i)*xa0(r,i,aa)/ygov0(r,gy))))$(itx(gy))
   +  (sum((i,aa)$(xdFlag(r,i,aa) and ArmSpec(r,i) ne aggArm),
            pdTax(r,i,aa,t)*gamma_edd(r,i,aa)*pdt(r,i,t)*xd(r,i,aa,t)
         *  (pdt0(r,i)*xd0(r,i,aa)/ygov0(r,gy)))
   +   sum((i,aa)$(xmFlag(r,i,aa) and ArmSpec(r,i) ne aggArm), pmTax(r,i,aa,t)*gamma_edm(r,i,aa)
$iftheni "%MRIO_MODULE%" == "ON"
         *  ((pma0(r,i,aa)*pma(r,i,aa,t))$(ArmSpec(r,i) eq MRIOArm)
         +   (pmt0(r,i)*pmt(r,i,t))$(ArmSpec(r,i) eq stdArm))
$else
         *  pmt0(r,i)*pmt(r,i,t)
$endif
         *  xm0(r,i,aa)*xm(r,i,aa,t)/ygov0(r,gy)))
         $(itx(gy))

*  Import tax

$iftheni "%MRIO_MODULE%" == "ON"
   +  (sum((s,i,aa)$(xwaFlag(s,i,r,aa) and ArmSpec(r,i) eq MRIOArm), xwa(s,i,r,aa,t)
   *     (mtaxa(s,i,r,aa,t)*M_PWM(s,i,r,t)*pwm0(s,i,r) + M_SPCTAR(s,i,r,t))
   *     (xwa0(s,i,r,aa)/ygov0(r,gy))))$mtx(gy)
$endif
   +  (sum((i,s)$(xwFlag(s,i,r) and ArmSpec(r,i) ne MRIOArm),
         lambdaw(s,i,r,t)*lambdax(s,i,r,t)*xw(s,i,r,t)
   *     (mtax(s,i,r,t)*M_PWM(s,i,r,t)*pwm0(s,i,r) + M_SPCTAR(s,i,r,t))
   *     (xw0(s,i,r)/ygov0(r,gy))))$mtx(gy)

*  Export tax

   +  (sum((i,d)$xwFlag(r,i,d), (etax(r,i,d,t)+etaxi(r,i,t))*pe(r,i,d,t)*xw(r,i,d,t)
   *     (pe0(r,i,d)*xw0(r,i,d)/ygov0(r,gy))))$etx(gy)

*  Income tax

   +  (sum((f,a)$xfFlag(r,f,a), kappaf(r,f,a,t)*pf(r,f,a,t)*xf(r,f,a,t)
         *(pf0(r,f,a)*xf0(r,f,a)/ygov0(r,gy)))
   +   kappah(r,t)*yh(r,t)*(yh0(r)/ygov0(r,gy)))$dtx(gy)

*  Add the waste tax(es)

   +   ((sum((i,h)$hWasteFlag(r,i,h), (xawc0(r,i,h)*(pa0(r,i,h)*xawc(r,i,h,t))
   *     M_PA(r,i,h,t)*wtaxh(r,i,h,t)
   +     wtaxhx(r,i,h,t)*pfd0(r,h)*pfd(r,h,t))))/ygov0(r,gy))$wtx(gy)

*  Carbon tax

   +  (sum((em,i,aa)$(ArmSpec(r,i) eq aggArm),
         chiEmi(r,em,aa,t)*emir(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)*xa(r,i,aa,t)
   *     (xa0(r,i,aa)/ygov0(r,gy))))$(ctx(gy))
   +  (sum((em,i,aa)$(ArmSpec(r,i) eq stdArm), chiEmi(r,em,aa,t)*emird(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)*xd(r,i,aa,t)
   *     (xd0(r,i,aa)/ygov0(r,gy)))
   +   sum((em,i,aa)$(ArmSpec(r,i) eq stdArm), chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)*xm(r,i,aa,t)
   *     (xm0(r,i,aa)/ygov0(r,gy))))$(ctx(gy))
   -  (sum(a$emiRebateFlag(r,a,t), emiRebate(r,a,t))/ygov0(r,gy))$(ctx(gy))
   +  (sum((ghg,a)$pCarb0(r,ghg,a), (pnum(t)*pCarb(r,ghg,a,t) + procEmiTax(r,ghg,a,t)/pCarb0(r,ghg,a))*procEmi(r,ghg,a,t)*pCarb0(r,ghg,a)*procEmi0(r,ghg,a)/ygov0(r,gy)))$(ctx(gy))
   ;

Variable
   lSubsY(r,t)       "Cost of labor subsidies wrt to reference labor tax"
   ctaxgap(r,t)      "Difference between carbon revenues and factor subsidies"
;

Variable
   alphaY(r,t)       "Share of carbon taxes going to subsidies"
   GDPShr(r,t)       "New subsidies as a share of GDP"
;
alphaY.fx(r,t) = 1 ;
GDPShr.l(r,t)  = 0 ;

Set
   lTaxFlag(r)       "Flag to calculate labor tax subsidies"
   fSubsFlag(r)      "Flag to calibrate factor subsidies"
;
lTaxFlag(r)  = no ;
fSubsFlag(r) = no ;

Parameter
   alphaFTaxMax(r,t) "Maximum subsidy rate"
;
alphaFTaxMax(r,tsim) = 0.99 ;

Equation
   lSubsYeq(r,t)     "Cost of labor subsidies wrt to reference labor tax"
   fSubsYeq(r,t)     "New subsidies as a share of GDP"
   ctaxgapeq(r,t)    "Calculates ctaxgap when there is no-recycling"
   ctaxgapfxeq(r,t)  "alphaFTax when there is re-cycling and no cap on the subsidies"
   alphaFTaxeq(r,t)  "Bounds on the subsidy rate"
;

lSubsYeq(r,t)$(ts(t) and rs(r) and lTaxFlag(r))..
   lSubsY(r,t) =e= sum((a,l), (M_PFTAX(r,l,a,t) - pftax(r,l,a,t0))
                *              pf(r,l,a,t)*xf(r,l,a,t)*pf0(r,l,a)*xf0(r,l,a)) ;

fSubsYeq(r,t)$(ts(t) and rs(r) and fsubsFlag(r))..
   -GDPShr(r,t)*GDPMP(r,t)
      =e= sum((a,f)$ifAfTaxFlag(r,f,a), (M_PFTAX(r,f,a,t) - pftax(r,f,a,t0))
       *               pf(r,f,a,t)*xf(r,f,a,t)*pf0(r,f,a)*xf0(r,f,a)/GDPMP0(r)) ;

*  Note change in sign as we are subsidizing factors

ctaxgapeq(r,t)$(ts(t) and rs(r) and (ifreCycle(r,t) eq noRecycle))..
   ctaxgap(r,t) =e= alphaY(r,t)*ygov(r,"ctax",t)*ygov0(r,"ctax")
                 +   sum((a,f)$ifAfTaxFlag(r,f,a), (M_PFTAX(r,f,a,t) - pftax(r,f,a,t0))
                 *               pf(r,f,a,t)*xf(r,f,a,t)*pf0(r,f,a)*xf0(r,f,a))
                 ;

ctaxgapfxeq(r,t)$(ts(t) and rs(r)
   and (ifreCycle(r,t) eq Recycle or ifreCycle(r,t) eq CapwRecycle))..

   ctaxgap(r,t) =e= alphaY(r,t)*ygov(r,"ctax",t)*ygov0(r,"ctax")
                 +   sum((a,f)$ifAfTaxFlag(r,f,a), (M_PFTAX(r,f,a,t) - pftax(r,f,a,t0))
                 *               pf(r,f,a,t)*xf(r,f,a,t)*pf0(r,f,a)*xf0(r,f,a))
                 ;

alphaFTaxeq(r,t)$(ts(t) and rs(r) and (ifreCycle(r,t) eq CapwRecycle))..
   -alphaFTaxMax(r,t) =l= alphaFTax(r,t) ;

*  Investment income

yfdInveq(r,t)$(ts(t) and rs(r))..
   yfd(r,inv,t) =e= sum(h, savh(r,h,t)*savh0(r,h)/yfd0(r,inv))
                 +         savg(r,t)/yfd0(r,inv)
                 +         pwsav(t)*savf(r,t)/yfd0(r,inv)
                 +         deprY0(r)*deprY(r,t)/yfd0(r,inv)
                 -         yfdexpadp(r,inv,t)
                 +  walras(t)$(ifGbl and rres(r))
                 ;

* --------------------------------------------------------------------------------------------------
*
*  FINAL DEMAND BLOCK
*
* --------------------------------------------------------------------------------------------------

*  Supernumery income

supyeq(r,h,t)$(ts(t) and rs(r)
      and (%utility%=CD or %utility%=LES or %utility%=ELES or %utility%=AIDADS))..
   supy(r,h,t) =e= ((yd(r,t)*(yd0(r)/(pop0(r)*supy0(r,h))))$(%utility%=ELES)
                +   (yc(r,h,t)*(yc0(r,h)/(pop0(r)*supy0(r,h))))$(%utility% ne ELES))
                /  pop(r,t)
                -  sum(k, pc(r,k,h,t)*gammac(r,k,h,t)*pc0(r,k,h)/supy0(r,h)) ;

*  CDE auxiliary variable

zconseq(r,k,h,t)$(ts(t) and rs(r) and xcFlag(r,k,h) and %utility%=CDE)..
$ontext
   zcons(r,k,h,t) =e= (alphah(r,k,h,t)*bh(r,k,h,t)
                   *    ((pc0(r,k,h)*pop0(r)*pop(r,t)*u0(r,h)**eh(r,k,h,t))**bh(r,k,h,t))
                   *    ((yc0(r,h)**(-bh(r,k,h,t)))/zcons0(r,k,h)))
                   *    ((pc(r,k,h,t)*u(r,h,t)**eh(r,k,h,t))/yc(r,h,t))**bh(r,k,h,t)
                   ;
$offtext
   log(zcons(r,k,h,t)) =e= log(alphah(r,k,h,t)*bh(r,k,h,t)
                   *    ((pc0(r,k,h)*pop0(r)*pop(r,t)*u0(r,h)**eh(r,k,h,t))**bh(r,k,h,t))
                   *    ((yc0(r,h)**(-bh(r,k,h,t)))/zcons0(r,k,h)))
                   +    eh(r,k,h,t)*bh(r,k,h,t) * log(u(r,h,t))
                   +    bh(r,k,h,t)*log(pc(r,k,h,t))
                   -    bh(r,k,h,t)*log(yc(r,h,t))
                   ;

*  Household consumption in household commodity space

xceq(r,k,h,t)$(ts(t) and rs(r) and xcFlag(r,k,h))..
   0 =e= (xc(r,k,h,t) - (pop0(r)*pop(r,t)*(gammac(r,k,h,t)/xc0(r,k,h)
                      + (betac(r,h,t)*muc(r,k,h,t)*supy(r,h,t)/pc(r,k,h,t))
                      * (muc0(r,k,h)*supy0(r,h)/(pc0(r,k,h)*xc0(r,k,h))))))
                      $(%utility%=CD or %utility%=LES or %utility%=ELES or %utility%=AIDADS)

      +  (hshr(r,k,h,t) - (zcons(r,k,h,t)*zcons0(r,k,h)/hshr0(r,k,h))
      /     sum(kp$xcFlag(r,kp,h), zcons0(r,kp,h)*zcons(r,kp,h,t)))$(%utility%=CDE) ;

*  Household budget share (out of expenditures on goods and services)

hshreq(r,k,h,t)$(ts(t) and rs(r) and xcFlag(r,k,h))..
   hshr(r,k,h,t) =e= pc(r,k,h,t)*xc(r,k,h,t)/yc(r,h,t)
                  *  (pc0(r,k,h)*xc0(r,k,h)/(hshr0(r,k,h)*yc0(r,h))) ;

*  Marginal budget share for AIDADS

muceq(r,k,h,t)$(ts(t) and rs(r) and xcFlag(r,k,h) and %utility%=AIDADS)..
   muc(r,k,h,t) =e= ((alphaAD(r,k,h,t) + betaAD(r,k,h,t)*exp(u(r,h,t)*u0(r,h)))
                 /  (1+exp(u(r,h,t)*u0(r,h))))/muc0(r,k,h) ;

*  Utility definition

*  !!!! Currently potential problems with ELES

ueq(r,h,t)$(ts(t) and rs(r))..
   0 =e= (u0(r,h)*u(r,h,t) - 1)$(%utility%=ELES and not uFlag(r,h))

      +  (u(r,h,t)*u0(r,h) - (supy(r,h,t)*supy0(r,h)
            / (prod(k$xcFlag(r,k,h), (pc(r,k,h,t)*pc0(r,k,h)/(muc0(r,k,h)*muc(r,k,h,t)))
            **(muc0(r,k,h)*muc(r,k,h,t)))
            * ((pfd(r,h,t)*pfd0(r,h)/(mus0(r,h)*mus(r,h,t)))**(mus0(r,h)*mus(r,h,t))))))
      $(%utility%=ELES and uFlag(r,h))

      +  (u(r,h,t)*u0(r,h) + 1 + log(aad(r,h,t))
      -   sum(k$xcFlag(r,k,h), muc0(r,k,h)*muc(r,k,h,t)*
            log(xc(r,k,h,t)*xc0(r,k,h)/(pop0(r)*pop(r,t)) - gammac(r,k,h,t))))
      $(%utility%=CD or %utility%=LES or %utility%=AIDADS)

      +  (1 - sum(k$xcFlag(r,k,h), zcons0(r,k,h)*zcons(r,k,h,t)/bh(r,k,h,t)))
      $(%utility%=CDE)
      ;

u.lo(r,h,t) = 0.001 ;

*  Demand for non-energy bundle by households

xcnnrgeq(r,k,h,t)$(ts(t) and rs(r) and xcnnrgFlag(r,k,h))..
   xcnnrg(r,k,h,t) =e= xc(r,k,h,t)*(pc(r,k,h,t)/pcnnrg(r,k,h,t))**nu(r,k,h) ;

*  Demand for energy bundle by households

xcnrgeq(r,k,h,t)$(ts(t) and rs(r) and xcnrgFlag(r,k,h))..
   xcnrg(r,k,h,t) =e= xc(r,k,h,t)*((dam_nrg(r,k,h,t)*lambdanrgc(r,k,h,t))**(nu(r,k,h)-1))
                   *    (pc(r,k,h,t)/pcnrg(r,k,h,t))**nu(r,k,h) ;

*  Price of consumer good k

pceq(r,k,h,t)$(ts(t) and rs(r) and xcFlag(r,k,h))..
   pc(r,k,h,t)**(1-nu(r,k,h))
      =e= shr0_cxnnrg(r,k,h)*pcnnrg(r,k,h,t)**(1-nu(r,k,h))
       +  shr0_cxnrg(r,k,h)*(pcnrg(r,k,h,t)/(dam_nrg(r,k,h,t)*lambdanrgc(r,k,h,t)))**(1-nu(r,k,h)) ;

pc.lo(r,k,h,t) = 0.001 ;

*  Decomposition of non-energy bundle by households

xacnnrgeq(r,ixn,h,t)$(ts(t) and rs(r) and xaFlag(r,ixn,h))..
   xa(r,ixn,h,t) =e= sum(k$shr0_c(r,ixn,k,h), (lambdac(r,ixn,k,h,t)**(nunnrg(r,k,h)-1))
                  *     xcnnrg(r,k,h,t)*(pcnnrg(r,k,h,t)/pah(r,ixn,h,t))**nunnrg(r,k,h)) ;

pcnnrgeq(r,k,h,t)$(ts(t) and rs(r) and xcnnrgFlag(r,k,h))..
   pcnnrg(r,k,h,t)**(1-nunnrg(r,k,h))
      =e= sum(ixn$shr0_c(r,ixn,k,h), shr0_c(r,ixn,k,h)
       *       (pah(r,ixn,h,t)/lambdac(r,ixn,k,h,t))**(1-nunnrg(r,k,h))) ;

pcnnrg.lo(r,k,h,t) = 0.001 ;

*  NRG bundle disaggregation -- single and multiple nests

xcnelyeq(r,k,h,t)$(ts(t) and rs(r) and xcnelyFlag(r,k,h) and ifNRGNest)..
   xcnely(r,k,h,t)
      =e=  alpha_cnely(r,k,h,t)*xcnrg(r,k,h,t)
       *   (((pcnrg(r,k,h,t)/pcnely(r,k,h,t))**nue(r,k,h))$(not ifNRGACES and nue(r,k,h))
       +    ((pcnrgNDX(r,k,h,t)/pcnely(r,k,h,t))**nue(r,k,h))$(ifNRGACES and nue(r,k,h))
       +    (1)$(nue(r,k,h) eq 0))
       ;

xcolgeq(r,k,h,t)$(ts(t) and rs(r) and xcolgFlag(r,k,h) and ifNRGNest)..
   xcolg(r,k,h,t)
      =e= xcnely(r,k,h,t)
       *  (((pcnely(r,k,h,t)/pcolg(r,k,h,t))**nunely(r,k,h))$(not ifNRGACES and nunely(r,k,h))
       +   ((pcnelyNDX(r,k,h,t)/pcolg(r,k,h,t))**nunely(r,k,h))$(ifNRGACES and nunely(r,k,h))
       +   (1)$(nunely(r,k,h) eq 0)) ;

xacNRGeq(r,k,h,NRG,t)$(ts(t) and rs(r) and xacNRGFlag(r,k,h,NRG) and ifNRGNest)..
   xacNRG(r,k,h,NRG,t)
      =e= (alpha_cNRG(r,k,h,nrg,t)*xcnrg(r,k,h,t)
       *   (((pcnrg(r,k,h,t)/pacNRG(r,k,h,NRG,t))**nue(r,k,h))$(not ifNRGACES and nue(r,k,h))
       +    ((pcnrgNDX(r,k,h,t)/pacNRG(r,k,h,NRG,t))**nue(r,k,h))$(ifNRGACES and nue(r,k,h))
       +    (1)$(nue(r,k,h) eq 0)))
       $ely(nrg)

       +  (xcnely(r,k,h,t)
       *     (((pcnely(r,k,h,t)/pacNRG(r,k,h,NRG,T))**nunely(r,k,h))
       $(not ifNRGACES and nunely(r,k,h))
       +      ((pcnelyNDX(r,k,h,t)/pacNRG(r,k,h,NRG,T))**nunely(r,k,h))
       $(ifNRGACES and nunely(r,k,h))
       +      (1)$(nunely(r,k,h) eq 0)))
       $coa(nrg)

       +  (xcolg(r,k,h,t)
       *     (((pcolg(r,k,h,t)/pacNRG(r,k,h,NRG,T))**nuolg(r,k,h))$(not ifNRGACES and nuolg(r,k,h))
       +      ((pcolgNDX(r,k,h,t)/pacNRG(r,k,h,NRG,T))**nuolg(r,k,h))$(ifNRGACES and nuolg(r,k,h))
       +      (1)$(nuolg(r,k,h) eq 0)))
       $gas(nrg)

       +  (xcolg(r,k,h,t)
       *     (((pcolg(r,k,h,t)/pacNRG(r,k,h,NRG,T))**nuolg(r,k,h))$(not ifNRGACES and nuolg(r,k,h))
       +      ((pcolgNDX(r,k,h,t)/pacNRG(r,k,h,NRG,T))**nuolg(r,k,h))$(ifNRGACES and nuolg(r,k,h))
       +      (1)$(nuolg(r,k,h) eq 0)))
       $oil(nrg)
       ;

xaceeq(r,e,h,t)$(ts(t) and rs(r) and xaFlag(r,e,h))..
   xa(r,e,h,t) =e=
           (sum(k, xcnrg(r,k,h,t)
*  Single energy nest, standard CES, sigma>0
       *       (((lambdace(r,e,k,h,t)**(nue(r,k,h)-1))*(pcnrg(r,k,h,t)/pah(r,e,h,t))**nue(r,k,h))
       $(nue(r,k,h) and not ifNRGACES)
*  Single energy nest, standard CES, sigma=0
       +       (1/lambdace(r,e,k,h,t))
       $(nue(r,k,h) eq 0 and not ifNRGACES)
*  Single energy nest, ACES, sigma > 0
       +       ((pcnrgNDX(r,k,h,t)/(lambdace(r,e,k,h,t)*pah(r,e,h,t)))**nue(r,k,h))
       $(nue(r,k,h) and ifNRGACES)
*  Single energy nest, ACES, sigma = 0
       +       (1)
       $(nue(r,k,h) eq 0 and ifNRGACES))
       $(not ifNRGNest)))

       +  (sum(k, sum(NRG$mape(NRG,e), xacNRG(r,k,h,NRG,t)
*  Nested, standard CES, sigma > 0
       *    (((lambdace(r,e,k,h,t)**(nuNRG(r,k,h,NRG)-1))
       *       (pacNRG(r,k,h,NRG,t)/pah(r,e,h,t))**nuNRG(r,k,h,NRG))
       $(nuNRG(r,k,h,NRG) ne 0 and not ifNRGACES)
*  Nested, standard CES, sigma = 0
       +     (1/lambdace(r,e,k,h,t))
       $(nuNRG(r,k,h,NRG) eq 0 and not ifNRGACES)
*  Nested, ACES, sigma > 0
       +     ((pacNRGNDX(r,k,h,NRG,t)/(lambdace(r,e,k,h,t)*pah(r,e,h,t)))**nuNRG(r,k,h,NRG))
       $(nuNRG(r,k,h,NRG) ne 0 and ifNRGACES)
*  Nested, ACES, sigma = 0
       +     (1)
       $(nuNRG(r,k,h,NRG) eq 0 and ifNRGACES)))))
       $(ifNRGNest)
       ;

*  Composite price of xacNRG bundle ifACES

pacNRGNDXeq(r,k,h,NRG,t)$(ts(t) and rs(r) and xacNRGFlag(r,k,h,NRG)
   and ifNRGACES and ifNRGNEST and nuNRG(r,k,h,NRG))..

   pacNRGNDX(r,k,h,NRG,t) =e=
      sum(e$mape(NRG,e), shrx0_c(r,e,k,h)*(lambdace(r,e,k,h,t)*pah(r,e,h,t))**(-nuNRG(r,k,h,NRG)))
      **(-1/nuNRG(r,k,h,NRG)) ;

pacNRGeq(r,k,h,NRG,t)$(ts(t) and rs(r) and xacNRGFlag(r,k,h,NRG) and ifNRGNest)..
   pacNRG(r,k,h,NRG,t) =e=
         (sum(e$mape(NRG,e), shr0_c(r,e,k,h)
       *    (pah(r,e,h,t)/lambdace(r,e,k,h,t))**(1-nuNRG(r,k,h,NRG)))**(1/(1-nuNRG(r,k,h,NRG))))
       $(nuNRG(r,k,h,NRG) and not ifNRGACES)

       + (sum(e$mape(NRG,e), shr0_c(r,e,k,h)*(pah(r,e,h,t)/lambdace(r,e,k,h,t))))
       $(nuNRG(r,k,h,NRG) eq 0 and not ifNRGACES)

       + (((pacNRGNDX(r,k,h,NRG,t)**nuNRG(r,k,h,NRG))$nuNRG(r,k,h,NRG) + 1$(nuNRG(r,k,h,NRG) eq 0))
       *    sum(e$mape(NRG,e), shr0_c(r,e,k,h)*(lambdace(r,e,k,h,t)**(1 - nuNRG(r,k,h,NRG)))
       *       pah(r,e,h,t)**(1 - nuNRG(r,k,h,NRG))))
       $(ifNRGACES)
       ;

pacNRG.lo(r,k,h,NRG,t) = 0.001 ;

*  Composite price of OLG bundle ifACES

pcOLGNDXeq(r,k,h,t)$(ts(t) and rs(r) and xcOLGFlag(r,k,h)
   and ifNRGACES and ifNRGNEST and nuolg(r,k,h))..

   pcOLGNDX(r,k,h,t) =e=
         (shrx0_cNRG(r,k,h,"GAS",t)
       *    pacNRG(r,k,h,"GAS",t)**(-nuolg(r,k,h))
       +  shrx0_cNRG(r,k,h,"OIL",t)
       *    pacNRG(r,k,h,"OIL",t)**(-nuolg(r,k,h)))**(1/(-nuolg(r,k,h)))
       ;

pcolgeq(r,k,h,t)$(ts(t) and rs(r) and xcolgFlag(r,k,h) and ifNRGNest)..
   pcolg(r,k,h,t) =e=
         ((shr0_cNRG(r,k,h,"GAS",t)*pacNRG(r,k,h,"GAS",t)**(1-nuolg(r,k,h))
      +    shr0_cNRG(r,k,h,"OIL",t)*pacNRG(r,k,h,"OIL",t)**(1-nuolg(r,k,h)))**(1/(1-nuolg(r,k,h))))
      $(not ifNRGACES and nuolg(r,k,h))

      +  ((shr0_cNRG(r,k,h,"GAS",t)*pacNRG(r,k,h,"GAS",t)
      +    shr0_cNRG(r,k,h,"OIL",t)*pacNRG(r,k,h,"OIL",t)))
      $(not ifNRGACES and nuolg(r,k,h) eq 0)

      +  (((pcolgNDX(r,k,h,t)**nuolg(r,k,h))$nuolg(r,k,h) + 1$(nuolg(r,k,h) eq 0))
      *   (shr0_cNRG(r,k,h,"GAS",t)*pacNRG(r,k,h,"GAS",t)**(1-nuolg(r,k,h))
      +    shr0_cNRG(r,k,h,"OIL",t)*pacNRG(r,k,h,"OIL",t)**(1-nuolg(r,k,h))))
      $(ifNRGACES)
      ;

pcolg.lo(r,k,h,t) = 0.001 ;

*  Composite price of NELY bundle ifACES

pcnelyNDXeq(r,k,h,t)$(ts(t) and rs(r) and xcnelyFlag(r,k,h)
   and ifNRGACES and ifNRGNEST and nunely(r,k,h))..

   pcnelyNDX(r,k,h,t) =e=
         (shrx0_cNRG(r,k,h,"COA",t)
       *    pacNRG(r,k,h,"COA",t)**(-nunely(r,k,h))
       +  shrx0_colg(r,k,h,t)
       *    pcolg(r,k,h,t)**(-nunely(r,k,h)))**(1/(-nunely(r,k,h)))
       ;

pcnelyeq(r,k,h,t)$(ts(t) and rs(r) and xcnelyFlag(r,k,h) and ifNRGNest)..
   pcnely(r,k,h,t) =e=
         ((shr0_cNRG(r,k,h,"COA",t)*pacNRG(r,k,h,"COA",t)**(1-nunely(r,k,h))
      +    shr0_colg(r,k,h,t)*pcolg(r,k,h,t)**(1-nunely(r,k,h)))**(1/(1-nunely(r,k,h))))
      $(not ifNRGACES and nunely(r,k,h))

      + ((shr0_cNRG(r,k,h,"COA",t)*pacNRG(r,k,h,"COA",t)
      +  shr0_colg(r,k,h,t)*pcolg(r,k,h,t)))
      $(not ifNRGACES and nunely(r,k,h) eq 0)

      +  (((pcnelyNDX(r,k,h,t)**nunely(r,k,h))$nunely(r,k,h) + 1$(nunely(r,k,h) eq 0))
      *     (shr0_cNRG(r,k,h,"COA",t)*pacNRG(r,k,h,"COA",t)**(1 - nunely(r,k,h))
      +      shr0_colg(r,k,h,t)*pcolg(r,k,h,t)**(1 - nunely(r,k,h))))
      $(ifNRGACES) ;

pcnely.lo(r,k,h,t) = 0.001 ;

pcnrgNDXeq(r,k,h,t)$(ts(t) and rs(r) and xcnrgFlag(r,k,h) and ifNRGACES and nue(r,k,h))..
   pcnrgNDX(r,k,h,t)

*  Single nest with ACES (PNDX = ACESNDX(PAH))

      =e= (((sum(e, shrx0_c(r,e,k,h)
       *        (pah(r,e,h,t)*lambdace(r,e,k,h,t))**(-nue(r,k,h))))**(1/(-nue(r,k,h)))))
       $(not ifNRGNest)

*  Nested energy with ACES (PNDX = ACESNDX(PAH("ELY"), PCNELY))

       +  ((alpha_cNRG(r,k,h,"ELY",t)*shrx0_cNRG(r,k,h,"ELY",t)
       *       pacNRG(r,k,h,"ELY",t)**(-nue(r,k,h))
       +     alpha_cnely(r,k,h,t)*shrx0_cnely(r,k,h,t)
       *       pcnely(r,k,h,t)**(-nue(r,k,h)))**(1/(-nue(r,k,h))))
       $(ifNRGNEST)
       ;

pcnrgeq(r,k,h,t)$(ts(t) and rs(r) and xcnrgFlag(r,k,h))..
   pcnrg(r,k,h,t) =e=

* Single nest, normal CES, sigma > 0, PNRG=CESP(PAH)
         ((sum(e, shr0_c(r,e,k,h)*(pah(r,e,h,t)/lambdace(r,e,k,h,t))**(1-nue(r,k,h)))
      **(1/(1-nue(r,k,h))))
      $(nue(r,k,h) and not ifNRGACES)
* Single nest, normal CES, sigma > 0, PNRG=CESP(PAH)
      + ((sum(e, shr0_c(r,e,k,h)*pah(r,e,h,t)/lambdace(r,e,k,h,t))))
      $(nue(r,k,h) eq 0 and not ifNRGACES)
* Single nest, ACES, PNRG=AVGPRICE(PAH)
      + (((pcnrgNDX(r,k,h,t)**nue(r,k,h))$nue(r,k,h) + 1$(nue(r,k,h) eq 0))
      *     sum(e, shr0_c(r,e,k,h)*(lambdace(r,e,k,h,t)**(-nue(r,k,h)))
      *        (pah(r,e,h,t)**(1-nue(r,k,h)))))$ifNRGACES)
      $(not ifNRGNest)

* Nested, normal CES, sigma > 0, PNRG=CESP(pac(ELY), pcnely)
      +  (((shr0_cNRG(r,k,h,"ELY",t)*alpha_cNRG(r,k,h,"ELY",t)*pacNRG(r,k,h,"ELY",t)**(1-nue(r,k,h))
      +   shr0_cnely(r,k,h,t)*alpha_cnely(r,k,h,t)*pcnely(r,k,h,t)**(1-nue(r,k,h)))
      **(1/((1-nue(r,k,h)))))
      $(nue(r,k,h) and not ifNRGACES)
* Nested, normal CES, sigma = 0, PNRG=CESP(pac(ELY), pcnely)
      +   ((shr0_cNRG(r,k,h,"ELY",t)*alpha_cNRG(r,k,h,"ELY",t)*pacNRG(r,k,h,"ELY",t)
      +   shr0_cnely(r,k,h,t)*alpha_cnely(r,k,h,t)*pcnely(r,k,h,t)))
      $(nue(r,k,h) eq 0 and not ifNRGACES)
* Nested, ACES, PNRG=AVGPRICE(pac(ELY), pcnely)
      + (((pcnrgNDX(r,k,h,t)**nue(r,k,h))$nue(r,k,h) + 1$(nue(r,k,h) eq 0))
      *  (shr0_cNRG(r,k,h,"ELY",t)*pacNRG(r,k,h,"ELY",t)**(1-nue(r,k,h))
      +   shr0_cnely(r,k,h,t)*pcnely(r,k,h,t)**(1-nue(r,k,h))))$(ifNRGACES))
      $ifNRGNest ;

pcnrg.lo(r,k,h,t) = 0.001 ;

*  Waste module

xaaceq(r,i,h,t)$(ts(t) and rs(r) and xaac0(r,i,h))..
   xaac(r,i,h,t) =e= (xa(r,i,h,t)
                  *     (paacc(r,i,h,t)/(lambdaac(r,i,h,t)*paac(r,i,h,t)))**sigmaac(r,i,h))
                  $(hWasteFlag(r,i,h))

                  +  (xa(r,i,h,t))
                  $(hWasteFlag(r,i,h) ne 1) ;

xawceq(r,i,h,t)$(ts(t) and rs(r) and hWasteFlag(r,i,h) and xawc0(r,i,h))..
   xawc(r,i,h,t) =e= xa(r,i,h,t)
                  *     (paacc(r,i,h,t)/(lambdawc(r,i,h,t)*pawc(r,i,h,t)))**sigmaac(r,i,h) ;

paacceq(r,i,h,t)$(ts(t) and rs(r) and hWasteFlag(r,i,h))..
   paacc(r,i,h,t)**(-sigmaac(r,i,h)) =e=
      shr0_ac(r,i,h)*(lambdaac(r,i,h,t)*paac(r,i,h,t))**(-sigmaac(r,i,h))
   +  shr0_wc(r,i,h)*(lambdawc(r,i,h,t)*pawc(r,i,h,t))**(-sigmaac(r,i,h)) ;

paaceq(r,i,h,t)$(ts(t) and rs(r) and xaac0(r,i,h))..
   pa0(r,i,h)*M_PA(r,i,h,t) =e= paac0(r,i,h)*paac(r,i,h,t) ;


Variable
   phhTaxY(r,t)            "Tax revenues from phantom taxes"
   phhTax(r,i,t)           "Phantom taxes"
   phhTax0(r,i,t)          "Initial phantom taxes"
   chiphh(r,t)             "Phantom tax shifter"
;

Equations
   phhTaxYeq(r,t)          "Tax revenues from phantom taxes"
   phhTaxeq(r,i,t)         "Phantom taxes"
;

Parameters
   phhTaxFlag(r)
;

sets
   iphh(r,i)               "Sectors with exogenous phantom taxes"
;

phhtax.fx(r,i,t) = 0 ;
paheq(r,i,h,t)$(ts(t) and rs(r) and xaac0(r,i,h))..
   0 =e= (pah(r,i,h,t)*xa(r,i,h,t)
      -     ((paac0(r,i,h)*xaac0(r,i,h)/(pa0(r,i,h)*xa0(r,i,h)))*paac(r,i,h,t)*xaac(r,i,h,t)
      +      (pawc0(r,i,h)*xawc0(r,i,h)/(pa0(r,i,h)*xa0(r,i,h)))*pawc(r,i,h,t)*xawc(r,i,h,t)))
      $hWasteFlag(r,i,h)
      +  (pah(r,i,h,t) - M_PA(r,i,h,t)*(1 + phhTax(r,i,t)))
      $(not hWasteFlag(r,i,h)) ;
 ;

pawceq(r,i,h,t)$(ts(t) and rs(r) and hWasteFlag(r,i,h))..
   pawc0(r,i,h)*pawc(r,i,h,t) =e= pa0(r,i,h)*M_PA(r,i,h,t)*(1 + wtaxh(r,i,h,t))
                               +    wtaxhx(r,i,h,t)*pfd0(r,h)*pfd(r,h,t) ;

phhTaxYeq(r,t)$(ts(t) and rs(r) and phhTaxFlag(r))..
   phhTaxY(r,t) =e= sum((i,h), phhTax(r,i,t)*m_pa(r,i,h,t)*xa(r,i,h,t)*xa0(r,i,h)*pa0(r,i,h)) ;

phhTaxeq(r,i,t)$(ts(t) and rs(r) and sum(h, xa0(r,i,h)) and phhTaxFlag(r))..
   phhTax(r,i,t) =e= phhTax0(r,i,t)*(1$iphh(r,i) + chiphh(r,t)$(not iphh(r,i))) ;

*  Other final demand -- investment and government

xafeq(r,i,fdc,t)$(ts(t) and rs(r) and xa0(r,i,fdc))..
   xa(r,i,fdc,t) =e= xfd(r,fdc,t)*(lambdafd(r,i,fdc,t)**(sigmafd(r,fdc)-1))
                  *  (pfd(r,fdc,t)/M_PA(r,i,fdc,t))**sigmafd(r,fdc) ;

pfdfeq(r,fdc,t)$(ts(t) and rs(r) and fdFlag(r,fdc))..
   pfd(r,fdc,t)**(1-sigmafd(r,fdc)) =e= sum(i,
         shr0_fd(r,i,fdc,t)*(M_PA(r,i,fdc,t)/lambdafd(r,i,fdc,t))**(1-sigmafd(r,fdc))) ;

pfd.lo(r,fd,t) = 0.001 ;

* !!!!! N.B. Excludes waste taxes in the case of households

$macro mQFD(r,fd,tp,tq) \
   (sum(i, (pa0(r,i,fd)*xa0(r,i,fd))*m_pa(r,i,fd,tp)*xa(r,i,fd,tq)))

pfdheq(r,h,t)$(ts(t) and rs(r))..
   pfd(r,h,t) =e= pfd(r,h,tLag)
              *   sqrt((mQFD(r,h,t,tLag)/mQFD(r,h,tLag,tLag))
              *        (mQFD(r,h,t,t)/mQFD(r,h,tLag,t))) ;

xfdheq(r,h,t)$(ts(t) and rs(r))..
   yfd(r,h,t) =e= sum(i, pah(r,i,h,t)*xa(r,i,h,t)*(pa0(r,i,h)*xa0(r,i,h)/yfd0(r,h))) ;

yfdeq(r,fd,t)$(ts(t) and rs(r) and fdFlag(r,fd))..
   yfd(r,fd,t) =e= pfd(r,fd,t)*xfd(r,fd,t)*(pfd0(r,fd)*xfd0(r,fd)/yfd0(r,fd)) ;

* --------------------------------------------------------------------------------------------------
*
*  ARMINGTON BLOCK
*
* --------------------------------------------------------------------------------------------------

*  Top level -- Armington decomposition: national sourcing

xateq(r,i,t)$(ts(t) and rs(r) and xatFlag(r,i) and ArmSpec(r,i) eq aggArm)..
   xat(r,i,t) =e= sum(aa, gamma_eda(r,i,aa)*xa(r,i,aa,t)*(xa0(r,i,aa)/xat0(r,i))) ;

pateq(r,i,t)$(ts(t) and rs(r) and xatFlag(r,i) and ArmSpec(r,i) eq aggArm)..
   pat(r,i,t) =e=
         ((alpha_dt(r,i,t)*shr0_dt(r,i)*pdt(r,i,t)**(1-sigmamt(r,i))
       +   alpha_mt(r,i,t)*shr0_mt(r,i)*pmt(r,i,t)**(1-sigmamt(r,i)))**(1/(1-sigmamt(r,i))))
       $(not ifARMACES(i))

       +  ((patNDX(r,i,t)**sigmamt(r,i))
       *    (shr0_dt(r,i)*pdt(r,i,t)**(1 - sigmamt(r,i))
       +     shr0_mt(r,i)*pmt(r,i,t)**(1 - sigmamt(r,i))))
       $(ifARMACES(i))
       ;

patNDXeq(r,i,t)$(ts(t) and rs(r) and xatFlag(r,i) and (ArmSpec(r,i) eq aggArm) and ifARMACES(i))..
   patNDX(r,i,t) =e=
         ((alpha_dt(r,i,t)*shrx0_dt(r,i)*pdt(r,i,t)**(-sigmamt(r,i))
       +   alpha_mt(r,i,t)*shrx0_mt(r,i)*pmt(r,i,t)**(-sigmamt(r,i)))**(1/(-sigmamt(r,i))))
       ;

pat.lo(r,i,t) = 0.001 ;

xdteq(r,i,t)$(ts(t) and rs(r) and xdtFlag(r,i))..
   xdt(r,i,t)

*           National sourcing

      =e= (((xdt0(r,i) - xtt0(r,i))/xdt0(r,i))
       *    alpha_dt(r,i,t)*xat(r,i,t)
       *   ((pat(r,i,t)$(not ifARMACES(i)) + patNDX(r,i,t)$ifARMACES(i))/pdt(r,i,t))**sigmamt(r,i))
       $(ArmSpec(r,i) eq aggArm and xddFlag(r,i))

*           Agent sourcing

       +  (sum(aa, gamma_edd(r,i,aa)*xd(r,i,aa,t)*(xd0(r,i,aa)/xdt0(r,i))))
       $(ArmSpec(r,i) ne aggArm and xddFlag(r,i))

*           Domestic supply of ITT services

       +   xtt(r,i,t)*(xtt0(r,i)/xdt0(r,i))
       ;

xmteq(r,i,t)$(ts(t) and rs(r) and xmtFlag(r,i) and ArmSpec(r,i) ne MRIOArm)..
   xmt(r,i,t)

*           National sourcing

      =e= (alpha_mt(r,i,t)*xat(r,i,t)
       *    ((pat(r,i,t)$(not ifARMACES(i)) + patNDX(r,i,t)$ifARMACES(i))/pmt(r,i,t))**sigmamt(r,i))
       $(ArmSpec(r,i) eq aggArm)

*           Agent sourcing

      +   (sum(aa, gamma_edm(r,i,aa)*xm(r,i,aa,t)*(xm0(r,i,aa)/xmt0(r,i))))
      $(ArmSpec(r,i) ne aggArm)
      ;

paNDXeq(r,i,aa,t)$(ts(t) and rs(r) and xaFlag(r,i,aa) and ArmSpec(r,i) ne aggArm and ifARMACES(i))..
   paNDX(r,i,aa,t) =e= (alpha_d(r,i,aa,t)*shrx0_D(r,i,aa)*M_PD(r,i,aa,t)**(-sigmam(r,i,aa))
                    +   alpha_m(r,i,aa,t)*shrx0_M(r,i,aa)*M_PM(r,i,aa,t)**(-sigmam(r,i,aa)))
                    **(1/(-sigmam(r,i,aa))) ;

paeq(r,i,aa,t)$(ts(t) and rs(r) and xaFlag(r,i,aa) and (ArmSpec(r,i) ne aggArm or (ArmSpec(r,i) eq aggArm and not ifSUB)))..
   pa(r,i,aa,t)

*           National sourcing

      =e= ((1 + paTax(r,i,aa,t))*gamma_eda(r,i,aa)*pat(r,i,t)*(pat0(r,i)/pa0(r,i,aa))
       +   sum(em, chiEmi(r,em,aa,t)*emir(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pa0(r,i,aa)))
       $(ArmSpec(r,i) eq aggArm)


*           Agent sourcing

       + ((alpha_d(r,i,aa,t)*shr0_D(r,i,aa)*M_PD(r,i,aa,t)**(1-sigmam(r,i,aa))
       +   alpha_m(r,i,aa,t)*shr0_M(r,i,aa)*M_PM(r,i,aa,t)**(1-sigmam(r,i,aa)))
       **(1/(1-sigmam(r,i,aa))))
       $(ArmSpec(r,i) ne aggArm and not ifARMACES(i))

       + ((paNDX(r,i,aa,t)**sigmam(r,i,aa))
       *    (shr0_D(r,i,aa)*M_PD(r,i,aa,t)**(1 - sigmam(r,i,aa))
       +     shr0_M(r,i,aa)*M_PM(r,i,aa,t)**(1 - sigmam(r,i,aa))))
       $(ArmSpec(r,i) ne aggArm and ifARMACES(i))
       ;

pa.lo(r,i,aa,t) = 0.001 ;

*  Top level -- Armington decomposition: agent sourcing

xdeq(r,i,aa,t)$(ts(t) and rs(r) and xdFlag(r,i,aa) and ArmSpec(r,i) ne aggArm)..
   xd(r,i,aa,t)
      =e= alpha_d(r,i,aa,t)*xa(r,i,aa,t)
       *   ((pa(r,i,aa,t)$(not ifARMACES(i)) + paNDX(r,i,aa,t)$ifARMACES(i))/M_PD(r,i,aa,t))
       **sigmam(r,i,aa) ;

xmeq(r,i,aa,t)$(ts(t) and rs(r) and xmFlag(r,i,aa) and ArmSpec(r,i) ne aggArm)..
   xm(r,i,aa,t)
      =e= alpha_m(r,i,aa,t)*xa(r,i,aa,t)
       *   ((pa(r,i,aa,t)$(not ifARMACES(i)) + paNDX(r,i,aa,t)$ifARMACES(i))/M_PM(r,i,aa,t))
       **sigmam(r,i,aa) ;

pdeq(r,i,aa,t)$(ts(t) and rs(r) and xdFlag(r,i,aa) and ArmSpec(r,i) ne aggArm and not ifSUB)..
   pd(r,i,aa,t)
      =e= (1 + pdtax(r,i,aa,t))*gamma_edd(r,i,aa)*pdt(r,i,t)*(pdt0(r,i)/pd0(r,i,aa))
       +  sum(em, chiEmi(r,em,aa,t)*emird(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pd0(r,i,aa)) ;

pd.lo(r,i,aa,t) = 0.001 ;

pmeq(r,i,aa,t)$(ts(t) and rs(r) and xmFlag(r,i,aa) and ArmSpec(r,i) ne aggArm and not ifSUB)..
$iftheni "%MRIO_MODULE%" == "ON"
   pm(r,i,aa,t)
      =e= ((1 + pmtax(r,i,aa,t))*gamma_edm(r,i,aa)
       *    (pma0(r,i,aa)*pma(r,i,aa,t))/pm0(r,i,aa)
       +  sum(em, chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pm0(r,i,aa)))
       $(ArmSpec(r,i) eq MRIOArm)
       +  ((1 + pmtax(r,i,aa,t))*gamma_edm(r,i,aa)
       *    (pmt0(r,i)*pmt(r,i,t))/pm0(r,i,aa)
       +  sum(em, chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pm0(r,i,aa)))
       $(ArmSpec(r,i) eq stdArm)
       ;
$else
   pm(r,i,aa,t)
      =e= ((1 + pmtax(r,i,aa,t))*gamma_edm(r,i,aa)
       *    (pmt0(r,i)*pmt(r,i,t))/pm0(r,i,aa)
       +  sum(em, chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax(r,em,aa,t)/pm0(r,i,aa)))
       ;
$endif

pm.lo(r,i,aa,t) = 0.001 ;

*  Second level Armington

$iftheni "%MRIO_MODULE%" == "ON"

*  Second level by agent

*  !!!! NEED TO TRACK DOWN WHY MACRO DOES NOT WORK WITH PDMA !!!!

xwaeq(s,i,r,aa,t)$(ts(t) and rs(r) and xwaFlag(s,i,r,aa) and (ArmSpec(r,i) eq MRIOArm))..
   xwa(s,i,r,aa,t) =e= (xm(r,i,aa,t)*(pma(r,i,aa,t)/M_PDMA(s,i,r,aa,t))**sigmawa(r,i,aa))$ifSUB
                    +  (xm(r,i,aa,t)*(pma(r,i,aa,t)/PDMA(s,i,r,aa,t))**sigmawa(r,i,aa))$(not ifSUB) ;

*  Aggregate import price by agent

pmaeq(r,i,aa,t)$(ts(t) and rs(r) and xmFlag(r,i,aa) and ArmSpec(r,i) eq MRIOArm)..
   xm(r,i,aa,t)*pma(r,i,aa,t)
      =e= sum(s$xwaFlag(s,i,r,aa), (pdma0(s,i,r,aa)*xwa0(s,i,r,aa)/(xm0(r,i,aa)*pma0(r,i,aa)))
       *    (M_PDMA(s,i,r,aa,t)$ifSUB + pdma(s,i,r,aa,t)$(not ifSUB))*xwa(s,i,r,aa,t)) ;

pma.lo(r,i,aa,t) = 0.001 ;

*  Bilateral import price by agent tariff inclusive

pdmaeq(s,i,r,aa,t)$(ts(t) and rs(r) and xwaFlag(s,i,r,aa) and ArmSpec(r,i) eq MRIOArm and not ifSUB)..
   pdma(s,i,r,aa,t) =e= (1 + mtaxa(s,i,r,aa,t))*M_PWM(s,i,r,t)*(pwm0(s,i,r)/pdma0(s,i,r,aa))
                     +   M_SPCTAR(s,i,r,t) / pdma0(s,i,r,aa) ;

pdma.lo(s,i,r,aa,t) = 0.001 ;

*  Total bilateral trad is simple aggregation across Armington agents

xwdMRIOeq(s,i,r,t)$(ts(t) and rs(r) and xwFlag(s,i,r) and ArmSpec(r,i) eq MRIOArm)..
   xw(s,i,r,t) =e= sum(aa, xwa(s,i,r,aa,t)*(xwa0(s,i,r,aa)/(xw0(s,i,r)*lambdaw(s,i,r,t)))) ;

$endif

*  Second level CES at national level

xwdeq(s,i,r,t)$(ts(t) and sd(s,r) and xwFlag(s,i,r) and ArmSpec(r,i) ne MRIOArm)..
   xw(s,i,r,t)
      =e= (alpha_w(s,i,r,t)*xmt(r,i,t)/(lambdax(s,i,r,t)*lambdaw(s,i,r,t)))
       *    ((pmt(r,i,t)$(not ifARMACES(i)) + pmtNDX(r,i,t)$ifARMACES(i))/M_PDM(s,i,r,t))
       **sigmaw(r,i) ;

*  Composite price of import bundle

pmtNDXeq(r,i,t)$(ts(t) and rs(r) and xmtFlag(r,i) and ifARMACES(i) and ArmSpec(r,i) ne MRIOArm)..
   pmtNDX(r,i,t) =e= sum(s, alpha_w(s,i,r,t)*shrx0_w(s,i,r)*M_PDM(s,i,r,t)**(-sigmaw(r,i)))
                  **(1/(-sigmaw(r,i))) ;

*  Price of import bundle

pmteq(r,i,t)$(ts(t) and rs(r) and xmtFlag(r,i) and ArmSpec(r,i) ne MRIOArm)..
   pmt(r,i,t)
      =e= (sum(s, alpha_w(s,i,r,t)*shr0_w(s,i,r)*M_PDM(s,i,r,t)**(1-sigmaw(r,i)))
       **(1/(1-sigmaw(r,i))))
       $(not ifARMACES(i))
       +  (sum(s, shr0_w(s,i,r)*M_PDM(s,i,r,t)*xw(s,i,r,t)) / xmt(r,i,t))
       $ifARMACES(i)
       ;

pmt.lo(r,i,t) = 0.001 ;

$ontext
mtaxeq(s,i,d,t)$(ts(t) and rs(r) and xwFlag(s,i,d) and trqFlag(s,i,d))..
   mtax(s,i,d,t) =e= mtax_in(s,i,d,t) + mtax_pr(s,i,d,t) ;

xw_inqeq(s,i,d,t)$(ts(t) and rs(r) and xwFlag(s,i,d) and trqFlag(s,i,d))..
   xw_inq(s,i,d,t) =l= xw_quota(s,i,d,t) ;

mtax_pr.lo(s,i,d,t)$(ts(t) and rs(r) and xwFlag(s,i,d) and trqFlag(s,i,d)) = 0 ;

mtax_preq(s,i,d,t)$(ts(t) and rs(r) and xwFlag(s,i,d) and trqFlag(s,i,d))..
   mtax_out(s,i,d,t) =g= mtax_in(s,i,d,t) + mtax_pr(s,i,d,t) ;

xw_out.lo(s,i,d,t)$(ts(t) and rs(r) and xwFlag(s,i,d) and trqFlag(s,i,d)) = 0 ;

xw_outqeq(s,i,d,t)$(ts(t) and rs(r) and xwFlag(s,i,d) and trqFlag(s,i,d))..
   lambdaw(s,i,d,t)*xw(s,i,d,t) =e= xw_inq(s,i,d,t) + xw_outq(s,i,d,t) ;
$offtext

* --------------------------------------------------------------------------------------------------
*
*   DOMESTIC AND EXPORT SUPPLY BLOCK
*
* --------------------------------------------------------------------------------------------------

pdteq(r,i,t)$(ts(t) and rs(r) and xdtFlag(r,i))..
   0 =e=

*        Finite transformation

         (xdt(r,i,t) - xs(r,i,t)*(pdt(r,i,t)/(ps(r,i,t)$(not ifARMACES(i))
            + psNDX(r,i,t)$ifARMACES(i)))**omegax(r,i))
      $(omegax(r,i) ne inf)

*        Perfect transformation

      +  (pdt(r,i,t) - gamma_esd(r,i)*ps(r,i,t)*(ps0(r,i)/pdt0(r,i)))
      $(omegax(r,i) eq inf) ;

pdt.lo(r,i,t) = 0.001 ;

xeteq(r,i,t)$(ts(t) and rs(r) and xetFlag(r,i))..
   0 =e=

*        Finite transformation

         (xet(r,i,t) - xs(r,i,t)*(pet(r,i,t)/(ps(r,i,t)$(not ifARMACES(i))
            + psNDX(r,i,t)$ifARMACES(i)))**omegax(r,i))
      $(omegax(r,i) ne inf)

*        Perfect transformation

      +  (pet(r,i,t) - gamma_ese(r,i)*ps(r,i,t)*(ps0(r,i)/pet0(r,i)))
      $(omegax(r,i) eq inf) ;

* pet.lo(r,i,t) = 0.001 ;

xseq(r,i,t)$(ts(t) and rs(r) and xsFlag(r,i))..
   0 =e=

*        Finite transformation--standard CET

         (ps(r,i,t)**(1+omegax(r,i))
      -     (shr0_dx(r,i,t)*pdt(r,i,t)**(1+omegax(r,i))
      +      shr0_ex(r,i,t)*pet(r,i,t)**(1+omegax(r,i))))
      $(omegax(r,i) ne inf and not ifARMACES(i))

*        Finite transformation--ACET

      +  (ps(r,i,t) - (psNDX(r,i,t)**(-omegax(r,i)))
      *     (shr0_dx(r,i,t)*pdt(r,i,t)**(1+omegax(r,i))
      +      shr0_ex(r,i,t)*pet(r,i,t)**(1+omegax(r,i))))
      $(omegax(r,i) ne inf and ifARMACES(i))

*        Perfect transformation

      +  (xs(r,i,t) - (gamma_esd(r,i)*xdt(r,i,t)*(xdt0(r,i)/xs0(r,i))
      +                gamma_ese(r,i)*xet(r,i,t)*(xet0(r,i)/xs0(r,i))))
      $(omegax(r,i) eq inf)
      ;

ps.lo(r,i,t) = 0.001 ;

psNDXeq(r,i,t)$(ts(t) and rs(r) and xsFlag(r,i)
   and (ifARMACES(i) and omegax(r,i) ne INF and omegax(r,i) ne 0))..

   psNDX(r,i,t) =e= (shrx0_dx(r,i,t)*pdt(r,i,t)**omegax(r,i)
                 +   shrx0_ex(r,i,t)*pet(r,i,t)**omegax(r,i))**(1/omegax(r,i))
                 ;

xwseq(r,i,d,t)$(ts(t) and sd(r,d) and xwFlag(r,i,d)
               and (ifGbl or (not ifGbl and omegaw(r,i) ne inf)))..

   0 =e= (xw(r,i,d,t) - xet(r,i,t)*(pe(r,i,d,t)/(pet(r,i,t)$(not ifARMACES(i))
      + petNDX(r,i,t)$ifARMACES(i)))**omegaw(r,i))
      $(omegaw(r,i) ne inf)

      +  (pe(r,i,d,t) - pet(r,i,t))
      $(omegaw(r,i) eq inf) ;

peteq(r,i,t)$(ts(t) and rs(r) and xetFlag(r,i))..

*        Finite transformation--normal CET

   0 =e= (pet(r,i,t)**(1+omegaw(r,i))
      -     sum(d$xwFlag(r,i,d), shr0_wx(r,i,d,t)*pe(r,i,d,t)**(1+omegaw(r,i))))
      $(omegaw(r,i) ne inf and not ifARMACES(i))

*        Finite transformation--ACET

      +  (pet(r,i,t) - (petNDX(r,i,t)**(-omegaw(r,i)))
      *     sum(d$xwFlag(r,i,d), shr0_wx(r,i,d,t)*pe(r,i,d,t)**(1+omegaw(r,i))))
      $(omegax(r,i) ne inf and ifARMACES(i))

*        Infinite transformation

      +  (xet(r,i,t) - sum(d$xwFlag(r,i,d), gamma_ew(r,i,d)*(xw0(r,i,d)/xet0(r,i))*xw(r,i,d,t)))
      $(omegaw(r,i) eq inf)
      ;

petNDXeq(r,i,t)$(ts(t) and rs(r) and xetFlag(r,i)
      and (ifARMACES(i) and omegaw(r,i) ne INF and omegaw(r,i) ne 0))..

   petNDX(r,i,t) =e= sum(d$xwFlag(r,i,d), shrx0_wx(r,i,d,t)*pe(r,i,d,t)**(omegaw(r,i)))
                  **(1/omegaw(r,i)) ;

*  Other bilateral prices

pweeq(r,i,d,t)$(ts(t) and rs(r) and sd(r,d) and xwFlag(r,i,d) and not ifSUB)..
   pwe(r,i,d,t) =e= (1 + etax(r,i,d,t) + etaxi(r,i,t))*pe(r,i,d,t)*(pe0(r,i,d)/pwe0(r,i,d)) ;

pwmeq(r,i,d,t)$(ts(t) and rs(r) and sd(r,d) and xwFlag(r,i,d) and not ifSUB)..
   pwm(r,i,d,t) =e=
      pwe(r,i,d,t)*(pwe0(r,i,d)/(lambdaw(r,i,d,t)*lambdax(r,i,d,t)*pwm0(r,i,d)))
   +  tmarg(r,i,d,t)*M_PWMG(r,i,d,t)/(lambdaw(r,i,d,t)*lambdax(r,i,d,t)*pwm0(r,i,d)) ;

pdmeq(r,i,d,t)$(ts(t) and rs(r) and sd(r,d) and xwFlag(r,i,d) and not ifSUB and ArmSpec(r,i) ne MRIOArm)..
   pdm(r,i,d,t) =e= (1 + mtax(r,i,d,t) + ntmAVE(r,i,d,t))*pwm(r,i,d,t)
                 *     (pwm0(r,i,d)/pdm0(r,i,d))
                 +     M_SPCTAR(r,i,d,t)/pdm0(r,i,d) ;

pe.lo(r,i,d,t) = 0.001 ;

* --------------------------------------------------------------------------------------------------
*
*   TRADE MARGINS BLOCK
*
* --------------------------------------------------------------------------------------------------

*  Total demand for TT services from r to d for good i

xwmgeq(r,i,d,t)$(ts(t) and rs(r) and tmgFlag(r,i,d) and not ifSUB)..
   xwmg(r,i,d,t) =e= tmarg(r,i,d,t)*xw(r,i,d,t)*(xw0(r,i,d)/xwmg0(r,i,d)) ;

*  Demand for TT services using m from r to rp for good i

xmgmeq(img,r,i,d,t)$(ts(t) and rs(r) and shr0_mgm(img,r,i,d) ne 0 and not ifSUB)..
   xmgm(img,r,i,d,t) =e= xwmg(r,i,d,t)/lambdamg(img,r,i,d,t) ;

*  The aggregate price of transporting i between r and rp
*  Note--the price per transport mode is uniform globally

pwmgeq(r,i,d,t)$(ts(t) and rs(r) and tmgFlag(r,i,d) and not ifSUB)..
   pwmg(r,i,d,t) =e= sum(img, shr0_mgm(img,r,i,d)*ptmg(img,t)/lambdamg(img,r,i,d,t)) ;

*  Global demand for TT services of type m

xtmgeq(img,t)$(ts(t))..
   xtmg(img,t) =e= sum((r,i,d)$xmgm0(img,r,i,d),
      M_XMGM(img,r,i,d,t)*(xmgm0(img,r,i,d)/xtmg0(img))) ;

*  Allocation across regions

xtteq(r,img,t)$(ts(t) and rs(r) and xttFlag(r,img) ne 0)..
   xtt(r,img,t) =e= xtmg(img,t)*(ptmg(img,t)/pdt(r,img,t))**sigmamg(img) ;

*  The average global price of mode m

ptmgeq(img,t)$(ts(t))..
   ptmg(img,t) =e= sum(r, shr0_xtmg(r,img,t)*pdt(r,img,t)**(1-sigmamg(img)))**(1/(1-sigmamg(img))) ;
*  ptmg(img,t)*xtmg(img,t) =e= sum(r, pdt(r,img,t)*xtt(r,img,t)
*                           * (pdt0(r,img)*xtt0(r,img)/(ptmg0(img)*xtmg0(img)))) ;

$iftheni "%DEPL_MODULE%" == "ON"

* --------------------------------------------------------------------------------------------------
*
*   Resource depletion module
*
*  01-Feb-2019
*
*     Coal is only extracted. Oil and gas are extracted and convert unproven to proven reserves
*
* --------------------------------------------------------------------------------------------------

prateq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   prat(r,a,t)*ptrend(r,a,t)
      =e= ((px(r,a,t)/pgdpmp(r,t))/(px(r,a,tLag)/pgdpmp(r,tLag)))**(1/gap(t)) ;

omegareq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   omegar(r,a,t) =e= omegard(r,a,"lo",t) + (omegard(r,a,"hi",t)-omegard(r,a,"lo",t))
                  *     sigmoid(kink*(prat(r,a,t)-1)) ;

dscRateeq(r,a,t)$(rs(r) and ts(t) and ifDsc(r,a))..
   dscRate(r,a,t) =g= chidscRate(r,a,t)*dscRate0(r,a,"ref")*prat(r,a,t)**omegar(r,a,t) ;

extrateeq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   extRate(r,a,t)
      =e= (chiextRate(r,a,t)*extRate(r,a,tLag)*prat(r,a,t)**omegar(r,a,t))$(not ifDsc(r,a))
       +  (chiextRate(r,a,t)*extRate(r,a,tLag)*prat(r,a,t)**omegae(r,a,t))$ifDsc(r,a)
       ;

cumexteq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   cumExt(r,a,t) =e= (0.5*gap(t)*(extr(r,a,t) + extr(r,a,tLag))
                  *     (extr0(r,a)/cumext0(r,a)))$(gap(t) gt 1)
                  +  (extr(r,a,tLag)*(extr0(r,a)/cumExt0(r,a)))$(gap(t) eq 1)
                  ;
$ontext
   0 =e= (cumExt(r,a,t)*(((extr(r,a,t)/extr(r,a,tLag))**(1/gap(t))) - 1)
      -     ((extr0(r,a)/cumExt0(r,a))*(extr(r,a,t) - extr(r,a,tLag))))$(gap(t) gt 1)
      +  (cumExt(r,a,t) - extr(r,a,tLag)*(extr0(r,a)/cumExt0(r,a)))$(gap(t) eq 1);
$offtext

cumExt.lo(r,a,t) = 0 ;

reseq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   res(r,a,t)*res0(r,a) =e= res(r,a,tLag)*res0(r,a) - cumExt(r,a,t)*cumExt0(r,a)
               + ((1 - power((1-dscRate(r,a,t)),gap(t)))*ytdres(r,a,tLag)*ytdRes0(r,a))
               $ifDsc(r,a) ;

*  Reserve level if on reserve profile

respeq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   resp(r,a,t)*resp0(r,a)
               =e= (power(1-extRate(r,a,t),gap(t))*resp(r,a,tLag)*resp0(r,a)
                +    (dscRate(r,a,t)*ytdres(r,a,tLag)*ytdRes0(r,a)
                *       (power((1-dscRate(r,a,t)),gap(t))
                -        power(1-extrate(r,a,t),gap(t)))
                /       ((1-dscRate(r,a,t)) - (1-extRate(r,a,t))))$(ifDsc(r,a)))
                $(gap(t) gt 1)
                +  ((1-extRate(r,a,t))*resp(r,a,tLag)*resp0(r,a)
                +    (dscRate(r,a,t)*ytdres(r,a,tLag)*ytdRes0(r,a))$(ifDsc(r,a)))
                $(gap(t) eq 1) ;

*  Level of yet-to-discover reserves

ytdreseq(r,a,t)$(rs(r) and ts(t) and ifDsc(r,a))..
   ytdres(r,a,t) =e= power((1 - dscRate(r,a,t)), gap(t))*ytdres(r,a,tLag) ;

*  Gap between actual reserves and reserve potential

resGapeq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   resGap(r,a,t) =g= res(r,a,t)*res0(r,a) - resP(r,a,t)*resp0(r,a) ;

*  Potential supply -- ifResPFlag  Regions/fuels on reserve profile

xfPoteq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   xfPot(r,a,t)*xfPot0(r,a) =e= extRate(r,a,t)*resP(r,a,t)*resp0(r,a)
                             + (resGap(r,a,t) / gap(t))$(not ifResPFlag(r,a)) ;

*  Level of extraction--temporarily set to grow at same rate as xf

extreq(r,a,t)$(rs(r) and ts(t) and ifDepl(r,a))..
   extr(r,a,t) =e= extr(r,a,tLag)*sum(nrs, xf(r,nrs,a,t)/xf(r,nrs,a,tLag)) ;

$endif

* --------------------------------------------------------------------------------------------------
*
*   FACTOR MARKETS
*
* --------------------------------------------------------------------------------------------------

*  Labor market

*  Labor demand by zone

ldzeq(r,l,z,t)$(ts(t) and rs(r) and lsFlag(r,l,z))..
   ldz(r,l,z,t) =e= sum(a$mapz(z,a), (xf(r,l,a,t)*(xf0(r,l,a)/ldz0(r,l,z)))) ;

*  Reservation wage -- depends on GDP growth, unemployment rate and CPI

resWageeq(r,l,z,t)$(ts(t) and rs(r) and lsFlag(r,l,z) and ueFlag(r,l,z) eq resWageUE)..
   resWage(r,l,z,t) =e= (chirw(r,l,z,t)*resWage(r,l,z,tLag))
                     *  (power(1+0.01*grrgdppc(r,t),gap(t))**omegarwg(r,l,z))
                     *  ((1-uez(r,l,z,t))**omegarwue(r,l,z))
                     *  (sum(h, pfd(r,h,t))**omegarwp(r,l,z))
                     ;
*  Equilibrium wage in each zone -- MCP with lower limit on UE

ewagezeq(r,l,z,t)$(ts(t) and rs(r) and ueFlag(r,l,z) eq resWageUE)..
   ewagez(r,l,z,t) =g= resWage(r,l,z,t)*(resWage0(r,l,z)/ewagez0(r,l,z)) ;

*  'Monash' style wage formulation -- only to be used for dynamic scenarios

Variable
   rwage(r,l,z,t)       "Real equilibrium wage for zone z and labor l"
   errW(r,l,z,t)        "Shift factor for real wage equation"
;

Parameters
   rwage0(r,l,z)        "Initial real equilibrium wage for zone z and labor l"
   rwageBaU(r,l,z,t)    "Baseline real wage"
   ldzBaU(r,l,z,t)      "Baseline labor demand for 'l'"

   chil(r,l,z,t)        "Average adjustment time wrt to labor deviation"
   etal(r,l,z)          "Elasticity of long-run demand for labor wrt to shocks"
;

set FEFLAG(r,l) ;

Equations
   ewagezDReq(r,l,z,t)  "Wage determination with Monash closure"
   rwageeq(r,l,z,t)     "Real wage by zone"
;

*ewagezDReq(r,l,z,t)$(ts(t) and rs(r) and lsFlag(r,l,z) and ifCal ne 1 and ueFlag(r,l,z) eq MonashUE)..
ewagezDReq(r,l,z,t)$(ts(t) and rs(r) and lsFlag(r,l,z) and ifCal ne 1 and FEFLAG(r,l))..
   rwage(r,l,z,t)/rwageBaU(r,l,z,t) - 1
      =e= (rwage(r,l,z,tLag)/rwageBaU(r,l,z,tLag) - 1)
       +  chil(r,l,z,t)*(ldz(r,l,z,t)/ldzBaU(r,l,z,t)
       -  (rwage(r,l,z,tLag)/rwageBaU(r,l,z,tLag))**etal(r,l,z))
       +  errW(r,l,z,t) ;

*  'Equilibrium condition' -- also defines UE

uezeq(r,l,z,t)$(ts(t) and rs(r) and lsFlag(r,l,z))..
   (1-uez(r,l,z,t))*lsz(r,l,z,t) =e= ldz(r,l,z,t)*(ldz0(r,l,z)/lsz0(r,l,z)) ;

*  Real wage

rwageeq(r,l,z,t)$(ts(t) and rs(r) and lsFlag(r,l,z))..
   rwage(r,l,z,t) =e= (awagez0(r,l,z)/rwage0(r,l,z))
                   *   awagez(r,l,z,t)/sum(h, cpi(r,h,"Tot",t)*cpi0(r,h,"Tot")) ;

*  Definition of sectoral wage net of tax

wageeq(r,l,a,t)$(ts(t) and rs(r) and xfFlag(r,l,a) and FEFlag(r,l))..
   pf(r,l,a,t) =e= sum(z$(mapz(z,a) and lsFlag(r,l,z)),
      wPrem(r,l,a,t)*ewagez(r,l,z,t)*(ewagez0(r,l,z)/pf0(r,l,a))) ;

pf.lo(r,f,a,t) = 0.001 ;

equation
   pfLabeq(r,l,a,t)     "Labor equilibrium with fixed sector supply"
;

pfLabeq(r,l,a,t)$(ts(t) and rs(r) and xfFlag(r,l,a) and not FEFlag(r,l))..
   xfs(r,l,a,t) =g= xf(r,l,a,t) ;

*  Average wage in each zone

awagezeq(r,l,z,t)$(ts(t) and rs(r) and lsFlag(r,l,z))..
   awagez(r,l,z,t) =e= sum(a$mapz(z,a), pf(r,l,a,t)*xf(r,l,a,t)
                    *      (pf0(r,l,a)*xf0(r,l,a)/awagez0(r,l,z)))
                    /  sum(a$mapz(z,a), (xf0(r,l,a)*xf(r,l,a,t))) ;

*  Expected urban premium

urbPremeq(r,l,t)$(ts(t) and rs(r) and tLabFlag(r,l) and (omegam(r,l) ne inf))..
   urbPrem(r,l,t)*sum(rur, (1-uez(r,l,rur,t))*awagez(r,l,rur,t)*(urbprem0(r,l)*awagez0(r,l,rur)))
      =e= sum(urb, (1-uez(r,l,urb,t))*awagez(r,l,urb,t)*awagez0(r,l,urb)) ;

*  Average economy-wide wage per skill (should equal awagez with no segmentation)

twageeq(r,l,t)$(ts(t) and rs(r) and tlabFlag(r,l))..
   twage(r,l,t) =e= sum(a, pf(r,l,a,t)*xf(r,l,a,t)*(pf0(r,l,a)*xf0(r,l,a)/twage0(r,l)))
                 /  sum(a, (xf0(r,l,a)*xf(r,l,a,t))) ;

*  Definition of skill premium relative to 'skill' bundle

skillpremeq(r,l,t)$(ts(t) and rs(r) and tlabFlag(r,l))..
   (1 + skillprem(r,l,t))*twage(r,l,t)
      =e= sum(lr, twage(r,lr,t)*ls(r,lr,t)*((twage0(r,lr)*ls0(r,lr))/twage0(r,l)))
       /  sum(lr, ls(r,lr,t)*ls0(r,lr)) ;

*  Definition of aggregate labor supply by skill

lseq(r,l,t)$(ts(t) and rs(r) and tlabFlag(r,l))..
   ls(r,l,t) =e= sum(z$lsFlag(r,l,z), lsz(r,l,z,t)*lsz0(r,l,z)/ls0(r,l)) ;

*  Definition of aggregate labor supply

tlseq(r,t)$(ts(t) and rs(r))..
   tls(r,t) =e= sum(l, ls(r,l,t)*(ls0(r,l)/tls0(r))) ;

*  Capital market
*  In CS version, use kslo as capital supply

kvseq(r,a,v,t)$(ts(t) and rs(r) and kflag(r,a) and not ifVint)..
   0 =e= (kslo(r,a,t) - tkaps(r,t)*(pk(r,a,v,t)/trent(r,t))**omegak(r))
      $(omegak(r) ne inf and omegak(r) ne 0)

      +  (kslo(r,a,t) - tkaps(r,t))
      $(omegak(r) eq 0)

      +  (pk(r,a,v,t) - trent(r,t))
      $(omegak(r) eq inf)
      ;

pk.lo(r,a,v,t) = 0.001 ;

trenteq(r,t)$(ts(t) and rs(r))..
   0 =e= (trent(r,t) - sum((a,v)$vOld(v),
            shr0_kvs(r,a,v)*pk(r,a,v,t)**(1+omegak(r)))**(1/(1+omegak(r))))
      $(not ifVint and omegak(r) ne inf and omegak(r) ne 0)

      +  (trent(r,t) - sum((a,v)$vOld(v),
            shr0_kvs(r,a,v)*pk(r,a,v,t)))
      $(not ifVint and omegak(r) eq 0)

      +  (tkaps(r,t) - sum((a,v),
            kv(r,a,v,t)*kv0(r,a)/tkaps0(r)))
      $(not ifVint and omegak(r) eq inf)

      +  (tkaps(r,t) - sum((a,v), kv(r,a,v,t)*(kv0(r,a)/tkaps0(r))))
      $ifVint
      ;

pkeq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a))..
   0 =e= (kslo(r,a,t) - kv(r,a,v,t))
      $(not ifVint)

      +  (pk(r,a,v,t) - rrat(r,a,t)*trent(r,t)*(trent0(r)/pk0(r,a)))
      $ifVint
      ;

Equation
   capuVeq(r,a,v,t)      "Put a lower cap on pk -- cap utilization takes the slack"
;

capuVeq(r,a,v,t)$(ts(t) and vOld(v) and rs(r) and kFlag(r,a))..
   0.25*trent(r,t)*trent0(r) =l= pk0(r,a)*pk(r,a,v,t) ;

rtrenteq(r,t)$(ts(t) and rs(r))..
   trent(r,t) =e= rtrent(r,t)*pgdpmp(r,t)*(rtrent0(r)*pgdpmp0(r)/trent0(r)) ;

*  Capital market -- dynamics

*  Capital supply for finite disinvestment elasticity

ksloeq(r,a,t)$(ts(t) and rs(r) and ifVint and invElas(r,a) ne inf and kfFlag(r,a))..
   (kslo(r,a,t) - k0(r,a,t)*rrat(r,a,t)**invElas(r,a))$(invElas(r,a))
   +  (kslo(r,a,t) - k0(r,a,t))$(invElas(r,a) eq 0) =e= 0 ;

rrat.lo(r,a,t)    = 0 ;
rrat.up(r,a,t)    = 1 ;
xpv.lo(r,a,v,t)   = 0 ;

rrateq(r,a,t)$(ts(t) and rs(r) and ifVint and kfFlag(r,a))..
   rrat(r,a,t)**invElas(r,a) =l= (kxrat0(r,a)*xp0(r,a)/(k00(r,a)*k0(r,a,t)))
      * sum(vOld, kxRat(r,a,vOld,t)*xp(r,a,t)) ;

kshieq(r,a,t)$(ts(t) and rs(r) and ifVint and kfFlag(r,a))..
   kslo(r,a,t) + kshi(r,a,t) =g= sum(v, kv(r,a,v,t)) ;

*  Capital supply for infinite disinvestment elasticity

ksloinfeq(r,a,t)$(ts(t) and rs(r) and invElas(r,a) eq inf and ifVint and kfFlag(r,a))..
   kslo(r,a,t) =g= sum(vOld, kv(r,a,vOld,t)) ;

rratinfeq(r,a,t)$(ts(t) and rs(r) and ifVint and invElas(r,a) eq inf and kfFlag(r,a))..
   rrat(r,a,t) =e= 1 ;

kxRateq(r,a,vOld,t)$(ts(t) and rs(r) and ifVint and kFlag(r,a))..
   kxRat(r,a,vOld,t) =e= (kv(r,a,vOld,t)/xpv(r,a,vOld,t))
                      *  (kv0(r,a)/(kxRat0(r,a)*xpv0(r,a))) ;

*  Vintage output allocation

xpveq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a))..

*     The first condition is only used for the vintage model

   0 =e= (xpv(r,a,v,t)*kxRat(r,a,v,t)*(xpv0(r,a)*kxRat0(r,a)/kv0(r,a)) - kslo(r,a,t))
      $(vOld(v) and ifVint)

*     The following condition is good for CS and Vintage

      +  (xp(r,a,t) - sum(vp, xpv(r,a,vp,t)*(xpv0(r,a)/xp0(r,a))))
      $vNew(v) ;

xpv.lo(r,a,vOld,t) = 1e-7 ;

*  Capital aggregation

capeq(r,cap,a,t)$(ts(t) and rs(r) and xfFlag(r,cap,a))..
   0 =e= (xf(r,cap,a,t) - sum(v, (kv0(r,a)/xf0(r,cap,a))*capu(r,a,v,t)*kv(r,a,v,t))) ;

pcapeq(r,cap,a,t)$(ts(t) and rs(r) and xfFlag(r,cap,a))..
   pf(r,cap,a,t) =e= sum(vOld, (pk0(r,a)/pf0(r,cap,a))*pk(r,a,vOld,t)) ;

arenteq(r,t)$(ts(t) and rs(r))..
   arent(r,t) =e= sum((a,v), pk(r,a,v,t)*kv(r,a,v,t0)*(pk0(r,a)*kv0(r,a)))
               /  sum((a,v), pk(r,a,v,t0)*kv(r,a,v,t0)*(pk0(r,a)*kv0(r,a))) ;

*  Land markets

*  Land supply

*  !!!! Check implementation of dam_lnd for the LOGIST and HYPERB cases

tlandeq(r,lnd,t)$(ts(t) and rs(r) and tlandFlag(r,lnd))..
   0 =e= (tland(r,lnd,t)/dam_lnd(r,lnd,t) - (chiLand(r,lnd,t)/tland0(r,lnd))
      *     ((ptland(r,lnd,t)/pgdpmp(r,t))*(ptland0(r,lnd)/pgdpmp0(r)))**etat(r,lnd))
      $(landAss(r) eq KELAS)

      +  (tland(r,lnd,t)/dam_lnd(r,lnd,t) - ((LandMax(r,lnd,t)/tland0(r,lnd))
      /     (1 + chiLand(r,lnd,t)
      *        exp(-gammatl(r,lnd,t)*(ptland(r,lnd,t)/pgdpmp(r,t))*(ptland0(r,lnd)/pgdpmp0(r))))))
      $(landAss(r) eq LOGIST)

      +  (tland(r,lnd,t)/dam_lnd(r,lnd,t) - ((LandMax(r,lnd,t)/tland0(r,lnd)) - (chiLand(r,lnd,t)/tland0(r,lnd))
      *     (ptland(r,lnd,t)/pgdpmp(r,t))*(ptland0(r,lnd)/pgdpmp0(r))**(-gammatl(r,lnd,t))))
      $(landAss(r) eq HYPERB)

      +  (ptland(r,lnd,t) - pgdpmp(r,t)*(pgdpmp0(r)/ptland0(r,lnd)))$(landAss(r) eq INFTY)
      ;

$ontext


                     TLAND
                      / \
                     /   \
                    /     \
                   /       \
                 LB(1)    NLB
                          /|\
                         / | \
                        /  |  \
                       /   |   \
                    LB(2) LB(3) LB(4)

                       Land by activity


$offtext

*  Top level nest

xlb1eq(r,lnd,lb,t)$(ts(t) and rs(r) and lb1(lb) and shr0_lb(r,lnd,lb,t) ne 0)..
   0 =e= (plb(r,lnd,lb,t) - ptland(r,lnd,t))
      $(omegat(r,lnd) eq inf)

      +  (xlb(r,lnd,lb,t) - tland(r,lnd,t)*(plb(r,lnd,lb,t)/ptlandndx(r,lnd,t))**omegat(r,lnd))
      $(omegat(r,lnd) ne inf)
      ;

xnlbeq(r,lnd,t)$(ts(t) and rs(r) and shr0_nlb(r,lnd,t) ne 0)..
   0 =e= (pnlb(r,lnd,t) - ptland(r,lnd,t))
      $(omegat(r,lnd) eq inf)

      +  (xnlb(r,lnd,t) - tland(r,lnd,t)*(pnlb(r,lnd,t)/ptlandndx(r,lnd,t))**omegat(r,lnd))
      $(omegat(r,lnd) ne inf)
      ;

ptlandndxeq(r,lnd,t)$(ts(t) and rs(r) and tlandFlag(r,lnd) and omegat(r,lnd) ne inf)..
   0 =e= (ptlandndx(r,lnd,t)**(1+omegat(r,lnd))
      -     (sum(lb1, shr0_lb(r,lnd,lb1,t)*plb(r,lnd,lb1,t)**(1+omegat(r,lnd)))
      +               shr0_nlb(r,lnd,t)*pnlb(r,lnd,t)**(1+omegat(r,lnd))))
      $(ifLandCET)

      +  (ptlandndx(r,lnd,t)**omegat(r,lnd)
      -     (sum(lb1, shr0_lb(r,lnd,lb1,t)*plb(r,lnd,lb1,t)**omegat(r,lnd))
      +               shr0_nlb(r,lnd,t)*pnlb(r,lnd,t)**omegat(r,lnd)))
      $(not ifLandCET)
      ;

ptlandeq(r,lnd,t)$(ts(t) and rs(r) and tlandFlag(r,lnd))..
   ptland(r,lnd,t)*tland(r,lnd,t) =e=
         sum(lb1, plb(r,lnd,lb1,t)*xlb(r,lnd,lb1,t)*(plb0(r,lnd,lb1)*xlb0(r,lnd,lb1)/(ptland0(r,lnd)*tland0(r,lnd))))
      +  pnlb(r,lnd,t)*xnlb(r,lnd,t)*(pnlb0(r,lnd)*xnlb0(r,lnd)/(ptland0(r,lnd)*tland0(r,lnd))) ;

ptland.lo(r,lnd,t) = 0.001 ;

*  Second level nest

xlbneq(r,lnd,lb,t)$(ts(t) and rs(r) and (not lb1(lb)) and shr0_lb(r,lnd,lb,t) ne 0)..
   0 =e= (plb(r,lnd,lb,t) - pnlb(r,lnd,t))
      $(omeganlb(r,lnd) eq inf)

      +  (xlb(r,lnd,lb,t) - xnlb(r,lnd,t)*(plb(r,lnd,lb,t)/pnlbndx(r,lnd,t))**omeganlb(r,lnd))
      $(omeganlb(r,lnd) ne inf)
      ;

pnlbndxeq(r,lnd,t)$(ts(t) and rs(r) and shr0_nlb(r,lnd,t) ne 0 and omeganlb(r,lnd) ne inf)..
   0 =e= (pnlbndx(r,lnd,t)**(1+omeganlb(r,lnd))
      -        sum(lb$(not lb1(lb)), shr0_lb(r,lnd,lb,t)*plb(r,lnd,lb,t)**(1+omeganlb(r,lnd))))
      $(ifLandCET)

      +  (pnlbndx(r,lnd,t)**omeganlb(r,lnd)
      -        sum(lb$(not lb1(lb)), shr0_lb(r,lnd,lb,t)*plb(r,lnd,lb,t)**omeganlb(r,lnd)))
      $(not ifLandCET)
      ;

pnlbndx.lo(r,lnd,t) = 0.001 ;

pnlbeq(r,lnd,t)$(ts(t) and rs(r) and shr0_nlb(r,lnd,t) ne 0)..
   pnlb(r,lnd,t)*xnlb(r,lnd,t) =e=  sum(lb$(not lb1(lb)), plb(r,lnd,lb,t)*xlb(r,lnd,lb,t)
                                *     ((plb0(r,lnd,lb)*xlb0(r,lnd,lb))/(pnlb0(r,lnd)*xnlb0(r,lnd)))) ;

*  Bottom nests

plandeq(r,lnd,a,t)$(ts(t) and rs(r) and xfFlag(r,lnd,a))..
   0 =e= sum(lb$maplb(lb,a),
            (pf(r,lnd,a,t) - plb(r,lnd,lb,t))
      $(omegalb(r,lnd,lb) eq inf)

         +  (xf(r,lnd,a,t)
         -     xlb(r,lnd,lb,t)*(pf(r,lnd,a,t)/plbndx(r,lnd,lb,t))**omegalb(r,lnd,lb))
      $(omegalb(r,lnd,lb) ne inf)
      ) ;

pfp.lo(r,f,a,t) = 0.001 ;

plbndxeq(r,lnd,lb,t)$(ts(t) and rs(r) and shr0_lb(r,lnd,lb,t) ne 0 and omegalb(r,lnd,lb) ne inf)..
   0 =e= (plbndx(r,lnd,lb,t)**(1+omegalb(r,lnd,lb))
      -     sum(a$maplb(lb,a), shr0_t(r,lnd,a,t)*pf(r,lnd,a,t)**(1+omegalb(r,lnd,lb))))
      $(ifLandCET)

      +  (plbndx(r,lnd,lb,t)**omegalb(r,lnd,lb)
      -     sum(a$maplb(lb,a), shr0_t(r,lnd,a,t)*pf(r,lnd,a,t)**omegalb(r,lnd,lb)))
      $(not ifLandCET)
      ;

plbndx.lo(r,lnd,lb,t) = 0.001 ;

plbeq(r,lnd,lb,t)$(ts(t) and rs(r) and shr0_lb(r,lnd,lb,t) ne 0)..
   plb(r,lnd,lb,t)*xlb(r,lnd,lb,t) =e= sum(a$maplb(lb,a), pf(r,lnd,a,t)*xf(r,lnd,a,t)
                            *    (pf0(r,lnd,a)*xf0(r,lnd,a)/(plb0(r,lnd,lb)*xlb0(r,lnd,lb)))) ;

plb.lo(r,lnd,lb,t) = 0.001 ;

*  Market for natural resources

etanrseq(r,a,t)$(xnrsFlag(r,a) ne 0 and xnrsFlag(r,a) ne inf and ts(t) and rs(r))..
   etanrs(r,a,t) =e= etanrsx(r,a,"lo") + ((etanrsx(r,a,"hi") - etanrsx(r,a,"lo"))
                  *  sigmoid(kink*(sum(nrs, xf(r,nrs,a,t)/xf(r,nrs,a,tLag))-1)))
                  $  (etanrsx(r,a,"hi") ne etanrsx(r,a,"lo")) ;

xfnoteq(r,nrs,a,t)$(ts(t) and rs(r) and xfFlag(r,nrs,a))..
   0 =e= ((xfnot(r,a,t)$ifdepl(r,a) + xfs(r,nrs,a,t)$(not ifdepl(r,a)))
      -     wchinrs(a,t)*(xf(r,nrs,a,tLag)*chinrs(r,a,t))
      *     (chinrsp(r,a)*(pf(r,nrs,a,t)/pgdpmp(r,t))
      /                   (pf(r,nrs,a,tLag)/pgdpmp(r,tLag)))**etanrs(r,a,t))
      $(xfFlag(r,nrs,a) ne inf)

      +  (chinrsp(r,a)*pf(r,nrs,a,t) - pgdpmp(r,t)*(pgdpmp0(r)/pf0(r,nrs,a)))
      $(xfFlag(r,nrs,a) eq inf) ;

$ontext
$iftheni "%DEPL_MODULE%" == "ON"

xfGapeq(r,a,t)$(ts(t) and rs(r) and ifDepl(r,a))..
   xfGap(r,a,t) =g= xfNot(r,a,t)*xfNot0(r,a) - xfPot(r,a,t)*xfPot0(r,a) ;

xfsnrseq(r,nrs,a,t)$(ts(t) and rs(r) and xfFlag(r,nrs,a) and ifDepl(r,a))..
   xfs(r,nrs,a,t)*xf0(r,nrs,a) =e= xfnot(r,a,t)*xfNot0(r,a) - xfGap(r,a,t) ;

$endif
$offtext

$iftheni "%DEPL_MODULE%" == "ON"

xfGapeq(r,a,t)$(ts(t) and rs(r) and ifDepl(r,a))..
   xfGap(r,a,t) =e= 0 ;

xfsnrseq(r,nrs,a,t)$(ts(t) and rs(r) and xfFlag(r,nrs,a) and ifDepl(r,a))..
   xfs(r,nrs,a,t)*xf0(r,nrs,a) =e= xfnot(r,a,t)*xfNot0(r,a) - xfGap(r,a,t) ;

$endif

pfnrseq(r,nrs,a,t)$(ts(t) and rs(r) and xfFlag(r,nrs,a))..
   xfs(r,nrs,a,t) =e= xf(r,nrs,a,t) ;

*  Market for water

$ontext


                     TH2OM = TH2O - ENV - GRD
                     /   \
                    /     \
                   /       \
                  /         \
               AGR           NAG
              /   \         /   \
             /     \       /     \
            /       \     /       \
          CRP       LVS  IND     MUN
         / | \
        /  |  \
       /   |   \
      Water demand
   by irrigated crops

$offtext

*  Total water supply

th2oeq(r,t)$(ts(t) and rs(r) and th2oFlag(r))..
   0 =e= (th2o(r,t) - (chih2o(r,t)/th2o0(r))*((pth2o(r,t)/pgdpmp(r,t))
      *                                       (pth2o0(r)/pgdpmp0(r)))**etaw(r))
      $(%WASS% eq KELAS)

      +  (th2o(r,t) - ((H2OMax(r,t)/th2o0(r))
      /     (1 + chih2o(r,t)*exp(-gammatw(r,t)*((pth2o(r,t)/pgdpmp(r,t))*(pth2o0(r)/pgdpmp0(r)))))))
      $(%WASS% eq LOGIST)

      +  (th2o(r,t) - ((H2OMax(r,t)/th2o0(r)) - (chih2o(r,t)/th2o0(r))
      *  ((pth2o(r,t)/pgdpmp(r,t))*(pth2o0(r)/pgdpmp0(r)))**(-gammatw(r,t))))
      $(%WASS% eq HYPERB)

      +  (pth2o(r,t) - pgdpmp(r,t)*(pgdpmp0(r)/pth2o0(r)))
      $(%WASS% eq INFTY)
      ;

*  Marketed water is equal to total water less exogenous demand

th2omeq(r,t)$(ts(t) and rs(r) and th2oFlag(r))..
   th2o(r,t) =e= th2om(r,t)*th2om0(r)/th2o0(r)
              +   sum(wbndEx, h2obnd(r,wbndEx,t)*h2obnd0(r,wbndEx)/th2o0(r)) ;

*  Demand for marketed water bundles -- both top level (wbnd1) and bottom level (wbnd2)

h2obndeq(r,wbnd,t)$(ts(t) and rs(r) and h2obndFlag(r,wbnd))..

*  Top level bundle

   0 =e= (h2obnd(r,wbnd,t)
      -     th2om(r,t)*(ph2obnd(r,wbnd,t)/pth2ondx(r,t))**omegaw1(r))
      $(wbnd1(wbnd) and omegaw1(r) ne inf)

      +  (ph2obnd(r,wbnd,t) - pth2o(r,t))
      $(wbnd1(wbnd) and omegaw1(r) eq inf)

*  Second level bundle

      +  (sum(wbnd1$mapw1(wbnd1, wbnd), (h2obnd(r,wbnd,t)
      -     h2obnd(r,wbnd1,t)*(ph2obnd(r,wbnd,t)/ph2obndndx(r,wbnd1,t))**omegaw2(r,wbnd1))
      $(omegaw2(r,wbnd1) ne inf)

      +     (ph2obnd(r,wbnd,t) - ph2obnd(r,wbnd1,t))
      $(omegaw2(r,wbnd1) eq inf)))
      $wbnd2(wbnd)
      ;

pth2ondxeq(r,t)$(ts(t) and rs(r) and th2oFlag(r) and omegaw1(r) ne inf)..
   0 =e= (pth2ondx(r,t)**omegaw1(r)
      -     sum(wbnd1, shr0_1h2o(r,wbnd1,t)*ph2obnd(r,wbnd1,t)**omegaw1(r))) ;

pth2oeq(r,t)$(ts(t) and rs(r) and th2oFlag(r))..
   pth2o(r,t)*th2om(r,t) =e= sum(wbnd1, ph2obnd(r,wbnd1,t)*h2obnd(r,wbnd1,t)
                          *   ((ph2obnd0(r,wbnd1)*h2obnd0(r,wbnd1))/(pth2o0(r)*th2om0(r)))) ;

*  Price index of 2nd and 3rd level bundles -- resp. wbnd1 and wbnda

ph2obndndxeq(r,wbnd,t)$(ts(t) and rs(r) and h2obndFlag(r,wbnd))..
   0 =e= (ph2obndndx(r,wbnd,t)**omegaw2(r,wbnd) - sum(wbnd2$mapw1(wbnd,wbnd2),
            shr0_2h2o(r,wbnd2,t)*ph2obnd(r,wbnd2,t)**omegaw2(r,wbnd)))
      $(wbnd1(wbnd) and omegaw2(r,wbnd) ne inf)

      +  (ph2obndndx(r,wbnd,t)**omegaw2(r,wbnd)
      -     sum((wat,a)$mapw2(wbnd,a), shr0_3h2o(r,a,t)*pf(r,wat,a,t)**omegaw2(r,wbnd)))
      $(wbnda(wbnd) and omegaw2(r,wbnd) ne inf)
      ;

*  Price of 2nd and 3rd level bundles:
*     Second level (wbnd1)
*     Third level when mapped to activities (wbnda)
*     Third level when mapped to aggregate sectoral output (wbndi)

ph2obndeq(r,wbnd,t)$(ts(t) and rs(r) and h2obndFlag(r,wbnd))..

*  Top level bundle price

   0 =e= (ph2obnd(r,wbnd,t)*h2obnd(r,wbnd,t)
      -     sum(wbnd2$mapw1(wbnd,wbnd2), ph2obnd(r,wbnd2,t)*h2obnd(r,wbnd2,t)
      *        ((ph2obnd0(r,wbnd2)*h2obnd0(r,wbnd2))/(ph2obnd0(r,wbnd)*h2obnd0(r,wbnd)))))
      $wbnd1(wbnd)

*  Second level bundle price (when bundle is mapped to activities)

      +  (ph2obnd(r,wbnd,t)*h2obnd(r,wbnd,t)
      -     sum((wat,a)$mapw2(wbnd,a), pf(r,wat,a,t)*xf(r,wat,a,t)
      *        ((pf0(r,wat,a)*xf0(r,wat,a))/(ph2obnd0(r,wbnd)*h2obnd0(r,wbnd)))))
      $(wbnda(wbnd))

*  Second level bundle price (when bundle is mapped to an output index)

      +  (h2obnd(r,wbnd,t) - (ah2obnd(r,wbnd,t)/(lambdah2obnd(r,wbnd,t)*h2obnd0(r,wbnd)))
      *   (((ph2obnd(r,wbnd,t)/pgdpmp(r,t))*(ph2obnd0(r,wbnd)/pgdpmp0(r)))**(-epsh2obnd(r,wbnd)))
      *   (sum(a$mapw2(wbnd,a), px(r,a,t0)*xp(r,a,t)*(px0(r,a)*xp0(r,a)))
      /    sum(a$mapw2(wbnd,a), px(r,a,t0)*xp(r,a,t0)*(px0(r,a)*xp0(r,a))))
      **etah2obnd(r,wbnd))
      $(wbndi(wbnd))
      ;

*  Third level bundle -- agriculture only

ph2oeq(r,wat,a,t)$(ts(t) and rs(r) and xfFlag(r,wat,a))..
   0 =e= sum(wbnd2$(wbnda(wbnd2) and mapw2(wbnd2,a)),
            (xf(r,wat,a,t) - ((h2obnd0(r,wbnd2)/xf0(r,wat,a))
      *        (pf0(r,wat,a)/ph2obndndx0(r,wbnd2))**omegaw2(r,wbnd2))
      *        h2obnd(r,wbnd2,t)*(pf(r,wat,a,t)/ph2obndndx(r,wbnd2,t))**omegaw2(r,wbnd2))
      $(omegaw2(r,wbnd2) ne inf)

      -     (pf(r,wat,a,t) - ph2obnd(r,wbnd2,t)*(pf0(r,wat,a)/ph2obnd0(r,wbnd2)))
      $(omegaw2(r,wbnd2) eq inf)) ;

*  Producer prices

pfpeq(r,f,a,t)$(ts(t) and rs(r) and xfFlag(r,f,a) and not ifSUB)..
   pfp(r,f,a,t) =e= (1 + M_PFTAX(r,f,a,t))*pf(r,f,a,t)*(pf0(r,f,a)/pfp0(r,f,a)) ;

pkpeq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a))..
   pkp(r,a,v,t) =e= (1 + sum(cap, M_PFTAX(r,cap,a,t)))*pk(r,a,v,t)*(pk0(r,a)/pkp0(r,a)) ;

pkp.lo(r,a,v,t) = 0.001 ;

* --------------------------------------------------------------------------------------------------
*
*   GDP definitions
*
* --------------------------------------------------------------------------------------------------

$macro mQGDP(r,tp,tq) \
      (sum((fd,i), (pa0(r,i,fd)*xa0(r,i,fd))*M_PA(r,i,fd,tp)*xa(r,i,fd,tq)) \
      + sum((i,d)$xwFlag(r,i,d), (pwe0(r,i,d)*xw0(r,i,d))*M_PWE(r,i,d,tp)*xw(r,i,d,tq)) \
      - sum((i,s)$xwFlag(s,i,r), (pwm0(s,i,r)*xw0(s,i,r))*M_PWM(s,i,r,tp) \
      *     lambdax(s,i,r,tq)*lambdaw(s,i,r,tq)*xw(s,i,r,tq)) \
      + sum(img, (pdt0(r,img)*xtt0(r,img))*pdt(r,img,tp)*xtt(r,img,tq)))

$macro mQCPIM(r,tp,tq) \
      (sum((h,i), (pa0(r,i,h)*xa0(r,i,h))*M_PA(r,i,h,tp)*xa(r,i,h,tq)))

conseq(r,t)$(ts(t) and rs(r))..
   cons(r,t) =e= mQCPIM(r,t,t) / cons0(r) ;

pconseq(r,t)$(ts(t) and rs(r))..
   pcons(r,t) =e= pcons(r,tlag)*sqrt((mQCPIM(r,t,tLag)/cons(r,tLag))*(cons(r,t)/mQCPIM(r,tLag,t))) ;

gdpmpeq(r,t)$(ts(t) and rs(r))..
   gdpmp(r,t) =e= mQGDP(r,t,t)/gdpmp0(r) ;

pgdpmpeq(r,t)$(ts(t) and rs(r))..
   pgdpmp(r,t) =e= pgdpmp(r,tLag)*sqrt((mQGDP(r,t,tLag)/gdpmp(r,tLag))*(gdpmp(r,t)/mQGDP(r,tLag,t))) ;

rgdpmpeq(r,t)$(ts(t) and rs(r))..
   rgdpmp(r,t) =e= (gdpmp(r,t)/pgdpmp(r,t))*(gdpmp0(r)/(pgdpmp0(r)*rgdpmp0(r))) ;

rgdppceq(r,t)$(ts(t) and rs(r))..
   rgdppc(r,t) =e= (rgdpmp(r,t)/pop(r,t))*(rgdpmp0(r)/(pop0(r)*rgdppc0(r))) ;

grrgdppceq(r,t)$(ts(t) and rs(r))..
   rgdppc(r,t) =e= power(1 + 0.01*grrgdppc(r,t), gap(t))*rgdppc(r,tLag) ;

klrateq(r,t)$(ts(t) and rs(r))..
   klrat(r,t) =e= sum((a,v), (pk0(r,a)*kv0(r,a)/klrat0(r))*lambdak(r,a,v,t)*kv(r,a,v,t))
               /  sum((a,l), (pf0(r,l,a)*xf0(r,l,a))*lambdaf(r,l,a,t)*xf(r,l,a,t)) ;

* --------------------------------------------------------------------------------------------------
*
*   MODEL CLOSURE
*
* --------------------------------------------------------------------------------------------------

$iftheni "%IFI_MODULE%" == "ON"
Parameters
   ifiOut0(r)
   ifiIn0(r)
   ifiOutShr(r)
;

Variables
   ifiOut(r,t)
   ifiIn(r,t)
   ifiTot(t)
;

Sets
   ifiFlag(r)
;

equation
   ifieq(r,t)  "Income for yfd(ini)"
   ifiToteq(t) "Total expenditures by IFI's"
;

ifieq(r,t)$(ts(t) and ifiFlag(r))..
   yfd(r,ifi,t) =e= pmuv(t)*ifiIn(r,t) / yfd0(r,ifi) ;

ifiToteq(t)$ts(t)..
   ifiTot(t) =e= sum(d, yfd0(d,ifi) * yfd(d,ifi,t)) ;

$endif

savgeq(r,t)$(ts(t) and rs(r))..
   savg(r,t) =e= sum(gy, ygov0(r,gy)*ygov(r,gy,t)) + sum((emq,aets),emiQuotaY(r,emq,aets,t))
              +  ntmY0(r)*ntmY(r,t)
              *      (1 - sum(s$(not sameas(s,r)), chigNTM(s,r,t)) - sum(s, chihNTM(s,r,t)))
              +  sum(s$(not sameas(s,r)), chigNTM(s,r,t)*ntmY0(s)*ntmY(s,t))
              +  ODAIn0(r)*ODAIn(r,t) - ODAOut0(r)*ODAOut(r,t)
              -  sum(fdg, yfd0(r,fdg)*yfd(r,fdg,t))
              -  sum(gov, yfdexpadp(r,gov,t))
              +  pmuv(t)*itransfers(r,t)
              -  sum(d, govTr0(r,d)*govTr(r,d,t)*pnum(t))
$iftheni "%IFI_MODULE%" == "ON"
              -  ifiOutShr(r)*ifiTot(t)
$endif
              ;

rsgeq(r,t)$(ts(t) and rs(r))..
   rsg(r,t)*pgdpmp(r,t)*pgdpmp0(r) =e= savg(r,t) ;

*  Share of real expenditures wrt to GDP

rfdshreq(r,fd,t)$(ts(t) and rs(r) and fdFlag(r,fd))..
   rfdshr(r,fd,t)*rgdpmp(r,t) =e= xfd(r,fd,t)*(xfd0(r,fd)/rgdpmp0(r)) ;

*  Share of nominal expenditures wrt to GDP

nfdshreq(r,fd,t)$(ts(t) and rs(r) and fdFlag(r,fd))..
   nfdshr(r,fd,t)*gdpmp(r,t) =e= yfd(r,fd,t)*(yfd0(r,fd)/gdpmp0(r)) ;

kstockeeq(r,t)$(ts(t) and rs(r))..
   kstocke(r,t) =e= (1-depr(r,t))*kstock(r,t) + sum(inv, xfd(r,inv,t)*xfd0(r,inv)/kstock0(r)) ;

roreq(r,t)$(ts(t) and rs(r))..
   ror(r,t)*ror0(r) =e= sum((a,cap,v),(1-kappaf(r,cap,a,t))*pk(r,a,v,t)*kv(r,a,v,t)
                     *     pk0(r,a)*kv0(r,a))
                     /    (kstock(r,t)*kstock0(r)) ;

rorceq(r,t)$(ts(t) and rs(r))..
   rorc(r,t)*rorc0(r) =e= ror(r,t)*ror0(r)/sum(inv, pfd(r,inv,t)*pfd0(r,inv)) - depr(r,t) ;

roreeq(r,t)$(ts(t) and rs(r))..
   rore(r,t)*rore0(r) =e= (rorc(r,t)*rorc0(r)*(kstocke(r,t)/kstock(r,t))**(-epsRor(r,t)))
                       $(savfFlag eq capFlexGTAP or savfFlag eq capFix
                           or savfFlag eq capRFix or savfFlag eq capFlexINF)
                       +  ((ror(r,t)*ror0(r)/sum(inv,pfd(r,inv,t)*pfd0(r,inv))
                       +      (1 - depr(r,t)))/(1+intRate) - 1)
                       $(savfFlag eq capFlexUSAGE) ;
                       ;

devRoReq(r,t)$(ts(t) and rs(r) and savfFlag eq capFlexUSAGE)..
   devRoR(r,t) =e= rore(r,t)*rore0(r) - rorn(r,t) - rord(r,t) - rorg(t) ;

grKeq(r,t)$(ts(t) and rs(r))..
   sum(inv, xfd(r,inv,t)*xfd0(r,inv)) =e= kstock(r,t)*kstock0(r)*(grK(r,t) + depr(r,t)) ;

$macro logasc(r,t) \
   ((grKMax(r,t) - grKTrend(r,t))/(grkTrend(r,t) - grKMin(r,t)))

savfeq(r,t)$(ts(t) and rs(r))..
   0 =e= (riskPrem(r,t)*rore(r,t)*rore0(r) - rorg(t)*rorg0)$(savfFlag eq capFlexGTAP)
      +  (riskPrem(r,t)*rorc(r,t)*rorc0(r) - rorg(t)*rorg0)$(savfFlag eq capFlexINF)
*     +  (riskPrem(r,t)*trent(r,t)*trent0(r) - rorg(t)*rorg0)$(savfFlag eq capFlexINF)
      +  (savf(r,t) - chiSavf(r,t)*savfBar(r,t))
      $     ((savfFlag eq capFix and not rres(r) and not fixER(r)) or (not ifGBL))
      +  (pwsav(t)*savf(r,t) - savfRat(r,t)*gdpmp(r,t)*gdpmp0(r))
      $     (savfFlag eq capRFix and not rres(r))
      +  (sum(s, savf(s,t)))$((savfFlag eq capFix or savfFlag eq capRFix) and rres(r) and ifGBL)
      +  (grk(r,t) - (grKMax(r,t)*exp(chigrK(r,t)*devRoR(r,t)) + grKMin(r,t)*logasc(r,t))
                   /  (exp(chigrK(r,t)*devRoR(r,t)) + logasc(r,t)))$(savfFlag eq capFlexUSAGE)
      ;

savfRateq(r,t)$(ts(t) and rs(r) and savfFlag ne capRFix and ifGbl)..
   pwsav(t)*savf(r,t) =e= savfRat(r,t)*gdpmp(r,t)*gdpmp0(r) ;

$macro netInvShr(r,t) \
   (sum(inv, yfd(r,inv,t)*yfd0(r,inv) - pfd(r,inv,t)*pfd0(r,inv)*depr(r,t)*kstock(r,t)*kstock0(r)) \
   /   sum((s,inv), yfd(s,inv,t)*yfd0(s,inv) \
   - pfd(s,inv,t)*pfd0(s,inv)*depr(s,t)*kstock(s,t)*kstock0(s)))

rorgeq(t)$(ts(t) and ifGbl)..
   0 =e= (sum(r, savf(r,t)))$(savfFlag ne capFix and savfFlag ne capRFix)
      +  (rorg(t)*rorg0 - sum(r, netInvShr(r,t)*rore(r,t)*rore0(r)))
      $     (savfFlag eq capFix or savfFlag eq capRFix) ;

$macro mQMUV(tp,tq) \
   (sum((s,i,d)$(rmuv(s) and imuv(i)), (pwe0(s,i,d)*xw0(s,i,d))*M_PWE(s,i,d,tp)*xw(s,i,d,tq)))

pmuveq(t)$ts(t)..
   pmuv(t) =e= (pmuv(tLag)*sqrt((mQMUV(t,tLag)/mQMUV(tLag,tLag))
            *                  (mQMUV(t,t)/mQMUV(tLag,t))))$ifGbl

            +  (pnum(t))$(not ifGbl) ;

*!!!! Excludes waste taxes

$macro mQCPI(tp,tq,subset) \
   (sum(i$mapCPI(cpindx,i), (pa0(r,i,h)*xa0(r,i,h))*m_pa(r,i,h,tp)*xa(r,i,h,tq)))

cpieq(r,h,cpindx,t)$(ts(t) and rs(r))..
   cpi(r,h,cpindx,t) =e= cpi(r,h,cpindx,tLag)
                      *     sqrt((mQCPI(t,tLag,cpindx)/mQCPI(tLag,tLag,cpindx))
                      *          (mQCPI(t,t,cpindx)/mQCPI(tLag,t,cpindx))) ;

*  Factor price index

$macro mQFACT(r,tp,tq) \
   (sum((f,a)$xf0(r,f,a), pf0(r,f,a)*xf0(r,f,a)*pf(r,f,a,tp)*xf(r,f,a,tq)))

pfacteq(r,t)$(ts(t) and rs(r))..
   pfact(r,t) =e= pfact(r,tLag)
               *     sqrt((mQFACT(r,t,tLag)/mQFACT(r,tLag,tLag))*(mQFACT(r,t,t)/mQFACT(r,tLag,t))) ;

$macro mQFACTw(tp,tq) \
   (sum((r,f,a)$xf0(r,f,a), pf0(r,f,a)*xf0(r,f,a)*pf(r,f,a,tp)*xf(r,f,a,tq)))

pwfacteq(t)$(ts(t) and ifGBL)..
   pwfact(t) =e= pwfact(tLag)
              *   sqrt((mqfactw(t,tLag)/mqfactw(tLag,tLag))
              *        (mqfactw(t,t)/mqfactw(tLag,t))) ;

pwgdpeq(t)$(ts(t) and ifGbl)..
   pwgdp(t) =e= sum(r, gdpmp(r,t))/sum(r, rgdpmp(r,t)) ;

pwsaveq(t)$ts(t)..
   pwsav(t) =e= pmuv(t) ;

pnumeq(t)$(ts(t) and ifGbl)..
   pnum(t) =e= 0*pwfact(t) + 1*pwgdp(t) + 0*pmuv(t) ;

$macro mQX(a,tp,tq) \
   (sum(r, (px0(r,a)*xp0(r,a))*px(r,a,tp)*xp(r,a,tq)))

pweq(a,t)$(ts(t) and ifGbl)..
   pw(a,t) =e= pw(a,tlag)*sqrt((mQX(a,t,tlag)/mQX(a,tlag,tlag))
            *                  (mQX(a,t,t)/mQX(a,tlag,t))) ;

walraseq(t)$(ts(t) and not ifGbl and 0)..
   walras(t) =e=  sum(r$rs(r), sum((i,d), pwe0(r,i,d)*M_PWE(r,i,d,t)*xw0(r,i,d)*xw(r,i,d,t)
              -      pwm0(d,i,r)*M_PWM(d,i,r,t)*lambdax(d,i,r,t)
              *         lambdaw(d,i,r,t)*xw0(d,i,r)*xw(d,i,r,t))
              +      sum(img, (pdt0(r,img)*pdt(r,img,t))*xtt(r,img,t)*xtt0(r,img))
              +      pwsav(t)*savf(r,t)
              +      yqht0(r)*yqht(r,t) - yqtf0(r)*yqtf(r,t)
              +      ODAIn0(r)*ODAIn(r,t) - ODAOut0(r)*ODAOut(r,t)
              +      sum((d,l),remit0(r,l,d)*remit(r,l,d,t)-remit0(d,l,r)*remit(d,l,r,t)))
              ;

* --------------------------------------------------------------------------------------------------
*
*   EMISSIONS MODULE
*
* --------------------------------------------------------------------------------------------------

*  Calculate emissions from all drivers

set
   maprcp(ra,r)      "Mapping of regions to coalitions for emission taxes"
;

*  Consumption based emissions

emiieq(r,em,i,aa,t)$(ts(t) and rs(r) and emir(r,em,i,aa) ne 0)..
   emi(r,em,i,aa,t) =e= (chiEmi(r,em,aa,t)*emir(r,em,i,aa)*xa(r,i,aa,t)*(xa0(r,i,aa)/emi0(r,em,i,aa)))
                     $(ArmSpec(r,i) eq aggArm)
                     +  (chiEmi(r,em,aa,t)*emird(r,em,i,aa)*xd(r,i,aa,t)*(xd0(r,i,aa)/emi0(r,em,i,aa))
                     +   chiEmi(r,em,aa,t)*emirm(r,em,i,aa)*xm(r,i,aa,t)*(xm0(r,i,aa)/emi0(r,em,i,aa)))
                     $(ArmSpec(r,i) ne aggArm)
                     ;

*  Factor-use based emissions

emifeq(r,em,f,a,t)$(ts(t) and rs(r) and emir(r,em,f,a) ne 0)..
   emi(r,em,f,a,t) =e= chiEmi(r,em,a,t)*emir(r,em,f,a)*xf(r,f,a,t)*(xf0(r,f,a)/emi0(r,em,f,a)) ;

*  Output based emissions

emixeq(r,em,tot,a,t)$(ts(t) and rs(r) and emir(r,em,tot,a) ne 0)..
   emi(r,em,tot,a,t) =e= chiEmi(r,em,a,t)*emir(r,em,tot,a)*xp(r,a,t)*(xp0(r,a)/emi0(r,em,tot,a)) ;

*  Calculate aggregate emissions including any exogenous emissions

emiToteq(r,em,t)$(ts(t) and rs(r) and emiTot0(r,em))..
   emiTot(r,em,t) =e= emiOth(r,em,t)/emiTot0(r,em)
      + sum((is,aa)$emir(r,em,is,aa), emi(r,em,is,aa,t)*(emi0(r,em,is,aa)/emiTot0(r,em)))
      + sum(a$ProcEmiFlag(r,em,a), ProcEmi(r,em,a,t)*(ProcEmi0(r,em,a)/emiTot0(r,em))) ;

*  Global atmospheric carbon emissions

emiGbleq(em, t)$(ts(t) and ifGbl and emiGbl0(em))..
   emiGbl(em, t) =e= sum(r, emiTot(r, em,t)*(emiTot0(r,em)/emiGbl0(em)))
                  +  emiOthGbl(em,t)/emiGbl0(em) ;

Sets
   aets                          "ETS aggregate agents"
   mapets(ra,aets,aa)            "Mapping from agents to ets aggregate agents"
   emiTotEtsFlag(ra,r,emq,aets)  "Flag for emissions by group of agents"
   ifEmiRCap(r,em,aa)            "(r,em,aa) are subject to a CAP regime"
   ifEmiCap(ra,emq,aets)         "(rq,aets) are subject to a CAP regime"
   ifEmiRQuota(r,emq,aets)       "Cap and trade regime subject to a quota"
   rqt(ra)                       "Set mapping for secondary target"
;
rqt(ra) = no ;

Variables
   emiTotAct(r,emq,a,t)          "Emissions per activity"
   emiInt(r,emq,a,t)             "Emissions intensity per activity"
   emiIntTgt(r,emq,a,t)          "Target for emissions intensity"
;

Parameters
   emiTotAct0(r,emq,a)           "Initial emissions per activity"
   emiInt0(r,emq,a)              "Initial emission intensity per activity"
   emiTotets0(ra,r,emq,aets)     "Initial emissions by (r,aets) pair"
;

scalar capFlag "Set to 1 to target emission level, set to 0 to target emission intensity" / 1 / ;

Equations
   emiTotActeq(r,emq,a,t)        "Emissions per activity"
   emiInteq(r,emq,a,t)           "Emission intensity"
   emiTotETSeq(ra,r,emq,aets,t)  "Emissions by group of agents"
   emiCTaxeq(ra,emq,aets,t)      "ETS Cap by ETS coalition"
   emiTaxeq(r,em,aa,t)           "ETS tax for each region in ETS coalition"
   procEmiTaxeq(r,ghg,a,t)       "ETS process emission tax for each region in ETS coalition"
   emiQuotaYeq(r,emq,aets,t)     "ETS quota transfers for region in ETS coalition"
;

*  Emissions per activity

emiTotActeq(r,emq,a,t)$(ts(t) and rs(r) and emiTotAct0(r,emq,a))..
   emiTotAct(r,emq,a,t)
*     Emissions linked to combustion and other 'input' emissions
      =e= sum((is,em)$(mapEM(emq,em) and emi0(r,em,is,a)),
            emi(r,em,is,a,t)*(emi0(r,em,is,a)/emiTotAct0(r,emq,a)))
*     Process emissions
       +  sum(em$(mapEM(emq,em) and ProcEmiFlag(r,em,a)),
            ProcEmi(r,em,a,t)*(ProcEmi0(r,em,a)/emiTotAct0(r,emq,a))) ;

*  Emission intensity

emiInteq(r,emq,a,t)$(ts(t) and rs(r) and emiInt0(r,emq,a))..
   emiInt(r,emq,a,t) * xp(r,a,t) =e= emiTotAct(r,emq,a,t) ;

*  Regional emissions per aets regime

emiTotETSeq(rq,r,emq,aets,t)$(ts(t) and rs(r) and emiTotETS0(rq,r,emq,aets))..
   emiTotETS(rq,r,emq,aets,t)

*     Production emissions
       =e= sum(a$(mapETS(rq,aets,a) and emiTotAct0(r,emq,a)), emiTotAct(r,emq,a,t)*(emiTotAct0(r,emq,a)/emiTotETS0(rq,r,emq,aets)))

*     Emissions linked to final demand
        +  sum((is,aa,em)$(not acts(aa) and mapETS(rq,aets,aa) and mapEM(emq,em) and emi0(r,em,is,aa)),
               emi(r,em,is,aa,t)*(emi0(r,em,is,aa)/emiTotETS0(rq,r,emq,aets)))
        ;

*  Coalition emission tax per (rq,aets) pair

alias(aets,aetstgt) ;

sets
   ifXCAP(ra,emq,aets)        "Caps are fully exogenous (default)"
   maprq(ra,ra)               "Mapping from 'regions' to aggregate 'regions'"
   ifRQCap(ra,emq,aetstgt)    "Aggregate regions subject to a potential regional cap"
   ifProcEmiRCap(r,ghg,a)     "Tax flag on process emissions"
   maprcpt(ra,r)              "Auxiliary mapping for secondary target"
   ifEmiIntCap(ra,emq,aets)   "Flag for cap on average intensity cap"
;

Parameters
   avgEmiInt0(ra,emq,aets)    "Initial average intensity per aets"
;

variables
   chiCap(ra,emq,aetsTgt,t)   "Emission cap shifter"
   avgEmiInt(ra,emq,aets,t)   "Average emission intensity"
;

equations
   chiCapeq(ra,emq,aetsTgt,t) "Aggregate emission cap"
   avgEmiInteq(ra,emq,aets,t) "Average emission intensity"
;

*  !!!! This should be an inequality--made it '=e=' for CNS...

emiCTAXeq(rq,emq,aets,t)$(ts(t) and ifGbl and ifEmiCap(rq,emq,aets))..
   emiCap(rq,emq,aets,t)*(1$ifXCAP(rq,emq,aets)
      + sum(ifRQCap(rqt,emq,aetsTgt)$maprq(rqt,rq), chiCap(rqt,emq,aetsTgt,t))
      $(not ifXCAP(rq,emq,aets)))
      =e= (sum(r$maprcp(rq,r), EmiTotETS(rq,r,emq,aets,t)*emiTotETS0(rq,r,emq,aets)))$(capFlag)
       +  (sum(r$maprcp(rq,r), sum(mapETS(rq,aets,a), emiInt0(r,emq,a)*emiInt(r,emq,a,t)*px0(r,a)*xp0(r,a)*xp(r,a,t))))$(not capFlag)
       ;

*  Average emission intensity

avgEmiInteq(rq,emq,aets,t)$(ts(t) and ifGbl and avgEmiInt0(rq,emq,aets))..
   avgEmiInt(rq,emq,aets,t) =e= sum(r$mapra(rq,r), EmiTotETS(rq,r,emq,aets,t)*emiTotETS0(rq,r,emq,aets))
                             /  sum(r$mapra(rq,r), sum(mapETS(rq,aets,a), px0(r,a)*xp0(r,a)*xp(r,a,t))) ;

*  Regional emission tax

emiTaxeq(r,em,aa,t)$(ts(t) and ifGbl and ifEmiRCap(r,em,aa))..
   emiTax(r,em,aa,t) =e= sum(rq$maprcp(rq,r), sum(aets$mapETS(rq,aets,aa), sum(emq$mapEM(emq,em), emiCTAX(rq,emq,aets,t)))) ;

*  Process emission tax

procEmiTaxeq(r,ghg,a,t)$(ts(t) and ifGbl and ifProcEmiRCap(r,ghg,a))..
   procEmiTax(r,ghg,a,t) =e= sum(rq$maprcp(rq,r), sum(aets$mapETS(rq,aets,a), sum(emq$mapEM(emq,ghg), emiCTAX(rq,emq,aets,t)))) ;

*  Some aggregate cap:

chiCapeq(rqt,emq,aetsTgt,t)$(ts(t) and ifGbl and ifRQCap(rqt,emq,aetsTgt))..
   emiCap(rqt,emq,aetsTgt,t)
      =e= sum(r$maprcpt(rqt,r), emiTotETS(rqt,r,emq,aetsTgt,t)*emiTotETS0(rqt,r,emq,aetsTgt)) ;

*  Quota income -- N.B. sum(r$mapr(rq,r),emiQuota(r,em,aets,t)) = emiCap(eq,em,aets,t)

emiQuotaYeq(r,emq,aets,t)$(ts(t) and ifGbl and ifEmiRQuota(r,emq,aets))..
   emiQuotaY(r,emq,aets,t) =e= sum(rq$maprcp(rq,r), emiCTAX(rq,emq,aets,t)
                           *  (emiQuota(r,emq,aets,t)
                           -     emiTotETS(rq,r,emq,aets,t)*emiTotETS0(rq,r,emq,aets))) ;

set
   ifBTA(ra,s,i,d)      "BTA activation flag"
   tflow / imp "Importer", exp "Exporter" / ;
;
ifBTA(ra,s,i,d) = no ;

Parameters
   BTAGauge(ra,s,i,d,tflow,t)    "BTA gauge"
;
BTAGauge(ra,s,i,d,tflow,t) = 1 ;

Equations
   emiTaxXeq(ra,s,i,d,t)
;

*  !!!! Might need some additional testing

emiTaxXeq(rq,s,i,d,t)$(ts(t) and ifGBL and ifBTA(rq,s,i,d))..
*  emiTaxX(s,i,d,t) =e= emiCTax(ra,"CO2","All",t) ;
*  emiTaxX(s,i,d,t) =e= sum(aets, sum(a$(mapets(aets,a) and mapmak(a,i)), emiCtax(ra,"CO2",aets,t)))
*                    /  sum(a$mapmak(a,i),1)
*                    -  sum(a$mapmak(a,i), emiTax(s,"CO2",a,t)) / sum(a$mapmak(a,i),1) ;
   emiTaxX(rq,s,i,d,t) =e= BTAGauge(rq,s,i,d,"imp",t)*(sum(a$mapmak(a,i), emiTax(d,"CO2",a,t)) / sum(a$mapmak(a,i),1))
                        -  BTAGauge(rq,s,i,d,"exp",t)*(sum(a$mapmak(a,i), emiTax(s,"CO2",a,t)) / sum(a$mapmak(a,i),1))
;

* --------------------------------------------------------------------------------------------------
*
*   MODEL DYNAMICS
*
* --------------------------------------------------------------------------------------------------

*  Migration level

migreq(r,l,t)$(ts(t) and rs(r) and migrFlag(r,l))..
   migr(r,l,t) =e= ((chim(r,l,t)/migr0(r,l))*urbPrem0(r,l)**omegam(r,l))
                *    urbPrem(r,l,t)**omegam(r,l) ;

*  Labor supply in each zone

*  Migration factor to for multi-year specification

migrMulteq(r,l,z,t)$(ts(t) and rs(r) and migrFlag(r,l))..
   migrMult(r,l,z,t)*((1 + 0.01*glabz(r,l,z,t))
      *  (urbPrem(r,l,tLag)/urbPrem(r,l,t))**(omegam(r,l)/gap(t))-1) =e=
         power(1 + 0.01*glabz(r,l,z,t), gap(t))*(urbPrem(r,l,tLag)/urbPrem(r,l,t))**omegam(r,l) - 1 ;

*  Labor supply by zone

lszeq(r,l,z,t)$(ts(t) and rs(r) and lsFlag(r,l,z))..
   lsz(r,l,z,t) =e= power(1 + 0.01*glabz(r,l,z,t), gap(t))*lsz(r,l,z,tLag)
                 +      kronm(z)*migrMult(r,l,z,t)*migr(r,l,t)*(migr0(r,l)/lsz0(r,l,z)) ;

*  Aggregate growth of labor supply by skill

glabeq(r,l,t)$(ts(t) and rs(r) and tlabFlag(r,l))..
   ls(r,l,t) =e= power(1 + 0.01*glab(r,l,t), gap(t))*ls(r,l,tLag) ;

invGFacteq(r,t)$(ts(t) and rs(r) and gap(t) gt 1)..
   invGFact(r,t)*((sum(inv,
      (xfd0(r,inv)*xfd(r,inv,t))
   /  (xfd0(r,inv)*xfd(r,inv,tLag))))**(1/gap(t)) - 1 + depr(r,t))
      =e= 1 ;
*  sum(inv, xfd(r,inv,t)) =e= sum(inv, xfd(r,inv,tLag))*power(1 + invGFact(r,t), gap(t)) ;

kstockeq(r,t)$(ts(t) and rs(r))..
   kstock(r,t)/dam_cap(r,t) =e= ((power(1 - depr(r,t), gap(t)) * kstock(r,tLag)
                +   0.5*gap(t)*sum(inv, (xfd(r,inv,tLag) + xfd(r,inv,t))*(xfd0(r,inv)/kstock0(r))))
                $(gap(t) gt 1)

                + ((1 - depr(r,t))*kstock(r,tLag)
                + sum(inv, xfd(r,inv,tLag)*(xfd0(r,inv)/kstock0(r))))
                $(gap(t) eq 1))$(dynPhase ge 2)
                + (kstock(r,tLag))$(dynPhase lt 2);

$ontext
   kstock(r,t) =e= (power(1 - depr(r,t), gap(t)) * (kstock(r,tLag)
                -   invGFact(r,t)*sum(inv, xfd(r,inv,tLag)*(xfd0(r,inv)/kstock0(r))))
                +   invGFact(r,t)*sum(inv, xfd(r,inv,t)*(xfd0(r,inv)/kstock0(r))))
                $(gap(t) gt 1)
   kstock(r,t) =e= (power(1 - depr(r,t), gap(t)) * kstock(r,tLag)
                +  ((power(1 + invGFact(r,t), gap(t)) - power(1 - depr(r,t), gap(t)))
                /  (invGFact(r,t) + depr(r,t)))
                *  sum(inv, xfd(r,inv,tLag)*(xfd0(r,inv)/kstock0(r))))
                $(gap(t) gt 1)
$offtext

tkapseq(r,t)$(ts(t) and rs(r))..
   tkaps(r,t)*caput(r,t) =e= chiKaps0(r)*kstock(r,t)*(kstock0(r)/tkaps0(r)) ;

$iftheni.R_D "%RD_MODULE%" == "ON"

*  Knowledge module:

$ontext

   Old method: use induction to calculate knowledge stock for simulation years

$macro m_rdlag(r,ty,t) \
   (sum((ky,tt)$(valk(ky) le gamPrm(r,"N") and years(ty)-years(tt) eq valk(ky)), \
      gamma(r,ky)*rd(r,tt)*rd0(r)/kn0(r)))

kneq(r,t)$(ts(t) and not t0(t) and knowFlag(r))..
   kn(r,t) =e= kn(r,tLag)*power(1-kdepr(r,t), gap(t))
            +  sum(ty$(years(ty) gt years(tLag) and years(ty) le years(t)),
                  power(1-kdepr(r,t), years(t) - years(ty))*m_rdlag(r,ty,t))
            ;

   New method: calculate knowledge stock for each individual year

$offtext

kneq(r,ty,t)$(ts(t) and knowFlag(r) and years(ty) gt years(tLag) and years(ty) le years(t))..
   kn(r,ty) =e= (1 - kdepr(r,t))*kn(r,ty-1)
             +  sum((ky,tt)$(valk(ky) le gamPrm(r,"N") and years(ty)-years(tt) eq valk(ky)),
                  gamma(r,ky)*rd(r,tt)*rd0(r)/kn0(r)) ;

*  Calculate R & D expenditures for intermediate years

rdeq(r,ty,t)$(ts(t) and knowFlag(r) and years(ty) gt years(tLag) and years(ty) le years(t))..
   rd(r,ty) =e= xfd(r,r_d,t)*(xfd0(r,r_d)/rd0(r))
             *  ((xfd(r,r_d,t)/xfd(r,r_d,tlag))**((years(ty) - years(t))/gap(t))) ;

$ontext
*     Intermediate years
         (((rd(r,tLag))**((years(t) - years(ty))/gap(t)))
      *   ((rd(r,t))**((gap(t) - (years(t) - years(ty)))/gap(t))))$(years(ty) lt years(t))
*     Simulation year
      +  (xfd(r,r_d,t)*(xfd0(r,r_d)/rd0(r)))$(years(ty) eq years(t)) ;
$offtext

pikeq(r,l,a,t)$(ts(t) and rs(r) and gammar(r,l,a,t) and knowFlag(r))..
   pik(r,l,a,t) =e= gammar(r,l,a,t)*epsr(r,l,a,t)*((kn(r,t)/kn(r,tLag))**(1/gap(t)) - 1) ;
$else.R_D
   pik.fx(r,l,a,t) = 0 ;
$endif.R_D

*  What are the impacts of putting the damage impacts on lambdaf as opposed to the components of lambdaf?

lambdafeq(r,l,a,t)$(ts(t) and rs(r) and xfFlag(r,l,a) and lambdafLabEndog)..
   lambdaf(r,l,a,t) =e= dam_lab(r,l,a,t)*dam_hht(r,l,a,t)*lambdaf(r,l,a,tLag)
      * ((power(1 + (1/3)*(chiglab(r,l,t) + pik(r,l,a,t)
      +     glAddShft(r,l,a,t) + glMltShft(r,l,a,t)*gl(r,t)), gap(t)))$(dynPhase eq 3)
      +  (power(1 + (2/3)*(chiglab(r,l,t) + pik(r,l,a,t)
      +     glAddShft(r,l,a,t) + glMltShft(r,l,a,t)*gl(r,t)), gap(t)))$(dynPhase eq 4)
      +  (power(1 + chiglab(r,l,t) + pik(r,l,a,t)
      +     glAddShft(r,l,a,t) + glMltShft(r,l,a,t)*gl(r,t), gap(t)))$(dynPhase ge 5)
      +  (1)$(dynPhase lt 3)) ;

Equation
   lambdakeq(r,a,v,t)
   capueq(r,a,v,t)
;

Variable
   gk(r,t)
   delCapu(r,t) ;
;

Parameters
   gkAddShft(r,a,v,t)
   gkMltShft(r,a,v,t)
;

set
   capuFlag(r)
;


gkAddShft(r,a,v,t) = 0 ;
gkMltShft(r,a,v,t) = 1 ;

gk.fx(r,t)      = 0 ;
capuFlag(r)     = no ;
delCapu.fx(r,t) = 0 ;

lambdakeq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a) and lambdaKEndog)..
   lambdak(r,a,v,t) =e= lambdak(r,a,v,tLag)
      * power(1 + gkAddShft(r,a,v,t) + gkMltShft(r,a,v,t)*gk(r,t), gap(t)) ;

capueq(r,a,v,t)$(ts(t) and rs(r) and kFlag(r,a) and capuFlag(r))..
   capu(r,a,v,t) =e= 1 + delCapu(r,t) ;

equation
   ftfpeq(r,a,v,t)   "Endogenous FTFP"
;

ftfpeq(r,a,v,t)$(ts(t) and rs(r) and xpFlag(r,a) and FTFPFlag(r))..
   ftfp(r,a,v,t) =e= ftfp(r,a,v,t0)*power(1 + etfp(r,t), gap(t)) ;

* --------------------------------------------------------------------------------------------------
*
*   CLIMATE MODULE
*
* --------------------------------------------------------------------------------------------------

$iftheni "%CLIM_MODULE%" == "ON"

EmiCO2eq(t)$(ts(t) and ifGBL)..
   EmiCO2(t) =E= EmiGbl0("CO2")*EmiGbl("CO2",t)/EmiCO20
              +   EmiOTHIND(t)/EmiCO20 + EmiLand(t)/EmiCO20 ;

*  Cumulative fossil fuel emissions

CumEmiIndeq(t)$(ts(t) and ifGBL)..
   CumEmiInd(t) =E= CumEmiInd(tLag) + gap(t)*((EmiGbl0("CO2")*EmiGbl("CO2",tLag)
                 +   EmiOTHIND(tLag))/CO22C)/CumEmiInd0 ;

*  Cumulative total emissions

CumEmieq(t)$(ts(t) and ifGBL)..
   CUMEmi(t) =E= CUMEmiIND(t)*CUMEmiIND0/CUMEmi0 + CUMEmiLand(t)/CUMEmi0 ;

*  Carbon cycle module

alphaeq(t)$(ts(t) and ifGBL)..
   r0 + rC*(CUMEmi(t)*CUMEmi0 - (MAT(t)*MAT0 - 588)) + rT*(TEMP("ATMOS",t)) =e=
      sum(b, alpha(t)*phi(b)*tau(b)*(1-exp(-100/(alpha(t) * tau(b))))) ;

*  !!!! Need to fix the lags for alpha !!!!
CReseq(b,t)$(ts(t) and ifGBL)..
   CRes(b,t) =e= CRes(b,tLag)*power(1 - 1/(alpha(tLag)*tau(b)), gap(t))
              +  alpha(tLag)*tau(b)*(phi(b)/CO22C)*EmiCO2(tLag)*(EmiCO20/CRes0(b))
              *      (1 - power(1 - 1/(alpha(tLag)*tau(b)), gap(t))) ;

mateq(t)$(ts(t) and ifGBL)..
   MAT(t) =E= sum(b, CRes(b, t)*CRes0(b)/mat0) + 588/mat0 ;

*  Radiative forcing

forceq(t)$(ts(t) and ifGBL)..
   FORC("CO2", t) =E= fco22x * ((log((MAT(t)*mat0/mat_eq))/log(2))) + forcoth(t) ;

*  Temperature module

tempeq(tb, tt,t)$(ts(t) and (years(tt) gt years(tLag) and years(tt) le years(t)) and ifGBL)..
   TEMP(tb,tt) =e= sum(tbp, AMAT1(tb,tbp)*TEMP(tbp,tt-1))
                +  FMAT(tb)*sum(mapt(tt,tp), forc("CO2", tp))/sum(mapt(tt,tp), 1) ;

*  Downscaling of temperature

deltempeq(r,t)$(ts(t) and rs(r))..
   delTemp(r,t) =e= temp("atmos",t) ;

$endif

$iftheni "%DAMAGE_MODULE%" == "ON"

* --------------------------------------------------------------------------------------------------
*
*  Damage module
*
* --------------------------------------------------------------------------------------------------

*  X-1   Temperature damage to TFP

dam_tfpeq(r,a,t)$(ts(t) and ifDamage(r))..
   dam_tfp(r,a,t) =e= (1 + dam_shft_tfp(r,a,t)
                   *  (dam_beta0_tfp(r,a,t)
                   +   dam_beta1_tfp(r,a,t) * (delTemp(r,t) - delTemp0(r))
                   +   dam_beta2_tfp(r,a,t) * power(delTemp(r,t) - delTemp0(r),2))) ;

*  X-2   Temperature damage to labor productivity
*  N.B. In original WB code, dam_shft_lab eq 0 for ord(t) < 11 and dmgShfitLambdaL(t-9) for ord(t) > 10!!!!
*  Would be much better to say x$(years(t) lt xxxx) + y$(years(t) ge xxxx)

dam_labeq(r,l,a,t)$(ts(t) and ifDamage(r))..
   dam_lab(r,l,a,t) =e= (1+dam_shft_lab(r,l,a,t)
                   *  (dam_beta0_lab(r,l,a,t)
                   +   dam_beta1_lab(r,l,a,t) * (delTemp(r,t) - delTemp0(r))
                   +   dam_beta2_lab(r,l,a,t) * power(delTemp(r,t) - delTemp0(r),2))) ;

*  X-3   Temperature damage adjustment to health--adds to labor productivity effect

dam_hhteq(r,l,a,t)$(ts(t) and ifDamage(r))..
   dam_hht(r,l,a,t) =e= (1+dam_shft_hht(r,l,a,t)
                     *  (dam_beta0_hht(r,l,a,t)
                     +   dam_beta1_hht(r,l,a,t) * (delTemp(r,t) - delTemp0(r))
                     +   dam_beta2_hht(r,l,a,t) * power(delTemp(r,t) - delTemp0(r),2))) ;

*  X-4   Temperature damage adjustment to household energy demand

dam_nrgeq(r,k,h,t)$(ts(t) and ifDamage(r))..
   dam_nrg(r,k,h,t) =e= (1+dam_shft_nrg(r,k,h,t)
                     *  (dam_beta0_nrg(r,k,h,t)
                     +   dam_beta1_nrg(r,k,h,t) * (delTemp(r,t) - delTemp0(r))
                     +   dam_beta2_nrg(r,k,h,t) * power(delTemp(r,t) - delTemp0(r),2))) ;

*  X-5   Temperature damage adjustment to land supply (sea-level rise induced)
*  !!!! N.B. WB code scales damage component by 1e-6 !!!!

dam_lndeq(r,lnd,t)$(ts(t) and ifDamage(r))..
   dam_lnd(r,lnd,t) =e= (1+dam_shft_lnd(r,lnd,t)
                     *  (dam_beta0_lnd(r,lnd,t)
                     +   dam_beta1_lnd(r,lnd,t) * (delTemp(r,t) - delTemp0(r))
                     +   dam_beta2_lnd(r,lnd,t) * power(delTemp(r,t) - delTemp0(r),2))) ;

*  X-6   Damages to tourism export revenues

*  Not yet integrated in the model

dam_toueq(r,i,t)$(ts(t) and ifDamage(r))..
   dam_tou(r,i,t) =e= (1+dam_shft_tou(r,i,t)
                   *  (dam_beta0_tou(r,i,t)
                   +   dam_beta1_tou(r,i,t) * (delTemp(r,t) - delTemp0(r))
                   +   dam_beta2_tou(r,i,t) * power(delTemp(r,t) - delTemp0(r),2))) ;

*  X-7   Damages to capital stock

dam_capeq(r,t)$(ts(t) and ifDamage(r))..
   dam_cap(r,t) =e= (1+dam_shft_cap(r,t)
                 *  (dam_beta0_cap(r,t)
                 +   dam_beta1_cap(r,t) * (delTemp(r,t) - delTemp0(r))
                 +   dam_beta2_cap(r,t) * power(delTemp(r,t) - delTemp0(r),2))) ;

* --------------------------------------------------------------------------------------------------
*
*  Adaptation module
*
* --------------------------------------------------------------------------------------------------

dam_shft_tfpeq(r,a,t)$(ts(t) and rs(r) and chi_adp_tfp(r,a,t) and ifDamage(r))..
   dam_shft_tfp(r,a,t) =e= chi_adp_tfp(r,a,t)*xfd(r,"adptfp",t)**(-rhodmg_tfp(r,t)) ;

dam_shft_labeq(r,l,a,t)$(ts(t) and rs(r) and chi_adp_lab(r,l,a,t) and ifDamage(r))..
   dam_shft_lab(r,l,a,t) =e= chi_adp_lab(r,l,a,t)*xfd(r,"adplab",t)**(-rhodmg_lab(r,t)) ;

dam_shft_hhteq(r,l,a,t)$(ts(t) and rs(r) and chi_adp_hht(r,l,a,t) and ifDamage(r))..
   dam_shft_hht(r,l,a,t) =e= chi_adp_hht(r,l,a,t)*xfd(r,"adphht",t)**(-rhodmg_hht(r,t)) ;

dam_shft_nrgeq(r,k,h,t)$(ts(t) and rs(r) and chi_adp_nrg(r,k,h,t) and ifDamage(r))..
   dam_shft_nrg(r,k,h,t) =e= chi_adp_nrg(r,k,h,t)*xfd(r,"adpnrg",t)**(-rhodmg_nrg(r,t)) ;

dam_shft_lndeq(r,lnd,t)$(ts(t) and rs(r) and chi_adp_lnd(r,lnd,t) and ifDamage(r))..
   dam_shft_lnd(r,lnd,t) =e= chi_adp_lnd(r,lnd,t)*xfd(r,"adplnd",t)**(-rhodmg_lnd(r,t)) ;

dam_shft_toueq(r,i,t)$(ts(t) and rs(r) and chi_adp_tou(r,i,t) and ifDamage(r))..
   dam_shft_tou(r,i,t) =e= chi_adp_tou(r,i,t)*xfd(r,"adptou",t)**(-rhodmg_tou(r,t)) ;

dam_shft_capeq(r,t)$(ts(t) and rs(r) and chi_adp_cap(r,t) and ifDamage(r))..
   dam_shft_cap(r,t) =e= chi_adp_cap(r,t)*xfd(r,"adpcap",t)**(-rhodmg_cap(r,t)) ;

*  Cost sharing equation

yfdexpadpeq(r,fd,t)$(ts(t) and ifAdpy(r,fd) and ifDamage(r))..
   yfdexpadp(r,fd,t) =e= sum(adp, chi_adp_exp(r,fd,adp,t)*pfd(r,adp,t)*xfd(r,adp,t)) ;

$endif

* --------------------------------------------------------------------------------------------------
*
*  Welfare module
*
* --------------------------------------------------------------------------------------------------

*  Price of savings

chisaveeq(t)$(ts(t) and ifGBL)..
   chisave(t) =e= sum((r,inv), m_phiInv(r,tLag)*pfd(r,inv,t)/pfd(r,inv,tLag))
               /  sum(r,       m_phiSav(r,tLag)*psave(r,t)/psave(r,tLag)) ;

psaveeq(r,t)$(ts(t) and rs(r))..
   psave(r,t) =e= chisave(t)*sum(inv, pfd(r,inv,t)*psave(r,tLag)/pfd(r,inv,tLag)) ;

*  Equivalent variation at base year prices
*  !!!! Check formulas for non-CDE

eveq(r,h,t)$(1 and ts(t) and rs(r))..
   0 =e= (1e0 - sum(k$xcFlag(r,k,h), (1e0*alphah(r,k,h,t)
      *           (u0(r,h)**(eh(r,k,h,t)*bh(r,k,h,t)))
      *           (pc0(r,k,h)*pop0(r)/ev0(r,h))**bh(r,k,h,t))
      *        (u(r,h,t)**(eh(r,k,h,t)*bh(r,k,h,t)))
      *        (pop(r,t)*pc(r,k,h,t0)/ev(r,h,t))**bh(r,k,h,t)))
      $(%utility%=CDE)

      +  (ev0(r,h)*ev(r,h,t)/(pop0(r)*pop(r,t))
      -     sum(k$xcFlag(r,k,h), gammac(r,k,h,t)*pc0(r,k,h)*pc(r,k,h,t0))
      -     u(r,h,t)*u0(r,h)*exp(
               mus0(r,h)*mus(r,h,t)*log(pfd0(r,h)*pfd(r,h,t0)/(mus0(r,h)*mus(r,h,t)))
      +        sum(k$xcFlag(r,k,h), muc0(r,k,h)*muc(r,k,h,t)
      *           log(pc0(r,k,h)*pc(r,k,h,t0)/(muc0(r,k,h)*muc(r,k,h,t))))))
      $(%utility%=ELES and uFlag(r,h))

      +  (1 - sum(k$xcFlag(r,k,h),  muc0(r,k,h)*muc(r,k,h,t)
      *     log(((muc0(r,k,h)*muc(r,k,h,t)/(pc0(r,k,h)*pc(r,k,h,t0)))
      *        (ev0(r,h)*ev(r,h,t)/(pop0(r)*pop(r,t))
      -           sum(kp$xcFlag(r,kp,h), pc0(r,kp,h)*pc(r,kp,h,t0)*gammac(r,kp,h,t))))
      /        (aad(r,h,t)*exp(u(r,h,t)*u0(r,h))))))
      $(%utility% ne CDE and %utility% ne ELES)
      ;

evfeq(r,fdc,t)$(ts(t) and rs(r) and fdFlag(r,fdc))..
   evf(r,fdc,t) =e= (yfd0(r,fdc)/evf0(r,fdc))*pfd(r,fdc,t0)*(yfd(r,fdc,t)/pfd(r,fdc,t)) ;

evseq(r,t)$(ts(t) and rs(r))..
   evs(r,t)*evs0(r) =e= sum(h, psave(r,t0)*(savh0(r,h)*savh(r,h,t)))
                     +         psave(r,t0)*savg(r,t)/psave(r,t) ;

sweq(t)$(ts(t) and ifGBL)..
   sw(t) =e= sum(r, (welfwgt(r,t)*pop0(r)*pop(r,t)/((1-epsw(t))*sw0*sum(rp,pop0(rp)*pop(rp,t))))
          *         (sum(h, ev0(r,h)*ev(r,h,t))/(pop0(r)*pop(r,t)))**(1-epsw(t))) ;

swteq(t)$(ts(t) and ifGBL)..
   swt(t) =e= sum(r, (welftwgt(r,t)*pop0(r)*pop(r,t)/((1-epsw(t))*swt0*sum(rp,pop0(rp)*pop(rp,t))))
           *         ((sum(h, ev0(r,h)*ev(r,h,t)) + sum(gov, evf0(r,gov)*evf(r,gov,t)))
           /                  (pop0(r)*pop(r,t)))**(1-epsw(t))) ;

swt2eq(t)$(ts(t) and ifGBL)..
   swt2(t) =e= sum(r, (welftwgt(r,t)*pop0(r)*pop(r,t)
            /           ((1-epsw(t))*swt20*sum(rp,pop0(rp)*pop(rp,t))))
            *   ((sum(h, ev0(r,h)*ev(r,h,t)) + sum(gov, evf0(r,gov)*evf(r,gov,t))
            +        evs(r,t)*evs0(r))
            /    (pop0(r)*pop(r,t)))**(1-epsw(t)))

Parameters
   evBaU(r,h,t)
;

Variables
   betaEV(r,t)          "Ratio of EV change relative to average"
;

Equations
   evRatioeq(r,ra,t)    "Assumption on relative income changes"
   itransferseq(ra,t)   "Net transfers must sum to zero"
;

sets
   evRatioFlag(r,ra)
   iTransferFlag(ra)
;

evRatioeq(r,ra,t)$(ts(t) and rs(r) and evRatioFlag(r,ra))..
   sum(h, ev0(r,h)*ev(r,h,t))/sum(h, evBaU(r,h,t))
      =e= betaEV(r,t)*sum((s,h)$mapra(ra,s), ev0(s,h)*ev(s,h,t))/sum((s,h)$mapra(ra,s),evBaU(s,h,t)) ;

itransferseq(ra,t)$(ts(t) and iTransferFlag(ra))..
   sum(r$mapra(ra,r), itransfers(r,t)) =e= 0 ;

objeq..
   obj =e= (sum(t$ts(t), sw(t)))$(ifGBL)
        +  (sum(t$ts(t), sum((h,r)$rs(r), ev(r,h,t))))$(not ifGBL) ;

*  !!!! Pairings are not complete as some depend on closure. To look into.

model core /

   emiRebateeq, pxeq, uceq.uc,
   xpneq.xpn, xghgeq.xghg, pxveq.pxv,
   procEmieq.procEmi, pxghgeq.pxghg,
   xpxeq.xpx, pxneq.pxn,
   nd1eq.nd1, vaeq.va, pxpeq.pxp,

   lab1eq.lab1, kefeq.kef, nd2eq.nd2,
   va1eq.va1, va2eq.va2, landdeq.landd,
   lndeq.xf, planddeq.plandd, planddndxeq.planddndx,
   pvaeq.pva, pva1eq.pva1, pva2eq.pva2

   kfeq.kf, xnrgeq.xnrg, pkefeq.pkef,

   ksweq.ksw, xnrseq.xf, pkfeq.pkf,

   kseq.ks, xwateq.xwat, pksweq.pksw, h2oeq.xf,

   kveq.kv, lab2eq.lab2, pkseq.pks,

   labbeq.labb, plab1eq.plab1, plab2eq.plab2,
   ldeq.xf, plabbeq.plabb,

   xapeq.xa, pnd1eq.pnd1, pnd2eq.pnd2, pwateq.pwat,
   xnelyeq.xnely, xolgeq.xolg,
   xaNRGeq.xaNRG, paNRGNDXeq.paNRGNDX, paNRGeq.paNRG, xaeeq.xa,
   polgeq.polg, polgNDXeq.polgNDX,
   pnelyNDXeq.pnelyNDX, pnelyeq.pnely,
   pnrgNDXeq.pnrgNDX, pnrgeq.pnrg,

$ontext
$iftheni "%FIX_OUTPUT%" == "1"
   xpeq.tfp,
$else
   xpeq.xp,
$endif
$offtext
   xpeq,
   peq.p, ppeq.pp, xeq.x, pseq.ps,
   xetdeq.x, xpoweq.xpow, pselyeq.ps, xpbeq, ppowndxeq.ppowndx, ppoweq.ppow,
   xbndeq.x, ppbndxeq.ppbndx, ppbeq.ppb,

   deprYeq.deprY, yqtfeq.yqtf, trustYeq.trustY, yqhteq.yqht, ntmYeq.ntmY,
   ODAIneq.ODAIn, ODAOuteq.ODAOut, ODAGbleq.ODAGbl, remiteq.remit,
   yheq.yh, ydeq.yd,
   savhELESeq.aps, apseq, savheq.savh, yceq.yc,
$iftheni "%IFI_MODULE%" == "ON"
   ifieq, ifiToteq,
$endif
   ygoveq.ygov, yfdInveq,
   lSubsYeq, fSubsYeq,

   ctaxgapeq.ctaxgap, ctaxgapfxeq.alphaFtax, alphaFtaxeq.alphaY,

*  supyeq.supy, thetaeq.theta, xceq.xc, hshreq.hshr,
   supyeq.supy, zconseq.zcons, xceq.xc, hshreq.hshr, muceq.muc, ueq.u,
   xcnnrgeq.xcnnrg, xcnrgeq.xcnrg, pceq.pc,
   xacnnrgeq, pcnnrgeq.pcnnrg,
   xcnelyeq.xcnely, xcolgeq.xcolg, xacNRGeq.xacNRG, xaceeq,
   pacNRGNDXeq.pacNRGNDX, pacNRGeq.pacNRG, pcolgNDXeq.pcolgNDX, pcolgeq.pcolg,
   pcnelyNDXeq.pcnelyNDX, pcnelyeq.pcnely, pcnrgeq.pcnrg,pcnrgNDXeq.pcnrgNDX,
   xaaceq, xawceq, paacceq, paaceq, paheq, pawceq,
*  xaaceq.xaac, xawceq.xawc, paacceq.paacc, paaceq.paac, pawceq.pawc,
   phhTaxYeq, phhTaxeq,

   xafeq.xa, pfdfeq.pfd, yfdeq.yfd,

   xateq.xat, xdteq.xdt, xmteq.xmt, pateq.pat, patNDXeq.patNDX, paeq.pa, paNDXeq.paNDX,
   xdeq.xd, xmeq.xm, pdeq.pd, pmeq.pm,

$iftheni "%MRIO_MODULE%" == "ON"
   xwaeq.xwa, pdmaeq.pdma, pmaeq.pma, xwdMRIOeq.xw,
$endif
   xwdeq.xw, pmtNDXeq.pmtNDX, pmteq.pmt,

*  pdteq.pdt, xeteq.xet, xseq.xs, xwseq.pe, peteq.pet,
   pdteq.pdt, xeteq.xet, xseq.xs, psNDXeq.psNDX, xwseq.pe, peteq, petNDXeq.petNDX,
   pweeq.pwe, pwmeq.pwm, pdmeq.pdm,

   xwmgeq.xwmg, xmgmeq.xmgm, pwmgeq.pwmg, xtmgeq.xtmg,
   xtteq.xtt, ptmgeq.ptmg,

   ldzeq, awagezeq.awagez, urbPremeq.urbPrem,
   resWageeq.resWage, ewagezDReq,
   uezeq, twageeq.twage, wageeq.pf, pflabeq.pf, rwageeq,

   skillpremeq, lseq.ls, tlseq.tls,

   kvseq, pkeq.pk, trenteq, rtrenteq,
*  kvseq, pkeq.pk, capuVeq.capu, trenteq, rtrenteq,
*  kxRateq.kxRat, rrateq.rrat, trentVinteq.trent, pkVinteq.pk,
*  ksloeq.kslo, rrateq.rrat, ksloinfeq.kslo, rratinfeq.rrat,
   ksloeq.kslo, rrateq.rrat,
   kxRateq.kxRat, kshieq.kshi,
*  k0eq.k0, xpveq.xpv, arenteq.arent, capeq.xf, pcapeq.pf,
   xpveq.xpv, arenteq.arent, capeq.xf, pcapeq.pf,
   capueq, tkapseq.tkaps,

   tlandeq.tland,
   xlb1eq.xlb, xnlbeq.xnlb, ptlandndxeq.ptlandndx, ptlandeq.ptland,
   xlbneq.xlb, pnlbndxeq.pnlbndx, pnlbeq.pnlb,
   plandeq.pf, plbndxeq.plbndx, plbeq.plb,

   etanrseq.etanrs, xfnoteq, pfnrseq.pf,

   th2oeq.th2o, h2obndeq.h2obnd, pth2ondxeq.pth2ondx, pth2oeq.pth2o, th2omeq.th2om,
   ph2obndndxeq.ph2obndndx, ph2obndeq.ph2obnd, ph2oeq.pf,

   pfpeq.pfp, pkpeq.pkp,

   pfdheq.pfd, xfdheq.xfd, conseq.cons, pconseq.pcons, gdpmpeq.gdpmp, rgdpmpeq, pgdpmpeq.pgdpmp,
   rgdppceq, ftfpeq,

   savgeq.savg, rsgeq,

   evRatioeq, itransferseq,

   rfdshreq, nfdshreq.nfdshr,
   kstockeeq.kstocke, roreq.ror, rorceq.rorc, roreeq.rore, savfeq, savfRateq, rorgeq,
   devRoReq.devRoR, grkeq.grK,
   cpieq.cpi, pmuveq.pmuv, pfacteq, pwfacteq, pwgdpeq.pwgdp, pwsaveq.pwsav, pnumeq, pweq,

*
   emiieq.emi, emifeq.emi, emixeq.emi,
   emiToteq.emiTot, emiGbleq.emiGbl,
   emiTotActeq.emiTotAct, emiInteq,
*  emiCapeq.emiRegTax, emiTaxeq.emiTax, emiQuotaYeq.emiQuotaY,

   emiTotETSeq.emiTotETS, emiCTAXeq.emiCTAX, chiCapeq.chiCap, avgEmiInteq,
   emiTaxeq.emiTax, procEmiTaxeq.procEmiTax, emiQuotaYeq.emiQuotaY, emiTaxXeq.emiTaxX,

$iftheni "%DAMAGE_MODULE%" == "ON"
   dam_tfpeq, dam_labeq, dam_hhteq, dam_nrgeq, dam_lndeq, dam_toueq, dam_capeq,
   dam_shft_tfpeq, dam_shft_labeq, dam_shft_hhteq, dam_shft_nrgeq,
   dam_shft_lndeq, dam_shft_toueq, dam_shft_capeq,
   yfdexpadpeq,
$endif

   tour_reveq, tour_revxeq, tour_shfteq,

   phTaxpbYeq, phTaxpbeq,

   chisaveeq.chisave, psaveeq.psave, eveq.ev, evfeq.evf, evseq.evs,
   sweq.sw, swteq.swt, swt2eq.swt2, objeq,

   walraseq
/ ;

core.holdfixed = 1 ;
core.tolinfrep    = 1e-5 ;

*  Equations used in all recursive dynamic scenarios

model coreRD /
$iftheni "%RD_MODULE%" == "ON"
   kneq, rdeq, pikeq
$endif

$iftheni.CS "%simType%" == "RcvDyn"
$iftheni.DEPL "%DEPL_MODULE%" == "ON"
   prateq.prat, omegareq.omegar, dscRateeq.dscRate, extRateeq.extRate,
   cumexteq.cumext, reseq.res, respeq.resp, ytdreseq.ytdres,
   resGapeq.resGap, xfPoteq.xfPot, extreq.extr,
   xfsnrseq.xfs, xfGapeq.xfGap
$endif.DEPL
$endif.CS

$iftheni.CLM "%CLIM_MODULE%" == "ON"
   EmiCO2eq, CumEmiIndeq, CumEmieq,
   alphaeq, CReseq, mateq,
   forceq, tempeq,
$endif.CLM

   klrateq,
   migreq.migr, migrMulteq.migrMult, lszeq.lsz, glabeq.glab,
   invGFacteq.invGFact, kstockeq.kstock, tkapseq.tkaps, lambdafeq.lambdaf, lambdakeq,

/ ;

model coreBau /
   core + coreRD +
$iftheni "%simType%" == "RcvDyn"
   uezeq, ewagezeq.chirw,
$endif
   grrgdppceq.gl
/ ;
coreBaU.holdfixed = 1 ;
coreBaU.tolinfrep = 1e-5 ;

model coreDyn /
   core + coreRD +
$iftheni "%simType%" == "RcvDyn"
   uezeq, ewagezeq.uez,
$endif
   grrgdppceq
/ ;
coreDyn.holdfixed = 1 ;
coreDyn.tolinfrep = 1e-5 ;

* -------------------------------------------------------------------------------------------------
*
*  For calculating embodied emissions after each time period
*
alias(i, jj) ;

Parameters
   axe(r,i,j,t)         "I-A, where A is the technical coefficients matrix"
   emiperoutpt(r,i,t)   "Emissions per output, kg CO2-eq per USD"
;

variables
   A_INV(r,i,j,t)    "Inverse of matrix (by regions and years)"
;

equations
   A_INVeq(r,i,j,t)  "Inverse calculation equation"
;

A_INVeq(r,i,j,t)$ts(t)..
   sum(jj, axe(r,i,jj,t)*A_INV(r,jj,j,t)) =e= 1$sameas(i,j) + 0$(not sameas(i,j)) ;

model aInvMod / A_INVeq / ;
aInvMod.holdfixed = 1 ;


