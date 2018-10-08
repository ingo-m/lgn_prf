#!/bin/bash


###############################################################################
# The first session is the reference for alignment, therefore the functional  #
# time series from the first session are not registered across sessions. They #
# still need to be copied to the respective target folder after across-       #
# session alignment.                                                          #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory:
strPathIn="${str_data_path}derivatives/${str_sub_id}/func_reg_to_anat/"

# Output directory:
strPathOut="${str_data_path}derivatives/${str_sub_id}/func_reg_across_ses/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Copy functional images from first session

# First session only:
idx_ses_id=${ary_ses_id[0]}

# Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
# etc.).
for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[0]})
do

	# Complete input path:
	strTmpIn="${strPathIn}/${str_sub_id}_${idx_ses_id}_run_${idx_num_run}.nii.gz"

	# Complete output path:
	strTmpOut="${strPathOut}/${str_sub_id}_${idx_ses_id}_run_${idx_num_run}.nii.gz"

	cp ${strTmpIn} ${strTmpOut}

	# Remove input:
	# rm ${strTmpIn}

done
#------------------------------------------------------------------------------
