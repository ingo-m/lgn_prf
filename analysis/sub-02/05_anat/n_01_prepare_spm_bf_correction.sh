#!/bin/bash


###############################################################################
# Copy input files for SPM bias field correction.                             #
###############################################################################


#------------------------------------------------------------------------------
# *** Define parameters:

# Input directory:
strPathIn="${str_data_path}derivatives/${str_sub_id}/anat/01_orig/"

# Output directory:
strPthOut="${str_data_path}derivatives/${str_sub_id}/anat/02_spm_bf_correction/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy files

# To prevent problems in case of empty target directory:
shopt -s nullglob

# Save original path in order to cd back to this path in the end:
strPathPwd=( $(pwd) )

# cd into input directory:
cd ${strPathIn}

# Get names of all input files:
aryIn=(*)

# Loop through files:
for strTmp in ${aryIn[@]}
do
	# Input file:
  strTmpPthIn="${strPathIn}${strTmp}"

  # Output file:
  strTmpPthOut="${strPthOut}${strTmp}"

  # Change file type to nii (uncompressed):
  fslchfiletype NIFTI ${strTmpPthIn} ${strTmpPthOut}
done

# cd back to original directory:
cd "${strPathPwd}"
#------------------------------------------------------------------------------
