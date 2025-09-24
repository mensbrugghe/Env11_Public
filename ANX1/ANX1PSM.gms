file acsv / ACES.csv / ;
put acsv ;
put "Variable,Region,Commodity,Activity,Vintage,Year,Value" / ;
acsv.pc=5 ;
acsv.nd=9 ;

$ONTEXT
$ondotl
loop((r,e,a,v,t)$xaFlag(r,e,a),
   put "ALPHA",    r.tl, e.tl, a.tl, v.tl, t.val:4:0, (alpha_eio(r,e,a,v,t)) / ;
   put "LAMBDA",   r.tl, e.tl, a.tl, v.tl, t.val:4:0, (lambdae(r,e,a,v,t)) / ;
   put "SIGMA",    r.tl, e.tl, a.tl, v.tl, t.val:4:0, (sigmae(r,a,v)) / ;
   put "XA",       r.tl, e.tl, a.tl, v.tl, t.val:4:0, (alpha_eio(r,e,a,v,t)*xnrg(r,a,v,t)*(pnrgNDX(r,a,v,t)/(lambdae(r,e,a,v,t)*M_PA(r,e,a,t)))**sigmae(r,a,v)) / ;
   put "XNRG",     r.tl, e.tl, a.tl, v.tl, t.val:4:0, (xnrg.l(r,a,v,t)) / ;
   put "PNRGNDX",  r.tl, e.tl, a.tl, v.tl, t.val:4:0, (pnrgNDX.l(r,a,v,t)) / ;
   put "PNRG",     r.tl, e.tl, a.tl, v.tl, t.val:4:0, (pnrg.l(r,a,v,t)) / ;
   put "PA",       r.tl, e.tl, a.tl, v.tl, t.val:4:0, (pa.l(r,e,a,t)) / ;
   put "XA0",      r.tl, e.tl, a.tl, v.tl, t.val:4:0, (1e6*xa0(r,e,a)) / ;
   put "XNRG0",    r.tl, e.tl, a.tl, v.tl, t.val:4:0, (1e6*xnrg0(r,a)) / ;
   put "PNRGNDX0", r.tl, e.tl, a.tl, v.tl, t.val:4:0, (pnrgNDX0(r,a)) / ;
   put "PNRG0",    r.tl, e.tl, a.tl, v.tl, t.val:4:0, (pnrg0(r,a)) / ;
   put "PA0",      r.tl, e.tl, a.tl, v.tl, t.val:4:0, (pa0(r,e,a)) / ;
) ;
$offdotl
$OFFTEXT

$ontext
loop((r,e,t),
   put "XAT", r.tl, e.tl, "", t.tl, (1e6*xat0(r,e)*xat.l(r,e,t)) / ;
   put "XDT", r.tl, e.tl, "", t.tl, (1e6*xdt0(r,e)*xdt.l(r,e,t)) / ;
   put "XMT", r.tl, e.tl, "", t.tl, (1e6*xmt0(r,e)*xmt.l(r,e,t)) / ;
   put "XET", r.tl, e.tl, "", t.tl, (1e6*xet0(r,e)*xet.l(r,e,t)) / ;
   put "XS",  r.tl, e.tl, "", t.tl, (1e6*xs0(r,e)*xs.l(r,e,t)) / ;
   put "PAT", r.tl, e.tl, "", t.tl, (pat0(r,e)*pat.l(r,e,t)) / ;
   put "PDT", r.tl, e.tl, "", t.tl, (pdt0(r,e)*pdt.l(r,e,t)) / ;
   put "PMT", r.tl, e.tl, "", t.tl, (pmt0(r,e)*pmt.l(r,e,t)) / ;
   put "PET", r.tl, e.tl, "", t.tl, (pet0(r,e)*pet.l(r,e,t)) / ;
   put "PS",  r.tl, e.tl, "", t.tl, (ps0(r,e)*ps.l(r,e,t)) / ;
   loop(d,
      put "XW",  r.tl, e.tl, d.tl, t.tl, (1e6*xw0(r,e,d)*xw.l(r,e,d,t)) / ;
      put "PE",  r.tl, e.tl, d.tl, t.tl, (pe0(r,e,d)*pe.l(r,e,d,t)) / ;
      put "PWE", r.tl, e.tl, d.tl, t.tl, (pwe0(r,e,d)*pwe.l(r,e,d,t)) / ;
      put "PWM", r.tl, e.tl, d.tl, t.tl, (pwm0(r,e,d)*pwm.l(r,e,d,t)) / ;
      put "PDM", r.tl, e.tl, d.tl, t.tl, (pdm0(r,e,d)*pdm.l(r,e,d,t)) / ;
   ) ;
   loop(aa,
      put "XA", r.tl, e.tl, aa.tl, t.tl, (1e6*xa0(r,e,aa)*xa.l(r,e,aa,t)) / ;
      put "XD", r.tl, e.tl, aa.tl, t.tl, (1e6*xd0(r,e,aa)*xd.l(r,e,aa,t)) / ;
      put "XM", r.tl, e.tl, aa.tl, t.tl, (1e6*xm0(r,e,aa)*xm.l(r,e,aa,t)) / ;
      put "PA", r.tl, e.tl, aa.tl, t.tl, (pa0(r,e,aa)*pa.l(r,e,aa,t)) / ;
      put "PD", r.tl, e.tl, aa.tl, t.tl, (pd0(r,e,aa)*pd.l(r,e,aa,t)) / ;
      put "PM", r.tl, e.tl, aa.tl, t.tl, (pm0(r,e,aa)*pm.l(r,e,aa,t)) / ;
   ) ;
) ;

put "Variable,Region,Energy,Activity,Vintage,Year,Value" / ;
acsv.pc=5 ;
acsv.nd=9 ;

loop((r,e,a,v,t),
   put "alpha", r.tl, e.tl, a.tl, v.tl, t.tl, alpha_eio(r,e,a,v,t) / ;
   put "lambdae", r.tl, e.tl, a.tl, v.tl, t.tl, lambdae.l(r,e,a,v,t) / ;
   put "shrx", r.tl, e.tl, a.tl, v.tl, t.tl, shrx0_eio(r,e,a) / ;
   put "shr", r.tl, e.tl, a.tl, v.tl, t.tl, shr0_eio(r,e,a) / ;
   put "sigma", r.tl, e.tl, a.tl, v.tl, t.tl, sigmae(r,a,v) / ;
   put "PA", r.tl, e.tl, a.tl, v.tl, t.tl, pa.l(r,e,a,t) / ;
   put "PA0", r.tl, e.tl, a.tl, v.tl, t.tl, pa0(r,e,a) / ;
   put "XA", r.tl, e.tl, a.tl, v.tl, t.tl, xa.l(r,e,a,t) / ;
   put "XA0", r.tl, e.tl, a.tl, v.tl, t.tl, (1e6*xa0(r,e,a)) / ;
) ;

loop((r,a,v,t),
   put "PNRG",  r.tl, "TOT", a.tl, v.tl, t.tl, pnrg.l(r,a,v,t) / ;
   put "PNRG0", r.tl, "TOT", a.tl, v.tl, t.tl, pnrg0(r,a) / ;
   put "PNRGNDX",  r.tl, "TOT", a.tl, v.tl, t.tl, pnrgNDX.l(r,a,v,t) / ;
   put "PNRGNDX0", r.tl, "TOT", a.tl, v.tl, t.tl, pnrgNDX0(r,a) / ;
   put "XNRG",  r.tl, "TOT", a.tl, v.tl, t.tl, xnrg.l(r,a,v,t) / ;
   put "XNRG0", r.tl, "TOT", a.tl, v.tl, t.tl, (1e6*xnrg0(r,a)) / ;
) ;

loop((r,NRG,a,v,t),
   put "alpha",     r.tl, NRG.tl, a.tl, v.tl, t.tl, alpha_NRGB(r,a,NRG,v,t) / ;
   put "shrx",      r.tl, NRG.tl, a.tl, v.tl, t.tl, shrx0_NRGB(r,a,NRG) / ;
   put "shr",       r.tl, NRG.tl, a.tl, v.tl, t.tl, shr0_NRGB(r,a,NRG) / ;
   put "PANRG",     r.tl, NRG.tl, a.tl, v.tl, t.tl, paNRG.l(r,a,NRG,v,t) / ;
   put "PANRG0",    r.tl, NRG.tl, a.tl, v.tl, t.tl, paNRG0(r,a,NRG) / ;
   put "PANRGNDX0", r.tl, NRG.tl, a.tl, v.tl, t.tl, paNRGNDX0(r,a,NRG) / ;
   put "XANRG",     r.tl, NRG.tl, a.tl, v.tl, t.tl, xaNRG.l(r,a,NRG,v,t) / ;
   put "XANRG0",    r.tl, NRG.tl, a.tl, v.tl, t.tl, (1e6*xaNRG0(r,a,NRG)) / ;
) ;


loop((r,a,v,t),
   put "shrx",   r.tl, "NELY", a.tl, v.tl, t.tl, shrx0_nely(r,a) / ;
   put "shr",    r.tl, "NELY", a.tl, v.tl, t.tl, shr0_nely(r,a) / ;
   put "pnely",  r.tl, "NELY", a.tl, v.tl, t.tl, pnely.l(r,a,v,t) / ;
   put "pnely0", r.tl, "NELY", a.tl, v.tl, t.tl, pnely0(r,a) / ;
   put "xnely",  r.tl, "NELY", a.tl, v.tl, t.tl, xnely.l(r,a,v,t) / ;
   put "xnely0", r.tl, "NELY", a.tl, v.tl, t.tl, (1e6*xnely0(r,a)) / ;

   put "shrx",   r.tl, "OLG", a.tl, v.tl, t.tl, shrx0_olg(r,a) / ;
   put "shr",    r.tl, "OLG", a.tl, v.tl, t.tl, shr0_olg(r,a) / ;
   put "polg",   r.tl, "OLG", a.tl, v.tl, t.tl, polg.l(r,a,v,t) / ;
   put "polg0",  r.tl, "OLG", a.tl, v.tl, t.tl, polg0(r,a) / ;
   put "xolg",   r.tl, "OLG", a.tl, v.tl, t.tl, xolg.l(r,a,v,t) / ;
   put "xolg0",  r.tl, "OLG", a.tl, v.tl, t.tl, (1e6*xolg0(r,a)) / ;
) ;

loop((r,e,h,k,v,t)$(vOld(v) and sameas(k,"nrg-k")),
   put "shrx", r.tl, e.tl, h.tl, v.tl, t.tl, shrx0_c(r,e,k,h) / ;
   put "shr", r.tl, e.tl, h.tl, v.tl, t.tl, shr0_c(r,e,k,h) / ;
   put "sigma", r.tl, e.tl, h.tl, v.tl, t.tl, nue(r,k,h) / ;
   put "PA", r.tl, e.tl, h.tl, v.tl, t.tl, pa.l(r,e,h,t) / ;
   put "PA0", r.tl, e.tl, h.tl, v.tl, t.tl, pa0(r,e,h) / ;
   put "XA", r.tl, e.tl, h.tl, v.tl, t.tl, xa.l(r,e,h,t) / ;
   put "XA0", r.tl, e.tl, h.tl, v.tl, t.tl, (1e6*xa0(r,e,h)) / ;
) ;

loop((r,h,k,v,t)$(vOld(v) and sameas(k,"nrg-k")),
   put "PNRG",     r.tl, "TOT", h.tl, v.tl, t.tl, pcnrg.l(r,k,h,t) / ;
   put "PNRG0",    r.tl, "TOT", h.tl, v.tl, t.tl, pcnrg0(r,k,h) / ;
   put "PNRGNDX",  r.tl, "TOT", h.tl, v.tl, t.tl, pcnrgNDX.l(r,k,h,t) / ;
   put "PNRGNDX0", r.tl, "TOT", h.tl, v.tl, t.tl, pcnrgNDX0(r,k,h) / ;
   put "XNRG",     r.tl, "TOT", h.tl, v.tl, t.tl, xcnrg.l(r,k,h,t) / ;
   put "XNRG0",    r.tl, "TOT", h.tl, v.tl, t.tl, (1e6*xcnrg0(r,k,h)) / ;
) ;

loop((r,NRG,h,k,v,t)$(vOld(v) and sameas(k,"nrg-k")),
   put "shrx",      r.tl, NRG.tl, h.tl, v.tl, t.tl, shrx0_cNRG(r,k,h,NRG,t) / ;
   put "shr",       r.tl, NRG.tl, h.tl, v.tl, t.tl, shr0_cNRG(r,k,h,NRG,t) / ;
   put "PANRG",     r.tl, NRG.tl, h.tl, v.tl, t.tl, pacNRG.l(r,k,h,NRG,t) / ;
   put "PANRG0",    r.tl, NRG.tl, h.tl, v.tl, t.tl, pacNRG0(r,k,h,NRG) / ;
   put "PANRGNDX",  r.tl, NRG.tl, h.tl, v.tl, t.tl, pacNRGNDX(r,k,h,NRG,t) / ;
   put "PANRGNDX0", r.tl, NRG.tl, h.tl, v.tl, t.tl, pacNRGNDX0(r,k,h,NRG) / ;
   put "XANRG",     r.tl, NRG.tl, h.tl, v.tl, t.tl, xacNRG.l(r,k,h,NRG,t) / ;
   put "XANRG0",    r.tl, NRG.tl, h.tl, v.tl, t.tl, (1e6*xacNRG0(r,k,h,NRG)) / ;
) ;

loop((r,h,k,v,t)$(vOld(v) and sameas(k,"nrg-k")),
   put "shrx",   r.tl, "NELY", h.tl, v.tl, t.tl, shrx0_cnely(r,k,h,t) / ;
   put "shr",    r.tl, "NELY", h.tl, v.tl, t.tl, shr0_cnely(r,k,h,t) / ;
   put "pnely",  r.tl, "NELY", h.tl, v.tl, t.tl, pcnely.l(r,k,h,t) / ;
   put "pnely0", r.tl, "NELY", h.tl, v.tl, t.tl, pcnely0(r,k,h) / ;
   put "xnely",  r.tl, "NELY", h.tl, v.tl, t.tl, xcnely.l(r,k,h,t) / ;
   put "xnely0", r.tl, "NELY", h.tl, v.tl, t.tl, (1e6*xcnely0(r,k,h)) / ;

   put "shrx",   r.tl, "OLG", h.tl, v.tl, t.tl, shrx0_colg(r,k,h,t) / ;
   put "shr",    r.tl, "OLG", h.tl, v.tl, t.tl, shr0_colg(r,k,h,t) / ;
   put "polg",   r.tl, "OLG", h.tl, v.tl, t.tl, pcolg.l(r,k,h,t) / ;
   put "polg0",  r.tl, "OLG", h.tl, v.tl, t.tl, pcolg0(r,k,h) / ;
   put "xolg",   r.tl, "OLG", h.tl, v.tl, t.tl, xcolg.l(r,k,h,t) / ;
   put "xolg0",  r.tl, "OLG", h.tl, v.tl, t.tl, (1e6*xcolg0(r,k,h)) / ;
) ;
$offtext
