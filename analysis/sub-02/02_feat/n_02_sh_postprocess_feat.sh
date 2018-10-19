#!/bin/bash


###############################################################################
# Postprocess feat filtering (move & rename images).                          #
###############################################################################


#------------------------------------------------------------------------------
# ### Define session IDs & paths

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory (followed containing feat directories):
strPathInput="${str_data_path}derivatives/${str_sub_id}/feat_level_1/"

# Output directory:
strPathOut="${str_data_path}derivatives/${str_sub_id}/func_filtered/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Move files

echo "------Postprocess FSL feat analysis (temporal filtering)"
date

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
  # etc.). Note that the number of runs may not be identical throughout
  # sessions.
	for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
  do

    # Complete input path:
    strTmpIn="${strPathInput}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}.feat/filtered_func_data.nii.gz"

		# Complete output path:
		strTmpOt="${strPathOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}.nii.gz"

		# Move filtered functional data:
		mv "${strTmpIn}" "${strTmpOt}"

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done

date
echo "done"
#------------------------------------------------------------------------------
