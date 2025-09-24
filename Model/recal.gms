if(ifVint and (ord(tsim) ge 3),
*                                 Agg   COMP PAGG  PCOMP     COEF       ELAST   SET   COMPTECH  AGGTECH
   $$batinclude "recalvat.gms"    xpv   xpn   uc    pxn      alpha_xpn  sigmaxp   a   lambdaxp  axghg
   $$batinclude "recalvat.gms"    xpv   xghg  uc    pxghg    alpha_ghg  sigmaxp   a   lambdaghg axghg
   $$batinclude "recalnnn.gms"    xpx   nd1   pxp   pnd1     alpha_nd1  sigmap    a
   $$batinclude "recalvnn.gms"    xpx   va    pxp   pva      alpha_va   sigmap    a
   $$batinclude "recalnnn.gms"    va    lab1  pva   plab1    alpha_lab1 sigmav    acr
   $$batinclude "recalnnn.gms"    va1   lab1  pva1  plab1    alpha_lab1 sigmav1   alv
   $$batinclude "recalnnn.gms"    va    lab1  pva   plab1    alpha_lab1 sigmav    ax
   $$batinclude "recalvnn.gms"    va2   kef   pva2  pkef     alpha_kef  sigmav2   acr
   $$batinclude "recalvnn.gms"    va1   kef   pva1  pkef     alpha_kef  sigmav1   alv
   $$batinclude "recalvnn.gms"    va1   kef   pva1  pkef     alpha_kef  sigmav1   ax
   $$batinclude "recalnnn.gms"    va1   nd2   pva1  pnd2     alpha_nd2  sigmav1   acr
   $$batinclude "recalnnn.gms"    va2   nd2   pva2  pnd2     alpha_nd2  sigmav2   alv
   $$batinclude "recalvnn.gms"    va    va1   pva   pva1     alpha_va1  sigmav    acr
   $$batinclude "recalvnn.gms"    va    va1   pva   pva1     alpha_va1  sigmav    alv
   $$batinclude "recalvnn.gms"    va    va1   pva   pva1     alpha_va1  sigmav    ax
   $$batinclude "recalvnn.gms"    va1   va2   pva1  pva2     alpha_va2  sigmav1   acr
   $$batinclude "recalvnn.gms"    va    va2   pva   pva2     alpha_va2  sigmav    alv

   $$batinclude "recalnnn.gms"    va2   landd pva2  plandd   alpha_land sigmav2   acr
   $$batinclude "recalnnn.gms"    va2   landd pva2  plandd   alpha_land sigmav2   alv
   $$batinclude "recalnnn.gms"    va1   landd pva1  plandd   alpha_land sigmav1   ax

$ontext
   $$batinclude "recalnnt.gms"    va2   xf    pva2  pfp      alpha_land sigmav2   acr lambdaf  lnd
   $$batinclude "recalnnt.gms"    va2   xf    pva2  pfp      alpha_land sigmav2   alv lambdaf  lnd
   $$batinclude "recalnnt.gms"    va1   xf    pva1  pfp      alpha_land sigmav1   ax  lambdaf  lnd
$offtext

   $$batinclude "recalvnn.gms"    kef   kf    pkef  pkf      alpha_kf   sigmakef  a
   $$batinclude "recalvnt.gms"    kef   xnrg  pkef  pnrg     alpha_nrg  sigmakef  a   lambdanrgp
   $$batinclude "recalvnn.gms"    kf    ksw   pkf   pksw     alpha_ksW  sigmakf   a
*  $$batinclude "recalnnt.gms"    kf    xf    pkf   pfp      alpha_nrs  sigmakf   a   lambdaf  nrs
   $$batinclude "recalnrs.gms"
   $$batinclude "recalvnn.gms"    ksw   ks    pksw  pks      alpha_ks   sigmakw   a
   $$batinclude "recalnnn.gms"    ksw   xwat  pksw  pwat     alpha_wat  sigmakw   a
   $$batinclude "recalvnt.gms"    ks    kv    pks   pkp      alpha_k    sigmak    a   lambdak
   $$batinclude "recalnnn.gms"    ks    lab2  pks   plab2    alpha_lab2 sigmak    a
   if(ifNRGNest,
      if(not ifNRGACES,
         $$batinclude "recalvnn.gms"    xnrg  xnely pnrg  pnely    alpha_nely sigmae    a
         $$batinclude "recalvnn.gms"    xnely xolg  pnely polg     alpha_olg  sigmanely a
         $$batinclude "recalnrg.gms"    xnrg  xaNRG pnrg  paNRG    alpha_NRGB sigmae    a  "ELY"
         $$batinclude "recalnrg.gms"    xnely xaNRG pnely paNRG    alpha_NRGB sigmanely a  "COA"
         $$batinclude "recalnrg.gms"    xolg  xaNRG polg  paNRG    alpha_NRGB sigmaolg  a  "GAS"
         $$batinclude "recalnrg.gms"    xolg  xaNRG polg  paNRG    alpha_NRGB sigmaolg  a  "OIL"
         $$batinclude "recalxanrgn.gms" xaNRG xa    paNRG pa       alpha_eio  sigmaNRG  a  lambdae
      else
         $$batinclude "recalvnnACES.gms"    xnrg  xnely pnrgNDX  pnely    alpha_nely sigmae    a
         $$batinclude "recalvnnACES.gms"    xnely xolg  pnelyNDX polg     alpha_olg  sigmanely a
         $$batinclude "recalnrgACES.gms"    xnrg  xaNRG pnrgNDX  paNRG    alpha_NRGB sigmae    a  "ELY"
         $$batinclude "recalnrgACES.gms"    xnely xaNRG pnelyNDX paNRG    alpha_NRGB sigmanely a  "COA"
         $$batinclude "recalnrgACES.gms"    xolg  xaNRG polgNDX  paNRG    alpha_NRGB sigmaolg  a  "GAS"
         $$batinclude "recalnrgACES.gms"    xolg  xaNRG polgNDX  paNRG    alpha_NRGB sigmaolg  a  "OIL"
         $$batinclude "recalxanrgnACES.gms" xaNRG xa    paNRGNDX pa       alpha_eio  sigmaNRG  a  lambdae
      ) ;
   else
      if(not ifNRGACES,
         $$batinclude "recalxanrg.gms"     xnrg xa pnrg     pa alpha_eio sigmae a  lambdae
      else
         $$batinclude "recalxanrgACES.gms" xnrg xa pnrgndx  pa alpha_eio sigmae a  lambdae
      ) ;
   ) ;
) ;

* --------------------------------------------------------------------------------------------------
*
*  'Twisting the Armington preference parameters
*
* --------------------------------------------------------------------------------------------------

$ondotL
if(ifCal,

*     Apply the twist parameters to top level Armington with national sourcing

   if(ArmFlag eq 0,
*     Calculate the top level import share
      ArmMShrt1(r,i)$xat0(r,i) =  pmt0(r,i)*pmt.l(r,i,tsim-1)*xmt0(r,i)*xmt.l(r,i,tsim-1)
                               / (pat0(r,i)*pat.l(r,i,tsim-1)*xat0(r,i)*xat.l(r,i,tsim-1)) ;
      alpha_dt(r,i,tsim) = alpha_dt(r,i,tsim-1)
                         * power(1/(1+ArmMShrt1(r,i)*twt1(r,i,tsim)), gap(tsim)) ;
      alpha_mt(r,i,tsim) = alpha_mt(r,i,tsim-1)
                         * power((1+twt1(r,i,tsim))/(1+ArmMShrt1(r,i)*twt1(r,i,tsim)), gap(tsim)) ;
   ) ;

*  Apply the twist parameters to top level Armington with agent-specific sourcing

   put screen ; put / ;
   if(ArmFlag,
*     Calculate the top level import shares

      ArmMShr1(r,i,aa)$xa.l(r,i,aa,tsim-1)
         =  pm0(r,i,aa)*M_PM(r,i,aa,tsim-1) * xm0(r,i,aa)*xm.l(r,i,aa,tsim-1)
         / (pa0(r,i,aa)*pa.l(r,i,aa,tsim-1) * xa0(r,i,aa)*xa.l(r,i,aa,tsim-1)) ;
         
      alpha_d(r,i,aa,tsim) = alpha_d(r,i,aa,tsim-1)
                           * power(1/(1+ArmMShr1(r,i,aa)*tw1(r,i,aa,tsim)), gap(tsim)) ;
      alpha_m(r,i,aa,tsim) = alpha_m(r,i,aa,tsim-1)
                           * power((1+tw1(r,i,aa,tsim))/(1+ArmMShr1(r,i,aa)*tw1(r,i,aa,tsim)),
                                    gap(tsim)) ;
   ) ;

*  Apply the twist parameters to second Armington nest -- rtwtgt(rp,r)
*                 is the target set of country(ies)

*  Total imports (of i into r)
   ArmMShr2(i,r) = sum(s, pdm0(s,i,r)*M_PDM(s,i,r,tsim-1)*xw0(s,i,r)*xw.l(s,i,r,tsim-1)) ;

*  Share of trade from target sources (of i into r)
   ArmMShr2(i,r)$ArmMShr2(i,r) = sum(s$rtwtgt(s,r), pdm0(s,i,r)*M_PDM(s,i,r,tsim-1)
                               * xw0(s,i,r)*xw.l(s,i,r,tsim-1))
                               / ArmMShr2(i,r) ;

   alpha_w(s,i,r,tsim) = alpha_w(s,i,r,tsim-1)
                       * ((power(1/(1+ArmMshr2(i,r)*tw2(r,i,tsim)), gap(tsim)))$(not rtwtgt(s,r))
                       +  (power((1+tw2(r,i,tsim))/(1+ArmMShr2(i,r)*tw2(r,i,tsim)), gap(tsim)))$(rtwtgt(s,r))) ;
) ;
$offDotL
