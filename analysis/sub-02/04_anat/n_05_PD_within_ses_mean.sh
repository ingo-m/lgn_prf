#!/bin/bash


###############################################################################
# Create within-session mean PD image.                                        #
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

  # Counter that is used to divide the sum of all individual mean images by N
  # (within session):
  var_cnt_div=$((0))

  # Path of mean image to create:
  strPthMne="${strPthIn}${idx_ses_id}/04_mean_PD/${str_sub_id}_${idx_ses_id}_PD"

  # Path of first proton density image from session is the starting point.
  # Subsequent images are added.
  strPthFrst="${strPthIn}${idx_ses_id}/01_in/${str_sub_id}_${idx_ses_id}_PD_01"

  # Copy first PD image (from current session):
  cp ${strPthFrst}.nii.gz ${strPthMne}.nii.gz

  # Loop through PD images, starting from second image (e.g. "02"); i.e. zero
  # filled indices ("02", "03", etc.). Note that the number of PD images may
  # not be identical throughout sessions.
	for idx_num_anat in $(seq -f "%02g" 2 ${ary_num_anat[var_cnt_ses]})
  do

    # Path of current PD image.
    strPthSrc="${strPthIn}${idx_ses_id}/03_reg_PD/${str_sub_id}_${idx_ses_id}_PD_${idx_num_anat}"

    # Add PD image from current session:
    fslmaths ${strPthMne} -add ${strPthSrc} ${strPthMne}

    # Increment image counter:
  	var_cnt_div=$((var_cnt_div+1))

  done

  # Divide sum of images by N:
  fslmaths ${strPthMne} -div ${var_cnt_div} ${strPthMne}

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------
