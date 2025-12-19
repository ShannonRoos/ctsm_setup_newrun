#!/bin/bash


# bash script to set up a CTSMv5.2 transient historical run
# information taken from Wim Thiery, adopted from:
# https://wiki.iac.ethz.ch/Climphys/ProjectCESM122SetupControlRun



#=====================================================
# initialisation
#=====================================================


# define path where cases are stored
CASEDIR=~/cases


# define path where CESM scripts are stored
SCRIPTSDIR=~/code/CTSM_HS/cime/scripts

# define output directory
OUTDIR=~/scratch

# define machine
MACH=derecho


# define project
PROJ=#####


# define compiler
#COMPILER=intel;  MPILIB=openmpi      # io


# define compset - more information below
COMP=IHistClm50BgcCrop


# define resolution
RES=f19_g17          # 1.9x2.5_gx1v7 (2°) resolution


# define number of cores
NTASKS=128           # number of tasks (= cores used)


# define other information
ver=e52                                                       # version, used in CASE name, e122 = CESM 1.2.2
#flavor="${COMPILER:0:1}${MPILIB:0:1}"                        # either im, io, pm, po
type=control                                                  # type of run
nexp=10						#number of experiment
desc=HSF_repr_exp$nexp                            # description, used in CASE name
comp=$( echo ${COMP:0:5} | tr '[:upper:]' '[:lower:]' )


# define run settings
start_year=1980 # start year of the simulation (1976)
end_year=2014   # end year of the SST dataset
simul_length=5  # years


# define namelist script
nl_file=user_nl.sh


# set whether you are in production mode or test mode
production=true  # true= production runs; false=testing
nresubmit=6     # if simul_length=12, this is number of years -1; use for final production runs including spinup



#=====================================================
# 1. create new case
#=====================================================a



# get path where setup scripts are
SETUPDIR=$(pwd)


# Change into the new case directory 
cd $SCRIPTSDIR


# generate casename
CASE=$comp.$ver.$COMP.$RES.$desc


# create a new case in the directory 'cases'
./create_newcase --case $CASEDIR/$CASE  --res $RES --compset $COMP --machine $MACH --project $PROJ

#copy CROPHEATSTRESS script to SourceMods
cp /glade/u/home/sroos/setup_newrun/HSF_repr_experiments/CropHeatStress_exp$nexp.F90 $CASEDIR/$CASE/SourceMods/src.clm/CropHeatStress.F90
cp /glade/u/home/sroos/setup_newrun/HSF_repr_experiments/CNAllocationMod_exp$nexp.F90 $CASEDIR/$CASE/SourceMods/src.clm/CNAllocationMod.F90


#=====================================================
# 2. invoke cesm_setup
#=====================================================


# Change into the new case directory 
cd $CASEDIR/$CASE


# copy this script to the case directory for reference
cp $SETUPDIR/`basename "$0"` .

# Modify env_build.xml
./xmlchange CIME_OUTPUT_ROOT=$OUTDIR

# Modify env_mach_pes.xml
# Note: If you change env_mach_pes.xml later, you have to do ./cesm_setup -clean; and again ./cesm_setup; ./$CASE.$MACH.build ! 
./xmlchange NTASKS=$NTASKS

# modify env_run.xml
./xmlchange DOUT_S=FALSE			# short-time archiving
./xmlchange RUN_STARTDATE=${start_year}"-01-01"  # year in which CESM starts running (1st January)
./xmlchange DATM_YR_ALIGN=${start_year}          # model year when you want the data to start
./xmlchange DATM_YR_START=${start_year}          # date on the file when the data starts
./xmlchange DATM_YR_END=${end_year}            # date on the file when the data ends
./xmlchange RUN_TYPE=startup                # Set to run type to startup (is the default)


# modify env_run.xml - MAY BE CHANGED ANYTIME during a run
./xmlchange STOP_OPTION=nyears
### ./xmlchange -file env_run.xml -id STOP_OPTION       -val ndays
./xmlchange STOP_N=${simul_length}



# introduce changes to CLM namelist
cp $SETUPDIR/$nl_file .
chmod 750 $nl_file
./$nl_file


# Configure case
./case.setup



#=====================================================
# 3. Build/Compile the model
#    note: restart from here when making source mods
#=====================================================


# Build/Compile the model
./case.build



#=====================================================
# 4. Submit run to the batch queue
#=====================================================


# change walltime from 23:59h to 03:59h - for 2degree run
### sed -i 's/#BSUB -W 23:59/#BSUB -W 03:59/g' $CASE.run


# run the model
if [ "$production" = true ]; then  # production runs

  ./xmlchange CONTINUE_RUN=FALSE
  ./xmlchange RESUBMIT=${nresubmit}
  ./case.submit

 
else                               # single year run

  ./case.submit

fi


# Check the submitted job status (can take a bit before status has come through)
#qstat -u sroos





