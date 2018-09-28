#!/bin/bash


###############################################################################
# Metascript for the LGN pRF analysis pipeline.                               #
###############################################################################


#------------------------------------------------------------------------------
# ### Get data

# Analysis parent directory, e.g.:
# "/home/john/PhD/GitLab/lgn_prf/analysis/" + "sub-02" + "/"
strPathPrnt="${str_anly_path}${str_sub_id}/"

 echo "-LGN pRF Analysis Pipleline --- ${str_sub_id}"
 date

 echo "---Automatic: Prepare directory tree"
 source ${strPathPrnt}00_get_data/n_01_sh_create_folders.sh

if ${bool_from_bids};
then
	echo "---Skipping DICOM to nii conversion (will look for BIDS data)."
else
	echo "---Automatic: DICOM to nii conversion."
	source ${strPathPrnt}00_get_data/n_02_sh_dcm2nii.sh

	if ${pacman_wait};
	then
		echo "---Manual:"
		echo "   Adjust file names in"
                echo "   ${strPathPrnt}00_get_data/n_03_sh_export_nii_to_bids.sh"
		echo "   and in"
                echo "   ${strPathPrnt}00_get_data/n_04_sh_export_json_to_bids.sh"
		echo "   Type 'go' to continue"
		read -r -s -d $'g'
		read -r -s -d $'o'
		date
	else
		:
	fi
fi

if ${bool_from_bids};
then
	:
else
	echo "---Automatic: Export nii to bids."
	source ${strPathPrnt}00_get_data/n_03_sh_export_nii_to_bids.sh
fi

if ${bool_from_bids};
then
	:
else
	echo "---Automatic: Export json metadata to bids."
	source ${strPathPrnt}00_get_data/n_04_sh_export_json_to_bids.sh
fi
#
# # if ${bool_from_bids};
# # then
# # 	:
# # else
# # 	echo "---Automatic: Deface nii data in bids folder."
# # 	python ${strPathPrnt}00_get_data/n_05_py_deface.py
# # fi
#
# echo "---Automatic: Import nii data from bids."
# source ${strPathPrnt}00_get_data/n_06_sh_import_from_bids.sh
# #-------------------------------------------------------------------------------


# #-------------------------------------------------------------------------------
# # ### Preprocessing
#
# echo "---Automatic: Reverse order of opposite PE images"
# python ${strPathPrnt}01_preprocessing/n_01_py_inverse_order_func_op.py
# date
#
# echo "---Automatic: Prepare moco of opposite phase encoding EPI images"
# source ${strPathPrnt}01_preprocessing/n_02a_sh_prepare_moco.sh
# source ${strPathPrnt}01_preprocessing/n_02b_sh_prepare_moco.sh
# date
#
# echo "---Automatic: Prepare moco"
# source ${strPathPrnt}01_preprocessing/n_02c_sh_prepare_moco.sh
# date
#
# if ${pacman_wait};
# then
# 	echo "---Manual:"
# 	echo "   Prepare reference weights for motion correction of functional"
# 	echo "   data and opposite-phase polarity data (based on SE EPI images,"
# 	echo "   i.e. ~/func_distcor/run_00 and ~/func_distcor_op/run_00) and place"
# 	echo "   them at:"
# 	echo "       ${str_anly_path}${str_sub_id}/01_preprocessing/n_03b_${str_sub_id}_spm_refweight.nii.gz"
# 	echo "   and"
# 	echo "       ${str_anly_path}${str_sub_id}/01_preprocessing/n_03d_${str_sub_id}_spm_refweight_op.nii.gz"
# 	echo "   Type 'go' to continue"
# 	read -r -s -d $'g'
# 	read -r -s -d $'o'
# 	date
# else
# 	:
# fi
#
# # Copy reference weight to spm directory:
# fslchfiletype \
#    NIFTI \
#    ${str_anly_path}${str_sub_id}/01_preprocessing/n_03b_${str_sub_id}_spm_refweight \
#    ${pacman_data_path}${str_sub_id}/nii/spm_reg/ref_weighting/n_03b_${str_sub_id}_spm_refweight
#
# # Copy reference weight for opposite-phase encoding data to spm directory:
# fslchfiletype \
#    NIFTI \
#    ${str_anly_path}${str_sub_id}/01_preprocessing/n_03d_${str_sub_id}_spm_refweight_op \
#    ${pacman_data_path}${str_sub_id}/nii/spm_reg_op/ref_weighting/n_03d_${str_sub_id}_spm_refweight_op
#
# echo "---Automatic: Run SPM motion correction on functional data"
# # matlab -nodisplay -nojvm -nosplash -nodesktop \
# #   -r "run('/home/john/PhD/GitHub/PacMan/analysis/20180118_distcor_func/01_preprocessing/n_06a_spm_create_moco_batch.m');"
# /opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${str_anly_path}${str_sub_id}/01_preprocessing/n_03a_spm_create_moco_batch.m
# date
#
# echo "---Automatic: Run SPM motion correction on opposite-phase polarity data"
# # matlab -nodisplay -nojvm -nosplash -nodesktop \
# #   -r "run('/home/john/PhD/GitHub/PacMan/analysis/20180118_distcor_func/01_preprocessing/n_06c_spm_create_moco_batch_op.m');"
# /opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${str_anly_path}${str_sub_id}/01_preprocessing/n_03c_spm_create_moco_batch_op.m
# date
#
# echo "---Automatic: Copy moco results"
# source ${strPathPrnt}01_preprocessing/n_04a_sh_postprocess_moco.sh
# date
#
# echo "---Automatic: Copy moco results of distcor EPI images"
# source ${strPathPrnt}01_preprocessing/n_04b_sh_postprocess_moco.sh
# date
#
# echo "---Automatic: Copy moco results of opposite-phase polarity distcor EPI images"
# source ${strPathPrnt}01_preprocessing/n_04c_sh_postprocess_moco.sh
# date
#
#echo "---Automatic: Calculate fieldmaps"
#source ${strPathPrnt}01_preprocessing/n_05a_sh_fsl_topup.sh
#date
#
#echo "---Automatic: Apply TOPUP on functional data"
#source ${strPathPrnt}01_preprocessing/n_06a_fsl_applytopup.sh
#date
#
#echo "---Automatic: Apply TOPUP on distcor EPI data"
#source ${strPathPrnt}01_preprocessing/n_06b_fsl_applytopup.sh
#date
#
#echo "---Automatic: Create mean undistorted distcor EPI image."
#source ${strPathPrnt}01_preprocessing/n_07_sh_mean_se.sh
#date
##-------------------------------------------------------------------------------
#
#
##-------------------------------------------------------------------------------
## ### First level FEAT
#
#echo "---Automatic: 1st level FSL FEAT."
#source ${strPathPrnt}02_feat/n_01_feat_level_1_script_parallel.sh
#date
##-------------------------------------------------------------------------------
#
#
##-------------------------------------------------------------------------------
## ### Intermediate steps
#
#
#echo "---Automatic: Calculate tSNR maps."
#source ${strPathPrnt}03_intermediate_steps/n_01_sh_tSNR.sh
#date
#
#echo "---Automatic: Update FEAT directories (dummy registration)."
#source ${strPathPrnt}03_intermediate_steps/n_02a_sh_fsl_updatefeatreg.sh
#date
#
#echo "---Automatic: Calculate spatial correlation."
#python ${strPathPrnt}03_intermediate_steps/n_12_py_spatial_correlation.py
#date
##-------------------------------------------------------------------------------
#
#
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


# #-------------------------------------------------------------------------------
# # ### MP2RAGE
#
# echo "---Automatic: Copy input files for SPM bias field correction."
# source ${strPathPrnt}06_mp2rage/n_01_prepare_spm_bf_correction.sh
# date
#
# echo "---Automatic: SPM bias field correction."
# #matlab -nodisplay -nojvm -nosplash -nodesktop \
# #	-r "run('/home/john/PhD/GitHub/PacMan/analysis/20180118_distcor_func/06_mp2rage/n_02_spm_bf_correction.m');"
# /opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${str_anly_path}${str_sub_id}/06_mp2rage/n_02_spm_bf_correction.m
# date
#
# echo "---Automatic: Copy results of SPM bias field correction, and remove"
# echo "   redundant files."
# source ${strPathPrnt}06_mp2rage/n_03_postprocess_spm_bf_correction.sh
# date
#
# if ${pacman_wait};
# then
# 	echo "---Manual:"
# 	cat ${strPathPrnt}06_mp2rage/n_04a_info_brainmask.txt
# 	echo " "
# 	echo "   Place the brain mask in the following folder:"
# 	echo "   ${strPathPrnt}06_mp2rage/n_04b_${str_sub_id}_pwd_brainmask.nii.gz"
# 	echo " "
# 	echo "   Type 'go' to continue"
# 	read -r -s -d $'g'
# 	read -r -s -d $'o'
# 	date
# else
# 	:
# fi
#
# # Copy brain mask into data directory:
# cp ${str_anly_path}${str_sub_id}/06_mp2rage/n_04b_${str_sub_id}_pwd_brainmask.nii.gz \
#    ${pacman_data_path}${str_sub_id}/nii/mp2rage/03_reg/02_brainmask/
#
# echo "---Automatic: Upsample & smooth mean EPI before MP2RAGE registration."
# source ${strPathPrnt}06_mp2rage/n_05_prepare_mean_epi.sh
# date
#
# echo "---Automatic: Prepare MP2RAGE to combined mean registration pipeline."
# source ${strPathPrnt}06_mp2rage/n_06_sh_prepare_reg.sh
# date
#
# echo "---Automatic: Register MP2RAGE image to mean EPI"
# #matlab -nodisplay -nojvm -nosplash -nodesktop \
# #	-r "run('/home/john/PhD/GitHub/PacMan/analysis/20180118_distcor_func/06_mp2rage/n_07_spm_create_corr_batch_prereg.m');"
# /opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${str_anly_path}${str_sub_id}/06_mp2rage/n_07_spm_create_corr_batch_prereg.m
# date
#
# echo "---Automatic: Postprocess SPM registration results."
# source ${strPathPrnt}06_mp2rage/n_08_sh_postprocess_spm_prereg.sh
# date
#
# echo "---Automatic: Prepare BBR."
# python ${strPathPrnt}06_mp2rage/n_09_py_prepare_bbr.py
# date
#
# echo "---Automatic: Perform BBR."
# source ${strPathPrnt}06_mp2rage/n_10_sh_bbr.sh
# date
#
# echo "---Automatic: Copy BBR results for segmentation."
# source ${strPathPrnt}06_mp2rage/n_11_copy.sh
# date
#
# echo "---Manual:"
# echo "   (1) Tissue type segmentation."
# echo "   (2) Cortical depth sampling."
#
# echo "-Done"
# #-------------------------------------------------------------------------------
