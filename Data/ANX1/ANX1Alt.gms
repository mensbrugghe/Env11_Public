*  Altertax shock
*
*  If new policy needs to be phased in, the basic implementation is
*
*     p(it) = pfinal*(it/n) + pinitial*(1-it/n)
*
*  See below for an example
*
*  Set the number of iterations on the command line, for example --niter=4

*  Introduce a 'small' tax on process emissions
*  Assume we are using 'AR4' and set a price of 25 cents per tCO2eq

$onText
ytax0(r,"ct")     = 1 ;

execute_load "%inDir%/%BaseName%NCO2.gdx", gwp, emi_iop, emi_endw, emi_qo ;

ProcEmi0(r,em,a)  = gwp(em,r,"AR4")*cscale
                  *  (sum(i, emi_iop(em, i, a, r))
                  +   sum(fp, emi_endw(em, fp, a, r))
                  +   emi_qo(em, a, r)) ;

pcarb0(r) = 0.25 ;

ctaxFlag(r,a)$sum(em, pcarb0(r)*(inscale/cscale)*procEmi0(r,em,a)) = yes ;
ctax.l(r,a,tsim)$ctaxFlag(r,a) = 0.0003 ;
ctax.lo(r,a,tsim)$ctaxFlag(r,a) = -inf ;
ctax.up(r,a,tsim)$ctaxFlag(r,a) = +inf ;
$offText