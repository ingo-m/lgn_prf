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
	mkdir "${str_pth_sub}/anat/03_sess_reg"
	mkdir "${str_pth_sub}/anat/03_sess_reg/01_in"
	mkdir "${str_pth_sub}/anat/03_sess_reg/02_brainmask"
	mkdir "${str_pth_sub}/anat/03_sess_reg/03_spm_reg"
	mkdir "${str_pth_sub}/anat/03_sess_reg/03_spm_reg/target"
	mkdir "${str_pth_sub}/anat/03_sess_reg/03_spm_reg/source"
	mkdir "${str_pth_sub}/anat/03_sess_reg/04_mean_anat"
	mkdir "${str_pth_sub}/anat/05_func_to_anat_reg"
	mkdir "${str_pth_sub}/anat/05_func_to_anat_reg/01_spm_reg"
	mkdir "${str_pth_sub}/anat/05_func_to_anat_reg/01_spm_reg/target"
	mkdir "${str_pth_sub}/anat/05_func_to_anat_reg/01_spm_reg/source"
	mkdir "${str_pth_sub}/anat/05_func_to_anat_reg/01_spm_reg/other"
	mkdir "${str_pth_sub}/anat/06_seg"

	# Functional images.
	mkdir "${str_pth_sub}/func"
	mkdir "${str_pth_sub}/func_reg"
	mkdir "${str_pth_sub}/func_reg_tsnr"
	mkdir "${str_pth_sub}/func_op"
	mkdir "${str_pth_sub}/func_op_inv"
	mkdir "${str_pth_sub}/func_op_reg"
	mkdir "${str_pth_sub}/func_distcorMerged"
	mkdir "${str_pth_sub}/func_distcorField"
	mkdir "${str_pth_sub}/func_distcorUnwrp"
	mkdir "${str_pth_sub}/func_unwrp_tsnr"

	# Motion correction of functional images. First round of moco, within runs,
	# without refweight.
	mkdir "${str_pth_sub}/spm_reg_within_runs"
	# Zero filled directoy names for SPM moco ("01", "02", etc.).
	for idx_num_run in $(seq -f "%02g" 1 $var_num_runs)
	do
		mkdir "${str_pth_sub}/spm_reg_within_runs/${idx_num_run}"
	done

	# Motion correction of opposite phase encoding data. First round of moco,
	# within runs, without refweight.
	mkdir "${str_pth_sub}/spm_reg_within_runs"
	# Zero filled directoy names for SPM moco ("01", "02", etc.).
	for idx_num_run in $(seq -f "%02g" 1 $var_num_runs)
	do
		mkdir "${str_pth_sub}/spm_reg_within_runs/${idx_num_run}"
	done

	# Motion correction of functional images. Second round of moco, across runs,
	# with refweight.
	mkdir "${str_pth_sub}/spm_reg_across_runs"
	# Zero filled directoy names for SPM moco ("01", "02", etc.).
	for idx_num_run in $(seq -f "%02g" 1 $var_num_runs)
	do
		mkdir "${str_pth_sub}/spm_reg_across_runs/${idx_num_run}"
	done
	mkdir "${str_pth_sub}/spm_reg_across_runs/ref_weighting"

	# Motion correction of opposite phase encoding data. Second round of moco,
	# across runs, with refweight.
	mkdir "${str_pth_sub}/spm_reg_op_across_runs"
	# Zero filled directoy names for SPM moco ("01", "02", etc.).
	for idx_num_run in $(seq -f "%02g" 1 $var_num_runs)
	do
		mkdir "${str_pth_sub}/spm_reg_op_across_runs/${idx_num_run}"
	done
	mkdir "${str_pth_sub}/spm_reg_op_across_runs/ref_weighting"

	# Population receptive field mapping results.
	mkdir "${str_pth_sub}/retinotopy"
	mkdir "${str_pth_sub}/retinotopy/mask"
	mkdir "${str_pth_sub}/retinotopy/pRF_results"
	mkdir "${str_pth_sub}/retinotopy/pRF_results_reg"

else

	echo "------Analysis directory tree for ${str_pth_sub} already exists."

fi
# -----------------------------------------------------------------------------
