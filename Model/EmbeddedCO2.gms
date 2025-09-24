*>>>Set definitions and data reads

$gdxin "%INPPATH%%INFILE%.gdx"
Set
   r(*)     "regions"
   em(*)    "emission types"
   is(*)    "SAM accounts"
   t(*)     "years"
   aa(*)    "armington agents"
   a(aa)    "activities"
   i(is)    "commodities"
   i        "margin coms"
;
alias (r,s,d);
alias (i,j,k);
$load r em is t aa a i

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
;

$load emi0 x0 xd0 xw0 px0 pwe0 pdt0 pd0 pe0 p0 xtt0 cscale inscale xs0 ps0
execute_load "%INPPATH%%INFILE%.gdx" emis=emi.l, xt=x.l, xd=xd.l, xw=xw.l, xtt=xtt.l, xs=xs.l, ps=ps.l, pdt=pdt.l, pe=pe.l ;

*Declare parameters
Set mapac(a,i)        "Mapping from activities to commodities" ;
mapac(a,i)$sum(r, x0(r,a,i)) = yes ;

$ontext
         crp-a.crp-c
         lvs-a.lvs-c
         COA-a.coa-c
         OIL-a.oil-c
         GAS-a.gas-c
         XEX-a.xex-c
         XMN-a.xmn-c
         KE5-a.ke5-c
         P_C-a.p_c-c
         ETD-a.ely-c
         ELC-a.ely-c
         ELG-a.ely-c
         ELN-a.ely-c
         ELH-a.ely-c
         ELS-a.ely-c
         ELW-a.ely-c
         ELX-a.ely-c
         CNS-a.cns-c
         TRP-a.trp-c
         XSV-a.xsv-c
/;
$offtext

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
domND(r,i,j,t)   =  sum(a$(mapac(a,j)), xd0(r,i,a)*pdt0(r,i)*xd(r,i,a,t))/inscale ;

if(0,
   output2(r,i,t) = xs0(r,i)*xs(r,i,t)*ps0(r,i)/inscale ;
   output2(r,i,t)$output2(r,i,t) = 100 * output(r,i,t) / (output2(r,i,t)) - 100 ;
   display "Real:", output2 ;
   output(r,i,t)    =  (sum(aa, pdt(r,i,t)*xd0(r,i,aa)*pdt0(r,i)*xd(r,i,aa,t))
                    +   sum(d, pe(r,i,d,t)*xw0(r,i,d)*pe0(r,i,d)*xw(r,i,d,t))
                    +   pdt(r,i,t)*pdt0(r,i)*xtt0(r,i)*xtt(r,i,t))/inscale ;
   output2(r,i,t) = ps(r,i,t)*xs0(r,i)*xs(r,i,t)*ps0(r,i)/inscale ;
   output2(r,i,t)$output2(r,i,t) = 100 * output(r,i,t) / (output2(r,i,t)) - 100 ;
   display "Nomimal:", output2 ;
   Abort "Temp" ;
) ;

display emireg, output, domND ;

*>>>Embodied emissions estimation

Parameters
   emiperoutpt(r,i,t)   "Emissions per output, kg CO2-eq per USD"
   ID(i,j)              "Identity matrix"
   AXE(r,i,j,t)         "ID - tech coeff matrix"
   Check(r,i,j,t)       "Inversion checks"
   EMIX(r,i,t)          "Kg CO2 emissions per $1 of exports/fin cons"
   EMITRD(s,i,d,t)      "CO2 emissions embodied into trade, Million metric tons of CO2-eq";

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

*  Calculate checks
check(r,i,j,t) = sum(k,AXE(r,i,k,t) * XINV.l(r,k,j,t)) ;
check(r,i,j,t)$(abs(check(r,i,j,t)) le 1e-10) = 0 ;
display check ;

*  Estimate emissions embodied in trade
*  Trade is evaluateted  in $million
*  EMIX is kg/$ --> EMIX*Trade = million kg --> 0.001*Emix*Trade = million ton

EMIX(r,i,t) = sum(j,emiperoutpt(r,j,t)*XINV.l(r,j,i,t)) ;
EMITRD(s,i,d,t)$sum(r,xw0(s,i,r)*pe0(r,i,r)*xw(s,i,r,t))
            = (1/1000)*EMIX(s,i,t)
            *  (xw0(s,i,d)*pe0(s,i,d)*xw(s,i,d,t)
            +   xtt0(s,i)*xtt(s,i,t)*xw0(s,i,d)*pe0(s,i,d)*xw(s,i,d,t)
            /     sum(r,xw0(s,i,r)*pe0(r,i,r)*xw(s,i,r,t)))/inscale ;

* Check output estimates

execute_unload '%OUTPATH%%BaseName%EmiOut.gdx' emireg output emiperoutpt XINV, AXE, check;
execute_unload '%OUTPATH%%BaseName%EmiX.gdx' EMITRD, EMIX;
