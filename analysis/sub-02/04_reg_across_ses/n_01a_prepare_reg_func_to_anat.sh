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
strPthMskPd="${str_data_path}analysis/${str_sub_id}/04_reg_across_ses/"

# Location of functional time series:
strPthFnc="${str_data_path}derivatives/${str_sub_id}/func_reg_to_anat/"

# Target directory basepath (followed by session ID, e.g. "ses-01").
strPthSpm="${str_data_path}derivatives/${str_sub_id}/reg_across_ses/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Apply mask to anatomical images

echo "------Apply mask to PD images"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Input path of proton density image:
  strPthPdw="${strPthAnat}${str_sub_id}_${idx_ses_id}_PD"

  # Path of mask for proton density image:
  strPthMskTmp="${strPthMskPd}n_01b_${str_sub_id}_${idx_ses_id}_PD_reg_mask"

  # Target path for masked anatomcial image:
  strPthTrgt="${strPthSpm}${idx_ses_id}/anat/${str_sub_id}_${idx_ses_id}_PD"

  # Apply mask:
  fslmaths ${strPthPdw} -mul ${strPthMskTmp} ${strPthTrgt}

  # Change filetype to uncompressed nii:
  fslchfiletype NIFTI ${strPthTrgt} ${strPthTrgt}

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Copy T1 images

# Registration will be based on proton density images. T1 images will be
# registered along.

echo "------Copy T1 images"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Input path of T1 image:
  strTmp01="${strPthAnat}${str_sub_id}_${idx_ses_id}_T1w_si"

  # Target path:
  strTmp02="${strPthSpm}${idx_ses_id}/other/${str_sub_id}_${idx_ses_id}_T1w_si"

  # Change filetype to uncompressed nii:
  fslchfiletype NIFTI ${strTmp01} ${strTmp02}

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
    strPthTmp02="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # Change filetype to uncompressed nii:
    fslchfiletype NIFTI ${strPthTmp01} ${strPthTmp02}

    # Remove input:
    # rm ${strPthTmp01}.nii.gz

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------
