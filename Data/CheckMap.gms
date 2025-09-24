$setArgs mapping Set0 SetAgg Description

check = 0 ;

loop(%Set0%,
   if(sum(%mapping%(%SetAgg%,%Set0%), 1) ne 1,
      check = check + 1 ;
      ifAllCheck = 1 ;
      if(check eq 1,
         Display "At least one original %Description% has not been mapped..." ;
         Display "Check the log file..." ;
         Put logFile ;
            put "The following original %Description% are not mapped:" / ;
      ) ;
      put "   ", %Set0%.tl, "  ", %Set0%.te(%Set0%) / ;
   ) ;
) ;

check = 0 ;
loop(%SetAgg%,
   if(sum(%mapping%(%SetAgg%,%Set0%), 1) eq 0,
      check = check + 1 ;
      ifAllCheck = 1 ;
      if(check eq 1,
         Display "At least one aggregate %Description% has not been mapped" ;
         Display "Check the log file..." ;
         Put logFile ;
            put "The following aggregate %Description% are not mapped:" / ;
      ) ;
      put "   ", %SetAgg%.tl, "   ", %SetAgg%.te(%SetAgg%) / ;
   ) ;
) ;

