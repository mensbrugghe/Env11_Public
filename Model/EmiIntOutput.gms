*  Calculate I-A, where A is the technical coefficients matrix
*  !!!! Question for Maksym, why not include imported intermediates?

axe(r,i,j,t) = (1$sameas(i,j) + 0$(not sameas(i,j)))
             - ((sum(a$mapmak(a,j), pdt0(r,i)*xd0(r,i,a)*xd.l(r,i,a,t)))/(ps0(r,j)*xs0(r,j)*xs.l(r,j,t)))$xs.l(r,j,t) ;

solve aInvMod using cns ;

emiperoutpt(r,i,t)$xs.l(r,i,t)
   = 1000*sum((a,j)$mapmak(a,i), emi0(r,"CO2",j,a)*emi.l(r,"CO2",j,a,t)/cscale)
   / (ps0(r,i)*xs0(r,i)*xs.l(r,i,t)/inscale) ;

$macro m_rho_ely(r) \
   (1000*sum((j,elyc),sum(a$mapmak(a,elyc), emi0(r,"CO2",j,a)*emi.l(r,"CO2",j,a,t)/cscale)) \
   / (sum(js,sum(elyc,nrgbal(r,elyc,js,t))) - sum((s,elyc),nrgbal(r,s,elyc,t))))

EMIXSC(r,i,"Scope1",t) = emiperoutpt(r,i,t);
EMIXSC(r,i,"Scope2",t)$xs.l(r,i,t)
   = EMIXSC(r,i,"Scope1",t)
   + m_rho_ely(r) * sum(elyc,sum(a$mapmak(a,i), nrgbal(r,elyc,a,t)))
   / (ps0(r,i)*xs0(r,i)*xs.l(r,i,t)/inscale) ;
EMIXSC(r,i,"Scope3",t) = sum(j,emiperoutpt(r,j,t)*A_INV.l(r,j,i,t)) ;

EMITRD(s,i,d,es,t)$sum(r,xw0(s,i,r)*pe0(r,i,r)*xw.l(s,i,r,t))
            = (1/1000)*EMIXSC(s,i,es,t)
            *  (xw0(s,i,d)*pe0(s,i,d)*xw.l(s,i,d,t)
            +   pdt0(s,i)*xtt0(s,i)*xtt.l(s,i,t)*xw0(s,i,d)*pe0(s,i,d)*xw.l(s,i,d,t)
            /   sum(r,xw0(s,i,r)*pe0(r,i,r)*xw.l(s,i,r,t)))/inscale ;
