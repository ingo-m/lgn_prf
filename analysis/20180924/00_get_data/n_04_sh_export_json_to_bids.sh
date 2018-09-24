#!/bin/bash


###############################################################################
# Copy JSON metadata into the BIDS directory.                                 #
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
strSe="${strBidsDir}${pacman_sub_id_bids}/func_distcor/"

# Destination directory for opposite-phase-polarity SE images:
strSeOp="${strBidsDir}${pacman_sub_id_bids}/func_distcor_op/"

# Destination directory for mp2rage images:
strAnat="${strBidsDir}${pacman_sub_id_bids}/anat/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy metadata for functional images

cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_01_SERIES_013_c32.json ${strFunc}func_01.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_02_SERIES_014_c32.json ${strFunc}func_02.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_03_SERIES_015_c32.json ${strFunc}func_03.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_04_SERIES_016_c32.json ${strFunc}func_04.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_05_SERIES_018_c32.json ${strFunc}func_05.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_06_SERIES_019_c32_e1.json ${strFunc}func_06.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_07_SERIES_021_c32_e1.json ${strFunc}func_07.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_run_08_SERIES_022_c32.json ${strFunc}func_08.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy metadata for opposite-phase-polarity SE images

cp ${strRaw}PROTOCOL_cmrr_mbep2d_se_LR_SERIES_005_c32.json ${strSeOp}func_00.json
cp ${strRaw}PROTOCOL_cmrr_mbep2d_se_RL_SERIES_006_c32.json ${strSe}func_00.json

cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_FH_SERIES_012_c32.json ${strDistcorOp}func_00.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func01_FOV_HF_SERIES_011_c32.json ${strDistcor}func_00.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy metadata for mp2rage images

cp ${strRaw}PROTOCOL_PD_cor_0.7mm_p2_SERIES_010_c32_e1.json ${strAnat}pdw_01.json
cp ${strRaw}PROTOCOL_PD_cor_0.7mm_p2_SERIES_017_c32.json ${strAnat}pdw_02.json
cp ${strRaw}PROTOCOL_WMN_cor_0.7mm_p2_SERIES_008_c32.json ${strAnat}sit1.json
#------------------------------------------------------------------------------
