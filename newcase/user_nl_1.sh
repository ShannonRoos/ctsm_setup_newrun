#! /bin/bash
# Author: Shannon de Roos (shannon.de.roos@vub.be), structure adopted from Wim Thiery.
# created: 8/11/24

# use this file to changes namelist settings for associated run

# CLM5
# add history fields, only output relevant variables
cat > user_nl_clm << EOF
!----------------------------------------------------------------------------------
! Users should add all user specific namelist changes below in the form of
! namelist_var = new_namelist_value
!
! EXCEPTIONS:
! Set use_cndv           by the compset you use and the CLM_BLDNML_OPTS -dynamic_vegetation setting
! Set use_vichydro       by the compset you use and the CLM_BLDNML_OPTS -vichydro           setting
! Set use_cn             by the compset you use and CLM_BLDNML_OPTS -bgc  setting
! Set use_crop           by the compset you use and CLM_BLDNML_OPTS -crop setting
! Set spinup_state       by the CLM_BLDNML_OPTS -bgc_spinup      setting
! Set co2_ppmv           with CCSM_CO2_PPMV                      option
! Set fatmlndfrc         with LND_DOMAIN_PATH/LND_DOMAIN_FILE    options
! Set finidat            with RUN_REFCASE/RUN_REFDATE/RUN_REFTOD options for hybrid or branch cases
!                        (includes $inst_string for multi-ensemble cases)
!                        or with CLM_FORCE_COLDSTART to do a cold start
!                        or set it with an explicit filename here.
! Set maxpatch_glc       with GLC_NEC                            option
! Set glc_do_dynglacier  with GLC_TWO_WAY_COUPLING               env variable
!----------------------------------------------------------------------------------


hist_empty_htapes = .true.

hist_fincl1 = 'GRAINC_TO_FOOD', 'TSA', 'TV', 'TLAI', 'TSOI','H2OSOI', 'QSOIL', 'QVEGT', 'TREFMNAV', 'SOILWATER_10CM', 'GPP', 'NPP'
hist_fincl2 = 'ELAI','TVMAX', 'TVMIN', 'TV', 'TSA', 'H2OSOI', 'TSOI', 'TREFMNAV', 'SOILWATER_10CM', 'GPP', 'NPP', 'TVDAY', 'TVNIGHT', 'HS_NDAYS', 'HW', 'BGLFR', 'HSF', 'GRAINC_TO_FOOD'
hist_fincl3 = 'GRAINC_TO_FOOD', 'LITFALL', 'ELAI','TLAI', 'TV', 'NPP', 'TVDAY', 'TVNIGHT'
hist_fincl4 = 'ELAI','TLAI', 'TV','TVMAX', 'TVMIN', 'GPP', 'CPHASE', 'NPP', 'TVDAY', 'TVNIGHT','HS_NDAYS', 'HW', 'BGLFR', 'HSF', 'GRAINC_TO_FOOD'
hist_fincl5 = 'SDATES', 'HDATES', 'GDDHARV_PERHARV', 'GDDACCUM_PERHARV', 'HUI_PERHARV', 'SOWING_REASON_PERHARV', 'HARVEST_REASON_PERHARV', 'GRAINC_TO_FOOD_PERHARV', 'GRAINC_TO_FOOD_ANN'

hist_nhtfrq = 0, -24, 0, -24, 17520
hist_mfilt  =1, 365, 1, 365, 999

hist_type1d_pertape = '', '', 'PFTS', 'PFTS', 'PFTS'
hist_dov2xy = .true., .true., .false., .false., .false.

EOF

