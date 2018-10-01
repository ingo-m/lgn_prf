#!/bin/bash


###############################################################################
# Copy JSON metadata into the BIDS directory.                                 #
###############################################################################


#------------------------------------------------------------------------------
# *** Define paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"

# BIDS target directory for this subject, e.g.
# "/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/" + "bids/" + "sub-01".
str_bids="${str_data_path}bids/${str_sub_id}/"

# Source directory, e.g.
# "/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/" + "derivatives/" + "sub-01"
# + "/raw_data/". Session index (e.g. "ses-01") still needs to be appended.
str_raw="${str_data_path}derivatives/${str_sub_id}/raw_data/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Create BIDS directory tree

# Check whether the subject directory (e.g. "sub-01") already exists. If not,
# create.
if [ ! -d "${str_bids}" ];
then
	echo "------Create BIDS directory: ${str_bids}"

	# Create BIDS subject parent directory:
	mkdir "${str_bids}"

else
	echo "------Directory ${str_bids} does already exist."
fi

# Check whether the session directories (e.g. "ses-01", "ses-02", etc.) already
# exist. If not, create them.
for idx_ses_id in ${ary_ses_id[@]}
do
	if [ ! -d "${str_bids}/${idx_ses_id}" ];
	then
		echo "------Create session directory: ${str_bids}/${idx_ses_id}"

		# Create BIDS subject parent directory:
		mkdir "${str_bids}/${idx_ses_id}"

		# Create BIDS subdirectories:
		mkdir "${str_bids}/${idx_ses_id}/anat"
		mkdir "${str_bids}/${idx_ses_id}/func"
		mkdir "${str_bids}/${idx_ses_id}/func_op"
	else
		echo "------Session directory ${str_bids}/${idx_ses_id} already exists."
	fi
done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** SESSION 01 - Copy functional data

# Automatic looping through sessions does not work here, because the raw image
# names are likely going to differ between sessions.

# Complete input & output paths for this session:
str_raw_tmp="${str_raw}ses-01/"
str_bids_tmp="${str_bids}ses-01/func/sub-01_ses-01_"

# Copy metadata:
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run01_SERIES_013_c32.json ${str_bids_tmp}run_01.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run02_SERIES_015_c32.json ${str_bids_tmp}run_02.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run03_SERIES_017_c32.json ${str_bids_tmp}run_03.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run04_SERIES_020_c32.json ${str_bids_tmp}run_04.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run05_SERIES_022_c32.json ${str_bids_tmp}run_05.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run06_SERIES_024_c32.json ${str_bids_tmp}run_06.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run07_SERIES_027_c32.json ${str_bids_tmp}run_07.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run08_SERIES_029_c32.json ${str_bids_tmp}run_08.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run09_SERIES_031_c32.json ${str_bids_tmp}run_09.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run10_SERIES_033_c32.json ${str_bids_tmp}run_10.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** SESSION 01 - Copy opposite-phase-polarity images

# Complete input & output paths for this session:
str_raw_tmp="${str_raw}ses-01/"
str_bids_tmp="${str_bids}ses-01/func_op/sub-01_ses-01_"

# Copy metadata:
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_anti_SERIES_012_c32.json ${str_bids_tmp}run_01.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run02_anti_SERIES_014_c32.json ${str_bids_tmp}run_02.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run03_anti_SERIES_016_c32.json ${str_bids_tmp}run_03.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run04_anti_SERIES_019_c32.json ${str_bids_tmp}run_04.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run05_anti_SERIES_021_c32.json ${str_bids_tmp}run_05.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run06_anti_SERIES_023_c32.json ${str_bids_tmp}run_06.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run07_anti_SERIES_026_c32.json ${str_bids_tmp}run_07.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run08_anti_SERIES_028_c32.json ${str_bids_tmp}run_08.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run09_anti_SERIES_030_c32.json ${str_bids_tmp}run_09.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run10_anti_SERIES_032_c32.json ${str_bids_tmp}run_10.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** SESSION 01 - Copy anatomical images

# Complete input & output paths for this session:
str_raw_tmp="${str_raw}ses-01/"
str_bids_tmp="${str_bids}ses-01/anat/sub-01_ses-01_"

# Copy metadata:
cp ${str_raw_tmp}PROTOCOL_PD_cor_0.7mm_p2_SERIES_010_c32.json ${str_bids_tmp}PD_01.json
cp ${str_raw_tmp}PROTOCOL_PD_cor_0.7mm_p2_SERIES_018_c32.json ${str_bids_tmp}PD_02.json
cp ${str_raw_tmp}PROTOCOL_PD_cor_0.7mm_p2_SERIES_025_c32.json ${str_bids_tmp}PD_03.json
cp ${str_raw_tmp}PROTOCOL_PD_cor_0.7mm_p2_SERIES_034_c32.json ${str_bids_tmp}PD_04.json
cp ${str_raw_tmp}PROTOCOL_WMN_cor_0.7mm_p2_SERIES_009_c32.json ${str_bids_tmp}T1w_si.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** SESSION 02 - Copy functional data

# Automatic looping through sessions does not work here, because the raw image
# names are likely going to differ between sessions.

# Complete input & output paths for this session:
str_raw_tmp="${str_raw}ses-02/"
str_bids_tmp="${str_bids}ses-02/func/${str_sub_id}_ses-02_"

# Reorient (and copy) images:
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run01_SERIES_010_c32.json ${str_bids_tmp}run_01.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run02_SERIES_012_c32.json ${str_bids_tmp}run_02.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run03_SERIES_014_c32.json ${str_bids_tmp}run_03.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run04_SERIES_016_c32.json ${str_bids_tmp}run_04.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run05_SERIES_018_c32.json ${str_bids_tmp}run_05.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run06_SERIES_021_c32.json ${str_bids_tmp}run_06.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run07_SERIES_023_c32.json ${str_bids_tmp}run_07.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run08_SERIES_025_c32.json ${str_bids_tmp}run_08.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run09_SERIES_027_c32.json ${str_bids_tmp}run_09.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** SESSION 02 - Copy opposite-phase-polarity images

# Complete input & output paths for this session:
str_raw_tmp="${str_raw}ses-02/"
str_bids_tmp="${str_bids}ses-02/func_op/${str_sub_id}_ses-02_"

# Reorient (and copy) images:
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_anti_SERIES_009_c32.json ${str_bids_tmp}run_01.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run02_anti_SERIES_011_c32.json ${str_bids_tmp}run_02.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run03_anti_SERIES_013_c32.json ${str_bids_tmp}run_03.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run04_anti_SERIES_015_c32.json ${str_bids_tmp}run_04.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run05_anti_SERIES_017_c32.json ${str_bids_tmp}run_05.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run06_anti_SERIES_020_c32.json ${str_bids_tmp}run_06.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run07_anti_SERIES_022_c32.json ${str_bids_tmp}run_07.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run08_anti_SERIES_024_c32.json ${str_bids_tmp}run_08.json
cp ${str_raw_tmp}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_run09_anti_SERIES_026_c32.json ${str_bids_tmp}run_09.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** SESSION 02 - Copy anatomical images

# Complete input & output paths for this session:
str_raw_tmp="${str_raw}ses-02/"
str_bids_tmp="${str_bids}ses-02/anat/${str_sub_id}_ses-02_"

# Reorient (and copy) images:
cp ${str_raw_tmp}PROTOCOL_PD_cor_0.7mm_p2_SERIES_007_c32.json ${str_bids_tmp}PD_01.json
cp ${str_raw_tmp}PROTOCOL_PD_cor_0.7mm_p2_SERIES_019_c32.json ${str_bids_tmp}PD_02.json
cp ${str_raw_tmp}PROTOCOL_PD_cor_0.7mm_p2_SERIES_028_c32.json ${str_bids_tmp}PD_03.json
cp ${str_raw_tmp}PROTOCOL_WMN_cor_0.7mm_p2_SERIES_006_c32.json ${str_bids_tmp}T1w_si.json
#------------------------------------------------------------------------------
