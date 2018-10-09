#!/bin/bash


###############################################################################
# Prepare registration of mean functional images to anatomical images (within #
# sessions).                                                                  #
###############################################################################


#------------------------------------------------------------------------------
# ### Define session IDs & paths

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Anatomical input directory:
strPthAnat="${str_data_path}derivatives/${str_sub_id}/anat/06_intermediate/"

# Location of masks for anatomical images (within analysis folder):
strPthMskPd="${str_anly_path}${str_sub_id}/04_reg_across_ses/"

# Location of functional time series:
strPthFnc="${str_data_path}derivatives/${str_sub_id}/func_reg_to_anat/"

# Target directory basepath (followed by session ID, e.g. "ses-01").
strPthSpm="${str_data_path}derivatives/${str_sub_id}/reg_across_ses/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Apply mask to anatomical images

echo "------Apply mask to anatomical images"

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Input path of anatomical image:
  strPthPwd="${strPthAnat}${str_sub_id}_${idx_ses_id}_PD"

  # Path of mask anatomical image:
  strPthMskTmp="${strPthMskPd}n_01b_${str_sub_id}_${idx_ses_id}_PD_reg_mask"

  # Path for masked anatomcial image (used as source image for registration):
  strPthSrc="${strPthSpm}${idx_ses_id}/run_01/anat/${str_sub_id}_${idx_ses_id}_PD"

  # Apply mask:
  fslmaths ${strPthPwd} -mul ${strPthMskTmp} ${strPthSrc}

  # Change filetype to uncompressed nii:
  fslchfiletype NIFTI ${strPthSrc} ${strPthSrc}

  # Remove compressed file:
  rm ${strPthSrc}.nii.gz

  # Because of SPM, the registration has to be performed separately for each
  # run (the same transformation is performed on each run). Copy files for
  # registration of each run. Loop through runs, starting from second run
  # (because the image is already present for the first run).
	for idx_num_run in $(seq -f "%02g" 2 ${ary_num_runs[var_cnt_ses]})
  do

    # Destination path:
    strPthTmp01="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/anat/${str_sub_id}_${idx_ses_id}_PD"

    # Copy image form first run to current run:
    cp ${strPthSrc}.nii ${strPthTmp01}.nii

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Copy whole brain T1 & PD image

# Whole brain (i.e. not masked) T1 & PD images are registered across sessions.

# Loop through sessions (e.g. "ses-02", "ses-03"), skipping the first session,
# because sessions are registered to first session.
for idx_ses_id in ${ary_ses_id[@]:1}
do

  # Input path of whole brain PD image (to be registered):
  strPthPwd="${strPthAnat}${str_sub_id}_${idx_ses_id}_PD"

  # Input path of whole brain T1 image (to be registered):
  strPthT1="${strPthAnat}${str_sub_id}_${idx_ses_id}_T1w_si"

  # Target path for whole brain PD image (to be registered):
  strPthTrgtPwd="${strPthSpm}${idx_ses_id}/other_01/other/${str_sub_id}_${idx_ses_id}_PD"

  # Target path for whole brain T1 image (to be registered):
  strPthTrgtT1="${strPthSpm}${idx_ses_id}/other_02/other/${str_sub_id}_${idx_ses_id}_T1w_si"

  # Uncompress & copy images:
  fslchfiletype NIFTI ${strPthPwd} ${strPthTrgtPwd}
  fslchfiletype NIFTI ${strPthT1} ${strPthTrgtT1}

  # The above images are regitered along with the masked anatomical image (used
  # as source image for registration to target). Copy masked anatomical image:

  # Path of masked anatomcial image (used as source for registration to
  # anatomical image from first session).
  strPthSrc="${strPthSpm}${idx_ses_id}/run_01/anat/${str_sub_id}_${idx_ses_id}_PD"

  # Destination path 1:
  strPthTmp01="${strPthSpm}${idx_ses_id}/other_01/anat/${str_sub_id}_${idx_ses_id}_PD"

  # Copy image form first run to current run:
  cp ${strPthSrc}.nii ${strPthTmp01}.nii

  # Destination path 2:
  strPthTmp02="${strPthSpm}${idx_ses_id}/other_02/anat/${str_sub_id}_${idx_ses_id}_PD"

  # Copy image form first run to current run:
  cp ${strPthSrc}.nii ${strPthTmp02}.nii

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Copy & uncompress functional time series

echo "------Copy & uncompress functional time series"

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

    # Input path functional run:
    strPthTmp01="${strPthFnc}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # Output path functional run:
    strPthTmp02="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/func/${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # Change filetype to uncompressed nii:
    fslchfiletype NIFTI ${strPthTmp01} ${strPthTmp02}

    # Remove input:
    # rm ${strPthTmp01}.nii.gz

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------
