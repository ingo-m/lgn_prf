#!/bin/bash


###############################################################################
# Apply transformation to functional images (across sessions registration).   #
###############################################################################


#------------------------------------------------------------------------------
# ### Define session IDs & paths

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory:
strPthIn="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs/"

# Output directory:
strPthOut="${str_data_path}derivatives/${str_sub_id}/func_reg_across_ses/"

# Location of transformation matrices functional --> anatomical. File names are
# expected to be `n_02_sub-*_ses-*_fsl_reg.mat`.
strPthMat01="${str_anly_path}${str_sub_id}/03_func_to_anat/"

# Location of transformation matrices anatomcial --> first session anatomical.
# File names are expected to be `n_02_sub-*_ses-*_to_ses-01_fsl_transform.mat`.
strPthMat02="${str_anly_path}${str_sub_id}/04_reg_across_ses/"

# Path of reference image (anatomical image from first session):
strPathRef="${str_data_path}derivatives/${str_sub_id}/anat/07_across_ses_reg/${str_sub_id}_ses-01_T1w_si"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### First session

# For the first session, only the tranformation functional --> anatomical is
# applied, because the anatomical image of the first session serves as the
# acrosss-sessions reference. (For subsequent sessions, the transformations
# functional --> anatomical within session --> anatomcial across session have
# to be concatenated.

# Session counter.
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[0]}
do

	# Path of transformation matrix functional --> within-session anatomy.
	strTmp01="${strPthMat01}n_02_${str_sub_id}_${idx_ses_id}_fsl_reg.mat"

  # Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
  # etc.). Note that the number of runs may not be identical throughout
  # sessions.
	for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
  do

    # Path of functional run:
    strTmp02="${strPthIn}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

		# Output path for registered time series:
		strTmp03="${strPthOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

		# Apply transformation (no parallelisation, because the transformation is
		# too memory-intense).
		flirt \
		-interp trilinear \
		-in ${strTmp02} \
		-ref ${strPathRef} \
		-applyxfm -init${strTmp01} \
		-out ${strTmp03}

  done

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Subsequent sessions

# For all but the first sessions, the transformations functional --> anatomical
# within session --> anatomcial across session have to be concatenated.

# Session counter (starting from one, because first session is reference and is
# therefore skipped).
var_cnt_ses=1

# Loop through sessions (e.g. "ses-02", "ses-03"), skipping the first session,
# because sessions are registered to first session.
for idx_ses_id in ${ary_ses_id[@]:1}
do

	# Path of transformation matrix functional --> within-session anatomy.
	strTmp01="${strPthMat01}n_02_${str_sub_id}_${idx_ses_id}_fsl_reg.mat"

	# Path of transformation matrix within-session anatomy --> across session
	# anatomy.
	strTmp04="${strPthMat02}n_02_${str_sub_id}_${idx_ses_id}_to_ses-01_fsl_transform.mat"

	# Path for concatenation of the two transformation matrices:
	strTmp05="${strPthMat02}${str_sub_id}_${idx_ses_id}_concat_func_to_ses-01_fsl_transform.mat"

	# Concatenate transformations.
	# convert_xfm -omat <outmat_AtoC> -concat <mat_BtoC> <mat_AtoB>
	convert_xfm -omat ${strTmp05} -concat ${strTmp04} ${strTmp01}

  # Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
  # etc.). Note that the number of runs may not be identical throughout
  # sessions.
	for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
  do

		# Path of functional run:
    strTmp02="${strPthIn}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

		# Output path for registered time series:
		strTmp03="${strPthOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

		# Apply transformation (no parallelisation, because the transformation is
		# too memory-intense).
		flirt \
		-interp trilinear \
		-in ${strTmp02} \
		-ref ${strPathRef} \
		-applyxfm -init ${strTmp05} \
		-out ${strTmp03}

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------
