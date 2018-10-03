#!/bin/bash


###############################################################################
# Metascript for the LGN pRF analysis pipeline.                               #
###############################################################################


#------------------------------------------------------------------------------
# ### Define parameters

# Move data
# from
#    /sourcedata/dicoms/20180926
# via
#    bids/sub-01/ses-01/func
# to
#    derivatives/sub-01/func/sub-01_ses-01_run_01

# Subject ID:
str_sub_id="sub-02"

# Session IDs:
ary_ses_id=("ses-01" \
            "ses-02")

# Date strings (in same order as session IDs):
ary_date_id=("20180926" \
             "20181001")

# Number of functional runs per session (in same order as session IDs):
ary_num_runs=(10 \
              9)

# Analysis parent directory (containing scripts):
str_anly_path="/home/john/PhD/GitLab/lgn_prf/analysis/"
# str_anly_path="/Users/john/1_PhD/GitLab/lgn_prf/analysis/"

# Parent data directory (containing subfolders 'bids', 'derivatives',
# 'sourcedata').
str_data_path="/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/"

# Whether to load data from BIDS structure. If 'true', data is loaded from BIDS
# structure. If 'false', DICOM data is converted into BIDS-compatible nii
# first.
bool_from_bids=true

# Wait for manual user input? When running the analysis for the first time,
# some steps need to be performed manually (e.g. creation of brain masks for
# moco reference weighting, and for registration). The script will pause and
# wait until the user provides the manual input. However, if the manual input
# is already available (when re-running the analysis), these breaks can be
# skipped. Set to 'true' if script should wait.
bool_wait=true

# Number of parallel processes to use (for pRF finding):
var_num_cpu=11
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Export paths

# Bash does not (currently) support export of arrays. Therefore, we need to
# turn the arrays into strings, and export the strings. The strings can
# subsequently be turned into python lists, like this:
#     python
#     import os
#     str_ses_id = str(os.environ['str_ses_id'])
#     lst_ses_id = str_ses_id.split(' ')
# Likewise, in child bash scripts, the environmental string variable can be
# cast back into an array as follows:
#     IFS=" " read -r -a new_ary_ses_id <<< "$str_ses_id"
# Turn arrays into strings:
str_ses_id=${ary_ses_id[@]}
str_date_id=${ary_date_id[@]}
str_num_runs=${ary_num_runs[@]}

# Calculate total number of runs (i.e. all runs of all session for given
# subject).
var_num_runs=0
for idx_num_run in ${ary_num_runs[@]}
do
	var_num_runs=`bc <<< ${var_num_runs}+${idx_num_run}`
done

# Export paths and variables so that all other scripts can use them.
export str_sub_id
export str_ses_id
export str_date_id
export str_num_runs
export str_anly_path
export str_data_path
export bool_from_bids
export bool_wait
export var_num_cpu
export var_num_runs
export USER=john
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Activate docker image

# Run dockerfrom image with shared folders (analysis folder is read-only).
# Environmental variables are passed in with the '-e' flag.
docker run -it --rm \
    -v ${str_data_path}:${str_data_path} \
    -v ${str_anly_path}:${str_anly_path} \
    -e str_sub_id \
    -e str_ses_id \
    -e str_date_id \
    -e str_num_runs \
    -e str_anly_path \
    -e str_data_path \
    -e bool_from_bids \
    -e bool_wait \
    -e var_num_cpu \
    -e var_num_runs \
    -e USER \
    dockerimage_pacman_jessie ${str_anly_path}${str_sub_id}/metascript_02.sh
#------------------------------------------------------------------------------
