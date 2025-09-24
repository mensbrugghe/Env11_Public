Parameter
   sigma2(r,a)
   sigma2i(r,i)
   sigma3i(r,i,aa)
   sigma2fd(r,fd)
   sigma3ci(r,i,h)
   sigma2e(r,elyc)
   sigma3(r,a,v)
   sigma3a(r,wb,a)
   sigma3e(r,pb,elyc)
   sigma4(r,a,NRG,v)
   sigma4c(r,k,h,NRG)

   eta2t(r,lnd)
   eta3n(r,a,lh)

   sigma3c(r,k,h)
;

$macro   M_diag2_1(name,r,a)  sigma2(r,a) = sum(rp$name(rp,a), 1) ;
$macro   M_diag2_2(name,r,a)  sigma2(r,a)$sigma2(r,a) = sum(rp, name(rp,a)) / sigma2(r,a) ;
$macro   M_diag2_3(name,r,a)  sigma2(r,a) = (100*name(r,a) / sigma2(r,a) - 100)$sigma2(r,a) + (-name(r,a))$(sigma2(r,a) eq 0) ;

$macro   M_diag2fd_1(name,r,fd)  sigma2fd(r,fd) = sum(rp$name(rp,fd), 1) ;
$macro   M_diag2fd_2(name,r,fd)  sigma2fd(r,fd)$sigma2fd(r,fd) = sum(rp, name(rp,fd)) / sigma2fd(r,fd) ;
$macro   M_diag2fd_3(name,r,fd)  sigma2fd(r,fd) = (100*name(r,fd) / sigma2fd(r,fd) - 100)$sigma2fd(r,fd) + (-name(r,fd))$(sigma2fd(r,fd) eq 0) ;

$macro   M_diag2i_1(name,r,i)  sigma2i(r,i) = sum(rp$name(rp,i), 1) ;
$macro   M_diag2i_2(name,r,i)  sigma2i(r,i)$sigma2i(r,i) = sum(rp, name(rp,i)) / sigma2i(r,i) ;
$macro   M_diag2i_3(name,r,i)  sigma2i(r,i) = (100*name(r,i) / sigma2i(r,i) - 100)$sigma2i(r,i) + (-name(r,i))$(sigma2i(r,i) eq 0) ;

$macro   M_diag3i_1(name,r,i,aa)  sigma3i(r,i,aa) = sum(rp$name(rp,i,aa), 1) ;
$macro   M_diag3i_2(name,r,i,aa)  sigma3i(r,i,aa)$sigma3i(r,i,aa) = sum(rp, name(rp,i,aa)) / sigma3i(r,i,aa) ;
$macro   M_diag3i_3(name,r,i,aa)  sigma3i(r,i,aa) = (100*name(r,i,aa) / sigma3i(r,i,aa) - 100)$sigma3i(r,i,aa) + (-name(r,i,aa))$(sigma3i(r,i,aa) eq 0) ;

$macro   M_diag3ci_1(name,r,i,h)  sigma3ci(r,i,h) = sum(rp$name(rp,i,h), 1) ;
$macro   M_diag3ci_2(name,r,i,h)  sigma3ci(r,i,h)$sigma3ci(r,i,h) = sum(rp, name(rp,i,h)) / sigma3ci(r,i,h) ;
$macro   M_diag3ci_3(name,r,i,h)  sigma3ci(r,i,h) = (100*name(r,i,h) / sigma3ci(r,i,h) - 100)$sigma3ci(r,i,h) + (-name(r,i,h))$(sigma3ci(r,i,h) eq 0) ;

$macro   M_diag2e_1(name,r,elyc)  sigma2e(r,elyc) = sum(rp$name(rp,elyc), 1) ;
$macro   M_diag2e_2(name,r,elyc)  sigma2e(r,elyc)$sigma2e(r,elyc) = sum(rp, name(rp,elyc)) / sigma2e(r,elyc) ;
$macro   M_diag2e_3(name,r,elyc)  sigma2e(r,elyc) = (100*name(r,elyc) / sigma2e(r,elyc) - 100)$sigma2e(r,elyc) + (-name(r,elyc))$(sigma2e(r,elyc) eq 0) ;

$macro   M_diag3_1(name,r,a,v)  sigma3(r,a,v) = sum(rp$name(rp,a,v), 1) ;
$macro   M_diag3_2(name,r,a,v)  sigma3(r,a,v)$sigma3(r,a,v) = sum(rp, name(rp,a,v)) / sigma3(r,a,v) ;
$macro   M_diag3_3(name,r,a,v)  sigma3(r,a,v) = (100*name(r,a,v) / sigma3(r,a,v) - 100)$sigma3(r,a,v) + (-name(r,a,v))$(sigma3(r,a,v) eq 0) ;

$macro   M_diag2t_1(name,r,lnd)  eta2t(r,lnd) = sum(rp$name(rp,lnd), 1) ;
$macro   M_diag2t_2(name,r,lnd)  eta2t(r,lnd)$eta2t(r,lnd) = sum(rp, name(rp,lnd)) / eta2t(r,lnd) ;
$macro   M_diag2t_3(name,r,lnd)  eta2t(r,lnd) = (100*name(r,lnd) / eta2t(r,lnd) - 100)$eta2t(r,lnd) + (-name(r,lnd))$(eta2t(r,lnd) eq 0) ;

$macro   M_diag3n_1(name,r,a,lh)  eta3n(r,a,lh) = sum(rp$name(rp,a,lh), 1) ;
$macro   M_diag3n_2(name,r,a,lh)  eta3n(r,a,lh)$eta3n(r,a,lh) = sum(rp, name(rp,a,lh)) / eta3n(r,a,lh) ;
$macro   M_diag3n_3(name,r,a,lh)  eta3n(r,a,lh) = (100*name(r,a,lh) / eta3n(r,a,lh) - 100)$eta3n(r,a,lh) + (-name(r,a,lh))$(eta3n(r,a,lh) eq 0) ;

$macro   M_diag3a_1(name,r,wb,a)  sigma3a(r,wb,a) = sum(rp$name(rp,wb,a), 1) ;
$macro   M_diag3a_2(name,r,wb,a)  sigma3a(r,wb,a)$sigma3a(r,wb,a) = sum(rp, name(rp,wb,a)) / sigma3a(r,wb,a) ;
$macro   M_diag3a_3(name,r,wb,a)  sigma3a(r,wb,a) = (100*name(r,wb,a) / sigma3a(r,wb,a) - 100)$sigma3a(r,wb,a) + (-name(r,wb,a))$(sigma3a(r,wb,a) eq 0) ;

$macro   M_diag3e_1(name,r,pb,elyc)  sigma3e(r,pb,elyc) = sum(rp$name(rp,pb,elyc), 1) ;
$macro   M_diag3e_2(name,r,pb,elyc)  sigma3e(r,pb,elyc)$sigma3e(r,pb,elyc) = sum(rp, name(rp,pb,elyc)) / sigma3e(r,pb,elyc) ;
$macro   M_diag3e_3(name,r,pb,elyc)  sigma3e(r,pb,elyc) = (100*name(r,pb,elyc) / sigma3e(r,pb,elyc) - 100)$sigma3e(r,pb,elyc) + (-name(r,pb,elyc))$(sigma3e(r,pb,elyc) eq 0) ;

$macro   M_diag3c_1(name,r,k,h)  sigma3c(r,k,h) = sum(rp$name(rp,k,h), 1) ;
$macro   M_diag3c_2(name,r,k,h)  sigma3c(r,k,h)$sigma3c(r,k,h) = sum(rp, name(rp,k,h)) / sigma3c(r,k,h) ;
$macro   M_diag3c_3(name,r,k,h)  sigma3c(r,k,h) = (100*name(r,k,h) / sigma3c(r,k,h) - 100)$sigma3c(r,k,h) + (-name(r,k,h))$(sigma3c(r,k,h) eq 0) ;

$macro   M_diag4_1(name,r,a,NRG,v)  sigma4(r,a,NRG,v) = sum(rp$name(rp,a,NRG,v), 1) ;
$macro   M_diag4_2(name,r,a,NRG,v)  sigma4(r,a,NRG,v)$sigma4(r,a,NRG,v) = sum(rp, name(rp,a,NRG,v)) / sigma4(r,a,NRG,v) ;
$macro   M_diag4_3(name,r,a,NRG,v)  sigma4(r,a,NRG,v) = (100*name(r,a,NRG,v) / sigma4(r,a,NRG,v) - 100)$sigma4(r,a,NRG,v) + (-name(r,a,NRG,v))$(sigma4(r,a,NRG,v) eq 0) ;

$macro   M_diag4c_1(name,r,k,h,NRG)  sigma4c(r,k,h,NRG) = sum(rp$name(rp,k,h,NRG), 1) ;
$macro   M_diag4c_2(name,r,k,h,NRG)  sigma4c(r,k,h,NRG)$sigma4c(r,k,h,NRG) = sum(rp, name(rp,k,h,NRG)) / sigma4c(r,k,h,NRG) ;
$macro   M_diag4c_3(name,r,k,h,NRG)  sigma4c(r,k,h,NRG) = (100*name(r,k,h,NRG) / sigma4c(r,k,h,NRG) - 100)$sigma4c(r,k,h,NRG) + (-name(r,k,h,NRG))$(sigma4c(r,k,h,NRG) eq 0) ;

M_Diag3_1(sigmaxp,r,a,v) M_Diag3_2(sigmaxp,r,a,v) M_Diag3_3(sigmaxp,r,a,v) display "sigmaxp", sigma3 ;
M_Diag3_1(sigmaProcEmi,r,a,v) M_Diag3_2(sigmaProcEmi,r,a,v) M_Diag3_3(sigmaProcEmi,r,a,v) display "sigmaProcEmi", sigma3 ;
M_Diag3_1(sigmanrs,r,a,v) M_Diag3_2(sigmanrs,r,a,v) M_Diag3_3(sigmanrs,r,a,v) display "sigmanrs", sigma3 ;
M_Diag3_1(sigmap,r,a,v) M_Diag3_2(sigmap,r,a,v) M_Diag3_3(sigmap,r,a,v) display "sigmap", sigma3 ;
M_Diag3_1(sigmav,r,a,v) M_Diag3_2(sigmav,r,a,v) M_Diag3_3(sigmav,r,a,v) display "sigmav", sigma3 ;
M_Diag3_1(sigmav1,r,a,v) M_Diag3_2(sigmav1,r,a,v) M_Diag3_3(sigmav1,r,a,v) display "sigmav1", sigma3 ;
M_Diag3_1(sigmav2,r,a,v) M_Diag3_2(sigmav2,r,a,v) M_Diag3_3(sigmav2,r,a,v) display "sigmav2", sigma3 ;
M_Diag3_1(sigmakef,r,a,v) M_Diag3_2(sigmakef,r,a,v) M_Diag3_3(sigmakef,r,a,v) display "sigmakef", sigma3 ;
M_Diag3_1(sigmakf,r,a,v) M_Diag3_2(sigmakf,r,a,v) M_Diag3_3(sigmakf,r,a,v) display "sigmakf", sigma3 ;
M_Diag3_1(sigmakw,r,a,v) M_Diag3_2(sigmakw,r,a,v) M_Diag3_3(sigmakw,r,a,v) display "sigmakw", sigma3 ;
M_Diag3_1(sigmak,r,a,v) M_Diag3_2(sigmak,r,a,v) M_Diag3_3(sigmak,r,a,v) display "sigmak", sigma3 ;
M_Diag3_1(sigmae,r,a,v) M_Diag3_2(sigmae,r,a,v) M_Diag3_3(sigmae,r,a,v) display "sigmae", sigma3 ;
M_Diag3_1(sigmanely,r,a,v) M_Diag3_2(sigmanely,r,a,v) M_Diag3_3(sigmanely,r,a,v) display "sigmanely", sigma3 ;
M_Diag3_1(sigmaolg,r,a,v) M_Diag3_2(sigmaolg,r,a,v) M_Diag3_3(sigmaolg,r,a,v) display "sigmaolg", sigma3 ;

M_Diag3a_1(sigmal,r,wb,a) M_Diag3a_2(sigmal,r,wb,a) M_Diag3a_3(sigmal,r,wb,a) display "sigmal", sigma3a ;

M_Diag2_1(sigmalnd,r,a) M_Diag2_2(sigmalnd,r,a) M_Diag2_3(sigmalnd,r,a) display "sigmalnd", sigma2 ;
M_Diag2_1(sigmawat,r,a) M_Diag2_2(sigmawat,r,a) M_Diag2_3(sigmawat,r,a) display "sigmawat", sigma2 ;
M_Diag2_1(sigmal1,r,a) M_Diag2_2(sigmal1,r,a) M_Diag2_3(sigmal1,r,a) display "sigmal1", sigma2 ;
M_Diag2_1(sigmal2,r,a) M_Diag2_2(sigmal2,r,a) M_Diag2_3(sigmal2,r,a) display "sigmal2", sigma2 ;
M_Diag2_1(sigman1,r,a) M_Diag2_2(sigman1,r,a) M_Diag2_3(sigman1,r,a) display "sigman1", sigma2 ;
M_Diag2_1(sigman2,r,a) M_Diag2_2(sigman2,r,a) M_Diag2_3(sigman2,r,a) display "sigman2", sigma2 ;
M_Diag2_1(omegas,r,a) M_Diag2_2(omegas,r,a) M_Diag2_3(omegas,r,a) display "omegas", sigma2 ;
M_Diag2_1(invelas,r,a) M_Diag2_2(invelas,r,a) M_Diag2_3(invelas,r,a) display "invelas", sigma2 ;

M_Diag2i_1(sigmas,r,i) M_Diag2i_2(sigmas,r,i) M_Diag2i_3(sigmas,r,i) display "sigmas", sigma2i ;
M_Diag2i_1(sigmamt,r,i) M_Diag2i_2(sigmamt,r,i) M_Diag2i_3(sigmamt,r,i) display "sigmamt", sigma2i ;
M_Diag2i_1(sigmaw,r,i) M_Diag2i_2(sigmaw,r,i) M_Diag2i_3(sigmaw,r,i) display "sigmaw", sigma2i ;
M_Diag2i_1(omegax,r,i) M_Diag2i_2(omegax,r,i) M_Diag2i_3(omegax,r,i) display "omegax", sigma2i ;
M_Diag2i_1(omegaw,r,i) M_Diag2i_2(omegaw,r,i) M_Diag2i_3(omegaw,r,i) display "omegaw", sigma2i ;

M_Diag3i_1(sigmam,r,i,aa) M_Diag3i_2(sigmam,r,i,aa) M_Diag3i_3(sigmam,r,i,aa) display "sigmam", sigma3i ;
M_Diag3i_1(sigmawa,r,i,aa) M_Diag3i_2(sigmawa,r,i,aa) M_Diag3i_3(sigmawa,r,i,aa) display "sigmawa", sigma3i ;

M_Diag2e_1(sigmael,r,elyc) M_Diag2e_2(sigmael,r,elyc) M_Diag2e_3(sigmael,r,elyc) display "sigmael", sigma2e ;
M_Diag2e_1(sigmapow,r,elyc) M_Diag2e_2(sigmapow,r,elyc) M_Diag2e_3(sigmapow,r,elyc) display "sigmapow", sigma2e ;
M_Diag3e_1(sigmapb,r,pb,elyc) M_Diag3e_2(sigmapb,r,pb,elyc) M_Diag3e_3(sigmapb,r,pb,elyc) display "sigmapb", sigma3e ;

M_Diag4_1(sigmaNRG,r,a,NRG,v) M_Diag4_2(sigmaNRG,r,a,NRG,v) M_Diag4_3(sigmaNRG,r,a,NRG,v) display "sigmaNRG", sigma4 ;

M_Diag3c_1(nu,r,k,h) M_Diag3c_2(nu,r,k,h) M_Diag3c_3(nu,r,k,h) display "nu", sigma3c ;
M_Diag3c_1(nunnrg,r,k,h) M_Diag3c_2(nunnrg,r,k,h) M_Diag3c_3(nunnrg,r,k,h) display "nunnrg", sigma3c ;
M_Diag3c_1(nue,r,k,h) M_Diag3c_2(nue,r,k,h) M_Diag3c_3(nue,r,k,h) display "nue", sigma3c ;
M_Diag3c_1(nuolg,r,k,h) M_Diag3c_2(nuolg,r,k,h) M_Diag3c_3(nuolg,r,k,h) display "nuolg", sigma3c ;
M_Diag3c_1(nunely,r,k,h) M_Diag3c_2(nunely,r,k,h) M_Diag3c_3(nunely,r,k,h) display "nunely", sigma3c ;

M_Diag4c_1(nuNRG,r,k,h,NRG) M_Diag4c_2(nuNRG,r,k,h,NRG) M_Diag4c_3(nuNRG,r,k,h,NRG) display "nuNRG", sigma4c ;

M_Diag3ci_1(sigmaac,r,i,h) M_Diag3ci_2(sigmaac,r,i,h) M_Diag3ci_3(sigmaac,r,i,h) display "sigmaac", sigma3ci ;

M_Diag2fd_1(sigmafd,r,fdc) M_Diag2fd_2(sigmafd,r,fdc) M_Diag2fd_3(sigmafd,r,fdc) display "sigmafd", sigma2fd ;

display "sigmamg", sigmamg ;
display "etal", etal ;

M_Diag2t_1(etat,r,lnd) M_Diag2t_2(etat,r,lnd) M_Diag2t_3(etat,r,lnd) display "etat", eta2t ;
M_Diag3n_1(etanrsx,r,a,lh) M_Diag3n_2(etanrsx,r,a,lh) M_Diag3n_3(etanrsx,r,a,lh) display "etanrsx", eta3n ;
