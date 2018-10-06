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



#------------------------------------------------------------------------------
# ### Anatomy & across runs & session registration

#echo "---Automatic: Prepare SPM bias field correction"
#source ${strPathPrnt}04_anat/n_01_prepare_spm_bf_correction.sh

#echo "---Automatic: SPM bias field correction"
#/opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${strPathPrnt}04_anat/n_02_spm_bf_correction.m

echo "---Automatic: Postprocess bias field corrected data"
source ${strPathPrnt}04_anat/n_03_postprocess_spm_bf_correction.sh

if ${bool_wait};
then
  echo "---Manual:"
  echo "   Prepare brain masks for all proton density images and place them at"
  echo "   ${strPathPrnt}04_anat/pd_brain_masks/${str_sub_id}_ses-01_PD_01"
  echo "   ${strPathPrnt}04_anat/pd_brain_masks/${str_sub_id}_ses-01_PD_02"
  echo "   ..."
  echo "   Type 'go' to continue"
  read -r -s -d $'g'
  read -r -s -d $'o'
  date
else
  :
fi


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
