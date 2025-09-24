$gdxin "%INPPATH%\%INFILE%.gdx"

Sets
   em(*)    "emission types"
   is(*)    "SAM accounts"
   t        "years"
   r(is)    "regions"
   aa(is)   "armington agents"
   a(aa)    "activities"
   i(is)    "commodities"
   elya(a)  "Power activities"
   elyc(i)  "Electricity commodities"
   es       "Emission scopes" /Scope1, Scope2, Scope3/
;
alias (r,s,d), (i,j,k), (is,js);
$load is r em t aa a i elya elyc

Parameters
   emi0(r,em,is,aa)     "Emissions in the reference year, billion tCO2-eq."
   emis(r,em,is,aa,t)   "Emissions change over time, 2014=1"
   x0(r,a,i)            "Output in reference year at market prices, trillion USD"
   xt(r,a,i,t)          "Output by years, 2014=1"
   xd0(r,i,aa)          "Domestic sales of domestic goods, trillion USD"
   xd(r,i,aa,t)         "Domestic sales of domestic goods by years, 2014=1"
   xw0(s,i,d)           "Volume of bilateral trade in ref year, trillion USD"
   xw(s,i,d,t)          "Volume of bilateral trade by years, 2014=1"
   p0(r,a,i)            "Price of good 'i' produced by activity 'a'--pre-tax"
   px0(r,a)             "Producer prices before tax"
   pwe0(s,i,d)          "FOB price of exports"
   pe0(s,i,d)           "Producer price of exports"
   pd0(r,i,aa)          "End user price of domestic goods with agent sourcing"
   pdt0(r,i)            "Producer price of goods sold on domestic markets"
   xtt0(r,i)            "Initial margin exports"
   xtt(r,i,t)           "Supply of m by region r"
   cscale               "Scale for emissions"
   inScale              "Scale for SAM"
   xs0(r,i)             "Base year domestic supply"
   ps0(r,i)             "Base year output price"
   xs(r,i,t)            "Domestic supply"
   ps(r,i,t)            "Domestic supply price"
   pdt(r,i,t)           "Domestic price"
   pe(s,i,d,t)          "Export price"
   nrgBal(r,is,js,t)    "Energy balances"
;

$load emi0 x0 xd0 xw0 px0 pwe0 pdt0 pd0 pe0 p0 xtt0 cscale inscale xs0 ps0 nrgBal
execute_load "%INPPATH%\%INFILE%.gdx" emis=emi.l, xt=x.l, xd=xd.l, xw=xw.l, xtt=xtt.l, xs=xs.l, ps=ps.l, pdt=pdt.l, pe=pe.l;

*Declare parameters
Set mapac(a,i)        "Mapping from activities to commodities" ;
mapac(a,i)$sum(r, x0(r,a,i)) = yes ;

Parameters
   emiReg(r,i,a,t)   "Production CO2 emissions over time, million tCO2-eq."
   output(r,i,t)     "Output, mn USD"
   domND(r,i,j,t)    "Intermediate use of domestic inputs, mn USD"
   output2(r,i,t)    "Second definition of output"
;

*  Rearrange data
emireg(r,i,a,t)  =  emi0(r,"CO2",i,a)*emis(r,"CO2",i,a,t)/cscale ;
output(r,i,t)    =  (sum(aa, xd0(r,i,aa)*pdt0(r,i)*xd(r,i,aa,t))
                 +   sum(d,xw0(r,i,d)*pe0(r,i,d)*xw(r,i,d,t))
                 +   pdt0(r,i)*xtt0(r,i)*xtt(r,i,t))/inscale ;
output2(r,i,t)   = xs(r,i,t)*xs0(r,i)*ps0(r,i)/inscale ;
domND(r,i,j,t)   =  sum(a$(mapac(a,j)), xd0(r,i,a)*pdt0(r,i)*xd(r,i,a,t))/inscale ;

*>>>Embodied emissions estimation

Parameters
   emiperoutpt(r,i,t)   "Emissions per output, kg CO2-eq per USD"
   ID(i,j)              "Identity matrix"
   AXE(r,i,j,t)         "ID - tech coeff matrix"
   Check(r,i,j,t)       "Inversion checks"
   EMIX(r,i,t,es)       "Kg CO2 emissions per $1 of exports/fin cons (by Scopes)"
   EMITRD(s,i,d,t,es)   "CO2 emissions embodied into trade, Million metric tons of CO2-eq (by Scopes)";

*  Emissions are in MMT, output is in Mn USD, the ratio is ton per dollar
*  Multiply by 1000 to get Kg/$

emiperoutpt(r,i,t)$output(r,i,t) =
   1000*sum((a,j)$(mapac(a,i)), emireg(r,j,a,t)) / output(r,i,t) ;

display emiperoutpt ;

ID(i,i) = 1 ;
AXE(r,i,j,t) = ID(i,j) - (domND(r,i,j,t)/output(r,j,t))$output(r,j,t) ;

*  Setup inversion -- do it one year at a time

set ts(t) ; ts(t) = no ;

variables
   XINV(r,i,j,t)     "Inverse of matrix (by regions and years)"
   dummy             "dummy obj function"
;

equations
   invert(r,i,j,t)   "Inverse calculation equation"
   edummy            "dummy obj func equation"
;

invert(r,i,j,t)$ts(t)..
   sum(k, AXE(r,i,k,t)*XINV(r,k,j,t)) =e= ID(i,j) ;

edummy..       dummy =e= 0 ;

model inverse / edummy, invert / ;

*  Find inverse by regions and years

alias(t,tsim) ;
loop(tsim,
   ts(tsim) = yes ;
   if(1,
      solve inverse using lp minimizing dummy ;
   else
      solve inverse using mcp ;
   ) ;
   ts(tsim) = no ;
);

$ontext
Execute_unload "z:\output\env11\ksa3\axe.gdx",
   r,i,t,axe,xinv.l ;
$offText

$ontext
Parameter
   axe0(i,j)      "Matrix to invert per region and year"
   aInv(i,j)      "Inverted matrix per region and year"
   XINVP(r,k,j,t) "Matrix of embodied emissions"
;

EmbeddedCode Python:
   import pandas
   import numpy as np
   import gams.transfer as gt
   
   verbose = True
pauseEmbeddedCode

$ontext
loop((r,t),
*  Move the matrix
   axe0(i,j) = axe(r,i,j,t) ;
   continueEmbeddedCode:
   m = gt.Container(gams.db)
   A = m.data["axe0"].toDense()
   m.data['aInv'].setRecords(np.linalg.inv(A))
   m.write(gams.db, ["aInv"])
   pauseEmbeddedCode aInv
   XINVP(r,i,j,t) = aInv(i,j) ;
);

continueEmbeddedCode:
gams.printLog(f"{aInv}")
endEmbeddedCode
$offtext

*  Calculate checks
check(r,i,j,t) = sum(k,AXE(r,i,k,t) * XINV.l(r,k,j,t)) ;
check(r,i,j,t)$(abs(check(r,i,j,t)) le 1e-10) = 0 ;
display check ;

*  Estimate emissions embodied in trade
*  Trade is evaluated  in $million
*  EMIX is kg/$ --> EMIX*Trade = million kg --> 0.001*Emix*Trade = million ton

$macro m_rho_ely(r) \
   (1000*sum((j,elyc),sum(a$mapac(a,elyc),emireg(r,j,a,t))) \
   /(sum(js,sum(elyc,nrgbal(r,elyc,js,t)))-sum((s,elyc),nrgbal(r,s,elyc,t))))

EMIX(r,i,t,"Scope1") = emiperoutpt(r,i,t);
EMIX(r,i,t,"Scope2")$output(r,i,t) = EMIX(r,i,t,"Scope1")
         + m_rho_ely(r)
         * sum(elyc,sum(a$mapac(a,i),nrgbal(r,elyc,a,t)))/ output(r,i,t);
EMIX(r,i,t,"Scope3") = sum(j,emiperoutpt(r,j,t)*XINV.l(r,j,i,t)) ;

EMITRD(s,i,d,t,es)$sum(r,xw0(s,i,r)*pe0(r,i,r)*xw(s,i,r,t))
            = (1/1000)*EMIX(s,i,t,es)
            *  (xw0(s,i,d)*pe0(s,i,d)*xw(s,i,d,t)
            +   xtt0(s,i)*xtt(s,i,t)*xw0(s,i,d)*pe0(s,i,d)*xw(s,i,d,t)
            /     sum(r,xw0(s,i,r)*pe0(r,i,r)*xw(s,i,r,t)))/inscale ;


* Check output estimates
execute_unload '%OUTPATH%\%BaseName%EmiOut.gdx' emireg, output, output2, emiperoutpt, XINV, AXE, check;
execute_unload '%OUTPATH%\%BaseName%EmiX.gdx' EMITRD, EMIX;
