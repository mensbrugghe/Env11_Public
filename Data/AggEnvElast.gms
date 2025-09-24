* ------------------------------------------------------------------------------
*
*  Aggregate the parameters
*
*  The input file is in 'SatAcct' and is designed for each major release of
*  the GTAP database
*
*  The original elasticities come from the OECD's Env-Linkage Model
*  They are mapped to each GTAP database (e.g., v:\GTAP10\Elast)
*
* ------------------------------------------------------------------------------

File logFile / "%BaseName%/AggEnvElastLog.txt" / ;

*  Get the Sets

Sets
   v     "Vintages"           / Old, New /
   NRG   "Energy bundles"     / COA, OIL, GAS, ELY /
   lb0   "Land bundles"       / lb1*lb3 /
   reg   "GTAP regions"
   comm  "GTAP commodities"
   acts  "GTAP activities"
   endw  "GTAP production factors"

   lab0(endw)  "Labor endowments"
   erg0(comm)  "Energy commodities"
   acr0(acts)  "Original crop sectors"
   alv0(acts)  "Original livestock sectors"
   elya0(acts) "Original electricity sectors"
;

$gdxIn "%GTAPDir%/%DataBase%Dat.gdx"
$load reg, comm, acts, endw
*$loaddc lab=endwl, cap

$gdxIn "%GTAPDir%/%DataBase%VOLE.gdx"
$loaddc erg0=erg

*  !!!! These should be read-in
Set lab0(endw)  "Labor endowments" /
   tech_aspros    "Technical and professional workers"
   clerks         "Clerical workers"
   service_shop   "Service shop"
   off_mgr_pros   "Management"
   ag_othlowsk    "Agriculture and other low-skill workers"
/ ;
Singleton set cap(endw) "Capital endowment"           / Capital / ;
Singleton set lnd(endw) "Land endowment"              / Land / ;
Singleton set nrs(endw) "Natural resource endowment"  / natlRes / ;

parameters

*  Production elasticities

   sigmaxp0(reg,acts,v)          "CES between GHG and XP"
   sigmap0(reg,acts,v)           "CES between ND1 and VA"
   sigmav0(reg,acts,v)           "CES between LAB1 and VA1 in crops and other, VA1 and VA2 in livestock"
   sigmav10(reg,acts,v)          "CES between ND2 (fert) and VA2 in crops, LAB1 and KEF in livestock and land and KEF in other"
   sigmav20(reg,acts,v)          "CES between land and KEF in crops, land and ND2 (feed) in livestock. Not used in other"
   sigmakef0(reg,acts,v)         "CES between KF and NRG"
   sigmakf0(reg,acts,v)          "CES between KSW and NRF"
   sigmakw0(reg,acts,v)          "CES between KS and XWAT"
   sigmak0(reg,acts,v)           "CES between LAB2 and K"
   sigmaul0(reg,acts)            "CES across unskilled labor"
   sigmasl0(reg,acts)            "CES across skilled labor"
   sigman10(reg,acts)            "CES across intermediate demand in ND1 bundle"
   sigman20(reg,acts)            "CES across intermediate demand in ND2 bundle"
   sigmawat0(reg,acts)           "CES across intermediate demand in WAT bundle"
   sigmae0(reg,acts,v)           "CES between ELY and NELY in energy bundle"
   sigmanely0(reg,acts,v)        "CES between COA and OLG in energy bundle"
   sigmaolg0(reg,acts,v)         "CES between OIL and GAS in energy bundle"
   sigmaNRG0(reg,acts,NRG,v)     "CES within each of the NRG bundles"

*  Make matrix elasticities (incl. power)

   omegas0(reg,acts)             "Make matrix transformation elasticities: one activity --> many commodities"
   sigmas0(reg,comm)             "Make matrix substitution elasticities: one commodity produced by many activities"
   sigmael0(reg)                 "Substitution between power and distribution and transmission"
   sigmapow0(reg)                "Substitution across power bundles"
   sigmapb0(reg)                 "Substitution across power activities within power bundles"

*  Final demand elasticities

   incElas0(reg,comm)            "Income elasticities"
   nu0(reg)                      "Elasticity of subsitution between energy and non-energy bundles in HH consumption"
   nunnrg0(reg)                  "Substitution elasticity across non-energy commodities in the non-energy bundle"
   nue0(reg)                     "Substitution elasticity between ELY and NELY bundle"
   nunely0(reg)                  "Substitution elasticity beteen COL and OLG bundle"
   nuolg0(reg)                   "Substitution elasticity between OIL and GAS bundle"
   nuNRG0(reg,NRG)               "Substitution elasticity within NRG bundles"
   sigma_gov0(reg)               "CES expenditure elasticity for government"
   sigma_inv0(reg)               "CES expenditure elasticity for investment"

*  Trade elasticities

   sigmam0(reg,comm)             "Top level Armington elasticity"
   sigmaw0(reg,comm)             "Second level Armington elasticity"
   omegax0(reg,comm)             "Top level CET export elasticity"
   omegaw0(reg,comm)             "Second level CET export elasticity"
   sigmamg0(comm)                "CES 'Make' elasticity for intl. trade and transport services"

*  Factor supply elasticities

   omegak0(reg)                  "CET capital mobility elasticity in comp. stat. model"
   etat0(reg)                    "Aggregate land supply elasticity"
   landMax0(reg)                 "Initial ratio of land maximum wrt to land use"
   omegat0(reg)                  "Land elasticity between intermed. land bundle and first land bundle"
   omeganlb0(reg)                "Land elasticity across intermediate land bundles"
   omegalb0(reg,lb0)             "Land elasticity within land bundles"
   etanrf0(reg,acts)             "Natural resource supply elasticity"
   invElas0(reg,acts)            "Dis-investment elasticity"

   omegam0(reg)                  "Elasticity of migration"
;

*  Read the base elasticities
execute_loaddc "%SatDir%/EnvLinkElast%ver%.gdx"
   sigmaxp0, sigmap0, sigman10, sigman20, sigmawat0,
   sigmav0, sigmav10, sigmav20,
   sigmakef0, sigmakf0, sigmakw0, sigmak0,
   sigmaul0, sigmasl0,
   sigmae0, sigmanely0, sigmaolg0, sigmaNRG0,
   omegas0, sigmas0,
   sigmael0, sigmapow0, sigmapb0,
   incElas0, nu0, nunnrg0,nue0, nunely0, nuolg0, nuNRG0,
   sigma_gov0, sigma_inv0,
   sigmam0, sigmaw0, omegax0, omegaw0, sigmamg0
   omegak0, invElas0, etat0, landMax0,
   omegat0, omeganlb0, omegalb0,
   etanrf0, omegam0
;

Parameters
   incPar0(comm,reg)       "CDE expansion parameters"
   subPar0(comm,reg)       "CDE substitution parameters"
;

Execute_loaddc "%GTAPDir%/%DataBase%Par.gdx",
   incpar0=incpar, subpar0=subpar ;

*  Calculate weights
*  !!!! NEED TO REVIEW AGGREGATION AND WEIGHTS

alias(reg,src) ; alias(reg,dst) ;
Parameters
   VDFP(comm,acts,reg)     "Intermediate purchases of domestic goods at purchasers' prices"
   VMFP(comm,acts,reg)     "Intermediate purchases of imported goods at purchasers' prices"
   VDFB(comm,acts,reg)     "Intermediate purchases of domestic goods at basic prices"
   VMFB(comm,acts,reg)     "Intermediate purchases of imported goods at basic prices"
   EVFP(endw,acts,reg)     "Value added at purchasers' prices"
   EVFB(endw,acts,reg)     "Value added at purchasers' prices"

   VDPP(comm,reg)          "Private purchases of domestic goods at purchasers' prices"
   VMPP(comm,reg)          "Private purchases of imported goods at purchasers' prices"
   VDPB(comm,reg)          "Private purchases of domestic goods at basic prices"
   VMPB(comm,reg)          "Private purchases of imported goods at basic prices"
   VDGP(comm,reg)          "Government purchases of domestic goods at purchasers' prices"
   VMGP(comm,reg)          "Government purchases of imported goods at purchasers' prices"
   VDGB(comm,reg)          "Government purchases of domestic goods at basic prices"
   VMGB(comm,reg)          "Government purchases of imported goods at basic prices"
   VDIP(comm,reg)          "Investment purchases of domestic goods at purchasers' prices"
   VMIP(comm,reg)          "Investment purchases of imported goods at purchasers' prices"
   VDIB(comm,reg)          "Investment purchases of domestic goods at basic prices"
   VMIB(comm,reg)          "Investment purchases of imported goods at basic prices"

   VST(comm,reg)           "Domestic sales of trade and transport services"
   VXSB(comm,src,dst)      "Export sales at basic prices"
   VOA(reg,acts)           "Production weights"
   VND(reg,acts)           "Intermediate demand weights"
   VVA(reg,acts)           "Valued added weights"
   VKAP(reg,acts)          "Capital weights"
   VLAB(reg,acts)          "Labor weights"
   VNRG(reg,acts)          "Energy weights"
;

Execute_loaddc "%GTAPDir%/%DataBase%Dat.gdx",
   vdfp, vmfp, vdfb, vmfb, evfp, evfb
   vdpp, vmpp, vdgp, vmgp, vdip, vmip
   vdpb, vmpb, vdgb, vmgb, vdib, vmib,
   vst, vxsb ;

vnd(reg,acts) = sum(comm, vdfp(comm,acts,reg) + vmfp(comm,acts,reg)) ;
vva(reg,acts) = sum(endw, evfp(endw,acts,reg)) ;
voa(reg,acts) = vnd(reg,acts) + vva(reg,acts) ;
vkap(reg,acts) = evfp(cap,acts,reg) ;
vlab(reg,acts) = sum(lab0, evfp(lab0,acts,reg)) ;
vnrg(reg,acts) = sum(comm$erg0(comm), vdfp(comm,acts,reg) + vmfp(comm,acts,reg)) ;

* ------------------------------------------------------------------------------
*
*  Declare the aggregate parameters
*
* ------------------------------------------------------------------------------

Sets
   r        "Aggregate regions"
   i        "Aggregate commodities"
   a        "Aggregate activities"
   fp       "Aggregate production factors"
   l(fp)    "Labor endowments"
*  !!!! Hard-coded
   h        "Households"  / hhd /

   reg1  "Primary regions"
   acts1 "Primary activities"
   comm1 "Primary commodities"
   endw1 "Primary endowments"

   mapr0(reg1,reg)      "Mapping from GTAP regions to primary regions"
   mapr1(r,reg1)        "Mapping from primary regions to modeled regions"
   mapa0(acts1,acts)    "Mapping from GTAP activities to primary activities"
   mapa1(a,acts1)       "Mapping from primary activities to modeled activities"
   mapi0(comm1,comm)    "Mapping from GTAP commodities to primary commodities"
   mapi1(i,comm1)       "Mapping from primary commodities to modeled commodities"
   mapf0(endw1,endw)    "Mapping from GTAP endowments to primary endowments"
   mapf1(fp,endw1)      "Mapping from primary endowments to modeled endowments"

   mapr(r,reg)          "Mapping from GTAP regions to modeled regions"
   mapa(a,acts)         "Mapping from GTAP activities to modeled activities"
   mapi(i,comm)         "Mapping from GTAP commodities to modeled commodities"
   mapf(fp,endw)        "Mapping from GTAP endowments to modeled endowments"
;

$gdxIn "%inFolder%/%BaseName%Dat.gdx"
$load r=reg, i=comm, a=acts, fp=endw
$load reg1, acts1, comm1, endw1
$loaddc l=lab,mapr0, mapr1, mapa0, mapa1, mapi0, mapi1, mapf0, mapf1

loop((reg,reg1,r), mapr(r,reg)$(mapr0(reg1,reg) and mapr1(r,reg1)) = yes ; ) ;
loop((acts,acts1,a), mapa(a,acts)$(mapa0(acts1,acts) and mapa1(a,acts1)) = yes ; ) ;
loop((comm,comm1,i), mapi(i,comm)$(mapi0(comm1,comm) and mapi1(i,comm1)) = yes ; ) ;
loop((endw,endw1,fp), mapf(fp,endw)$(mapf0(endw1,endw) and mapf1(fp,endw1)) = yes ; ) ;

*  Get the Envisage sets

alias(l,lab) ;
$include "../%BaseName%/%BaseName%Sets.gms"

*  !!!! This is a convenient spot to check mapk!

scalar check / 0 / ;
scalar ifAllCheck / 0 / ;

$batInclude "CheckMap" mapk i k  Consumer_commodities

parameters

*  Production elasticities

   sigmaxp(r,a,v)          "CES between GHG and XP"
   sigmap(r,a,v)           "CES between ND1 and VA"
   sigmav(r,a,v)           "CES between LAB1 and VA1 in crops and other, VA1 and VA2 in livestock"
   sigmav1(r,a,v)          "CES between ND2 (fert) and VA2 in crops, LAB1 and KEF in livestock and land and KEF in other"
   sigmav2(r,a,v)          "CES between land and KEF in crops, land and ND2 (feed) in livestock. Not used in other"
   sigmakef(r,a,v)         "CES between KF and NRG"
   sigmakf(r,a,v)          "CES between KSW and NRF"
   sigmakw(r,a,v)          "CES between KS and XWAT"
   sigmak(r,a,v)           "CES between LAB2 and K"
   sigmaul(r,a)            "CES across unskilled labor"
   sigmasl(r,a)            "CES across skilled labor"
   sigman1(r,a)            "CES across intermediate demand in ND1 bundle"
   sigman2(r,a)            "CES across intermediate demand in ND2 bundle"
   sigmawat(r,a)           "CES across intermediate demand in WAT bundle"
   sigmae(r,a,v)           "CES between ELY and NELY in energy bundle"
   sigmanely(r,a,v)        "CES between COA and OLG in energy bundle"
   sigmaolg(r,a,v)         "CES between OIL and GAS in energy bundle"
   sigmaNRG(r,a,NRG,v)     "CES within each of the NRG bundles"

*  Make matrix elasticities (incl. power)

   omegas(r,a)             "Make matrix transformation elasticities: one activity --> many commodities"
   sigmas(r,i)             "Make matrix substitution elasticities: one commodity produced by many activities"
   sigmael(r,elyc)         "Substitution between power and distribution and transmission"
   sigmapow(r,elyc)        "Substitution across power bundles"
   sigmapb(r,pb,elyc)      "Substitution across power activities within power bundles"

*  Final demand elasticities

   incElas(k,r)            "Income elasticities"
   nu(r,k,h)               "Elasticity of subsitution between energy and non-energy bundles in HH consumption"
   nunnrg(r,k,h)           "Substitution elasticity across non-energy commodities in the non-energy bundle"
   nue(r,k,h)              "Substitution elasticity between ELY and NELY bundle"
   nunely(r,k,h)           "Substitution elasticity beteen COL and OLG bundle"
   nuolg(r,k,h)            "Substitution elasticity between OIL and GAS bundle"
   nuNRG(r,k,h,NRG)        "Substitution elasticity within NRG bundles"
   sigma_gov(r)            "CES expenditure elasticity for government"
   sigma_inv(r)            "CES expenditure elasticity for investment"

*  Trade elasticities

   sigmam(r,i)             "Top level Armington elasticity"
   sigmaw(r,i)             "Second level Armington elasticity"
   omegax(r,i)             "Top level CET export elasticity"
   omegaw(r,i)             "Second level CET export elasticity"
   sigmamg(i)              "CES 'Make' elasticity for intl. trade and transport services"

*  Factor supply elasticities

   omegak(r)               "CET capital mobility elasticity in comp. stat. model"
   etat(r)                 "Aggregate land supply elasticity"
   landMax(r)              "Initial ratio of land maximum wrt to land use"
   omegat(r)               "Land elasticity between intermed. land bundle and first land bundle"
   omeganlb(r)             "Land elasticity across intermediate land bundles"
   omegalb(r,lb0)          "Land elasticity within land bundles"
   etanrf(r,a)             "Natural resource supply elasticity"
   invElas(r,a)            "Dis-investment elasticity"

   omegam(r,l)             "Elasticity of migration"
;

$macro agg2(sigma,sigma0,wgt,r1,s1,r,s,mapr,maps) \
   sigma(r,s)$sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1)) \
      = sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1) * sigma0(r1,s1)) \
      / sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1))

$macro agg2v(sigma,sigma0,wgt,r1,s1,r,s,mapr,maps) \
   sigma(r,s,v)$sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1)) \
      = sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1) * sigma0(r1,s1,v)) \
      / sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1))

$macro agg2ve(sigma,sigma0,wgt,r1,s1,r,s,mapr,maps) \
   sigma(r,s,NRG,v)$sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1)) \
      = sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1) * sigma0(r1,s1,NRG,v)) \
      / sum((r1,s1)$(mapr(r,r1) and maps(s,s1)), wgt(r1,s1))



*  !!!! Why not use sigmav2, sigmakw0

agg2v(sigmaxp,  sigmaxp0,  voa, reg, acts, r, a, mapr, mapa) ;
agg2v(sigmap,   sigmap0,   voa, reg, acts, r, a, mapr, mapa) ;
agg2v(sigmav,   sigmav0,   vva, reg, acts, r, a, mapr, mapa) ;
agg2v(sigmav1,  sigmav10,  vva, reg, acts, r, a, mapr, mapa) ;
agg2v(sigmav2,  sigmav20,  vva, reg, acts, r, a, mapr, mapa) ;
agg2v(sigmakef, sigmakef0, vva, reg, acts, r, a, mapr, mapa) ;
agg2v(sigmakf,  sigmakf0,  vva, reg, acts, r, a, mapr, mapa) ;
agg2v(sigmakw,  sigmakw0,  vva, reg, acts, r, a, mapr, mapa) ;
agg2v(sigmak,   sigmak0,   vva, reg, acts, r, a, mapr, mapa) ;
agg2(sigmaul,   sigmaul0, vlab, reg, acts, r, a, mapr, mapa) ;
agg2(sigmasl,   sigmasl0, vlab, reg, acts, r, a, mapr, mapa) ;

*  Intermediate demand bundle ND1

loop(mapa(a,acts), acr0(acts)$acr(a) = yes ) ;
loop(mapa(a,acts), alv0(acts)$alv(a) = yes ) ;
loop(mapa(a,acts), elya0(acts)$elya(a) = yes ) ;

vnd(reg,acts) = sum((comm,i)$(mapi(i,comm) and not frt(i) and not e(i)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg))$acr0(acts)
              + sum((comm,i)$(mapi(i,comm) and not feed(i) and not e(i)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg))$alv0(acts)
              + sum((comm,i)$(mapi(i,comm) and not e(i)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg))$(not acr0(acts) and not alv0(acts))
              ;
agg2(sigman1, sigman10, vnd, reg, acts, r, a, mapr, mapa) ;

*  Intermediate demand bundle ND2
vnd(reg,acts) = sum((comm,i)$(mapi(i,comm) and frt(i)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg))$acr0(acts)
              + sum((comm,i)$(mapi(i,comm) and feed(i)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg))$alv0(acts)
              + 0$(not acr0(acts) and not alv0(acts))
              ;
agg2(sigman2, sigman20, vnd, reg, acts, r, a, mapr, mapa) ;

*  Water bundle
vnd(reg,acts) = sum((comm,i)$(mapi(i,comm) and iw(i)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg)) ;
agg2(sigmawat, sigmawat0, vnd, reg, acts, r, a, mapr, mapa) ;

*  Energy bundle
agg2v(sigmae, sigmae0, vnrg, reg, acts, r, a, mapr, mapa) ;

*  Non-electric bundle

vnrg(reg,acts) = sum((comm,i)$(mapi(i,comm) and e(i) and not elyc(i)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg)) ;
agg2v(sigmanely, sigmanely0, vnrg, reg, acts, r, a, mapr, mapa) ;

*  Oil & gas bundle
vnrg(reg,acts) = sum((comm,e)$(mapi(e,comm) and mape("oil",e) and mape("gas",e)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg)) ;
agg2v(sigmaolg, sigmaolg0, vnrg, reg, acts, r, a, mapr, mapa) ;

*  Loop over the energy bundles
loop(NRG,
   vnrg(reg,acts) = sum((comm,e)$(mapi(e,comm) and mape(NRG,e)), vdfp(comm,acts,reg) + vmfp(comm,acts,reg)) ;
   agg2ve(sigmaNRG, sigmaNRG0, vnrg, reg, acts, r, a, mapr, mapa) ;
) ;

*  Make matrix elasticities including power

* !!!! There are no standard elasticities for 'make' matrix for the moment

omegas(r,a) = 2 ;
sigmas(r,i) = 2 ;

*  !!!! There are no standard elasticities for 'power' bundle

sigmael(r,elyc)$sum((reg,elya0)$mapr(r,reg), voa(reg,elya0))
   = sum((reg,elya0)$mapr(r,reg), voa(reg,elya0)*sigmael0(reg))
   / sum((reg,elya0)$mapr(r,reg), voa(reg,elya0)) ;

sigmapow(r,elyc)$sum((reg,elya0)$mapr(r,reg), voa(reg,elya0))
   = sum((reg,elya0)$mapr(r,reg), voa(reg,elya0)*sigmapow0(reg))
   / sum((reg,elya0)$mapr(r,reg), voa(reg,elya0)) ;

sigmapb(r,pb,elyc)$sum((reg,elya0)$mapr(r,reg), voa(reg,elya0))
   = sum((reg,elya0)$mapr(r,reg), voa(reg,elya0)*sigmapb0(reg))
   / sum((reg,elya0)$mapr(r,reg), voa(reg,elya0)) ;

*  Final demand elasticities

alias(k,kp) ;
Parameters
   b_c(k,r)       "Substitution parameter for final disaggregation"
   e_c(k,r)       "Expansion parameter for final disaggregation"
   s_c(k,r)       "Share parameter for final disaggregation"
   incElasG(k,r)  "GTAP income elasticity"
   hwgt(k,r)      "Budget shares"
;

scalar denom ;

hwgt(k,r) = sum(mapk(k,i), sum((comm,reg)$(mapi(i,comm) and mapr(r,reg)), vdpp(comm,reg) + vmpp(comm,reg))) ;

$macro aggh(prm, prm0, hwgt) \
   prm(k,r)$hwgt(k,r) = sum(mapk(k,i), sum((comm,reg)$(mapi(i,comm) and mapr(r,reg)), prm0(comm,reg)*(vdpp(comm,reg) + vmpp(comm,reg)))) \
            / hwgt(k,r) ;

aggh(e_c, incpar0, hwgt)
aggh(b_c, subpar0, hwgt)
s_c(k,r) = hwgt(k,r) / sum((comm,reg), vdpp(comm,reg) + vmpp(comm,reg)) ;
incElasG(k,r) = (e_c(k,r)*b_c(k,r) - sum(kp, s_c(kp,r)*e_c(kp,r)*b_c(kp,r)))
              / sum(kp, s_c(kp,r)*e_c(kp,r))
              - (b_c(k,r)-1) + sum(kp, s_c(kp,r)*b_c(kp,r)) ;

*  Aggregate the income elasticity in the default ENV parameter file
*  Bit of a mess with the ordering of the indices

incElas(k,r)$hwgt(k,r) = sum(mapk(k,i), sum((comm,reg)$(mapi(i,comm) and mapr(r,reg)), incElas0(reg,comm)*(vdpp(comm,reg) + vmpp(comm,reg))))
            / hwgt(k,r) ;

*  Aggregate the private agents energy elasticities

*  Elasticity between energy and non-energy bundles
nu(r,k,h)$sum((reg,comm), vdpp(comm,reg) + vmpp(comm,reg))
   = sum((reg,comm), (vdpp(comm,reg) + vmpp(comm,reg))*nu0(reg))
   / sum((reg,comm), vdpp(comm,reg) + vmpp(comm,reg)) ;

*  Elasticity across non-energy commodities in non-energy bundle
nunnrg(r,k,h)$sum((reg,comm)$(not erg0(comm)), vdpp(comm,reg) + vmpp(comm,reg))
   = sum((reg,comm)$(not erg0(comm)), (vdpp(comm,reg) + vmpp(comm,reg))*nunnrg0(reg))
   / sum((reg,comm)$(not erg0(comm)), vdpp(comm,reg) + vmpp(comm,reg)) ;

* Substitution elasticity between ELY and NELY bundle
nue(r,k,h)$sum((reg,comm)$erg0(comm), vdpp(comm,reg) + vmpp(comm,reg))
   = sum((reg,comm)$erg0(comm), (vdpp(comm,reg) + vmpp(comm,reg))*nue0(reg))
   / sum((reg,comm)$erg0(comm), vdpp(comm,reg) + vmpp(comm,reg)) ;

* Substitution elasticity beteen COL and OLG bundle
nunely(r,k,h)$sum((reg,erg0,e)$(mapi(e,erg0) and not mape("ELY",e)) , vdpp(erg0,reg) + vmpp(erg0,reg))
   = sum((reg,erg0,e)$(mapi(e,erg0) and not mape("ELY",e)), (vdpp(erg0,reg) + vmpp(erg0,reg))*nunely0(reg))
   / sum((reg,erg0,e)$(mapi(e,erg0) and not mape("ELY",e)), vdpp(erg0,reg) + vmpp(erg0,reg)) ;

* Substitution elasticity beteen oil and gas
nuolg(r,k,h)$sum((reg,erg0,e)$(mapi(e,erg0) and (mape("OIL",e) or mape("GAS",e))) , vdpp(erg0,reg) + vmpp(erg0,reg))
   = sum((reg,erg0,e)$(mapi(e,erg0) and (mape("OIL",e) or mape("GAS",e))), (vdpp(erg0,reg) + vmpp(erg0,reg))*nuolg0(reg))
   / sum((reg,erg0,e)$(mapi(e,erg0) and (mape("OIL",e) or mape("GAS",e))), vdpp(erg0,reg) + vmpp(erg0,reg)) ;

* Substitution elasticity within NRG bundles
nuNRG(r,k,h,NRG)$sum((reg,erg0,e)$(mapi(e,erg0) and mape(NRG,e)) , vdpp(erg0,reg) + vmpp(erg0,reg))
   = sum((reg,erg0,e)$(mapi(e,erg0) and mape(NRG,e)), (vdpp(erg0,reg) + vmpp(erg0,reg))*nunely0(reg))
   / sum((reg,erg0,e)$(mapi(e,erg0) and mape(NRG,e)), vdpp(erg0,reg) + vmpp(erg0,reg)) ;

*  Other final demand CES expenditure elasticities
sigma_gov(r)$sum((reg,comm)$(mapr(r,reg)), vdgp(comm,reg) + vmgp(comm,reg))
   = sum((reg,comm)$(mapr(r,reg)), (vdgp(comm,reg) + vmgp(comm,reg))*sigma_gov0(reg))
   / sum((reg,comm)$(mapr(r,reg)), vdgp(comm,reg) + vmgp(comm,reg)) ;
sigma_inv(r)$sum((reg,comm)$(mapr(r,reg)), vdip(comm,reg) + vmip(comm,reg))
   = sum((reg,comm)$(mapr(r,reg)), (vdip(comm,reg) + vmip(comm,reg))*sigma_inv0(reg))
   / sum((reg,comm)$(mapr(r,reg)), vdip(comm,reg) + vmip(comm,reg)) ;

*  Trade elasticities

Parameters
   domdem(r,i)
   impdem(r,i)
   absorb(r,i)
   domsales(r,i)
   expsales(r,i)
   totsales(r,i)
;

*  !!!! Should add investment demand
domdem(r,i) = sum((reg,comm)$(mapr(r,reg) and mapi(i,comm)),
                  sum(acts, vdfp(comm,acts,reg)) + vdpp(comm,reg) + vdgp(comm,reg)) ;
impdem(r,i) = sum((reg,comm)$(mapr(r,reg) and mapi(i,comm)),
                  sum(acts, vmfp(comm,acts,reg)) + vmpp(comm,reg) + vmgp(comm,reg)) ;
absorb(r,i) = domdem(r,i) + impdem(r,i) ;

domsales(r,i) = sum((reg,comm), sum(acts, vdfb(comm,acts, reg))
              +     vdpb(comm,reg) + vdgb(comm,reg) + vdib(comm,reg)
              +     vst(comm,reg)) ;
expsales(r,i) = sum((reg,comm)$(mapr(r,reg) and mapi(i,comm)), sum(dst, vxsb(comm,reg,dst))) ;
totsales(r,i) = domsales(r,i) + expsales(r,i) ;

*  Top level Armington -- weight is domestic and import demand at purchasers' price

*  !!!! NEED TO DEAL WITH NON-DIAGONAL MAKE MATRIX FOR EXAMPLE ELY-C

sigmam(r,i)$absorb(r,i)
            = sum((reg,comm)$(mapr(r,reg) and mapi(i,comm)),
               sigmam0(reg,comm)*(sum(acts, vdfp(comm,acts,reg)+vmfp(comm,acts,reg))
            +     vdpp(comm,reg) + vdgp(comm,reg) + vmpp(comm,reg) + vmgp(comm,reg)))
            /  absorb(r,i) ;

*  Second level Armington -- weight is import demand at purchasers' price
sigmaw(r,i)$impdem(r,i)
            = sum((reg,comm)$(mapr(r,reg) and mapi(i,comm)),
               sigmaw0(reg,comm)*(sum(acts, vmfp(comm,acts,reg))
            +     vmpp(comm,reg) + vmgp(comm,reg)))
            /  impdem(r,i) ;

*  Top level CET
omegax(r,i)$totsales(r,i)
            = sum((reg,comm)$(mapr(r,reg) and mapi(i,comm)),
               ((omegax0(reg,comm)*(sum(acts, vdfb(comm,acts,reg))
            +     vdpb(comm,reg) + vdgb(comm,reg) + vdib(comm,reg) + vst(comm,reg)
            +     sum(dst, vxsb(comm,reg,dst))))$(omegax0(reg,comm) ne inf))
            +  (inf$(omegax0(reg,comm) eq inf)))
            /  totsales(r,i) ;

omegaw(r,i)$expsales(r,i)
            = sum((reg,comm)$(mapr(r,reg) and mapi(i,comm)),
               ((omegaw0(reg,comm)*(sum(dst, vxsb(comm,reg,dst))))$(omegaw0(reg,comm) ne inf))
            +  (inf$(omegaw0(reg,comm) eq inf)))
            /  expsales(r,i) ;

*  Intl. trade margins 'make' elasticity -- weight is aggregate TT services

sigmamg(i)$sum((reg,comm)$mapi(i,comm), vst(comm,reg))
   = sum((reg,comm)$mapi(i,comm), sigmamg0(comm)*vst(comm,reg))
   / sum((reg,comm)$mapi(i,comm), vst(comm,reg)) ;

*  Capital mobility for comp. stat. model -- weight is capital remuneration

omegak(r)$sum((acts,reg)$mapr(r,reg), evfb(cap,acts,reg))
   = sum((acts,reg)$mapr(r,reg), ((omegak0(reg)*evfb(cap,acts,reg))$(omegak0(reg) ne inf))
   +  (inf$(omegak0(reg) eq inf)))
   / sum((acts,reg)$mapr(r,reg), evfb(cap,acts,reg)) ;

*  Land elasticity -- weight is total land remuneration
*  !!!! Perhaps should be at basic prices???
etat(r)$sum((acts,reg)$mapr(r,reg), evfp(lnd,acts,reg))
   = sum((acts,reg)$mapr(r,reg), etat0(reg)*evfp(lnd,acts,reg))
   / sum((acts,reg)$mapr(r,reg), evfp(lnd,acts,reg)) ;

*  Land potential -- weight is total land remuneration

landmax(r)$sum((acts,reg)$mapr(r,reg), evfp(lnd,acts,reg))
   = sum((acts,reg)$mapr(r,reg), landmax0(reg)*evfp(lnd,acts,reg))
   / sum((acts,reg)$mapr(r,reg), evfp(lnd,acts,reg)) ;

*  Top level land allocation elasticity -- weight is total land remuneration
omegat(r)$sum((acts,reg)$mapr(r,reg), evfp(lnd,acts,reg))
   = sum((acts,reg)$mapr(r,reg), ((omegat0(reg)*evfp(lnd,acts,reg))$(omegat0(reg) ne inf))
   +  (inf$(omegat0(reg) eq inf)))
   / sum((acts,reg)$mapr(r,reg), evfp(lnd,acts,reg)) ;

*  Different from original aggregation -- use generic weights
*  Can be modified in the model initialization

* Intermediate land bundle -- weight is total land remuneration for land not in bundle 1
omeganlb(r)$sum((acts,reg,a,lb1)$(mapr(r,reg) and mapa(a,acts)), evfp(lnd,acts,reg))
   = sum((acts,reg,a,lb1)$(mapr(r,reg) and mapa(a,acts)), omeganlb0(reg)*evfp(lnd,acts,reg))
   / sum((acts,reg,a,lb1)$(mapr(r,reg) and mapa(a,acts)), evfp(lnd,acts,reg)) ;

*  Bottom level land bundles -- weight is total land remuneration of the bundles
omegalb(r,lb0)$sum((acts,reg,a)$(mapr(r,reg) and mapa(a,acts)), evfp(lnd,acts,reg))
   = sum((acts,reg,a)$(mapr(r,reg) and mapa(a,acts)), omegalb0(reg,lb0)*evfp(lnd,acts,reg))
   / sum((acts,reg,a)$(mapr(r,reg) and mapa(a,acts)), evfp(lnd,acts,reg)) ;

*  Elasticity of supply of natural resources -- weight is total natl. res. remuneration
etanrf(r,a)$sum((acts,reg)$(mapr(r,reg) and mapa(a,acts)), evfp(nrs,acts,reg))
   = sum((acts,reg)$(mapr(r,reg) and mapa(a,acts)), etanrf0(reg,acts)*evfp(nrs,acts,reg))
   / sum((acts,reg)$(mapr(r,reg) and mapa(a,acts)), evfp(nrs,acts,reg)) ;

*  Dis-investment elasticity -- weight is capital remuneration
invElas(r,a)$sum((acts,reg,lab)$(mapr(r,reg) and mapa(a,acts)), evfp(cap,acts,reg))
   = sum((acts,reg)$(mapr(r,reg) and mapa(a,acts)), invElas0(reg,acts)*evfp(cap,acts,reg))
   / sum((acts,reg)$(mapr(r,reg) and mapa(a,acts)), evfp(cap,acts,reg)) ;

*  Migration elasticity -- weight is labor remuneration in rural activities
omegam(r,l)$sum((acts,a,reg,lab0)$(mapr(r,reg) and mapa(a,acts) and mapf(l,lab0) and mapz(rur,a)), evfp(lab0,acts,reg))
   = sum((acts,a,reg,lab0)$(mapr(r,reg) and mapa(a,acts) and mapf(l,lab0) and mapz(rur,a)), omegam0(reg)*evfp(lab0,acts,reg))
   / sum((acts,a,reg,lab0)$(mapr(r,reg) and mapa(a,acts) and mapf(l,lab0) and mapz(rur,a)), evfp(lab0,acts,reg)) ;


execute_unload "%outFolder%/%baseName%Prm.gdx"
   sigmaxp=sigmaxp0, sigmap=sigmap0, sigman1=sigman10, sigman2=sigman20, sigmawat=sigmawat0,
   sigmav=sigmav0, sigmav1=sigmav10, sigmav2=sigmav20,
   sigmakef=sigmakef0, sigmakf=sigmakf0, sigmakw=sigmakw0, sigmak=sigmak0,
   sigmaul=sigmaul0, sigmasl=sigmasl0,
   sigmae=sigmae0, sigmanely=sigmanely0, sigmaolg=sigmaolg0, sigmaNRG=sigmaNRG0,
   omegas=omegas0, sigmas=sigmas0,
   sigmael=sigmael0, sigmapow=sigmapow0, sigmapb=sigmapb0,
   incElas=incElas0, e_c=eh0, b_c=bh0, nu=nu0, nunnrg=nunnrg0, nue=nue0, nunely=nunely0, nuolg=nuolg0, nuNRG=nuNRG0,
   sigma_gov=sigma_gov0, sigma_inv=sigma_inv0,
   sigmam=sigmam0, sigmaw=sigmaw0, omegax=omegax0, omegaw=omegaw0, sigmamg=sigmamg0
   omegak=omegak0, invElas=invElas0, etat=etat0, landMax=landMax00,
   omegat=omegat0, omeganlb=omeganlb0, omegalb=omegalb0,
   etanrf=etanrf0, omegam=omegam0
;
