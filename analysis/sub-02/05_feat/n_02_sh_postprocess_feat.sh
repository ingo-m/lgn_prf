#!/bin/bash


###############################################################################
# Postprocess feat filtering (move & rename images).                          #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory (followed containing feat directories):

/media/sf_D_DRIVE/MRI_Data_PhD/05_PacMan/20180118/nii/feat_level_1/func_01.feat/filtered_func_data.nii.gz

strPathInput="${str_data_path}derivatives/${str_sub_id}/feat_level_1/"

# SPM directory:
strPathSpm="${str_data_path}derivatives/${str_sub_id}/reg_within_runs_op/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------






# Counter for total number of runs (across sessions). Because moco is with SPM,
# we count from one (matlab convention).
var_cnt_run=1

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
    strTmpIn="${strPathInput}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # Zero pad the counter for SPM directory name:
    strTmpSpmCnt=`printf %02d ${var_cnt_run}`

    # Complete output path:
  	strTmpOt="${strPathSpm}${strTmpSpmCnt}/${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

  	echo "------fslchfiletype on: ${strTmpIn}"
  	echo "----------------output: ${strTmpOt}"
  	fslchfiletype NIFTI ${strTmpIn} ${strTmpOt}

    # Increment run counter:
    var_cnt_run=`bc <<< ${var_cnt_run}+1`

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done

date
echo "done"
#------------------------------------------------------------------------------
