File logFile / AdjustAuxAccounts.log / ;
put logFile ;
put "Infolder: ",  "%inFolder%" / ;
put "Outfolder: ", "%outFolder%" / ;

sets
   comm        "Commodities"
   endw        "Endowments"
   acts        "Activities"
   reg         "Regions"
   erg(comm)   "Energy commodities"
   marg(comm)  "Margin commodities"
;

$gdxIn "%inFolder%/%baseName%Dat.gdx"
$load comm, acts, reg, endw
$loaddc marg

$gdxIn "%inFolder%/%baseName%VOLE.gdx"
$loaddc erg
alias(reg, src) ; alias(reg, dst) ;

* ------------------------------------------------------------------------------
*
*  Adjust the energy data
*
* ------------------------------------------------------------------------------

put "Adjusting the energy balances..." / ;

*  Read the pre-filter data sets

*  Energy matrices

parameters
   EDF(ERG, ACTS, REG)     "Usage of domestic products by firms"
   EMF(ERG, ACTS, REG)     "Usage of imported products by firms"
   EDP(ERG,REG)            "Private consumption of domestic goods"
   EMP(ERG,REG)            "Private consumption of imported goods"
   EDG(ERG,REG)            "Public consumption of domestic goods"
   EMG(ERG,REG)            "Public consumption of imported goods"
   EDI(ERG,REG)            "Investment consumption of domestic goods"
   EMI(ERG,REG)            "Investment consumption of imported goods"
   EXI(ERG, REG, REG)      "Bilateral trade in energy"
   EQO(ACTS, REG)          "Output in MTOE"
   EMAK(ERG, ACTS, REG)    "Energy make matrix"
;

execute_loaddc "%inFolder%/%baseName%VOLE.gdx"
   EDF, EMF, EDP, EMP, EDG, EMG, EDI, EMI, EXI, EQO, EMAK
;

parameters
   VDFB(COMM, ACTS, REG)   "Usage of domestic products by firms"
   VMFB(COMM, ACTS, REG)   "Usage of imported products by firms"
   EVFB(ENDW, ACTS, REG)   "Usage of endowments by firms"
   VDPB(COMM, REG)         "Private consumption of domestic goods"
   VMPB(COMM, REG)         "Private consumption of imported goods"
   VDGB(COMM, REG)         "Public consumption of domestic goods"
   VMGB(COMM, REG)         "Public consumption of imported goods"
   VDIB(COMM, REG)         "Investment consumption of domestic goods"
   VMIB(COMM, REG)         "Investment consumption of imported goods"
   VXSB(COMM, REG, REG)    "Bilateral trade in energy"
   VOA(ACTS, REG)          "Output by activity"
   MAKS(COMM, ACTS, REG)   "Energy make matrix"
;

execute_loaddc "%inFolder%/%baseName%Dat.gdx"
   VDFB, VMFB, EVFB, VDPB, VMPB, VDGB, VMGB, VDIB, VMIB, VXSB, VOA, MAKS
;

*  Calculate the energy coefficient
EDF(erg,acts,reg)$VDFB(erg,acts,reg) = EDF(erg,acts,reg) / VDFB(erg,acts,reg) ;
EMF(erg,acts,reg)$VMFB(erg,acts,reg) = EMF(erg,acts,reg) / VMFB(erg,acts,reg) ;
EDP(erg,reg)$VDPB(erg,reg) = EDP(erg,reg) / VDPB(erg,reg) ;
EMP(erg,reg)$VMPB(erg,reg) = EMP(erg,reg) / VMPB(erg,reg) ;
EDG(erg,reg)$VDGB(erg,reg) = EDG(erg,reg) / VDGB(erg,reg) ;
EMG(erg,reg)$VMGB(erg,reg) = EMG(erg,reg) / VMGB(erg,reg) ;
EDI(erg,reg)$VDIB(erg,reg) = EDI(erg,reg) / VDIB(erg,reg) ;
EMI(erg,reg)$VMIB(erg,reg) = EMI(erg,reg) / VMIB(erg,reg) ;
EXI(erg,src,dst)$VXSB(erg,src,dst)    = EXI(erg,src,dst) / VXSB(erg,src,dst) ;
EQO(acts,reg)$VOA(acts,reg) = EQO(acts,reg) / VOA(acts,reg) ;
EMAK(erg,acts,reg)$MAKS(erg,acts,reg) = EMAK(erg,acts,reg) / MAKS(erg,acts,reg) ;

*  Read the post-filter data set
parameters
   VDFB1(COMM, ACTS, REG)  "Usage of domestic products by firms"
   VMFB1(COMM, ACTS, REG)  "Usage of imported products by firms"
   EVFB1(ENDW, ACTS, REG)  "Usage of endowments by firms"
   VDPB1(COMM, REG)        "Private consumption of domestic goods"
   VMPB1(COMM, REG)        "Private consumption of imported goods"
   VDGB1(COMM, REG)        "Public consumption of domestic goods"
   VMGB1(COMM, REG)        "Public consumption of imported goods"
   VDIB1(COMM, REG)        "Investment consumption of domestic goods"
   VMIB1(COMM, REG)        "Investment consumption of imported goods"
   VXSB1(COMM, REG, REG)   "Bilateral trade in energy"
   VOA1(ACTS, REG)         "Output by activity"
   MAKS1(COMM, ACTS, REG)  "Energy make matrix"
;
execute_loaddc "%outFolder%/%baseName%Dat.gdx"
   VDFB1=VDFB, VMFB1=VMFB, EVFB1=EVFB, VDPB1=VDPB, VMPB1=VMPB, VDGB1=VDGB, VMGB1=VMGB,
   VDIB1=VDIB, VMIB1=VMIB, VXSB1=VXSB, VOA1=VOA, MAKS1=MAKS ;
;

*  Re-calculate the energy volumes using the previous coefficients

EDF(erg,acts,reg) = EDF(erg,acts,reg) * VDFB1(erg,acts,reg) ;
EMF(erg,acts,reg) = EMF(erg,acts,reg) * VMFB1(erg,acts,reg) ;
EDP(erg,reg) = EDP(erg,reg) * VDPB1(erg,reg) ;
EMP(erg,reg) = EMP(erg,reg) * VMPB1(erg,reg) ;
EDG(erg,reg) = EDG(erg,reg) * VDGB1(erg,reg) ;
EMG(erg,reg) = EMG(erg,reg) * VMGB1(erg,reg) ;
EDI(erg,reg) = EDI(erg,reg) * VDIB1(erg,reg) ;
EMI(erg,reg) = EMI(erg,reg) * VMIB1(erg,reg) ;
EXI(erg,src,dst)   = EXI(erg,src,dst) * VXSB1(erg,src,dst) ;
EQO(acts,reg)      = EQO(acts,reg) * VOA1(acts,reg) ;
EMAK(erg,acts,reg) = EMAK(erg,acts,reg) * MAKS1(erg,acts,reg) ;

*  Save the data

execute_unload "%outFolder%/%baseName%VOLE.gdx"
   ACTS, COMM, REG, MARG, ERG,
   EDF, EMF, EDP, EMP, EDG, EMG, EDI, EMI, EXI, EQO, EMAK
;

* ------------------------------------------------------------------------------
*
*  Adjust the CO2 emissions data
*
* ------------------------------------------------------------------------------

sets
   FUEL(comm)     "Combustible fuels"
;

$gdxIn "%inFolder%/%baseName%Emiss.gdx"
$loaddc FUEL

*  CO2 Emission matrices

parameters
   MDF(FUEL, ACTS, REG)          "Emissions from domestic product in current production, .."
   MMF(FUEL, ACTS, REG)          "Emissions from imported product in current production, .."
   MDP(FUEL, REG)                "Emissions from private consumption of domestic product, Mt CO2"
   MMP(FUEL, REG)                "Emissions from private consumption of imported product, Mt CO2"
   MDG(FUEL, REG)                "Emissions from govt consumption of domestic product, Mt CO2"
   MMG(FUEL, REG)                "Emissions from govt consumption of imported product, Mt CO2"
   MDI(FUEL, REG)                "Emissions from invt consumption of domestic product, Mt CO2"
   MMI(FUEL, REG)                "Emissions from invt consumption of imported product, Mt CO2"
   nrgCOMB(FUEL,ACTS,REG)        "Energy combusted"   
;

execute_loaddc "%inFolder%/%baseName%EMISS.gdx"
   MDF, MMF, MDP, MMP, MDG, MMG, MDI, MMI, nrgCOMB
;

*  Calculate the emission coefficients coefficient
MDF(FUEL,acts,reg)$VDFB(FUEL,acts,reg) = MDF(FUEL,acts,reg) / VDFB(FUEL,acts,reg) ;
MMF(FUEL,acts,reg)$VMFB(FUEL,acts,reg) = MMF(FUEL,acts,reg) / VMFB(FUEL,acts,reg) ;
MDP(FUEL,reg)$VDPB(FUEL,reg) = MDP(FUEL,reg) / VDPB(FUEL,reg) ;
MMP(FUEL,reg)$VMPB(FUEL,reg) = MMP(FUEL,reg) / VMPB(FUEL,reg) ;
MDG(FUEL,reg)$VDGB(FUEL,reg) = MDG(FUEL,reg) / VDGB(FUEL,reg) ;
MMG(FUEL,reg)$VMGB(FUEL,reg) = MMG(FUEL,reg) / VMGB(FUEL,reg) ;
MDI(FUEL,reg)$VDIB(FUEL,reg) = MDI(FUEL,reg) / VDIB(FUEL,reg) ;
MMI(FUEL,reg)$VMIB(FUEL,reg) = MMI(FUEL,reg) / VMIB(FUEL,reg) ;

parameters
   MDF1(FUEL, ACTS, REG)         "Emissions from domestic product in current production, .."
   MMF1(FUEL, ACTS, REG)         "Emissions from imported product in current production, .."
   MDP1(FUEL, REG)               "Emissions from private consumption of domestic product, Mt CO2"
   MMP1(FUEL, REG)               "Emissions from private consumption of imported product, Mt CO2"
   MDG1(FUEL, REG)               "Emissions from govt consumption of domestic product, Mt CO2"
   MMG1(FUEL, REG)               "Emissions from govt consumption of imported product, Mt CO2"
   MDI1(FUEL, REG)               "Emissions from invt consumption of domestic product, Mt CO2"
   MMI1(FUEL, REG)               "Emissions from invt consumption of imported product, Mt CO2"
;

MDF1(FUEL,acts,reg) = MDF(FUEL,acts,reg) * VDFB1(FUEL,acts,reg) ;
MMF1(FUEL,acts,reg) = MMF(FUEL,acts,reg) * VMFB1(FUEL,acts,reg) ;
MDP1(FUEL,reg) = MDP(FUEL,reg) * VDPB1(FUEL,reg) ;
MMP1(FUEL,reg) = MMP(FUEL,reg) * VMPB1(FUEL,reg) ;
MDG1(FUEL,reg) = MDG(FUEL,reg) * VDGB1(FUEL,reg) ;
MMG1(FUEL,reg) = MMG(FUEL,reg) * VMGB1(FUEL,reg) ;
MDI1(FUEL,reg) = MDI(FUEL,reg) * VDIB1(FUEL,reg) ;
MMI1(FUEL,reg) = MMI(FUEL,reg) * VMIB1(FUEL,reg) ;

*  !!!! Should presumably adjust nrgCOMB?

execute_unload  "%outFolder%/%baseName%EMISS.gdx"
   acts, comm, marg, reg, FUEL,
   MDF1=MDF, MMF1=MMF, MDP1=MDP, MMP1=MMP, MDG1=MDG, MMG1=MMG, MDI1=MDI, MMI1=MMI, nrgCOMB
;

* ------------------------------------------------------------------------------
*
*  Adjust non-CO2 emissions data
*
* ------------------------------------------------------------------------------

$set ifNCO2 0
$if exist "%inFolder%/%baseName%NCO2.gdx" $set ifNCO2 1

*  Mostly NON-CO2 emission matrices

sets
   EM          "Set of emissions"
   EMN(EM)     "Non-CO2 emissions"
   GHG(EM)     "Greenhouse gas emissions"
   NGHG(EMN)   "Non-greehnouse gas emissions"

   LU_CAT      "Land use categories"
   LU_SUBCAT   "Land use sub-categories"
   AR          "IPCC Assessment Reports"
;


$ifthen.NCO2 %ifNCO2% == 1

$gdxin "%inFolder%/%baseName%NCO2.gdx"
$load EM, LU_CAT, LU_SUBCAT, AR
$loaddc EMN, GHG, NGHG

parameters
   EMI_IO(EM, COMM, ACTS, REG)         "IO-based emissions in Mmt"
   EMI_IOP(EM, COMM, ACTS, REG)        "IO-based process emissions in Mmt"
   EMI_ENDW(EM, ENDW, ACTS, REG)       "Endowment-based emissions in Mmt"
   EMI_QO(EM, ACTS, REG)               "Output-based emissions in Mmt"
   EMI_HH(EM, COMM, REG)               "Private consumption-based emissions in Mmt"
   EMI_LU(GHG,LU_CAT,LU_SUBCAT,REG)    "Land-use based emissions"
   GWP(ghg, reg, ar)                   "Global warming potential"
;

*  Load the data

execute_loaddc "%inFolder%/%baseName%NCO2.gdx",
   EMI_IO, EMI_IOP, EMI_ENDW, EMI_QO, EMI_HH, EMI_LU, GWP ;
;

parameters
   EMI_IO1(EM, COMM, ACTS, REG)        "IO-based emissions in Mmt"
   EMI_IOP1(EM, COMM, ACTS, REG)       "IO-based process emissions in Mmt"
   EMI_ENDW1(EM, ENDW, ACTS, REG)      "Endowment-based emissions in Mmt"
   EMI_QO1(EM, ACTS, REG)              "Output-based emissions in Mmt"
   EMI_HH1(EM, COMM, REG)              "Private consumption-based emissions in Mmt"
;

*  Calculate the original emission coefficients

EMI_IO(EM, COMM, ACTS, REG)$(VDFB(COMM,ACTS,REG) + VMFB(COMM,ACTS,REG))
   = EMI_IO(EM, COMM, ACTS, REG) / (VDFB(COMM,ACTS,REG) + VMFB(COMM,ACTS,REG)) ;
EMI_IOP(EM, COMM, ACTS, REG)$(VDFB(COMM,ACTS,REG) + VMFB(COMM,ACTS,REG))
   = EMI_IOP(EM, COMM, ACTS, REG) / (VDFB(COMM,ACTS,REG) + VMFB(COMM,ACTS,REG)) ;
EMI_ENDW(EM, ENDW, ACTS, REG)$EVFB(ENDW,ACTS,REG)
   = EMI_ENDW(EM, ENDW, ACTS, REG) / EVFB(ENDW,ACTS,REG) ;
EMI_QO(EM, ACTS, REG)$VOA(ACTS,REG) = EMI_QO(EM, ACTS, REG) / VOA(ACTS,REG) ;
EMI_HH(EM, COMM, REG)$(VDPB(COMM,REG) + VMPB(COMM,REG))
   = EMI_HH(EM, COMM, REG) / (VDPB(COMM,REG) + VMPB(COMM,REG)) ;

*  Calculate the adjusted emission coefficients

EMI_IO1(EM, COMM, ACTS, REG)
   = EMI_IO(EM, COMM, ACTS, REG) * (VDFB1(COMM,ACTS,REG) + VMFB1(COMM,ACTS,REG)) ;
EMI_IOP1(EM, COMM, ACTS, REG)
   = EMI_IOP(EM, COMM, ACTS, REG) * (VDFB1(COMM,ACTS,REG) + VMFB1(COMM,ACTS,REG)) ;
EMI_ENDW1(EM, ENDW, ACTS, REG)
   = EMI_ENDW(EM, ENDW, ACTS, REG) * EVFB1(ENDW,ACTS,REG) ;
EMI_QO1(EM, ACTS, REG) = EMI_QO(EM, ACTS, REG) * VOA(ACTS,REG) ;
EMI_HH1(EM, COMM, REG)
   = EMI_HH(EM, COMM, REG) * (VDPB1(COMM,REG) + VMPB1(COMM,REG)) ;

*  Save the data

execute_unload "%outFolder%/%baseName%NCO2.gdx",
   ar, comm, endw, acts, reg, em, emn, ghg, nghg, LU_CAT, LU_SUBCAT, GWP,
   emi_IO1=emi_IO, emi_QO1=emi_QO,
   emi_IOP1=emi_IOP,
   emi_ENDW1=emi_ENDW, emi_HH1=emi_HH, emi_LU ;
;

$endif.nco2

*  !!!! TBD if necessary: BoP, FBS and LU