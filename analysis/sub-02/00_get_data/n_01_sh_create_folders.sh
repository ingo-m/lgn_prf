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

# Calculate total number of runs (i.e. all runs of all session for given
# subject).
var_num_runs=0
for idx_num_run in ${ary_num_runs[@]}
do
	var_num_runs=`bc <<< ${var_num_runs}+${idx_num_run}`
done
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Create session parent directory

# Check whether directory already exists:
if [ ! -d "${str_pth_sub}" ];
then

	echo "Creating parent directory for ${str_sub_ID}"
	mkdir "${str_pth_sub}"

else

	echo "Directory ${str_sub_ID} already exists."

fi
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Create nii directory (main analysis directory)

# Number of runs:
# var_include=${#ary_run_IDs[@]}

# Check whether directory already exists:
if [ ! -d "${str_pth_sub}" ];
then

	echo "Creating analysis directory ${str_pth_sub}"

	mkdir "${str_pth_sub}/"

	mkdir "${str_pth_sub}/feat_level_1"

	mkdir "${str_pth_sub}/func"
	mkdir "${str_pth_sub}/func_distcorField"
	mkdir "${str_pth_sub}/func_reg"
	mkdir "${str_pth_sub}/func_reg_tsnr"
	mkdir "${str_pth_sub}/func_reg_distcorUnwrp"

	mkdir "${str_pth_sub}/func_distcor"
	mkdir "${str_pth_sub}/func_distcor_reg"
	mkdir "${str_pth_sub}/func_distcor_op"
	mkdir "${str_pth_sub}/func_distcor_op_inv"
	mkdir "${str_pth_sub}/func_distcor_op_inv_reg"
	mkdir "${str_pth_sub}/func_distcor_merged"

	mkdir "${str_pth_sub}/anat"

	mkdir "${str_pth_sub}/anat/01_orig"
	mkdir "${str_pth_sub}/anat/02_spm_bf_correction"
	mkdir "${str_pth_sub}/anat/03_reg"
	mkdir "${str_pth_sub}/anat/03_reg/01_in"
	mkdir "${str_pth_sub}/anat/03_reg/02_brainmask"
	mkdir "${str_pth_sub}/anat/03_reg/03_prereg"
	mkdir "${str_pth_sub}/anat/03_reg/03_prereg/combined_mean"
	mkdir "${str_pth_sub}/anat/03_reg/03_prereg/mp2rage_other"
	mkdir "${str_pth_sub}/anat/03_reg/03_prereg/mp2rage_t1w"
	mkdir "${str_pth_sub}/anat/03_reg/04_reg"
	mkdir "${str_pth_sub}/anat/03_reg/04_reg/01_in"
	mkdir "${str_pth_sub}/anat/03_reg/04_reg/02_bbr_prep"
	mkdir "${str_pth_sub}/anat/03_reg/04_reg/03_bbr"
	mkdir "${str_pth_sub}/anat/03_reg/04_reg/04_inv_bbr"
	mkdir "${str_pth_sub}/anat/04_seg"

	mkdir "${str_pth_sub}/raw_data"

	mkdir "${str_pth_sub}/retinotopy"
	mkdir "${str_pth_sub}/retinotopy/mask"
	mkdir "${str_pth_sub}/retinotopy/pRF_results"
	mkdir "${str_pth_sub}/retinotopy/pRF_results_up"
	mkdir "${str_pth_sub}/retinotopy/pRF_stimuli"

	# Create subfolders for SPM - func across runs moco:
	mkdir "${str_pth_sub}/spm_reg"
	mkdir "${str_pth_sub}/spm_reg/ref_weighting"
	for index_1 in ${ary_run_IDs[@]}
	do
		str_tmp_1="${str_pth_sub}/spm_reg/${index_1}"
		mkdir "${str_tmp_1}"
	done

	# Create SPM subfolder for SE run:
	mkdir "${str_pth_sub}/spm_reg/func_00"

	# Create SPM subfolders for opposite-phase-polarity run:
	mkdir "${str_pth_sub}/spm_reg_op"
	mkdir "${str_pth_sub}/spm_reg_op/func_00"
	mkdir "${str_pth_sub}/spm_reg_op/ref_weighting"

	mkdir "${str_pth_sub}/spm_reg_reference_weighting"
	mkdir "${str_pth_sub}/spm_reg_moco_params"

	mkdir "${str_pth_sub}/stat_maps"
	mkdir "${str_pth_sub}/stat_maps_up"

else

	echo "Analysis directory ${str_pth_sub} already exists."

fi
# -----------------------------------------------------------------------------
