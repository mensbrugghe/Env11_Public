file fsamalt / samalt.csv / ;
put fsamalt ;
put "Region,Rlab,Clab,Year,Value" / ;
fsamalt.nd = 10 ;

$onDotL

*  Demand for domestic goods at basic prices

loop((r,i,aa,t)$xd.l(r,i,aa,t),
   if(a(aa),
      put r.tl:card(r.tl), ',d_', i.tl:card(i.tl), ',a_', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (pdt0(r,i)*pdt.l(r,i,t)*xd0(r,i,aa)*xd.l(r,i,aa,t)/inscale) / ;
      put r.tl:card(r.tl), ',tssd_', i.tl:card(i.tl), ',a_', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (pdTax(r,i,aa,t)*pdt0(r,i)*pdt.l(r,i,t)*xd0(r,i,aa)*xd.l(r,i,aa,t)/inscale) / ;
   else
      put r.tl:card(r.tl), ',d_', i.tl:card(i.tl), ',', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (pdt0(r,i)*pdt.l(r,i,t)*xd0(r,i,aa)*xd.l(r,i,aa,t)/inscale) / ;
      put r.tl:card(r.tl), ',tssd_', i.tl:card(i.tl), ',', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (pdTax(r,i,aa,t)*pdt0(r,i)*pdt.l(r,i,t)*xd0(r,i,aa)*xd.l(r,i,aa,t)/inscale) / ;
   ) ;
   put r.tl:card(r.tl), ',regY', "", ',tssd_', i.tl:card(i.tl), ',', t.tl:card(t.tl), ',', (pdTax(r,i,aa,t)*pdt0(r,i)*pdt.l(r,i,t)*xd0(r,i,aa)*xd.l(r,i,aa,t)/inscale) / ;
) ;

*  Demand for imported goods at basic prices

loop((r,i,aa,t)$xm.l(r,i,aa,t),
   if(a(aa),
      put r.tl:card(r.tl), ',m_', i.tl:card(i.tl), ',a_', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (pmt0(r,i)*pmt.l(r,i,t)*xm0(r,i,aa)*xm.l(r,i,aa,t)/inscale) / ;
      put r.tl:card(r.tl), ',tssm_', i.tl:card(i.tl), ',a_', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (pmTax(r,i,aa,t)*pmt0(r,i)*pmt.l(r,i,t)*xm0(r,i,aa)*xm.l(r,i,aa,t)/inscale) / ;
   else
      put r.tl:card(r.tl), ',m_', i.tl:card(i.tl), ',', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (pmt0(r,i)*pmt.l(r,i,t)*xm0(r,i,aa)*xm.l(r,i,aa,t)/inscale) / ;
      put r.tl:card(r.tl), ',tssm_', i.tl:card(i.tl), ',', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (pmTax(r,i,aa,t)*pmt0(r,i)*pmt.l(r,i,t)*xm0(r,i,aa)*xm.l(r,i,aa,t)/inscale) / ;
   ) ;
   put r.tl:card(r.tl), ',regY', "", ',tssm_', i.tl:card(i.tl), ',', t.tl:card(t.tl), ',', (pmTax(r,i,aa,t)*pmt0(r,i)*pmt.l(r,i,t)*xm0(r,i,aa)*xm.l(r,i,aa,t)/inscale) / ;
) ;

*  Make matrix at basic prices

loop((r,i,a,t)$x.l(r,a,i,t),
   put r.tl:card(r.tl), ',a_', a.tl:card(a.tl), ',d_', i.tl:card(i.tl), ',', t.tl:card(t.tl), ',', (pp0(r,a,i)*pp.l(r,a,i,t)*x0(r,a,i)*x.l(r,a,i,t)/inscale) / ;
   put r.tl:card(r.tl), ',tprd_', i.tl:card(i.tl), ',a_', a.tl:card(a.tl), ',', t.tl:card(t.tl), ',', (ptax(r,a,i,t)*p0(r,a,i)*p.l(r,a,i,t)*x0(r,a,i)*x.l(r,a,i,t)/inscale) / ;
   put r.tl:card(r.tl), ',regY', "", ',tprd_', i.tl:card(i.tl), ',', t.tl:card(t.tl), ',', (ptax(r,a,i,t)*p0(r,a,i)*p.l(r,a,i,t)*x0(r,a,i)*x.l(r,a,i,t)/inscale) / ;
) ;

*  Factor use

loop((r,fp,a,t)$xf.l(r,fp,a,t),
   put r.tl:card(r.tl), ',', fp.tl:card(fp.tl), ',a_', a.tl:card(a.tl), ',', t.tl:card(t.tl), ',', (pf0(r,fp,a)*pf.l(r,fp,a,t)*xf0(r,fp,a)*xf.l(r,fp,a,t)/inscale) / ;
   put r.tl:card(r.tl), ',tfe_', fp.tl:card(fp.tl), ',a_', a.tl:card(a.tl), ',', t.tl:card(t.tl), ',', (M_PFTAX(r,fp,a,t)*pf0(r,fp,a)*pf.l(r,fp,a,t)*xf0(r,fp,a)*xf.l(r,fp,a,t)/inscale) / ;
   put r.tl:card(r.tl), ',regY', "", ',tfe_', fp.tl:card(fp.tl), ',', t.tl:card(t.tl), ',', (M_PFTAX(r,fp,a,t)*pf0(r,fp,a)*pf.l(r,fp,a,t)*xf0(r,fp,a)*xf.l(r,fp,a,t)/inscale) / ;
   put r.tl:card(r.tl), ',regY', "", ',', fp.tl:card(fp.tl), ',', t.tl:card(t.tl), ',', ((1-kappaf(r,fp,a,t))*pf0(r,fp,a)*pf.l(r,fp,a,t)*xf0(r,fp,a)*xf.l(r,fp,a,t)/inscale) / ;
   put r.tl:card(r.tl), ',tinc_', a.tl:card(a.tl), ',', fp.tl:card(fp.tl), ',', t.tl:card(t.tl), ',', (kappaf(r,fp,a,t)*pf0(r,fp,a)*pf.l(r,fp,a,t)*xf0(r,fp,a)*xf.l(r,fp,a,t)/inscale) / ;
   put r.tl:card(r.tl), ',regY', "", ',tinc_', a.tl:card(a.tl), ',', t.tl:card(t.tl), ',', (kappaf(r,fp,a,t)*pf0(r,fp,a)*pf.l(r,fp,a,t)*xf0(r,fp,a)*xf.l(r,fp,a,t)/inscale) / ;
) ;

*  Depreciation
loop((r,cap,inv,t),
   put r.tl:card(r.tl), ',', inv.tl:card(inv.tl), ',', cap.tl:card(cap.tl), ',', t.tl:card(t.tl), ',', (deprY0(r)*deprY(r,t)/inscale) / ;
) ;

*  Imports

loop((r,i,s,t)$xw.l(s,i,r,t),
   put r.tl:card(r.tl), ',tmm_', s.tl:card(s.tl), ',m_', i.tl:card(i.tl), ',', t.tl:card(t.tl), ',', (mtax(s,i,r,t)*M_PWM(s,i,r,t)*pwm0(s,i,r)*xw(s,i,r,t)*xw0(s,i,r)/inscale) / ;
   put r.tl:card(r.tl), ',regY', "", ',tmm_', s.tl:card(s.tl), ',', t.tl:card(t.tl), ',', (mtax(s,i,r,t)*M_PWM(s,i,r,t)*pwm0(s,i,r)*xw(s,i,r,t)*xw0(s,i,r)/inscale) / ;
   put r.tl:card(r.tl), ',svc_', s.tl:card(s.tl), ',m_', i.tl:card(i.tl), ',', t.tl:card(t.tl), ',', (tmarg(s,i,r,t)*M_PWMG(s,i,r,t)*pwmg0(s,i,r)*xw(s,i,r,t)*xw0(s,i,r)/inscale) / ;
   put r.tl:card(r.tl), ',svc_pvst', "", ',svc_', s.tl:card(s.tl), ',', t.tl:card(t.tl), ',', (tmarg(s,i,r,t)*M_PWMG(s,i,r,t)*pwmg0(s,i,r)*xw(s,i,r,t)*xw0(s,i,r)/inscale) / ;
   put r.tl:card(r.tl), ',ww_', s.tl:card(s.tl), ',m_', i.tl:card(i.tl), ',', t.tl:card(t.tl), ',', (pwe(s,i,r,t)*pwe0(s,i,r)*xw(s,i,r,t)*xw0(s,i,r)/inscale) / ;
) ;

*  Exports

loop((r,i,d,t)$xw.l(r,i,d,t),
   put r.tl:card(r.tl), ',d_', i.tl:card(i.tl), ',ww_', d.tl:card(d.tl), ',', t.tl:card(t.tl), ',', (pwe(r,i,d,t)*pwe0(r,i,d)*xw(r,i,d,t)*xw0(r,i,d)/inscale) / ;
   put r.tl:card(r.tl), ',tee_', d.tl:card(d.tl), ',d_', i.tl:card(i.tl), ',', t.tl:card(t.tl), ',', (etax(r,i,d,t)*pe(r,i,d,t)*pe0(r,i,d)*xw(r,i,d,t)*xw0(r,i,d)/inscale) / ;
   put r.tl:card(r.tl), ',regY', "", ',tee_', d.tl:card(d.tl), ',', t.tl:card(t.tl), ',', (etax(r,i,d,t)*pe(r,i,d,t)*pe0(r,i,d)*xw(r,i,d,t)*xw0(r,i,d)/inscale) / ;
) ;

loop((r,i,t)$xtt.l(r,i,t),
   put r.tl:card(r.tl), ',d_', i.tl:card(i.tl), ',svc_pvst', "", ',', t.tl:card(t.tl), ',', (pdt0(r,i)*pdt.l(r,i,t)*xtt.l(r,i,t)*xtt0(r,i)/inscale) / ;
) ;

*  Carbon tax

Parameter
   ctaxtemp(r,aa,t) 
;
ctaxtemp(r,a,t) = sum(ghg, (pnum.l(t)*pCarb.l(r,ghg,a,t) + procEmiTax.l(r,ghg,a,t)/pCarb0(r,ghg,a))
                *     procEmi.l(r,ghg,a,t)*pCarb0(r,ghg,a)*procEmi0(r,ghg,a)) ;
ctaxtemp(r,aa,t) = ctaxtemp(r,aa,t)
                 + sum((i,em), chiEmi.l(r,em,aa,t)*emird(r,em,i,aa)*part(r,em,i,aa)*emiTax.l(r,em,aa,t)*xd.l(r,i,aa,t)*xd0(r,i,aa)
                 +             chiEmi.l(r,em,aa,t)*emirm(r,em,i,aa)*part(r,em,i,aa)*emiTax.l(r,em,aa,t)*xm.l(r,i,aa,t)*xm0(r,i,aa)) ;
                
loop((r,aa,t)$ctaxtemp(r,aa,t),
   if(a(aa),
      put r.tl:card(r.tl), ',ctax', '', ',a_', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (ctaxtemp(r,aa,t)/inscale) / ;
   else
      put r.tl:card(r.tl), ',ctax', '', ',a_', aa.tl:card(aa.tl), ',', t.tl:card(t.tl), ',', (ctaxtemp(r,aa,t)/inscale) / ;
   ) ;
   put r.tl:card(r.tl), ',regY', ',ctax', ',', t.tl:card(t.tl), ',', (ctaxtemp(r,aa,t)/inscale) / ;
) ;

*  Closure

*  Allocation of regional income

loop((r,h,t)$yc.l(r,h,t),
   put r.tl:card(r.tl), ',', h.tl:card(h.tl), ',regY', "", ',', t.tl:card(t.tl), ',', (yc0(r,h)*yc.l(r,h,t)/inscale) / ;
) ;

loop((r,gov,t)$yfd(r,gov,t),
   put r.tl:card(r.tl), ',', gov.tl:card(gov.tl), ',regY', "", ',', t.tl:card(t.tl), ',', (sum(fdg, yfd0(r,fdg)*yfd(r,fdg,t))/inscale) / ;
) ;   

loop((r,h,inv,t)$savh(r,h,t),
   put r.tl:card(r.tl), ',', inv.tl:card(inv.tl), ',regY', "", ',', t.tl:card(t.tl), ',', (savh0(r,h)*savh.l(r,h,t)/inscale) / ;
) ;

*  Bilateral and services trade balance

loop((r,s,inv,t),
   put r.tl:card(r.tl), ',', inv.tl:card(inv.tl), ',ww_', s.tl:card(s.tl), ',', t.tl:card(t.tl), ',',
      (sum(i, pwe(s,i,r,t)*pwe0(s,i,r)*xw(s,i,r,t)*xw0(s,i,r) - pwe(r,i,s,t)*pwe0(r,i,s)*xw(r,i,s,t)*xw0(r,i,s))/inscale) / ;
) ;
loop((r,inv,t),
   put r.tl:card(r.tl), ',', inv.tl:card(inv.tl), ',svc_pvst', "", ',', t.tl:card(t.tl), ',',
      (sum(i, sum(s,tmarg(s,i,r,t)*M_PWMG(s,i,r,t)*pwmg0(s,i,r)*xw(s,i,r,t)*xw0(s,i,r)) - pdt0(r,i)*pdt.l(r,i,t)*xtt.l(r,i,t)*xtt0(r,i))/inscale) / ;
) ;

*  Departures from standard GTAP Model

*  Remittances
loop((r,h,l,inv,t),
*  Calculate net remittances
   put r.tl:card(r.tl), ',regY,', l.tl:card(l.tl),  ',', t.tl:card(t.tl), ',', (-(sum(d, remit.l(d,l,r,t)*remit0(d,l,r)) - sum(s, remit.l(r,l,s,t)*remit0(r,l,s)))/inscale) / ;
   put r.tl:card(r.tl), ',', inv.tl:card(inv.tl), ',', l.tl:card(l.tl),  ',', t.tl:card(t.tl), ',', ((sum(d, remit.l(d,l,r,t)*remit0(d,l,r)) - sum(s, remit.l(r,l,s,t)*remit0(r,l,s)))/inscale) / ;
) ;

*  Foreign capital income

loop((r,cap,inv,t),
*  Calculate net profits
   put r.tl:card(r.tl), ',regY,', cap.tl:card(cap.tl),  ',', t.tl:card(t.tl), ',', (-(yqtf.l(r,t)*yqtf0(r) - yqht.l(r,t)*yqht0(r))/inscale) / ;
   put r.tl:card(r.tl), ',', inv.tl:card(inv.tl), ',', cap.tl:card(cap.tl),  ',', t.tl:card(t.tl), ',', ((yqtf.l(r,t)*yqtf0(r) - yqht.l(r,t)*yqht0(r))/inscale) / ;
) ;

*  ODA

loop((r,gov,inv,t),
*  ODA
   put r.tl:card(r.tl), ',', gov.tl:card(gov.tl), ',', 'regY',  ',', t.tl:card(t.tl), ',', ((ODAIn.l(r,t)*ODAIn0(r) - ODAOut.l(r,t)*ODAOut0(r))/inscale) / ;
   put r.tl:card(r.tl), ',', inv.tl:card(inv.tl), ',', gov.tl:card(gov.tl),  ',', t.tl:card(t.tl), ',', (-(ODAIn.l(r,t)*ODAIn0(r) - ODAOut.l(r,t)*ODAOut0(r))/inscale) / ;
) ;

*  Put the labels in some order

file flabel / samLabel.csv / ;
put flabel ;
loop(i,
   put 'm_', i.tl:card(i.tl), ', Demand for imported goods: ', i.te(i):card(i.te) / ;
) ;
loop(i,
   put 'd_', i.tl:card(i.tl), ', Demand for domestic goods: ', i.te(i):card(i.te) / ;
) ;
loop(a,
   put 'a_', a.tl:card(a.tl), ', Production of goods: ', a.te(a):card(a.te) / ;
) ;
loop(fp,
   put '', fp.tl:card(fp.tl), ', Production factors goods: ', fp.te(fp):card(fp.te) / ;
) ;
loop(r,
   put 'tmm_', r.tl:card(r.tl), ', Import tariffs: ', r.te(r):card(r.te) / ;
) ;
loop(r,
   put 'tee_', r.tl:card(r.tl), ', Export taxes: ', r.te(r):card(r.te) / ;
) ;
loop(i,
   put 'tssm_', i.tl:card(i.tl), ', Sales tax on imported goods: ', i.te(i):card(i.te) / ;
) ;
loop(i,
   put 'tssd_', i.tl:card(i.tl), ', Sales tax on domestic goods: ', i.te(i):card(i.te) / ;
) ;
loop(fp,
   put 'tfe_', fp.tl:card(fp.tl), ', Taxes on factor use: ', fp.te(fp):card(fp.te) / ;
) ;
loop(r,
   put 'svc_', r.tl:card(r.tl), ', Demand for international trade margins: ', r.te(r):card(r.te) / ;
) ;
put 'svc_', 'pvst', ', Supply of international trade margins' / ;
loop(r,
   put 'ww_', r.tl:card(r.tl), ', Trade at world (export) prices: ', r.te(r):card(r.te) / ;
) ;
loop(i,
   put 'tprd_', i.tl:card(i.tl), ', Production taxes: ', i.te(i):card(i.te) / ;
) ;
loop(a,
   put 'tinc_', a.tl:card(a.tl), ', Income taxes: ', a.te(a):card(a.te) / ;
) ;
put 'ctax', ', Emission taxes' / ;
put 'regY', ', Regional household' / ;
loop(fd,
   put fd.tl:card(fd.tl), ', Domestic final demand agents: ', fd.te(fd):card(fd.te) / ;
) ;




