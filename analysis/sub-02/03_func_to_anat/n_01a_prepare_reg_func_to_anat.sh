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

# Basepath of anatomical directory (followed by session ID, e.g. "ses-01").
strPthAnat="${str_data_path}derivatives/${str_sub_id}/anat/03_reg_within_sess/"

# Location of masks for T1 image(within analysis folder):
strPthMskT1="${str_data_path}analysis/${str_sub_id}/03_func_to_anat/"

# Target directory basepath (followed by session ID, e.g. "ses-01").
strPthSpm="${str_data_path}derivatives/${str_sub_id}/reg_func_to_anat/"




#------------------------------------------------------------------------------
str_anly_path="/home/john/PhD/GitLab/lgn_prf/analysis/"
str_data_path="/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/"


#------------------------------------------------------------------------------
# ### Apply mask to anatomical images

echo "------Apply mask to anatomical images"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Input path of short inversion T1 weighted image:
  strPthT1="${strPthAnat}${idx_ses_id}/03_reg_PD/${str_sub_id}_${idx_ses_id}_T1w_si"

  # Path of mask for T1 weighted image:
  strPthMskTmp="${strPthMskT1}n_01b_${str_sub_id}_${idx_ses_id}_PD_reg_mask"

  # Target path for masked anatomcial image:
  strPthTrgt="${strPthSpm}${idx_ses_id}/anat/${str_sub_id}_${idx_ses_id}_T1w_si"

  # Apply mask:
  fslmaths ${strPthT1} -mul ${strPthMskTmp} ${strPthTrgt}

  # Change filetype to uncompressed nii:
  fslchfiletype NIFTI ${strPthTrgt} ${strPthTrgt}

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Apply mask to mean functional images

echo "------Apply mask to mean functional images"




for image

/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/func_reg_across_runs_tsnr/sub-02_ses-01_mean.nii.gz

apply mask

/home/john/PhD/GitLab/lgn_prf/analysis/sub-02/01_preprocessing/n_09c_spm_moco_refweight_sub-02_ses-01.nii.gz

save to

/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/reg_func_to_anat/ses-01/mask_func
/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/reg_func_to_anat/ses-01/mean_func

for images

/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/func_reg_across_runs/sub-02_ses-01_run_01.nii.gz

savefiletype and save to

/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/reg_func_to_anat/ses-01/run_01
