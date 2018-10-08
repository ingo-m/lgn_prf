#!/bin/bash


###############################################################################
# Calculate tSNR of functional time series after within-session moco.         #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory:
strPathFunc="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs/"

# Output directory:
strPathOut="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs_tsnr/"
#------------------------------------------------------------------------------