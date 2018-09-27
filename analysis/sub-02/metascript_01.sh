#!/bin/bash


################################################################################
# Metascript for the LGN pRF analysis pipeline.                                #
################################################################################


#-------------------------------------------------------------------------------
# ### Define parameters

# Move data
# from
#    /sourcedata/dicoms/20180926
# via
#    bids/sub-01/ses-01/func
# to
#    derivatives/sub-01/func/sub-01_ses-01_func_01

# Subject ID:
str_sub_id="sub-02"

# Session IDs:
ary_ses_id=(ses-01 \
            ses-02 \
            ses-03)

# Date strings (in same order as session IDs):
ary_date_id=(20180926 \
             20180926 \
             20180926)

# Number of runs per session (in same order as session IDs):
ary_num_runs=(10 \
              10 \
              10)

# Analysis parent directory (containing scripts):
str_anly_path="/home/john/PhD/GitLab/lgn_prf/analysis/"

# Parent data directory (containing subfolders 'bids', 'derivatives',
# 'sourcedata').
str_data_path="/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/"

# Whether to load data from BIDS structure. If 'true', data is loaded from BIDS
# structure. If 'false', DICOM data is converted into BIDS-compatible nii first.
bool_from_bids=false

# Wait for manual user input? When running the analysis for the first time, some
# steps need to be performed manually (e.g. creation of brain masks for moco
# reference weighting, and for registration). The script will pause and wait
# until the user provides the manual input. However, if the manual input is
# already available (when re-running the analysis), these breaks can be skipped.
# Set to 'true' if script should wait.
bool_wait=true

# Number of parallel processes to use (for pRF finding):
var_num_cpu="11"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Export paths

# Export paths and variables so that all other scripts can use them.
export str_sub_id
export ary_ses_id
export ary_date_id
export ary_num_runs
export str_anly_path
export str_data_path
export bool_from_bids
export bool_wait
export var_num_cpu
export USER=john
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# ### Activate docker image

# Run dockerfrom image with shared folders (analysis folder is read-only).
# Environmental variables are passed in with the '-e' flag.
docker run -it --rm \
    -v ${str_data_path}:${str_data_path} \
    -v ${str_anly_path}:${str_anly_path} \
    -e str_sub_id \
    -e ary_ses_id \
    -e ary_date_id \
    -e ary_num_runs \
    -e str_anly_path \
    -e str_data_path \
    -e bool_from_bids \
    -e bool_wait \
    -e var_num_cpu \
    -e USER \
    dockerimage_lgn_jessie ${str_anly_path}${str_sub_id}/metascript_02.sh
#-------------------------------------------------------------------------------
