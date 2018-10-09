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


#------------------------------------------------------------------------------
# ### Get data

#echo "---Automatic: Prepare directory tree"
#source ${strPathPrnt}00_get_data/n_01_sh_create_folders.sh

#if ${bool_from_bids};
#then
#	echo "---Skipping DICOM to nii conversion (will look for BIDS data)."
#else
#	echo "---Automatic: DICOM to nii conversion."
#	source ${strPathPrnt}00_get_data/n_02_sh_dcm2nii.sh
#
#	echo "---Automatic: Rename nii images (remove `_e1` suffix)."
#	python ${strPathPrnt}00_get_data/n_03_py_rename.py
#
#	if ${bool_wait};
#	then
#		echo "---Manual:"
#		echo "   Adjust file names in"
#                echo "   ${strPathPrnt}00_get_data/n_04_sh_export_nii_to_bids.sh"
#		echo "   and in"
#                echo "   ${strPathPrnt}00_get_data/n_05_sh_export_json_to_bids.sh"
#		echo "   Type 'go' to continue"
#		read -r -s -d $'g'
#		read -r -s -d $'o'
#		date
#	else
#		:
#	fi
#fi

#if ${bool_from_bids};
#then
#	:
#else
#	echo "---Automatic: Export nii to bids."
#	source ${strPathPrnt}00_get_data/n_04_sh_export_nii_to_bids.sh
#fi
#
#if ${bool_from_bids};
#then
#	:
#else
#	echo "---Automatic: Export json metadata to bids."
#	source ${strPathPrnt}00_get_data/n_05_sh_export_json_to_bids.sh
#fi
#
#if ${bool_from_bids};
#then
#	:
#else
#	echo "---Automatic: Deface nii data in bids folder."
#	python ${strPathPrnt}00_get_data/n_06_py_deface.py
#fi

#echo "---Automatic: Import nii data from bids."
#source ${strPathPrnt}00_get_data/n_07_sh_import_from_bids.sh
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Preprocessing

#echo "---Automatic: Reverse order of opposite PE images"
#python ${strPathPrnt}01_preprocessing/n_01_py_inverse_order_func_op.py
#date

#echo "---Automatic: Prepare within-run SPM motion correction"
#source ${strPathPrnt}01_preprocessing/n_02a_sh_prepare_moco.sh
#source ${strPathPrnt}01_preprocessing/n_02b_sh_prepare_moco_op.sh
#date

## The within-run motion correction can be parallelised (several runs at the
## same time).
#echo "---Automatic: Run within-run SPM motion correction on functional data"
#source ${strPathPrnt}01_preprocessing/n_03a_spm_moco_parallel.sh
#date

#echo "---Automatic: Run within-run SPM motion correction on opposite-phase polarity data"
## matlab -nodisplay -nojvm -nosplash -nodesktop \
##   -r "run('....m');"
#/opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${str_anly_path}${str_sub_id}/01_preprocessing/n_03c_spm_create_moco_batch_op.m
#date

#echo "---Automatic: Copy moco results"
#source ${strPathPrnt}01_preprocessing/n_04a_sh_postprocess_moco.sh
#date

#echo "---Automatic: Copy moco results of opposite phase encoding images"
#source ${strPathPrnt}01_preprocessing/n_04b_sh_postprocess_moco_op.sh
#date

#echo "---Automatic: Calculate tSNR maps before distortion correction."
#source ${strPathPrnt}01_preprocessing/n_05_sh_tSNR.sh
#date

#echo "---Automatic: Calculate fieldmaps"
#source ${strPathPrnt}01_preprocessing/n_06a_sh_fsl_topup.sh
#date

#echo "---Automatic: Apply TOPUP on functional data"
#source ${strPathPrnt}01_preprocessing/n_07a_fsl_applytopup.sh
#date

#echo "---Automatic: Prepare within-session, across-runs motion correction."
#source ${strPathPrnt}01_preprocessing/n_08_sh_prepare_moco.sh
#date

#if ${bool_wait};
#then
#  echo "---Manual:"
#  echo "   Reference weights for SPM motion correction, and place them at"
#  echo "   ${strPathPrnt}01_preprocessing/n_09c_spm_moco_refweight_${str_sub_id}_ses-01.nii.gz"
#  echo "   ${strPathPrnt}01_preprocessing/n_09c_spm_moco_refweight_${str_sub_id}_ses-02.nii.gz"
#  echo "   ${strPathPrnt}01_preprocessing/n_09c_spm_moco_refweight_${str_sub_id}_ses-03.nii.gz"
#  echo "   ..."
#  echo "   Type 'go' to continue"
#  read -r -s -d $'g'
#  read -r -s -d $'o'
#  date
#else
#  :
#fi

## Loop through sessions and copy reference weights:
#echo "---Automatic: Copy reference weights for motion correction."
#for idx_ses_id in ${ary_ses_id[@]}
#do
#  fslchfiletype NIFTI \
#  ${strPathPrnt}01_preprocessing/n_09c_spm_moco_refweight_${str_sub_id}_${idx_ses_id} \
#  ${str_data_path}derivatives/${str_sub_id}/reg_across_runs/${idx_ses_id}/ref_weighting/refweight_${str_sub_id}_${idx_ses_id}
#done

#echo "---Automatic: Within-session, across-runs motion correction."
#source ${strPathPrnt}01_preprocessing/n_09a_spm_moco_parallel.sh
#date

#echo "---Automatic: Postprocess within-session, across-runs motion correction."
#source ${strPathPrnt}01_preprocessing/n_10_sh_postprocess_moco.sh
#date

#echo "---Automatic: Calculate tSNR maps."
#source ${strPathPrnt}01_preprocessing/n_11_sh_tSNR.sh
#date
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Register anatomy within session

#echo "---Automatic: Prepare SPM bias field correction"
#source ${strPathPrnt}02_anat/n_01_prepare_spm_bf_correction.sh
#date

#echo "---Automatic: SPM bias field correction"
#/opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${strPathPrnt}02_anat/n_02_spm_bf_correction.m
#date

#echo "---Automatic: Postprocess bias field corrected data"
#source ${strPathPrnt}02_anat/n_03_postprocess_spm_bf_correction.sh
#date

#if ${bool_wait};
#then
#  echo "---Manual:"
#  echo "   Prepare brain masks for all proton density images and place them at"
#  echo "   ${strPathPrnt}02_anat/pd_brain_masks/${str_sub_id}_ses-01_PD_01"
#  echo "   ${strPathPrnt}02_anat/pd_brain_masks/${str_sub_id}_ses-01_PD_02"
#  echo "   ..."
#  echo "   Type 'go' to continue"
#  read -r -s -d $'g'
#  read -r -s -d $'o'
#  date
#else
#  :
#fi

#echo "---Automatic: Register proton density images within sessions"
#source ${strPathPrnt}02_anat/n_04_reg_PDs_within_ses.sh
#date

#echo "---Automatic: Create within-session mean proton density image"
#source ${strPathPrnt}02_anat/n_05_PD_within_ses_mean.sh
#date

#echo "---Automatic: Move anatomical images"
#source ${strPathPrnt}02_anat/n_06_move_anat.sh
#date

#echo "---Automatic: Prepare SPM bias field correction (within session mean PD)"
#source ${strPathPrnt}02_anat/n_07_prepare_spm_bf_correction.sh
#date

#echo "---Automatic: SPM bias field correction (within session mean PD)"
#/opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${strPathPrnt}02_anat/n_08_spm_bf_correction.m
#date

#echo "---Automatic: Postprocess bias field corrected data"
#source ${strPathPrnt}02_anat/n_09_postprocess_spm_bf_correction.sh
#date
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Register functional to anatomy within session

## Manual mask creation for anatomical images.
#if ${bool_wait};
#then
#  echo "---Manual:"
#
#  echo "   Prepare registration masks for all proton density images. The masks"
#  echo "   should cover the field of view of the functional images, plus some"
#  echo "   margin (especially in anterior & posterior directions). Regions"
#  echo "   with bad signal (e.g. ventral end of FOV), may be leaft out. Place"
#  echo "   the masks at:"
#  echo "   ${strPathPrnt}03_func_to_anat/n_01b_${str_sub_id}_ses-01_PD_reg_mask"
#  echo "   ${strPathPrnt}03_func_to_anat/n_01b_${str_sub_id}_ses-02_PD_reg_mask"
#  echo "   ${strPathPrnt}03_func_to_anat/n_01b_${str_sub_id}_ses-03_PD_reg_mask"
#  echo "   ..."
#  echo "   Type 'go' to continue"
#  read -r -s -d $'g'
#  read -r -s -d $'o'
#  date
#else
#  :
#fi

#echo "---Automatic: Prepare registration functional to anatomy"
#source ${strPathPrnt}03_func_to_anat/n_01a_prepare_reg_func_to_anat.sh
#date

echo "---Automatic: Registration functional to anatomy (SPM)"
source ${strPathPrnt}03_func_to_anat/n_02a_spm_corr_parallel.sh
date

#echo "---Automatic: Postprocess registration results"
#source ${strPathPrnt}03_func_to_anat/n_03_sh_postprocess_reg.sh
#date
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Across-session registration

# Manual mask creation for anatomical images (within-session mean PD images).
#if ${bool_wait};
#then
#  echo "---Manual:"
#
#  echo "   Prepare registration masks for all proton density images. The masks"
#  echo "   should cover the field of view of the functional images, plus some"
#  echo "   margin (especially in anterior & posterior directions). Regions"
#  echo "   with bad signal (e.g. ventral end of FOV), may be leaft out. Place"
#  echo "   the masks at:"
#  echo "   ${strPathPrnt}04_reg_across_ses/n_01b_${str_sub_id}_ses-01_PD_reg_mask"
#  echo "   ${strPathPrnt}04_reg_across_ses/n_01b_${str_sub_id}_ses-02_PD_reg_mask"
#  echo "   ${strPathPrnt}04_reg_across_ses/n_01b_${str_sub_id}_ses-03_PD_reg_mask"
#  echo "   ..."
#  echo "   Type 'go' to continue"
#  read -r -s -d $'g'
#  read -r -s -d $'o'
#  date
#else
#  :
#fi

#echo "---Automatic: Prepare across-sessions registration"
#source ${strPathPrnt}04_reg_across_ses/n_01a_prepare_reg_func_to_anat.sh
#date

#echo "---Automatic: Across-sessions registration"
#source ${strPathPrnt}04_reg_across_ses/n_02a_spm_corr_parallel.sh
#date

#echo "---Automatic: Postprocess results from across sessions registration"
#source ${strPathPrnt}04_reg_across_ses/n_03_sh_postprocess_reg.sh
#date

#echo "---Automatic: Copy images from reference session"
#source ${strPathPrnt}04_reg_across_ses/n_04_sh_copy_reference_session.sh
#date

#echo "---Automatic: Calculate tSNR maps"
#source ${strPathPrnt}04_reg_across_ses/n_05_sh_tSNR.sh
#date

#echo "---Automatic: Calculate spatial correlation."
#python ${strPathPrnt}04_reg_across_ses/n_06_py_spatial_correlation.py
#date
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# ### FSL FEAT (temporal filtering)

#echo "---Automatic: FSL FEAT (temporal filtering)."
#source ${strPathPrnt}05_feat/n_01_feat_level_1_script_parallel.sh
#date
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
