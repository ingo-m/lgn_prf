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

# Location of masks for T1 images (within analysis folder):
strPthMskT1="${str_anly_path}${str_sub_id}/03_func_to_anat/"

# Location of mean functional images (within session means):
strPthFncMne="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs_tsnr/"

# Location of masks for functional images (within analysis folder). Same as SPM
# moco refweights.
strPthMskFnc="${str_anly_path}${str_sub_id}/01_preprocessing/"

# Location of functional time series:
strPthFnc="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs/"

# Target directory basepath (followed by session ID, e.g. "ses-01").
strPthSpm="${str_data_path}derivatives/${str_sub_id}/reg_func_to_anat/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Apply mask to anatomical images

echo "------Apply mask to anatomical images"

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Input path of short inversion T1 weighted image:
  strPthT1="${strPthAnat}${str_sub_id}_${idx_ses_id}_T1w_si"

  # Path of mask for T1 weighted image:
  strPthMskTmp="${strPthMskT1}n_01b_${str_sub_id}_${idx_ses_id}_PD_reg_mask"

  # Target path for masked anatomcial image:
  strPthTrgt="${strPthSpm}${idx_ses_id}/run_01/anat/${str_sub_id}_${idx_ses_id}_T1w_si"

  # Apply mask:
  fslmaths ${strPthT1} -mul ${strPthMskTmp} ${strPthTrgt}

  # Change filetype to uncompressed nii:
  fslchfiletype NIFTI ${strPthTrgt} ${strPthTrgt}

  # Remove compressed file:
  rm ${strPthTrgt}.nii.gz

  # Because of SPM, the registration has to be performed separately for each
  # run (the same transformation is performed on each run). Copy files for
  # registration of each run. Loop through runs, starting from second run
  # (because the image is already present for the first run).
	for idx_num_run in $(seq -f "%02g" 2 ${ary_num_runs[var_cnt_ses]})
  do

    # Destination path:
    strPthTmp01="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/anat/${str_sub_id}_${idx_ses_id}_T1w_si"

    # Copy image form first run to current run:
    cp ${strPthTrgt}.nii ${strPthTmp01}.nii

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Smoothing

# Perform anisotropic diffusion based smoothing in order to enhance contrast
# between grey matter and white matter.

# Activate segmentator conda environment
source activate py_segmentator

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Path of within-session mean functional image:
  strPthTmp01="${strPthFncMne}${str_sub_id}_${idx_ses_id}_mean"

  # Perform smoothing:
  segmentator_filters \
      ${strPthTmp01}.nii.gz \
      --smoothing cCED \
      --nr_iterations 7 \
      --save_every 7

  # Rename output:
  mv -T ${strPthTmp01}*cCED*.nii.gz ${strPthTmp01}_smooth.nii.gz

done

# Switch back to default conda environment
source activate py_main
# -----------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Apply mask to mean functional images

echo "------Apply mask to mean functional images"

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Path of within-session mean functional image:
  strPthTmp01="${strPthFncMne}${str_sub_id}_${idx_ses_id}_mean_smooth"

  # Mask for mean functional image:
  stPthTmp02="${strPthMskFnc}n_09c_spm_moco_refweight_${str_sub_id}_${idx_ses_id}"

  # The mask (moco reference weight image) first needs to be binarised. Target
  # directory for binarised masks:
  strPthTmp03="${strPthSpm}${idx_ses_id}/run_01/mean_func/${str_sub_id}_${idx_ses_id}_mask"

  # Output path for masked mean functional image:
  strPthTmp04="${strPthSpm}${idx_ses_id}/run_01/mean_func/${str_sub_id}_${idx_ses_id}_mean"

  # Binarise moco reference weight image:
  fslmaths ${stPthTmp02} -bin ${strPthTmp03}

  # Apply mask:
  fslmaths ${strPthTmp01} -mul ${strPthTmp03} ${strPthTmp04}

  # Change filetype to uncompressed nii:
  fslchfiletype NIFTI ${strPthTmp04} ${strPthTmp04}

  # Remove compressed file:
  rm ${strPthTmp04}.nii.gz

  # Remove mask (so as not to upset SPM):
  rm ${strPthTmp03}.nii.gz

  # Because of SPM, the registration has to be performed separately for each
  # run (the same transformation is performed on each run). Copy files for
  # registration of each run. Loop through runs, starting from second run
  # (because the image is already present for the first run).
	for idx_num_run in $(seq -f "%02g" 2 ${ary_num_runs[var_cnt_ses]})
  do

    # Destination path:
    strPthTmp01="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/mean_func/${str_sub_id}_${idx_ses_id}_mean"

    # Copy image form first run to current run:
    cp ${strPthTmp04}.nii ${strPthTmp01}.nii

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Copy & uncompress functional time series

echo "------Copy & uncompress functional time series"

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
