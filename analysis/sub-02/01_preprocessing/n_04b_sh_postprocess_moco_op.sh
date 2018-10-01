#!/bin/bash


###############################################################################
# Change the file type of the functional time series that have been motion    #
# corrected with SPM back to compressed nii.                                  #
#                                                                             #
# IMPORTANT: The uncompressed nii files produced by SPM are deleted in order  #
#            to conserve disk space.                                          #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Output directory:
strPathOutput="${str_data_path}derivatives/${str_sub_id}/func_op_reg/"

# SPM directory:
strPathSpm="${str_data_path}derivatives/${str_sub_id}/spm_reg_op/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Change filetype and save resulting nii file to SPM directory:

# SPM requires *.nii files as input, not *.nii.gz.

echo "-----------Compress SPM output and delete uncompressed files-----------"
date

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

    # Zero pad the counter for SPM directory name:
    strTmpSpmCnt=`printf %02d ${var_cnt_run}`

    # Complete input path:
  	strTmpIn="${strPathSpm}${strTmpSpmCnt}/r${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # Complete output path:
    strTmpOt="${strPathOutput}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

  	echo "------fslchfiletype on: ${strTmpIn}"
  	echo "----------------output: ${strTmpOt}"
  	fslchfiletype NIFTI_GZ ${strTmpIn} ${strTmpOt}

    echo "------Removing uncompressed nii files"

    # The time series that motion corretion was performed on:
  	strTmp01="${strPathSpm}${strTmpSpmCnt}/${str_sub_id}_${idx_ses_id}_run_${idx_num_run}.nii"

    # The time series that has been 'resliced':
  	strTmp02="${strPathSpm}${strTmpSpmCnt}/r${str_sub_id}_${idx_ses_id}_run_${idx_num_run}.nii"


    echo "------rm ${strTmp01}"
    rm ${strTmp01}

    echo "------rm ${strTmp02}"
    rm ${strTmp02}

    # Increment run counter:
    var_cnt_run=`bc <<< ${var_cnt_run}+1`

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done

date
echo "done"
#------------------------------------------------------------------------------
