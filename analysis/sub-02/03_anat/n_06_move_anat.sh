#!/bin/bash


###############################################################################
# Move anatomical images.                                                     #
###############################################################################


#------------------------------------------------------------------------------
# *** Define parameters:

# Input directorybasename (child directories: "ses-01", "ses-02", etc.):
strPthIn="${str_data_path}derivatives/${str_sub_id}/anat/03_reg_within_sess/"

# Output directory basename (child directories: "ses-01", "ses-02", etc.):
strPthOut="${str_data_path}derivatives/${str_sub_id}/anat/04_intermediate/"

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_anat <<< "$str_num_anat"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Move anatomical images

# echo "------Move anatomical images"

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Path of image to be moved:
  strPth01="${strPthIn}${idx_ses_id}/03_reg_PD/${str_sub_id}_${idx_ses_id}_T1w_si.nii.gz"

  # Target path:
  strPth02="${strPthOut}${str_sub_id}_${idx_ses_id}_T1w_si.nii.gz"

  cp ${strPth01} ${strPth02}

  # Path of image to be moved:
  strPth01="${strPthIn}${idx_ses_id}/04_mean_PD/${str_sub_id}_${idx_ses_id}_PD.nii.gz"

  # Target path:
  strPth02="${strPthOut}${str_sub_id}_${idx_ses_id}_PD.nii.gz"

  cp ${strPth01} ${strPth02}

done
#------------------------------------------------------------------------------
