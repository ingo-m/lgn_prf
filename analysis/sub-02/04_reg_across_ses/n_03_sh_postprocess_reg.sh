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

# Output directory for registred functional time series:
strPthOut="${str_data_path}derivatives/${str_sub_id}/func_reg_across_ses/"

# Output directory for registred anatomical images:
strPthOutAnat="${str_data_path}derivatives/${str_sub_id}/anat/07_across_ses_reg/"

# SPM directory base (followed by session ID, e.g. "ses-01"):
strPathSpm="${str_data_path}derivatives/${str_sub_id}/reg_across_ses/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Change filetype and save resulting nii file to SPM directory:

# SPM requires *.nii files as input, not *.nii.gz.

echo "-----------Compress SPM output and delete uncompressed files-----------"
date

# Session counter (starting from one, because first session is reference and is
# therefore skipped).
var_cnt_ses=1

# Loop through sessions (e.g. "ses-02", "ses-03"), skipping the first session,
# because sessions are registered to first session.
for idx_ses_id in ${ary_ses_id[@]:1}
do

  # Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
  # etc.). Note that the number of runs may not be identical throughout
  # sessions.
	for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
  do

    # Complete input path:
  	strTmpIn="${strPathSpm}${idx_ses_id}/run_${idx_num_run}/func/r${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # Complete output path:
    strTmpOt="${strPthOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

  	echo "------fslchfiletype on: ${strTmpIn}"
  	echo "----------------output: ${strTmpOt}"
  	fslchfiletype NIFTI_GZ ${strTmpIn} ${strTmpOt}

    echo "------Removing uncompressed nii files"

    # The time series that motion corretion was performed on:
  	strTmp01="${strPathSpm}${idx_ses_id}/run_${idx_num_run}/func/${str_sub_id}_${idx_ses_id}_run_${idx_num_run}.nii"

    # The time series that has been 'resliced':
  	strTmp02="${strTmpIn}.nii"

    echo "------rm ${strTmp01}"
    rm ${strTmp01}

    echo "------rm ${strTmp02}"
    rm ${strTmp02}

  done

	# Copy registered whole brain (i.e. not masked) T1 & PD images.

	# FIRST 'other' image (e.g. T1 image).

	# Registered image:
	strTmp01="${strPathSpm}${idx_ses_id}/other_01/other/r${str_sub_id}_${idx_ses_id}_PD"

	# Target path:
	strTmp02="${strPthOutAnat}${str_sub_id}_${idx_ses_id}_PD"

	# Move image:
	fslchfiletype NIFTI_GZ ${strTmp01} ${strTmp02}

	# Remove uncompressed registered image:
	rm ${strTmp01}.nii

	# Remove uncompressed original image:
	rm ${strPathSpm}${idx_ses_id}/other_01/other/${str_sub_id}_${idx_ses_id}_PD.nii

	# SECOND 'other' image (e.g. PD image).

	# Registered image:
	strTmp01="${strPathSpm}${idx_ses_id}/other_02/other/r${str_sub_id}_${idx_ses_id}_T1w_si"

	# Target path:
	strTmp02="${strPthOutAnat}${str_sub_id}_${idx_ses_id}_T1w_si"

	# Move image:
	fslchfiletype NIFTI_GZ ${strTmp01} ${strTmp02}

	# Remove uncompressed registered image:
	rm ${strTmp01}.nii

	# Remove uncompressed original image:
	rm ${strPathSpm}${idx_ses_id}/other_02/other/${str_sub_id}_${idx_ses_id}_T1w_si.nii

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done

date
echo "done"
#------------------------------------------------------------------------------
