$ontext

$batinclude "recalnrs.gms"

Arguments
   1     CES aggregate volume
   2     Component volume (has vintage)
   3     CES aggregate price
   4     Component price
   5     Component share parameter
   6     Elasticity of substitution
   7     Sectors
   8     Component tech progress
   9     Factor

$offtext

loop((r,nrs,a)$xfFlag(r,nrs,a),

   tvol = (sum(v, kf.l(r,a,v,tsim-1)))$(not ifNRSTop(r,a))
        + (sum(v, xpn.l(r,a,v,tsim-1)))$ifNRSTop(r,a) ;

   if(tvol ne 0,

      tprice = ((sum(v, pkf.l(r,a,v,tsim-1) * kf.l(r,a,v,tsim-1)))
             $(not ifNRSTop(r,a))
             + (sum(v, pxn.l(r,a,v,tsim-1) * xpn.l(r,a,v,tsim-1)))$ifNRSTop(r,a))
             / tvol ;

      vol = xf.l(r,nrs,a,tsim-1) ;

      if(vol ne 0,

         price = pfp.l(r,nrs,a,tsim-1) ;

         alpha_nrs(r,a,vOld,tsim)
            = ((lambdaf.l(r,nrs,a,tsim-1)**(1-sigmakf(r,a,vOld)))
            * (vol/tvol)
            * (price/tprice)**sigmakf(r,a,vOld))$(not ifNRSTop(r,a))
            + ((lambdaf.l(r,nrs,a,tsim-1)**(1-sigmaNRS(r,a,vOld)))
            * (vol/tvol)
            * (price/tprice)**sigmaNRS(r,a,vOld))$ifNRSTop(r,a) ;
      ) ;
   ) ;
) ;
