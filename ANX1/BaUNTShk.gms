if(years(tsim) ge 2030,
   alpha_s(r,"clp-a",elyc,tsim)
      = (0.7/shr0_s(r,"clp-a",elyc) - 1)*(tsim.val - 2030)/(2050-2030) + 1 ;
   alpha_s(r,"ccs-a",elyc,tsim)
      = ((1-0.7)/shr0_s(r,"ccs-a",elyc) - 1)*(tsim.val - 2030)/(2050-2030) + 1 ;
   alpha_s(r,"gsp-a",elyc,tsim)
      = (0.7/shr0_s(r,"gsp-a",elyc) - 1)*(tsim.val - 2030)/(2050-2030) + 1 ;
   alpha_s(r,"gcc-a",elyc,tsim)
      = ((1-0.7)/shr0_s(r,"gcc-a",elyc) - 1)*(tsim.val - 2030)/(2050-2030) + 1 ;
   alpha_s(r,"nuc-a",elyc,tsim)
      = (0.7/shr0_s(r,"nuc-a",elyc) - 1)*(tsim.val - 2030)/(2050-2030) + 1 ;
   alpha_s(r,"adv-a",elyc,tsim)
      = ((1-0.7)/shr0_s(r,"adv-a",elyc) - 1)*(tsim.val - 2030)/(2050-2030) + 1 ;
) ;
