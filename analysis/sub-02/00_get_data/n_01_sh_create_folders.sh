#!/bin/bash


###############################################################################
# Create subject's directory tree for the PacMan analusis pipeline.           #
###############################################################################


# -----------------------------------------------------------------------------
# *** Define parameters:


# Get subject ID (from environmental variable, which is defined in metascript).
# E.g., "sub-02".
str_sub_ID="${str_sub_id}"

# Get session IDs (from environmental variable). E.g. "ses-01", "ses-02").
str_ses_id="${str_ses_id}"

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Get subject data directory (from environmental variable, which is defined in
# metascript). For instance:
# "/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/" + "derivatives" + "sub-01".
str_pth_sub="${str_data_path}derivatives/${str_sub_ID}"
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Create session parent directory

# Check whether directory already exists:
if [ ! -d "${str_pth_sub}" ];
then

	echo "------Creating directory tree for ${str_sub_ID}"

	# Create subject parent directory (e.g. "sub-02").
	mkdir "${str_pth_sub}/"

	# Target folders for dicom to nii conversion (one per session).
	mkdir "${str_pth_sub}/raw_data"

	# Target folders for dicom to nii conversion (one per session).
	for idx_ses_id in ${ary_ses_id[@]}
	do
		mkdir "${str_pth_sub}/raw_data/${idx_ses_id}"
	done

	# Anatomical images.
	mkdir "${str_pth_sub}/anat"
	mkdir "${str_pth_sub}/anat/01_orig"
	mkdir "${str_pth_sub}/anat/02_spm_bf_correction"
	mkdir "${str_pth_sub}/anat/03_reg_within_sess"
	for idx_ses_id in ${ary_ses_id[@]}
	do
	  mkdir "${str_pth_sub}/anat/03_reg_within_sess/${idx_ses_id}"
	  mkdir "${str_pth_sub}/anat/03_reg_within_sess/${idx_ses_id}/01_in"
	  mkdir "${str_pth_sub}/anat/03_reg_within_sess/${idx_ses_id}/02_brainmask"
	  mkdir "${str_pth_sub}/anat/03_reg_within_sess/${idx_ses_id}/03_reg_PD"
	  mkdir "${str_pth_sub}/anat/03_reg_within_sess/${idx_ses_id}/04_mean_PD"
  done
	mkdir "${str_pth_sub}/anat/04_intermediate"
	mkdir "${str_pth_sub}/anat/05_spm_bf_correction"
	mkdir "${str_pth_sub}/anat/06_intermediate"
	mkdir "${str_pth_sub}/anat/07_across_ses_reg"
	mkdir "${str_pth_sub}/anat/08_seg"

	# Functional images.
	mkdir "${str_pth_sub}/func"
	mkdir "${str_pth_sub}/func_reg_within_runs"
	mkdir "${str_pth_sub}/func_reg_within_runs_tsnr"
	mkdir "${str_pth_sub}/func_reg_across_runs"
	mkdir "${str_pth_sub}/func_reg_across_runs_tsnr"
	# mkdir "${str_pth_sub}/func_reg_to_anat"
	mkdir "${str_pth_sub}/func_reg_across_ses"
	mkdir "${str_pth_sub}/func_reg_across_ses_tsnr"
	mkdir "${str_pth_sub}/func_op"
	mkdir "${str_pth_sub}/func_op_inv"
	mkdir "${str_pth_sub}/func_op_reg_within_runs"
	mkdir "${str_pth_sub}/func_distcorMerged"
	mkdir "${str_pth_sub}/func_distcorField"
	mkdir "${str_pth_sub}/func_distcorUnwrp"
	mkdir "${str_pth_sub}/func_unwrp_tsnr"
	mkdir "${str_pth_sub}/func_filtered"

	# FSL feat direcoty (feat is used for filtering).
	mkdir "${str_pth_sub}/feat_level_1"

	# Motion correction of functional images. First round of moco, within runs,
	# without refweight.
	mkdir "${str_pth_sub}/reg_within_runs"
	# Zero filled directoy names for SPM moco ("01", "02", etc.).
	for idx_num_run in $(seq -f "%02g" 1 $var_num_runs)
	do
		mkdir "${str_pth_sub}/reg_within_runs/${idx_num_run}"
	done

	# Motion correction of opposite phase encoding data. First round of moco,
	# within runs, without refweight.
	mkdir "${str_pth_sub}/reg_within_runs_op"
	# Zero filled directoy names for SPM moco ("01", "02", etc.).
	for idx_num_run in $(seq -f "%02g" 1 $var_num_runs)
	do
		mkdir "${str_pth_sub}/reg_within_runs_op/${idx_num_run}"
	done

	# Session counter:
	var_cnt_ses=0

	# Registration of functional images across runs, within session.
	mkdir "${str_pth_sub}/reg_across_runs"
	for idx_ses_id in ${ary_ses_id[@]}
	do
	  mkdir "${str_pth_sub}/reg_across_runs/${idx_ses_id}"

		# Loop through runs, zero filled indices ("01", "02", # etc.). Note that
		# the number of runs may not be identical throughout # sessions.
		for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
		do
	  	mkdir "${str_pth_sub}/reg_across_runs/${idx_ses_id}/${idx_num_run}"
		done

		mkdir "${str_pth_sub}/reg_across_runs/${idx_ses_id}/ref_weighting"

		# Increment session counter:
	  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`
	done

	# Registration of functional images to anatomical, within sessions.
	mkdir "${str_pth_sub}/reg_func_to_anat"
	for idx_ses_id in ${ary_ses_id[@]}
	do

		mkdir "${str_pth_sub}/reg_func_to_anat/${idx_ses_id}"

  done

	# Session counter:
	#var_cnt_ses=0

	# Registration of PD & functional images across sessions.
	mkdir "${str_pth_sub}/reg_across_ses"
	#for idx_ses_id in ${ary_ses_id[@]}
	#do
	#	mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}"
	#	# Loop through runs, zero filled indices ("01", "02", # etc.). Note that
	#	# the number of runs may not be identical throughout # sessions.
	#	for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
	#	do
	#		# Because of SPM, each run needs to be registered separately (the same
	#		# transformation is performed).
	#		mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/run_${idx_num_run}"
	#		mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/run_${idx_num_run}/anat"
	#		mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/run_${idx_num_run}/func"
	#	done
	#	# Folders for registration of whole-brain T1 and PD images:
	#	mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/other_01"
	#	mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/other_01/anat"
	#	mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/other_01/other"
	#	mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/other_02"
	#	mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/other_02/anat"
	#	mkdir "${str_pth_sub}/reg_across_ses/${idx_ses_id}/other_02/other"
	#	# Increment session counter:
	#  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`
  #done

	# Population receptive field mapping results.
	mkdir "${str_pth_sub}/retinotopy"
	mkdir "${str_pth_sub}/retinotopy/mask"
	mkdir "${str_pth_sub}/retinotopy/pRF_results"
	mkdir "${str_pth_sub}/retinotopy/pRF_results_reg"

	mkdir "${str_pth_sub}/spatial_correlation"

else

	echo "------Analysis directory tree for ${str_pth_sub} already exists."

fi
# -----------------------------------------------------------------------------
