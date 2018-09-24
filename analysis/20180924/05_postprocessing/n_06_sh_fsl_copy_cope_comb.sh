#!/bin/bash


###############################################################################
# Copy and rename statistical maps.                                           #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

strPathParent01="${pacman_data_path}${pacman_sub_id}/nii/feat_level_2_comb/"

# Contrasts are coded as follows (sst = sustained, trn = transient):
#     cope  1: Pd_sst
#     cope  2: Cd_sst
#     cope  3: Ps_sst
#     cope  4: Pd_min_Cd_sst
#     cope  5: Pd_min_Ps_sst
#     cope  6: Cd_min_Ps_sst
#     cope  7: linear_sst
#     cope  8: Pd_min_Cd_Ps_sst
#     cope  9: Pd_trn
#     cope 10: Cd_trn
#     cope 11: Ps_trn
#     cope 12: Pd_min_Cd_trn
#     cope 13: Pd_min_Ps_trn
#     cope 14: Cd_min_Ps_trn
#     cope 15: linear_trn
#     cope 16: Pd_min_Cd_Ps_trn
#     cope 17: sst_min_trn

# Input (feat directories):
lstIn=(feat_level_2.gfeat/cope1.feat/stats/cope1.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope2.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope3.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope4.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope5.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope6.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope7.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope8.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope9.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope10.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope11.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope12.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope13.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope14.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope15.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope16.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/cope17.nii.gz)

# Output (file names):
lstOt=(Pd_sst \
       Cd_sst \
       Ps_sst \
       Pd_min_Cd_sst \
       Pd_min_Ps_sst \
       Cd_min_Ps_sst \
       Linear_sst \
       Pd_min_Cd_Ps_sst \
       Pd_trn \
       Cd_trn \
       Ps_trn \
       Pd_min_Cd_trn \
       Pd_min_Ps_trn \
       Cd_min_Ps_trn \
       Linear_trn \
       Pd_min_Cd_Ps_trn \
       sst_min_trn)

strPathOutput="${pacman_data_path}${pacman_sub_id}/nii/stat_maps_comb/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Copy and rename statistical maps:

echo "---Copy and rename statistical maps---"
date

# Check number of files to be processed:
varNumIn=${#lstIn[@]}

# Since indexing starts from zero, we subtract one:
varNumIn=$((varNumIn - 1))

for index01 in $(seq 0 $varNumIn)
do

	strTmpIn="${strPathParent01}${lstIn[index01]}"
	strTmpOut="${strPathOutput}feat_level_2_${lstOt[index01]}_cope.nii.gz"
	echo "------cp ${strTmpIn} ${strTmpOut}"
	cp ${strTmpIn} ${strTmpOut}

done

date
echo "done"
#------------------------------------------------------------------------------
