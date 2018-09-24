#!/bin/bash


###############################################################################
# The purpose of this script is to copy the 'original' nii images, after      #
# DICOM to nii conversion, and reorient them to standard orientation. The     #
# contents of this script have to be adjusted individually for each session,  #
# as the original file names may differ from session to session.              #
###############################################################################


#------------------------------------------------------------------------------
# *** Define paths:

# Parent directory:
strPthPrnt="${pacman_data_path}${pacman_sub_id}/nii"

# BIDS directory:
strBidsDir="${pacman_data_path}BIDS/"

# 'Raw' data directory, containing nii images after DICOM->nii conversion:
strRaw="${strPthPrnt}/raw_data/"

# Destination directory for functional data:
strFunc="${strBidsDir}${pacman_sub_id_bids}/func/"

# Destination directory for same-phase-polarity SE images:
strDistcor="${strBidsDir}${pacman_sub_id_bids}/func_distcor/"

# Destination directory for opposite-phase-polarity SE images:
strDistcorOp="${strBidsDir}${pacman_sub_id_bids}/func_distcor_op/"

# Destination directory for mp2rage images:
strAnat="${strBidsDir}${pacman_sub_id_bids}/anat/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Create BIDS directory tree

# Check whether the session directory already exists:
if [ ! -d "${strBidsDir}${pacman_sub_id_bids}" ];
then
	echo "Create BIDS directory for ${strBidsDir}${pacman_sub_id_bids}"

	# Create BIDS subject parent directory:
	mkdir "${strBidsDir}${pacman_sub_id_bids}"

	# Create BIDS directory tree:
	mkdir "${strAnat}"
	mkdir "${strFunc}"
	mkdir "${strDistcor}"
	mkdir "${strDistcorOp}"
else
	echo "Directory for ${strBidsDir}${pacman_sub_id_bids} does already exist."
fi
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy functional data

fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_01_SERIES_013_c32 ${strFunc}func_01
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_02_SERIES_014_c32 ${strFunc}func_02
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_03_SERIES_015_c32 ${strFunc}func_03
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_04_SERIES_016_c32 ${strFunc}func_04
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_05_SERIES_018_c32 ${strFunc}func_05
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_06_SERIES_019_c32_e1 ${strFunc}func_06
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_07_SERIES_021_c32_e1 ${strFunc}func_07
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_08_SERIES_022_c32 ${strFunc}func_08
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy opposite-phase-polarity images

fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_SERIES_012_c32 ${strDistcorOp}func_00
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_SERIES_011_c32 ${strDistcor}func_00
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy anatomical images

fslreorient2std ${strRaw}PROTOCOL_PD_cor_0.7mm_p2_SERIES_010_c32_e1 ${strAnat}pdw_01
fslreorient2std ${strRaw}PROTOCOL_PD_cor_0.7mm_p2_SERIES_017_c32 ${strAnat}pdw_02
fslreorient2std ${strRaw}PROTOCOL_WMN_cor_0.7mm_p2_SERIES_008_c32 ${strAnat}sit1
#------------------------------------------------------------------------------
