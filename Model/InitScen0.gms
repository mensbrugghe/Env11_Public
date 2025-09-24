Parameters
   popg(r)
   popScen(scen, r, tranche, tt)
   gdpScen(mod, ssp, var, r, tt)
   educScen(scen, r, tranche, ed, tt)
   ghgHist(ghgcodes, r, tt)
;

Execute_load "%BASENAME%Scn.gdx", popScen, gdpScen, educScen, ghgHist ;

*  All incoming data is assumed to be in millions -- SSP database is in levels

popScen(scen, r, tranche, tt)      = 1e-6*popScen(scen, r, tranche, tt) ;
educScen(scen, r, tranche, ed, tt) = 1e-6*educScen(scen, r, tranche, ed, tt) ;

if(%OVERLAYPOP%,
   popg(r) = popScen("%POPSCEN%", r, "PTOTL", t0) ;
else
   Execute_load "%BASENAME%Dat.gdx", popg=pop ;
) ;

popT(r,"PTOTL", t0) = popScale*popg(r) ;

*  Calculate the growth in total population

loop(t$(not t0(t)),
   popT(r,"PTOTL", t) = popT(r,"PTOTL",t-1)*(popScen("%POPSCEN%", r, "PTOTL", t)/popScen("%POPSCEN%", r, "PTOTL", t-1)) ;
) ;

*  Update the tranches according to the structure in popScen

popT(r,tranche,t) = popT(r,"PTOTL", t)*popScen("%POPSCEN%",r,tranche,t)/popScen("%POPSCEN%",r,"PTOTL",t) ;

pop.l(r,t) = popT(r, "PTOTL", t) ; pop0(r) = pop.l(r,t0) ;

*  Calculate GDP trend, assuming per capita growth rates are as given by scenario

rgdppcT(r,t) = gdpScen("%SSPMOD%", "%SSPSCEN%", "gdppc", r, t) ;

*  Assumptions about labor force participation rates

lfpr(r, l, "PLT15", t) = 0 ;
lfpr(r, l, "P1564", t) = 2/3 ;
lfpr(r, l, "P65UP", t) = 0 ;

*  Calculate education-based growth rates of labor
*  Size of labor by skill based on education and lfpr
*  Needs modification if using UN population profile (for aggregate labor growth)

*  Check to see if we are using an SSP scenario for labor

work = sum(ssp$sameas("%LABSCEN%", ssp), 1) ;

if(work = 1,
   educ(r, l, t) = sum(trs, lfpr(r,l,trs,t)*sum(educMap(r,l,ed), educScen("%LABSCEN%", r, trs, ed, t))) ;
   gLabT(r,l,t)$(years(t) gt years(t0)) = 100*((educ(r, l, t)/educ(r, l, t-1))**(1/gap(t)) - 1) ;
   glab.l(r,l,t)$(years(t) gt years(t0))    = gLabT(r,l,t) ;
   gLabz.l(r,l,z,t)$(years(t) gt years(t0)) = gLabT(r,l,t) ;
   gtlab.l(r,t)$(years(t) gt years(t0)) = 100*((sum(l, educ(r, l, t))
                  /       sum(l, educ(r, l, t-1)))**(1/gap(t))-1) ;
else
*  Just use the growth of the working age population
   gtlab.l(r,t)$(years(t) gt years(t0)) = 100*((popT(r,"P1564",t)/popT(r,"P1564",t-1))**(1/gap(t))-1) ;
   glab.l(r,l,t) = gtlab.l(r,t) ;
   glabT(r,l,t)  = glab.l(r,l,t) ;
   glabz.l(r,l,z,t) = glab.l(r,l,t) ;
) ;
*display work, gtlab.l ;

*  Assumptions about labor productivity

glAddShft(r,l,a,t) = 0 ;
glMltShft(r,l,a,t) = 1 ;
glAddShft(r,l,agr,t) = 0.02 ;
glAddShft(r,l,man,t) = 0.02 ;

*  AEEI assumptions (in percent)

aeei(r,a,v,t)  = 1.0 ;
aeeic(r,k,h,t) = 1.0 ;

*  Exogenous yield assumptions (in percent)

yexo(r,acr,t) = 1 ;

*  Exogenous assumption on improvement in trading margins (in percent)

tteff(s,i,d,t) = 1 ;

*  Emission rate assumptions

emiRate(r,em,is,aa,t) = 0 ;

$iftheni "%CLIM_MODULE%" == "ON"
*  Default land emission assumptions
   emiLand.l(t)      = emiLand0 ;
   cumEmiLand.l(t0) = cumEmiLand0 ;
   loop(t$(not t0(t)),
      cumEmiLand.l(t)
         = cumEmiLand.l(t-1) + gap(t) * emiLand.l(t-1)/CO22C ;
   ) ;
$endif

*  Initialize the investment target assumptions

Parameter
   invTgt(mod, ssp, r, tt)
   kadj0(r)
   deprM(r,tt)
   invTarget0(r,t)
   invTargetT(r,t)
;
invTargetT(r,t) = na ;
kadj0(r)        = 1 ;

$ifthen.invTgt exist "%BaseName%InvTgt.gdx"
   $$iftheni.eucc "%BaseName%" == "EUCC0"
      execute_loaddc "%BaseName%InvTgt.gdx", invTgt ;
   $$else.eucc
      execute_loaddc "%BaseName%InvTgt.gdx", invTgt, kadj0, deprM = deprT ;
      kadj0(r)$(kadj0(r) eq 0) = 1 ;
   $$endif.eucc
   invTarget0(r,t) = invTgt("%SSPMOD%", "%SSPSCEN%", r, t) ;

   set tint(r,t) Investment target intervals ;
   tint(r,t0) = yes ;
   tint(r,t)$(invTarget0(r,t) > 0) = yes ;
*  display tint ;

  Parameter
      year0    "Start year of an interval"
      tgt0     "Ratio at beginning of an interval"
      tgt1     "Ratio at end of an interval"
      delT     "Year-gap of an interval"
   ;

   loop((r,tsim)$tint(r,tsim),

      if(years(tsim) eq years(t0),

*        Beginning of time, initialize

         year0 = years(t0) ;
         tgt0  = invTarget0(r,t0) ;

      else

*        tsim is the upper end of an interval

         delT = (years(tsim) - year0) ;
         tgt1 = invTarget0(r,tsim) ;

         loop(t$(years(t) > year0),

            if(years(t) <= years(tsim),
               invTargetT(r,t) = tgt1*(years(t) - year0)/delT
                               + tgt0*(years(tsim) - years(t))/delT
                               ;
            else
*              invTargetT(r,t) = tgt1 ;
            ) ;
         ) ;

*        Reset for next interval

         year0 = years(tsim) ;
         tgt0  = tgt1 ;
      ) ;
   ) ;

$endif.invTgt

* display invTargetT ;
