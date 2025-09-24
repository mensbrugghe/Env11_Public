$ondotl
put nrgcsv ;
put "Variable,Region,Activity,Energy,Vintage,Year,Value" / ;
nrgcsv.pc=5 ;
nrgcsv.nd=9 ;

loop((r,a,v,t),
   put "xnrg",          r.tl, a.tl, "",     v.tl, years(t):4:0, (xnrg0(r,a)*xnrg.l(r,a,v,t)/inscale) / ;
   put "pnrg",          r.tl, a.tl, "",     v.tl, years(t):4:0, (pnrg0(r,a)*pnrg.l(r,a,v,t)) / ;
   put "xnely",         r.tl, a.tl, "",     v.tl, years(t):4:0, (xnely0(r,a)*xnely.l(r,a,v,t)/inscale) / ;
   put "pnely",         r.tl, a.tl, "",     v.tl, years(t):4:0, (pnely0(r,a)*pnely.l(r,a,v,t)) / ;
   put "alpha_nely",    r.tl, a.tl, "",     v.tl, years(t):4:0, (alpha_nely(r,a,v,t)) / ;
   put "shr0_nely",     r.tl, a.tl, "",     v.tl, years(t):4:0, (shr0_nely(r,a)) / ;
   put "xolg",          r.tl, a.tl, "",     v.tl, years(t):4:0, (xolg0(r,a)*xolg.l(r,a,v,t)/inscale) / ;
   put "polg",          r.tl, a.tl, "",     v.tl, years(t):4:0, (polg0(r,a)*polg.l(r,a,v,t)) / ;
   put "alpha_olg",     r.tl, a.tl, "",     v.tl, years(t):4:0, (alpha_olg(r,a,v,t)) / ;
   put "shr0_olg",      r.tl, a.tl, "",     v.tl, years(t):4:0, (shr0_olg(r,a)) / ;
   put "sigmanely",     r.tl, a.tl, "",     v.tl, years(t):4:0, (sigmanely(r,a,v)) / ;
   put "sigmaolg",      r.tl, a.tl, "",     v.tl, years(t):4:0, (sigmaolg(r,a,v)) / ;
   put "sigmae",        r.tl, a.tl, "",     v.tl, years(t):4:0, (sigmae(r,a,v)) / ;
   loop(NRG,
      put "xaNRG",      r.tl, a.tl, NRG.tl, v.tl, years(t):4:0, (xaNRG0(r,a,NRG)*xaNRG.l(r,a,NRG,v,t)/inscale) / ;
      put "paNRG",      r.tl, a.tl, NRG.tl, v.tl, years(t):4:0, (paNRG0(r,a,NRG)*paNRG.l(r,a,NRG,v,t)) / ;
      put "alpha_NRGB", r.tl, a.tl, NRG.tl, v.tl, years(t):4:0, (alpha_NRGB(r,a,NRG,v,t)) / ;
      put "shr0_NRGB",  r.tl, a.tl, NRG.tl, v.tl, years(t):4:0, (shr0_NRGB(r,a,NRG)) / ;
      put "sigmaNRG",   r.tl, a.tl, NRG.tl, v.tl, years(t):4:0, (sigmaNRG(r,a,NRG,v)) / ;
   ) ;
   loop(e,
      put "alpha_eio", r.tl, a.tl, e.tl, v.tl, years(t):4:0, (alpha_eio(r,e,a,v,t)) / ;
      put "lambdae",   r.tl, a.tl, e.tl, v.tl, years(t):4:0, (lambdae(r,e,a,v,t)) / ;
  ) ;
) ;
loop((r,a,t),
   loop(e,
      put "xa",        r.tl, a.tl, e.tl, "", years(t):4:0, (xa0(r,e,a)*xa.l(r,e,a,t)/inscale) / ;
      put "pa",        r.tl, a.tl, e.tl, "", years(t):4:0, (pa0(r,e,a)*M_PA(r,e,a,t)) / ;
      put "shr0_eio",  r.tl, a.tl, e.tl, "", years(t):4:0, (shr0_eio(r,e,a)) / ;
  ) ;
) ;
$offdotl
