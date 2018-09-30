#!/bin/bash


###############################################################################
# Prepare motion correction of functional runs. The following steps are       #
# performed:                                                                  #
#   - Copy files into SPM directory tree                                      #
#   - Remove input files                                                      #
# Motion correction and registrations can be  performed with SPM afterwards.  #
###############################################################################


#-------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory:
strPathInput="${str_data_path}derivatives/${str_sub_id}/func/"

# SPM directory:
strPathSpm="${str_data_path}derivatives/${str_sub_id}/spm_reg/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Change filetype and save resulting nii file to SPM directory:

# SPM requires *.nii files as input, not *.nii.gz.

echo "-----Change filetype and save resulting nii file to SPM directory:-----"
date

# Counter for total number of runs (across sessions):
var_cnt_run=0

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

  	# Remove input:
  	echo "------rm ${strTmpIn}.nii.gz"
  	rm "${strTmpIn}.nii.gz"

    # Increment run counter:
    var_cnt_run=`bc <<< ${var_cnt_run}+1`

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done

date
echo "done"
#-------------------------------------------------------------------------------
