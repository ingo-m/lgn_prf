#!/bin/bash


###############################################################################
# Copy results of SPM bias field correction, and remove redundant files.      #
###############################################################################


#------------------------------------------------------------------------------
# *** Define parameters:

# Input directory:
strPthIn="${str_data_path}derivatives/${str_sub_id}/anat/02_spm_bf_correction/"

# Output directory basename ("ses-01"):
strPthOut="${str_data_path}derivatives/${str_sub_id}/anat/03_reg_within_sess/"

# In order to select the correct files for further processing and removal, we
# need the original input file names. To get them, we simply cd into the
# respective directory. Path of original input directory of anatomy pipeline:
strPathOrig="${str_data_path}derivatives/${str_sub_id}/anat/01_orig/"

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_anat <<< "$str_num_anat"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy files for further processing

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Copy T1 image (only one pre session).

  # Path and file name of bias-corrected image (SPM prepends an "m"):
  strTmpIn="${strPthIn}m${str_sub_id}_${idx_ses_id}_T1w_si"

  strTmpOut="${strPthOut}${idx_ses_id}/01_in/${str_sub_id}_${idx_ses_id}_T1w_si"

  fslchfiletype NIFTI_GZ ${strTmpIn} ${strTmpOut}

  # Loop through PD images (e.g. "01"); i.e. zero filled indices ("01", "02",
  # etc.). Note that the number of PD images may not be identical throughout
  # sessions.
	for idx_num_anat in $(seq -f "%02g" 1 ${ary_num_anat[var_cnt_ses]})
  do

    # Input path for current PD image:
    strTmpIn="${strPthIn}m${str_sub_id}_${idx_ses_id}_PD_${idx_num_anat}"

    # Output path for current PD image:
    strTmpOut="${strPthOut}${idx_ses_id}/01_in/${str_sub_id}_${idx_ses_id}_PD_${idx_num_anat}"

  fslchfiletype NIFTI_GZ ${strTmpIn} ${strTmpOut}

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

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
aryRm=( $(ls | grep '\<m.*.nii\>') )

# Loop through files:
for strTmp in ${aryRm[@]}
do
  rm ${strTmp}
done

# cd back to original directory:
cd "${strPathPwd}"
#------------------------------------------------------------------------------
