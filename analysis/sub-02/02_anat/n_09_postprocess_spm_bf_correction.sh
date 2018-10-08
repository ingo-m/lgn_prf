#!/bin/bash


###############################################################################
# Copy results of SPM bias field correction, and remove redundant files.      #
###############################################################################


#------------------------------------------------------------------------------
# *** Define parameters:

# Input directory:
strPthIn="${str_data_path}derivatives/${str_sub_id}/anat/05_spm_bf_correction/"

# Output directory basename (child directories: "ses-01", "ses-02", etc.):
strPthOut="${str_data_path}derivatives/${str_sub_id}/anat/06_intermediate/"

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_anat <<< "$str_num_anat"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy files for further processing

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Copy T1 image.

  # Path and file name of bias-corrected image (SPM prepends an "m"):
  strTmpIn="${strPthIn}m${str_sub_id}_${idx_ses_id}_T1w_si"

  strTmpOut="${strPthOut}${str_sub_id}_${idx_ses_id}_T1w_si"

  fslchfiletype NIFTI_GZ ${strTmpIn} ${strTmpOut}

  # Copy PD image.

  # Path and file name of bias-corrected image (SPM prepends an "m"):
  strTmpIn="${strPthIn}m${str_sub_id}_${idx_ses_id}_PD"

  strTmpOut="${strPthOut}${str_sub_id}_${idx_ses_id}_PD"

  fslchfiletype NIFTI_GZ ${strTmpIn} ${strTmpOut}

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Remove redundant files

# cd into target directory and create list of images to be removed:
cd "${strPthIn}"

# First list of files to be removed:
aryRm=( $(ls | grep '\<c.*.nii\>') )

# Loop through files:
for strTmp in ${aryRm[@]}
do
  rm ${strTmp}
done

# Second list of files to be removed:
aryRm=( $(ls | grep '\<s.*.nii\>') )

# Loop through files:
for strTmp in ${aryRm[@]}
do
  rm ${strTmp}
done

# Third list of files to be removed:
aryRm=( $(ls | grep '\<m.*.nii\>') )

# Loop through files:
for strTmp in ${aryRm[@]}
do
  rm ${strTmp}
done

# cd back to original directory:
cd "${strPathPwd}"
#------------------------------------------------------------------------------
