$onDotL

   xa_check(r,e,h,t)$(ts(t) and rs(r) and xaFlag(r,e,h)) = (xa(r,e,h,t) -
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
       *    (((lambdace(r,e,k,h,t)**(nuNRG(r,k,h,NRG)-1))*(pacNRG(r,k,h,NRG,t)/pah(r,e,h,t))**nuNRG(r,k,h,NRG))
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
       $(ifNRGNest))
       ;

$offdotl
options decimals=8 ;
display xa_check ;
