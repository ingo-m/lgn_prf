#!/bin/bash


###############################################################################
# Copy input files for SPM bias field correction.                             #
###############################################################################


#------------------------------------------------------------------------------
# *** Define parameters:

# Input directory:
strPathIn="${str_data_path}derivatives/${str_sub_id}/01_orig/"

# Output directory:
strPthOut="${str_data_path}derivatives/${str_sub_id}/02_spm_bf_correction/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy files

# To prevent problems in case of empty target directory:
shopt -s nullglob

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
#------------------------------------------------------------------------------
