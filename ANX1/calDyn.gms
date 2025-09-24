*  Set up the estimation

Parameters
   rconspc(r)        "Measure of real per capita consumption"
;

variables
   alpha_v(k)        "Intercept term"
   beta_v(k)         "Slope term"
   gamma_v(k)        "Quadratic term"
   obj               "Objective"
;

positive variables
   errp_v(r,k,h)     "Positive error term"
   errn_v(r,k,h)     "Negative error term"
;

Equations
   fitEheq(r,k,h,t)  "Linear equation with error terms"
   OLSobjeq          "Objective function"
;

loop(t0,
   if(0,
      rconspc(r) = sum((f,a), pf0(r,f,a)*xf0(r,f,a)*pf.l(r,f,a,t0)*xf.l(r,f,a,t0))
                 - deprY0(r)*deprY.l(r,t0) ;
   else
*     rconspc(r) = ppp(r)*rgdppc.l(r,t0)*rgdppc0(r) ;
      rconspc(r) = ppp(r)*sum(h, yd0(r)*yd.l(r,t0) - savh0(r,h)*savh.l(r,h,t0)) ;
   ) ;
) ;

fitEheq(r,k,h,t)$t0(t)..
   eh.l(r,k,h,t) =e= alpha_v(k) + beta_v(k)*log(rconspc(r)/pop.l(r,t)) + gamma_v(k)*log(rconspc(r)/pop.l(r,t))*log(rconspc(r)/pop.l(r,t))
                  +  errp_v(r,k,h) - errn_v(r,k,h) ;
;

OLSobjeq..
   obj =e= sum((r,k,h,t0), (errp_v(r,k,h) + errn_v(r,k,h))*pop.l(r,t0))
        /  sum((r,k,h,t0), pop.l(r,t0)) ;

model fitEH / fitEheq, OLSobjeq / ;
file olscsv / ehOls.csv / ;

if(ifCal,

*  Estimate the parameters and save them in a GDX file
   options solprint=off, limrow=0, limcol=0 ;
   solve fitEh  using NLP minimizing obj ;

   execute_unload "%wdir%%baseName%DynPrm.gdx", alpha_v.l, beta_v.l, gamma_v.l, errp_v.l, errn_v.l ;

   if(0,
      put olscsv ;
      put "Var,Region,Comm,Value" / ;
      olscsv.pc=5 ;
      olscsv.nd=9 ;

      loop((r,k,h,t0),
         put "Act", r.tl, k.tl, eh.l(r,k,h,t0) / ;
         put "Fit", r.tl, k.tl, (alpha_v.l(k) + beta_v.l(k)*log(rconspc(r)/pop.l(r,t0)) + gamma_v.l(k)*log(rconspc(r)/pop.l(r,t0))*log(rconspc(r)/pop.l(r,t0))) / ;
         put "Epsp", r.tl, k.tl, errp_v.l(r,k,h) / ;
         put "Epsn", r.tl, k.tl, errn_v.l(r,k,h) / ;
         put "alpha", r.tl, k.tl, alpha_v.l(k) / ;
         put "beta", r.tl, k.tl, beta_v.l(k) / ;
         put "gamma", r.tl, k.tl, gamma_v.l(k) / ;
         put "facty", r.tl, k.tl, rconspc(r) / ;
         put "pop", r.tl, k.tl, pop.l(r,t0) / ;
         put "hshr", r.tl, k.tl, (hshr0(r,k,h)*hshr.l(r,k,h,t0)) / ;
      ) ;
   ) ;

else

*  Read the parameters from the GDX file

   execute_load "%wdir%%baseName%DynPrm.gdx", alpha_v.l, beta_v.l, gamma_v.l, errp_v.l, errn_v.l ;

) ;
