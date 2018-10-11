#!/bin/bash


###############################################################################
# Prepare registration of anatomical images across sessions.                  #
###############################################################################


#------------------------------------------------------------------------------
# ### Define session IDs & paths

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Anatomical input directory:
strPthAnat="${str_data_path}derivatives/${str_sub_id}/anat/06_intermediate/"

# Location of masks for anatomical images (within analysis folder):
strPthMskPd="${str_anly_path}${str_sub_id}/04_reg_across_ses/"

# Location of functional time series:
strPthFnc="${str_data_path}derivatives/${str_sub_id}/func_reg_to_anat/"

# Target directory basepath (followed by session ID, e.g. "ses-01").
strPthSpm="${str_data_path}derivatives/${str_sub_id}/reg_across_ses/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Apply mask to anatomical images

echo "------Apply mask to anatomical images"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Proton density images.

  # Input path of anatomical image:
  strPthPwd="${strPthAnat}${str_sub_id}_${idx_ses_id}_PD"

  # Path of mask anatomical image:
  strPthMskTmp="${strPthMskPd}n_01b_${str_sub_id}_${idx_ses_id}_PD_reg_mask"

  # Path for masked anatomcial image (used as source image for registration):
  strPthSrc="${strPthSpm}${str_sub_id}_${idx_ses_id}_PD"

  # Apply mask:
  fslmaths ${strPthPwd} -mul ${strPthMskTmp} ${strPthSrc}

  # T1 images.

  # Input path of anatomical image:
  strPthT1="${strPthAnat}${str_sub_id}_${idx_ses_id}_T1w_si"

  # Path of mask anatomical image:
  strPthMskTmp="${strPthMskPd}n_01b_${str_sub_id}_${idx_ses_id}_PD_reg_mask"

  # Path for masked anatomcial image (used as source image for registration):
  strPthSrc="${strPthSpm}${str_sub_id}_${idx_ses_id}_T1w_si"

  # Apply mask:
  fslmaths ${strPthT1} -mul ${strPthMskTmp} ${strPthSrc}

done
#------------------------------------------------------------------------------
