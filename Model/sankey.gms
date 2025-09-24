$setGlobal inFile  "z:/Output/Env10/ANX1/BaU.gdx"

Sets
   is          "SAM labels"
   t           "Time"
   ra          "Aggregate regions"
   r(is)       "Regions"
   mapr(ra,r)  "Mapping from regions to aggregate regions"
   i(is)       "Commodities"
   aa(is)      "Agents"
   a(is)       "Activities"
   elya(is)    "Electricity generation"
   e(is)       "Energy commodities"
;

alias(is,js) ; alias(s,r) ; alias(d,r) ;

Parameter
   nrgBal(r,is,js,t)
;

scalar escale "Energy scale" ;

$gdxin "%inFile%"

$load is, t, ra
$loaddc r, mapr, i, e, aa, a, elya

execute_load "%inFile%", NRGBal, escale ;
nrgBal(r,is,js,t) = nrgBal(r,is,js,t) / escale ;

set node_Labels /
   Nuclear               "Nuclear"
   CoalRes               "Coal reserves"
   CoalImp               "Coal imports"
   GasRes                "Gas reserves"
   GasImp                "Gas imports"
   ElyImp                "Electricity imports"
   Hydro                 "Hydro"
   Wind                  "Wind"
   Solar                 "Solar"
   OthRen                "Other renewable"
   OilRes                "Oil reserves"
   OilImp                "Oil imports"
   LiqImp                "Liquid imports"
   Coal                  "Coal"
   Gas                   "Gas"
   Oil                   "Oil"
   Thermal               "Thermal"
   Liquids               "Liquids"
   ElyGrid               "Electric grid"
   ElyLoss               "Electricity losses"
   Agriculture           "Agriculture"
   Industry              "Industry"
   Services              "Services"
   FinalDem              "Final demand"
   Exports               "Exports"
   LiquidLoss            "Liquid losses"
/ ;

alias(node_labels,src) ; alias(node_labels,dst) ;

Parameter
   nrgMat(ra,src,dst,t)
;

set mapa(dst,aa) /
   Agriculture.(AGR-a, FRS-a)
   Industry.(OXT-a, COA-A, OIL-A, GAS-A, EIT-a, XMN-a)
   Services.(SRV-a)
   FinalDem.(hhd,gov,inv)
/ ;

set mape(src,e) /
   Coal.coa-c
   Oil.oil-c
   Gas.gas-c
   Liquids.p_c-c
   ElyGrid.ely-c
/ ;

set flagf(dst) ; flagf(dst)$sum(mapa(dst,aa),1) = yes ;

set mapdrop(src,dst) "Drop some internal links" /
   elygrid.thermal
   liquids.(thermal,liquids)
/ ;
* mapdrop(src,dst) = no ;

loop(ra,
   nrgMat(ra,"CoalRes","Coal",t)    = sum(mapr(ra,r), nrgBal(r,"COA-a","COA-c",t)) ;
   nrgMat(ra,"CoalImp","Coal",t)    = sum(mapr(ra,r), sum(s, nrgBal(r,s,"COA-c",t))) ;
   nrgMat(ra,"GasRes","Gas",t)      = sum(mapr(ra,r), nrgBal(r,"GAS-a","GAS-c",t)) ;
   nrgMat(ra,"GasImp","Gas",t)      = sum(mapr(ra,r), sum(s, nrgBal(r,s,"GAS-c",t))) ;
   nrgMat(ra,"OilRes","Oil",t)      = sum(mapr(ra,r), nrgBal(r,"OIL-a","OIL-c",t)) ;
   nrgMat(ra,"OilImp","Oil",t)      = sum(mapr(ra,r), sum(s, nrgBal(r,s,"OIL-c",t))) ;
   nrgMat(ra,"Nuclear","Thermal",t) = sum(mapr(ra,r), nrgBal(r,"NUC-a","ELY-c",t)) ;
   nrgMat(ra,"Coal","Thermal",t)    = sum(mapr(ra,r), sum(elya, nrgBal(r,"COA-c",elya,t))) ;
   nrgMat(ra,"Gas","Thermal",t)     = sum(mapr(ra,r), sum(elya, nrgBal(r,"GAS-c",elya,t))) ;
   nrgMat(ra,"Oil","Thermal",t)     = sum(mapr(ra,r), sum(elya, nrgBal(r,"OIL-c",elya,t))) ;
   nrgMat(ra,"Liquids","Thermal",t) = sum(mapr(ra,r), sum(elya, nrgBal(r,"P_C-c",elya,t))) ;
   nrgMat(ra,"ElyGrid","Thermal",t) = sum(mapr(ra,r), sum(elya, nrgBal(r,"ELY-c",elya,t))) ;
   nrgMat(ra,"Hydro","ElyGrid",t)   = sum(mapr(ra,r), nrgBal(r,"HYD-a","ELY-c",t)) ;
   nrgMat(ra,"Wind","ElyGrid",t)    = sum(mapr(ra,r), nrgBal(r,"WND-a","ELY-c",t)) ;
   nrgMat(ra,"Solar","ElyGrid",t)   = sum(mapr(ra,r), nrgBal(r,"SOL-a","ELY-c",t)) ;
   nrgMat(ra,"OthRen","ElyGrid",t)  = sum(mapr(ra,r), nrgBal(r,"XEL-a","ELY-c",t)) ;
   nrgMat(ra,"ElyImp","ElyGrid",t)  = sum(mapr(ra,r), sum(s, nrgBal(r,s,"ELY-c",t))) ;
   nrgMat(ra,"LiqImp","Liquids",t)  = sum(mapr(ra,r), sum(s, nrgBal(r,s,"P_C-c",t))) ;
   nrgMat(ra,"Coal","Liquids",t)    = sum(mapr(ra,r), nrgBal(r,"COA-C","P_C-a",t)) ;
   nrgMat(ra,"Gas","Liquids",t)     = sum(mapr(ra,r), nrgBal(r,"GAS-C","P_C-a",t)) ;
   nrgMat(ra,"OIL","Liquids",t)     = sum(mapr(ra,r), nrgBal(r,"OIL-C","P_C-a",t)) ;
   nrgMat(ra,"ElyGrid","Liquids",t) = sum(mapr(ra,r), nrgBal(r,"ELY-C","P_C-a",t)) ;
   nrgMat(ra,"Liquids","Liquids",t) = sum(mapr(ra,r), nrgBal(r,"P_C-C","P_C-a",t)) ;
   loop(dst$flagf(dst),
      nrgMat(ra,"Coal",dst,t)     = sum(mapr(ra,r), sum(mapa(dst,aa), nrgBal(r,"COA-c",aa,t))) ;
      nrgMat(ra,"Gas",dst,t)      = sum(mapr(ra,r), sum(mapa(dst,aa), nrgBal(r,"GAS-c",aa,t))) ;
      nrgMat(ra,"Oil",dst,t)      = sum(mapr(ra,r), sum(mapa(dst,aa), nrgBal(r,"OIL-c",aa,t))) ;
      nrgMat(ra,"Liquids",dst,t)  = sum(mapr(ra,r), sum(mapa(dst,aa), nrgBal(r,"P_C-c",aa,t))) ;
      nrgMat(ra,"ElyGrid",dst,t)  = sum(mapr(ra,r), sum(mapa(dst,aa), nrgBal(r,"ELY-c",aa,t))) ;
   ) ;
   loop(mape(src,e),
      nrgMat(ra,src, "Exports",t) = sum(mapr(ra,r), sum(d, nrgBal(r,e,d,t))) ;
   ) ;
*  Balance -- thermal residual must match total electricity demand
   nrgMat(ra,"Thermal","ElyGrid",t) = sum(dst, nrgMat(ra,"ElyGrid",dst,t)) - sum(src, nrgMat(ra,src,"ElyGrid",t)) ;
*  Balance -- thermal losses must match thermal inputs
   nrgMat(ra,"Thermal", "ElyLoss", t) = sum(src, nrgMat(ra,src,"Thermal",t)) - nrgMat(ra,"Thermal", "ElyGrid", t) ;
*  Balance -- Liquid losses must match liquid inputs
   nrgMat(ra,"Liquids", "LiquidLoss", t) = sum(src, nrgMat(ra,src,"Liquids",t)) - sum(dst, nrgMat(ra,"Liquids", dst, t)) ;
) ;

*  !!!! Re-base to EJ?

file csv / "v:/env10/anx1/doc/sankey.csv" / ;
put csv ;
put "Region,Source,Destination,Year,Value" / ;
csv.pc=5 ;
csv.nd=10 ;

loop((ra,src,dst,t)$nrgMat(ra,src,dst,t),
   put ra.tl, src.te(src), dst.te(dst), t.val:4:0, nrgMat(ra,src,dst,t) / ;
) ;

*  Output for Python

set flagt(t) / 2014, 2020, 2025, 2030, 2035, 2040, 2045, 2050 / ;

file pcsv / "v:/env10/anx1/doc/sankeyANX1.csv" / ;
put pcsv ;
put "Region,Source,Destination,Year,Value" / ;
pcsv.pc=5 ;
pcsv.nd=10 ;

loop((ra,src,dst,t)$(nrgMat(ra,src,dst,t) and not mapdrop(src,dst) and flagt(t)),
   put ra.tl, src.te(src), dst.te(dst), t.val:4:0, nrgMat(ra,src,dst,t) / ;
) ;
