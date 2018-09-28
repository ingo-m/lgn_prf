#!/bin/bash


###############################################################################
# Import data from BIDS folder structure into LGN pRF analysis pipeline.      #
###############################################################################


#------------------------------------------------------------------------------
# *** Define paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"

# BIDS source directory for this subject, e.g.
# "/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/" + "bids/" + "sub-01".
str_bids="${str_data_path}bids/${str_sub_id}/"

# Target directory, e.g.
# "/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/" + "derivatives/" + "sub-01".
# Folder (e.g. "func/") still needs to be appended.
str_trgt="${str_data_path}derivatives/${str_sub_id}/"
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# *** Copy functional data

# Loop through sessions (e.g. "ses-01", "ses-02", etc.).
for idx_ses_id in ${ary_ses_id[@]}
do
  cp -r ${str_bids}${idx_ses_id}/func/*.nii.gz ${str_trgt}func/
done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy opposite-phase-polarity images

# Loop through sessions (e.g. "ses-01", "ses-02", etc.).
for idx_ses_id in ${ary_ses_id[@]}
do
  cp -r ${str_bids}${idx_ses_id}/func_op/*.nii.gz ${str_trgt}func_op/
done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy anatomical images

# Loop through sessions (e.g. "ses-01", "ses-02", etc.).
for idx_ses_id in ${ary_ses_id[@]}
do
  cp -r ${str_bids}${idx_ses_id}/anat/*.nii.gz ${str_trgt}anat/01_orig/
done
#------------------------------------------------------------------------------
