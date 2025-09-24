ifDamage(r)  = yes ;

rhodmg_tfp(r,t) = 0.1 ;
rhodmg_lab(r,t) = 0.1 ;
rhodmg_hht(r,t) = 0.1 ;
rhodmg_nrg(r,t) = 0.1 ;
rhodmg_lnd(r,t) = 0.1 ;
rhodmg_tou(r,t) = 0.1 ;
rhodmg_cap(r,t) = 0.1 ;

*  Set intercepts to 0 and assume that T(t)-T(t0) = 0 for t=t0

dam_beta0_tfp(r,a,t)   = 0 ;
dam_beta1_tfp(r,a,t)   = 0 ;
dam_beta2_tfp(r,a,t)   = 0 ;
dam_beta0_lab(r,l,a,t) = 0 ;
dam_beta1_lab(r,l,a,t) = 0 ;
dam_beta2_lab(r,l,a,t) = 0 ;
dam_beta0_hht(r,l,a,t) = 0 ;
dam_beta1_hht(r,l,a,t) = 0 ;
dam_beta2_hht(r,l,a,t) = 0 ;
dam_beta0_nrg(r,k,h,t) = 0 ;
dam_beta1_nrg(r,k,h,t) = 0 ;
dam_beta2_nrg(r,k,h,t) = 0 ;
dam_beta0_lnd(r,lnd,t) = 0 ;
dam_beta1_lnd(r,lnd,t) = 0 ;
dam_beta2_lnd(r,lnd,t) = 0 ;
dam_beta0_tou(r,i,t)   = 0 ;
dam_beta1_tou(r,i,t)   = 0 ;
dam_beta2_tou(r,i,t)   = 0 ;
dam_beta0_cap(r,t)     = 0 ;
dam_beta1_cap(r,t)     = 0 ;
dam_beta2_cap(r,t)     = 0 ;
