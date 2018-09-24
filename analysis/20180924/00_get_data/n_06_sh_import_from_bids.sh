#!/bin/bash


###############################################################################
# Import data from BIDS folder structure into PacMan analysis pipeline.       #
###############################################################################


#------------------------------------------------------------------------------
# *** Define paths:

# Parent directory:
strPthPrnt="${pacman_data_path}${pacman_sub_id}/nii"

# BIDS directory:
strBidsDir="${pacman_data_path}BIDS/"

# BIDS directory containing functional data:
strBidsFunc="${strBidsDir}${pacman_sub_id_bids}/func/"

# Destination directory for functional data:
strFunc="${strPthPrnt}/func/"

# BIDS directory containing same-phase-polarity images:
strBidsSe="${strBidsDir}${pacman_sub_id_bids}/func_distcor/"

# Destination directory for same-phase-polarity images:
strSe="${strPthPrnt}/func_distcor/"

# BIDS directory containing opposite-phase-polarity images:
strBidsSeOp="${strBidsDir}${pacman_sub_id_bids}/func_distcor_op/"

# Destination directory for opposite-phase-polarity SE images:
strSeOp="${strPthPrnt}/func_distcor_op/"

# BIDS directory containing anatomical images:
strBidsAnat="${strBidsDir}${pacman_sub_id_bids}/anat/"

# Destination directory for anatomical images:
strAnat="${strPthPrnt}/anat/01_orig/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy functional data

cp -r ${strBidsFunc}*.nii.gz ${strFunc}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy opposite-phase-polarity images

cp -r ${strBidsSe}*.nii.gz ${strSe}
cp -r ${strBidsSeOp}*.nii.gz ${strSeOp}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy anatomical images

cp -r ${strBidsAnat}*.nii.gz ${strAnat}
#------------------------------------------------------------------------------
