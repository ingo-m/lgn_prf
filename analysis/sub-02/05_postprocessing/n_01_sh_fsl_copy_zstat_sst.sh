#!/bin/bash


###############################################################################
# Copy and rename statistical maps.                                           #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

strPathParent01="${pacman_data_path}${pacman_sub_id}/nii/feat_level_2/"

# Contrasts are coded as follows:
#     cope 1: Pd
#     cope 2: Cd
#     cope 3: Ps
#     cope 4: Pd_min_Cd
#     cope 5: Pd_min_Ps
#     cope 6: Cd_min_Ps
#     cope 7: Linear
#     cope 8: Pd_min_Cd_Ps

# Input (feat directories):
lstIn=(feat_level_2.gfeat/cope1.feat/stats/zstat1.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/zstat2.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/zstat3.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/zstat4.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/zstat5.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/zstat6.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/zstat7.nii.gz \
       feat_level_2.gfeat/cope1.feat/stats/zstat8.nii.gz)

# Output (file names):
lstOt=(Pd \
       Cd \
       Ps \
       Pd_min_Cd \
       Pd_min_Ps \
       Cd_min_Ps \
       Linear \
       Pd_min_Cd_Ps)

strPathOutput="${pacman_data_path}${pacman_sub_id}/nii/stat_maps/"
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
	strTmpOut="${strPathOutput}feat_level_2_${lstOt[index01]}_zstat.nii.gz"
	echo "------cp ${strTmpIn} ${strTmpOut}"
	cp ${strTmpIn} ${strTmpOut}

done

date
echo "done"
#------------------------------------------------------------------------------
