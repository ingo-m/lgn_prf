#!/bin/bash


###############################################################################
# Copy results of SPM bias field correction, and remove redundant files.      #
###############################################################################


#------------------------------------------------------------------------------
# *** Define parameters:

# Input directory:
strPthIn="${str_data_path}derivatives/${str_sub_id}/anat/02_spm_bf_correction/"

# Output directory:
strPthOut="${str_data_path}derivatives/${str_sub_id}/anat/03_sess_reg/01_in/"


# In order to select the correct files for further processing and removal, we
# need the original input file names. To get them, we simply cd into the
# respective directory. Path of original input directory of anatomy pipeline:
strPathOrig="${str_data_path}derivatives/${str_sub_id}/anat/01_orig/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy files for further processing

# To prevent problems in case of empty target directory:
shopt -s nullglob

# Save original path in order to cd back to this path in the end:
strPathPwd=( $(pwd) )

# cd into original input directory of anatomy pipeline:
cd ${strPathOrig}

# Get names of original input files:
aryIn=(*)

# Loop through files:
for strTmp in ${aryIn[@]}
do
  # Path and file name of bias-corrected image (SPM prepends an "m"):
  strTmpPthIn="${strPthIn}m${strTmp}"

  # Output file:
  strTmpPthOut="${strPthOut}${strTmp}"

  # Change file type to nii.gz & move image:
  fslchfiletype NIFTI_GZ ${strTmpPthIn} ${strTmpPthOut}
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
