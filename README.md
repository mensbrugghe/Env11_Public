# Envisage V11

## Introduction

This repository contains the code for Envisage 11, including an aggregation
facility that is coupled with the GTAP Data Base and other external databases
such as the Shared Socio-Economic Pathways (SSP) database. It includes a single
project folder ("ANX1"), which represents a specific aggregation and that
can be used to run simulations in both comparative static and recursive
dynamic modes. Though this repository is publicly available, there is
only limited support for the use of the Envisage model.

## Data aggregation
To run the data aggregation, run the "Makedata.gms" file in the "Data" folder.
It is setup to run the "ANX1" aggregation, with the required definitions
for the aggregation in the folder "Data/ANX1" (but also requires the "sets"
definition file in the (top) folder "ANX1"). To create a new aggregation, create
a new folder in the "Data" folder and name it with the  code for the project. To start with,
copy the input files in the "Data/ANX1" folder, rename them, and modify them for
this specific project, e.g., new regional and commodity aggregation. Create
a new project folder in the top-level directory, copy the "sets" file
from the "ANX1" folder, rename it and make the desired changes. Finally,
change the name of the project on the first line of the "MakeData.gms" file.
If "MakeData" runs successfully, the aggregated files, all saved as
GDX files, will have been created in the project folder.

## Initial steps for simulation

Simulations require three input files---apart from the aggregated data
files: the "sets" file, which the user will have created for the
aggregation facility, the "prm" file, which contains the key parameters
for the model, and the "opt" file, which contains the key options for
running simulations---for example the time framework. As above, it
is often best to start with an existing template, such as the files
in the "ANX1" folder.

## Comparative static simulations

Before undertaking policy simulations, it is always best practice
to undertake some diagnostic simulations. The standard "opt" file
has a comparative static setup with time defined as "base", "check",
and "shock". Typically, the model is not solved for the "base", which
represents the initialized levels of the model's parameters and
variables. The "check" simulation is one with no shocks to any
exogenous variable or parameter. It is intended to verify that the
model can re-produce the base. The simulation should run in 0 or 1
iterations and the maximum residual should be near zero (e.g., 1e-5 or smaller).
The "shock" simulation can be used to test the price homogeneity of
the model. This is done by setting the numéraire to some level different
from 1, e.g., 1.5. The "CompShk.gms" file contains the code for doing shocks
and it can be used for other comparative static shocks as well, e.g., tariff changes, carbon
pricing, etc. Users can use the "runAllComp.gms" file to run comparative
static simulations in sequence.

## Dynamic simulations

Dynamic simulations are not very different from comparative static simulations, though
the time framework is given by actual years and the code is coupled
with external data---such as the SSP projections. The first dynamic
simulation is always the baseline. The baseline assumes that GDP
pathways are fixed and the model calculates changes in labor productivity
that produce the exogenous GDP pathways and subject to all of the
other assumptions. With a new project, or with changes to the baseline,
it is recommended to run a "no Shock" diagnostic simulation, which should re-produce
the baseline. The code allows for loading an existing simulation
before starting the simulation. In the case of the "no Shock" scenario, if
the baseline file is loaded, the "no Shock" scenario should replicate
the baseline with 0 or 1 iterations for each year. When running policy shocks, one
can use a previous simulation as a starting point, but this may not be 
a good starting point once the policy is being implemented. In this case,
it is best to use a prior simulation up to and including the year
of the start of the policy. Afterwards, it is best to use as a starting
point the values from the solution of the previous year (i.e., "t-1").
The file "RunAll.gms" contains a workflow that will run a sequence of
simulations and that provides the user with some flexibility as to the
choice of starting point.

##  Post-simulation

Results from the simulations are contained in separate GDX containers. Users can
extract the data from the containers, but this is often tedious, particularly
since most of the variables are normalized. The "runTab.gms" file provides
a workflow for the 'makCSV/makTab' GAMS programs that will extract
requested data, perform additional aggregations (e.g., across regions,
commodities, factors, etc.) and save the extracted data into CSV files---for one or more simulations. In
addition, the CSV files are automatically loaded into Excel files as Pivot tables.
Users are free to modify the Excel files, including adding worksheets
and additional Pivot tables and charts. Subsequent use of "runTab.gms" will
"refresh" the existing Pivot table, rather than create a new copy. Users
need to edit "runTab.gms" as well as the options file (e.g., "ANX1Tab.gms").
