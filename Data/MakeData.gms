$setGlobal BaseName   ANX1

$setGlobal ifClean    1
$setGlobal ifAgg      1
$setGlobal ifFilter   1
$setGlobal ifAgg2     1
$setGlobal ifAlterTax 1
$setGlobal ifEnv      1
$setGlobal ifGTAP     1
$setGlobal ifDyn      1
$SetGlobal SatDir  SatAcct
$setGlobal ifRystad   0
$setGlobal ifSAM      1

$include "%BaseName%/%BaseName%Opt.gms"

$set OPSYS
$If %system.filesys% == UNIX     $set OPSYS "UNIX"
$If %system.filesys% == DOS      $set OPSYS "DOS"
$If %system.filesys% == "MSNT"   $set OPSYS "DOS"
$If "%OPSYS%." == "." Abort "filesys not recognized" ;

$iftheni "%OPSYS%" == "UNIX"
   $$setGlobal sep /
$elseifi "%OPSYS%" == "DOS"
   $$setGlobal sep \
$else
   Abort "Unknown operating system" ;
$endif

$ifThen.Clean %ifClean% == 1
   set folders / Agg1, Flt, Agg2, Alt, Fnl / ;
   $$call del %BaseName%\Agg1\*.gdx
   $$call del %BaseName%\Flt\*.gdx
   $$call del %BaseName%\Agg2\*.gdx
   $$call del %BaseName%\Alt\*.gdx
   $$call del %BaseName%\Fnl\*.gdx
   $$ontext
   loop(folders and 0,
      put_utilities 'exec' / 'del ' '%BaseName%%sep%':0 folders.tl:0 '%sep%*.gdx':0
   ) ;
   $$offtext
$endif.Clean

*  First aggregation of the database, which must be diagonal for the Filter routine
$ifThen.Agg1 %ifAgg% == 1
   $$call gams AggGTAP --BaseName=%BaseName% --MapName=%BaseName%Map1 --outDir=Agg1 --ver=%ver% --GTAPDir=%GTAPDir% --DataBase=%DataBase%
   $$ifE errorLevel<>0 $abort 'Problem calling gams AggGTAP for initial aggregation'
   $$if not exist "%BaseName%/Flt" $call mkdir "%BaseName%/Flt"
   $$call copy %BaseName%%sep%Agg1%sep%*.gdx %BaseName%%sep%Flt
$endIf.Agg1

*  Filter the diagonal aggregated database
$ifThen.Filter %ifFilter% == 1
   $$call gams Filter --BaseName=%BaseName% --inFolder=%BaseName%%sep%Agg1 --outFolder=%BaseName%%sep%Flt
   $$ifE errorLevel<>0 $abort 'Problem calling gams Filter'
*  Adjust the auxiliary databases after filtering
   $$call gams AdjustAuxAccounts --BaseName=%BaseName% --inFolder=%BaseName%/Agg1 --outFolder=%BaseName%/Flt
   $$if not exist "%BaseName%/Agg2" $call mkdir "%BaseName%/Agg2"
   $$call copy %BaseName%%sep%Flt%sep%*.gdx %BaseName%%sep%Agg2
$endIf.Filter

*  Do the secondary aggregation
$ifThen.Agg2 %ifAgg2% == 1
*  Do the secondary aggregation--which does not require diagonality
   $$call gams AggGTAP --BaseName=%BaseName% --MapName=%BaseName%Map2 --outDir=Agg2 --GTAPDir=%BaseName%/Flt --DataBase=%BaseName%
   $$ifE errorLevel<>0 $abort 'Problem calling gams AggGTAP for secondary aggregation'
   $$if not exist "%BaseName%/Alt" $call mkdir "%BaseName%/Alt"
   $$call copy %BaseName%%sep%Agg2%sep%*.gdx %BaseName%%sep%Alt
   $$iftheni.SAM %ifSAM% == 1
      $$call gams makeSAM --BaseName=%BaseName% --inDir=%BaseName%/AGG2 --outDir=%BaseName% --Outfile=%BaseName%SAM --NAME=AGG2 --ifAppend=0
   $$endif.SAM
$endIf.Agg2

*  Run the Altertax program to modify the database
$ifThen.Altertax %ifAlterTax% == 1
   $$call gams Altertax -pw=110 -idir=GTAPModel --BaseName=%BaseName% --inFolder=%BaseName%%sep%Agg2 --outFolder=%BaseName%/Alt --niter=0 --ifMRIO=0
   $$ifE errorLevel<>0 $abort 'Problem calling gams Altertax'
*  Adjust the auxiliary databases after filtering
   $$call gams AdjustAuxAccounts --BaseName=%BaseName% --inFolder=%BaseName%%sep%Agg2 --outFolder=%BaseName%%sep%Alt
   $$if not exist "%BaseName%/Fnl" $call mkdir "%BaseName%/Fnl"
   $$call copy %BaseName%%sep%Alt%sep%*.gdx %BaseName%%sep%Fnl
   $$iftheni.SAM %ifSAM% == 1
      $$call gams makeSAM --BaseName=%BaseName% --inDir=%BaseName%/Alt --outDir=%BaseName% --Outfile=%BaseName%SAM --NAME=Alt --ifAppend=1
   $$endif.SAM
$endIf.Altertax

*  Aggregate the Rystad data

$ifThen.Rystad %ifRystad% == 1
   $$call gams AggRystad --BaseName=%BaseName% --oil=oil-a --gas=gas-a
   $$ifE errorLevel<>0 $abort 'Problem calling gams AggRystad for aggregating the Rystad data'
$endIf.Rystad

*  Process information for Envisage

*  Aggregate the GTAP-level Envisage elasticities to the model aggregation (the file is stored in the 'Fnl' folder)
$ifThen.Env %ifEnv% == 1
*  Requires 'sets' file from simulation folder
   $$call gams AggEnvElast -pw=110 --BaseName=%BaseName% --GTAPDir=%GTAPDir% --ver=%ver% --DataBase=%DataBase% --inFolder=%BaseName%%sep%Fnl --outFolder=%BaseName%%sep%Fnl --SatDir=%SatDir%
   $$ifE errorLevel<>0 $abort 'Problem calling gams AggEnvElast'
$endIf.Env

*  Process information for the Standard GTAP model in GAMS

*  Prepare a
$ifThen.GTAP %ifGTAP% == 1
$endIf.GTAP

$ifThen.Dyn %ifDyn% == 1
   $$call gams AggDyn -pw=110 --BaseName=%BaseName% --GTAPDir=%GTAPDir% --DataBase=%DataBase% --refYear=%refYear% --PPPYear=%PPPYear% --SatDir=%SatDir% --SSPFile=%SSPFile% --giddFile=%giddFile%
   $$ifE errorLevel<>0 $abort 'Problem calling gams AggDyn'

*  Run the dynamic macro Model
*  $$call gams Macro --pw=110 --BaseName=%BaseName% --inFolder=%BaseName%%sep%Fnl
$endIf.Dyn

*  Copy 'Fnl' data files to project folder
$$call copy %BaseName%%sep%Fnl%sep%%BaseName%*.gdx ..%sep%%BaseName%\

