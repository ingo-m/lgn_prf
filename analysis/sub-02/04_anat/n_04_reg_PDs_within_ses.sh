#!/bin/bash


###############################################################################
# Register anatomical images within sessions.                                 #
###############################################################################


#------------------------------------------------------------------------------
# *** Define parameters:

# Input directorybasename (child directories: "ses-01", "ses-02", etc.):
strPthIn="${str_data_path}derivatives/${str_sub_id}/anat/03_reg_within_sess/"

# Output directory basename (child directories: "ses-01", "ses-02", etc.):
strPthOut="${str_data_path}derivatives/${str_sub_id}/anat/03_reg_within_sess/"

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_anat <<< "$str_num_anat"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Register anatomical images within session

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Register proton density images (several per session).

  # Path of reference image (first proton density image from each session).
  strPthRef="${strPthIn}${idx_ses_id}/01_in/${str_sub_id}_${idx_ses_id}_PD_01"

  # Path of brain mask for reference PD image:
  strPthRefMsk="${str_anly_path}${str_sub_id}/04_anat/pd_brain_masks/${str_sub_id}_${idx_ses_id}_PD_01_mask"

  # Loop through PD images, starting from second image (e.g. "02"); i.e. zero
  # filled indices ("02", "03", etc.). Note that the number of PD images may
  # not be identical throughout sessions.
	for idx_num_anat in $(seq -f "%02g" 2 ${ary_num_anat[var_cnt_ses]})
  do

    # Path of source image (PD image to be registered).
    strPthSrc="${strPthIn}${idx_ses_id}/01_in/${str_sub_id}_${idx_ses_id}_PD_${idx_num_anat}"

    # Path of brain mask for current PD image:
    strPthSrfMsk="${str_anly_path}${str_sub_id}/04_anat/pd_brain_masks/${str_sub_id}_${idx_ses_id}_PD_${idx_num_anat}_mask"

    # Path for transformation matrix:
    strPthMat="${strPthIn}${idx_ses_id}/01_in/${str_sub_id}_${idx_ses_id}_PD_${idx_num_anat}_to_${str_sub_id}_${idx_ses_id}_PD_01_mat"

    # Path of registered image:
    strPthReg="${strPthOut}${idx_ses_id}/03_reg_PD/${str_sub_id}_${idx_ses_id}_PD_${idx_num_anat}"

    # Calculate transformation matrix:
    flirt \
    -cost normcorr \
    -searchcost normcorr \
    -interp trilinear \
    -bins 256 \
    -dof 6 \
    -minsampling 0.7 \
    -ref ${strPthRef} \
    -refweight ${strPthRefMsk} \
    -in ${strPthSrc} \
    -inweight ${strPthSrfMsk} \
    -omat ${strPthMat}

    # Apply transformation matrix:
    flirt \
    -interp trilinear \
    -in ${strPthSrc} \
    -ref ${strPthRef} \
    -applyxfm -init ${strPthMat} \
    -out ${strPthReg}

  done

  # Register short inversion T1 image (one per session).

  # Path of source image (PD image to be registered).
  strPthSrc="${strPthIn}${idx_ses_id}/01_in/${str_sub_id}_${idx_ses_id}_T1w_si"

  # Path of brain mask for current PD image:
  strPthSrfMsk="${str_anly_path}${str_sub_id}/04_anat/pd_brain_masks/${str_sub_id}_${idx_ses_id}_T1w_si_mask"

  # Path for transformation matrix:
  strPthMat="${strPthIn}${idx_ses_id}/01_in/${str_sub_id}_${idx_ses_id}_T1w_si_${idx_num_anat}_to_${str_sub_id}_${idx_ses_id}_PD_01_mat"

  # Path of registered image:
  strPthReg="${strPthOut}${idx_ses_id}/03_reg_PD/${str_sub_id}_${idx_ses_id}_T1w_si"

  # Calculate transformation matrix:
  flirt \
  -cost corratio \
  -searchcost corratio \
  -interp trilinear \
  -bins 256 \
  -dof 6 \
  -minsampling 0.7 \
  -ref ${strPthRef} \
  -refweight ${strPthRefMsk} \
  -in ${strPthSrc} \
  -inweight ${strPthSrfMsk} \
  -omat ${strPthMat}

  # Apply transformation matrix:
  flirt \
  -interp trilinear \
  -in ${strPthSrc} \
  -ref ${strPthRef} \
  -applyxfm -init ${strPthMat} \
  -out ${strPthReg}

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------
