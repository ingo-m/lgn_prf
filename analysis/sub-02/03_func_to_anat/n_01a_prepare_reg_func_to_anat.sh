#!/bin/bash


###############################################################################
# Prepare registration of mean functional images to anatomical images (within #
# sessions).                                                                  #
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

# Location of masks for T1 images (within analysis folder):
strPthMskT1="${str_anly_path}${str_sub_id}/03_func_to_anat/"

# Location of mean functional images (within session means):
strPthFncMne="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs_tsnr/"

# Location of masks for functional images (within analysis folder).
strPthMskFnc="${str_anly_path}${str_sub_id}/03_func_to_anat/"

# Location of functional time series:
# strPthFnc="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs/"

# Target directory basepath (followed by session ID, e.g. "ses-01").
strPthSpm="${str_data_path}derivatives/${str_sub_id}/reg_func_to_anat/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Apply mask to anatomical images

echo "------Apply mask to anatomical images"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Input path of short inversion T1 weighted image:
  strPthT1="${strPthAnat}${str_sub_id}_${idx_ses_id}_T1w_si"

  # Path of mask for T1 weighted image:
  strPthMskTmp="${strPthMskT1}n_01b_${str_sub_id}_${idx_ses_id}_PD_reg_mask"

  # Target path for masked anatomcial image:
  strPthTrgt="${strPthSpm}${idx_ses_id}/${str_sub_id}_${idx_ses_id}_T1w_si"

  # Apply mask:
  fslmaths ${strPthT1} -mul ${strPthMskTmp} ${strPthTrgt}

done
#------------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Smoothing

# Perform anisotropic diffusion based smoothing in order to enhance contrast
# between grey matter and white matter.

# Activate segmentator conda environment
source activate py_segmentator

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Path of within-session mean functional image:
  strPthTmp01="${strPthFncMne}${str_sub_id}_${idx_ses_id}_mean"

  # Perform smoothing:
  segmentator_filters \
      ${strPthTmp01}.nii.gz \
      --smoothing cCED \
      --nr_iterations 7 \
      --save_every 7

  # Rename output:
  mv -T ${strPthTmp01}*cCED*.nii.gz ${strPthTmp01}_smooth.nii.gz

done

# Switch back to default conda environment
source activate py_main
# -----------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Apply mask to mean functional images

echo "------Apply mask to mean functional images"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Path of within-session mean functional image:
  strPthTmp01="${strPthFncMne}${str_sub_id}_${idx_ses_id}_mean_smooth"

  # Mask for mean functional image:
  stPthTmp02="${strPthMskFnc}n_01c_spm_reg_mask_${str_sub_id}_${idx_ses_id}"

  # Binarised the mask (in case a non-binary reference weight is used).
  strPthTmp03="${strPthSpm}${idx_ses_id}/${str_sub_id}_${idx_ses_id}_mask"

  # Output path for masked mean functional image:
  strPthTmp04="${strPthSpm}${idx_ses_id}/${str_sub_id}_${idx_ses_id}_mean"

  # Binarise mask (necessary in case moco reference weight image is used):
  fslmaths ${stPthTmp02} -bin ${strPthTmp03}

  # Apply mask:
  fslmaths ${strPthTmp01} -mul ${strPthTmp03} ${strPthTmp04}

  # Remove mask (to avoid clutter):
  rm ${strPthTmp03}.nii.gz

done
#------------------------------------------------------------------------------
