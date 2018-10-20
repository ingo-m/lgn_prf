#!/bin/bash


###############################################################################
# Metascript for the LGN pRF analysis pipeline.                               #
###############################################################################


#------------------------------------------------------------------------------
# ### Preparations

echo "-LGN pRF Analysis Pipleline --- ${str_sub_id}"
date

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Analysis parent directory, e.g.:
# "/home/john/PhD/GitLab/lgn_prf/analysis/" + "sub-02" + "/"
strPathPrnt="${str_anly_path}${str_sub_id}/"
#------------------------------------------------------------------------------


# --- CUTOUT ---


echo "---Automatic: Register proton density images within sessions"
source ${strPathPrnt}03_anat/n_04_reg_PDs_within_ses.sh
date

echo "---Automatic: Create within-session mean proton density image"
source ${strPathPrnt}03_anat/n_05_PD_within_ses_mean.sh
date

echo "---Automatic: Move anatomical images"
source ${strPathPrnt}03_anat/n_06_move_anat.sh
date

echo "---Automatic: Prepare SPM bias field correction (within session mean PD)"
source ${strPathPrnt}03_anat/n_07_prepare_spm_bf_correction.sh
date

echo "---Automatic: SPM bias field correction (within session mean PD)"
/opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${strPathPrnt}03_anat/n_08_spm_bf_correction.m
date

echo "---Automatic: Postprocess bias field corrected data"
source ${strPathPrnt}03_anat/n_09_postprocess_spm_bf_correction.sh
date
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Register functional to anatomy within session

# "B ..> C": Register first session functional to first session anatomical.

# Manual mask creation for anatomical images.
if ${bool_wait};
then
  echo "---Manual:"

  echo "   Prepare registration masks for all proton density images. The masks"
  echo "   should cover the field of view of the functional images, plus some"
  echo "   margin (especially in anterior & posterior directions). Regions"
  echo "   with bad signal (e.g. ventral end of FOV), may be leaft out. Place"
  echo "   the masks at:"
  echo "   ${strPathPrnt}04_func_to_anat/n_01b_${str_sub_id}_ses-01_PD_reg_mask"
  echo "   ..."
  echo "   Type 'go' to continue"
  read -r -s -d $'g'
  read -r -s -d $'o'
  date
else
  :
fi

# Manual mask creation for mean functional images (within-session mean).
if ${bool_wait};
then
  echo "---Manual:"

  echo "   Prepare registration masks for mean functional images (one per"
  echo "   session). Place the masks at:"
  echo "   ${strPathPrnt}04_func_to_anat/n_01c_spm_reg_mask_${str_sub_id}_ses-01"
  echo "   ..."
  echo "   Type 'go' to continue"
  read -r -s -d $'g'
  read -r -s -d $'o'
  date
else
  :
fi

echo "---Automatic: Prepare registration functional to anatomy"
source ${strPathPrnt}04_func_to_anat/n_01a_prepare_reg_func_to_anat.sh
date

# Manual mask creation for mean functional images (within-session mean).
if ${bool_wait};
then
  echo "---Manual:"

  echo "   Register the mean functional image of the first session:"
  echo "     ${str_data_path}derivatives/${str_sub_id}/reg_func_to_anat/ses-01/${str_sub_id}_ses-01_mean"
  echo "     ..."
  echo "   to the anatomical image:"
  echo "     ${str_data_path}derivatives/${str_sub_id}/reg_func_to_anat/ses-01/${str_sub_id}_ses-01_T1w_si"
  echo "   You may use itk-snap's registration utility (use cross-correlation"
  echo "   cost function, and try resolution schedule 2x, 1x. Save the"
  echo "   transformation matrix, and convert it to FSL convention using"
  echo "   the c3d_affine_tool, e.g.:"
  echo "     c3d_affine_tool"
  echo "     ~/sub-02_ses-01_itksnap_transform.mat"
  echo "     -info"
  echo "     -ref ~/sub-02_ses-01_T1w_si.nii.gz"
  echo "     -src ~/sub-02_ses-01_mean.nii.gz"
  echo "     -ras2fsl"
  echo "     -o ~/sub-02_ses-01_fsl_transform.mat"
  echo "   Place the FSL transformation matrices at:"
  echo "     ${strPathPrnt}04_func_to_anat/n_02_${str_sub_id}_ses-01_fsl_reg.mat"
  echo "   Alternatively, any other tool may be used to create the FSL "
  echo "   transformation matrix (but FSL FLIRT and SPM correg were found not"
  echo "   to be robust on the given data)."
  echo "   Type 'go' to continue"
  read -r -s -d $'g'
  read -r -s -d $'o'
  date
else
  :
fi
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Across-session registration

# Manual mask creation for anatomical images (within-session mean PD images).
if ${bool_wait};
then
  echo "---Manual:"

  echo "   Prepare registration masks for all proton density images. The masks"
  echo "   should cover the field of view of the functional images, plus some"
  echo "   margin (especially in anterior & posterior directions). Regions"
  echo "   with bad signal (e.g. ventral end of FOV), may be leaft out. Place"
  echo "   the masks at:"
  echo "   ${strPathPrnt}05_reg_across_ses/n_01b_${str_sub_id}_ses-01_PD_reg_mask"
  echo "   ${strPathPrnt}05_reg_across_ses/n_01b_${str_sub_id}_ses-02_PD_reg_mask"
  echo "   ${strPathPrnt}05_reg_across_ses/n_01b_${str_sub_id}_ses-03_PD_reg_mask"
  echo "   ..."
  echo "   Type 'go' to continue"
  read -r -s -d $'g'
  read -r -s -d $'o'
  date
else
  :
fi

echo "---Automatic: Prepare across-sessions registration"
source ${strPathPrnt}05_reg_across_ses/n_01a_prepare_reg_across_ses.sh
date

# Manual mask creation for mean functional images (within-session mean).
if ${bool_wait};
then
  echo "---Manual:"

  echo "   Register the mean functional images of the second and third (and"
  echo "   subsequent sessions if there are more) to the mean functional of"
  echo "   the first session. Reference (first session):"
  echo "     ${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs_tsnr/${str_sub_id}_ses-01_mean_smooth"
  echo "   Images to be registered:"
  echo "     ${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs_tsnr/${str_sub_id}_ses-02_mean_smooth"
  echo "     ${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs_tsnr/${str_sub_id}_ses-03_mean_smooth"
  echo "     ..."
  echo "   Use reference mask:"
  echo "     ${strPathPrnt}04_func_to_anat/n_01c_spm_reg_mask_${str_sub_id}_ses-01.nii.gz"
  echo "   You may use itk-snap's registration utility. Save the"
  echo "   transformation matrix, and convert it to FSL convention using"
  echo "   the c3d_affine_tool, e.g.:"

  echo "     c3d_affine_tool"
  echo "     ~/${str_sub_id}_ses-02_to_ses-01_itksnap_transform.mat"
  echo "     -info"
  echo "     -ref ~/${str_sub_id}_ses-01_mean_smooth.nii.gz"
  echo "     -src ~/${str_sub_id}_ses-02_mean_smooth.nii.gz"
  echo "     -ras2fsl"
  echo "     -o ~/${str_sub_id}_ses-02_to_ses-01_fsl_transform.mat"

  echo "   Place the FSL transformation matrices at:"
  echo "     ${strPathPrnt}05_reg_across_ses/n_02_${str_sub_id}_ses-02_to_ses-01_fsl_transform.mat"
  echo "     ${strPathPrnt}05_reg_across_ses/n_02_${str_sub_id}_ses-03_to_ses-01_fsl_transform.mat"
  echo "     ..."
  echo "   Alternatively, any other tool may be used to create the FSL "
  echo "   transformation matrix."
  echo "   Type 'go' to continue"
  read -r -s -d $'g'
  read -r -s -d $'o'
  date
else
  :
fi

echo "---Automatic: Apply across-runs registration on anatomical images."
source ${strPathPrnt}05_reg_across_ses/n_03_sh_reg_anat.sh
date

echo "---Automatic: Apply across-runs registration on functional images."
source ${strPathPrnt}05_reg_across_ses/n_04_sh_reg_func.sh
date

echo "---Automatic: Calculate tSNR maps"
source ${strPathPrnt}05_reg_across_ses/n_05_sh_tSNR.sh
date

if ${bool_wait};
then
  echo "---Manual:"
  echo "   Prepare mask within which to calculate spatial correlation (brain"
  echo "   mask or region of interest) and place it at:"
  echo "   ${strPathPrnt}05_reg_across_ses/n_06b_refweight_spatial_correlation.nii.gz"
  echo "   Type 'go' to continue"
  read -r -s -d $'g'
  read -r -s -d $'o'
  date
else
  :
fi

echo "---Automatic: Calculate spatial correlation."
python ${strPathPrnt}05_reg_across_ses/n_06a_py_spatial_correlation.py
date
#------------------------------------------------------------------------------


## #------------------------------------------------------------------------------
# # ### pRF analysis
#
# echo "---Automatic: Prepare pRF analysis."
# python ${strPathPrnt}07_pRF/01_py_prepare_prf.py
# source ${strPathPrnt}07_pRF/02a_prepare_pRF_config.sh
# date
#
# echo "---Automatic: Perform pRF analysis with pyprf"
# pyprf -config ${strPathPrnt}07_pRF/02b_pRF_config_sed.csv
# date
#
# echo "---Automatic: Upsample pRF results."
# source ${strPathPrnt}07_pRF/03_upsample_retinotopy.sh
# date
#
# echo "---Automatic: Calculate overlap between voxel pRFs and stimulus."
# python ${strPathPrnt}07_pRF/04_PacMan_pRF_overlap.py
# date
# #------------------------------------------------------------------------------
