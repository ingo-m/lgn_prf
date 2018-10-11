#!/bin/bash


###############################################################################
# Apply transformation to anatomical images (across sessions registration).   #
###############################################################################


#------------------------------------------------------------------------------
# ### Define session IDs & paths

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory:
strPathIn="${str_data_path}derivatives/${str_sub_id}/anat/06_intermediate/"

# Output directory:
strPathOut="${str_data_path}derivatives/${str_sub_id}/anat/07_across_ses_reg/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Copy functional images from first session

# The first session serves as reference. Therefore, images are not transformed.
# Copy images from first session.
cp \
${strPathIn}${str_sub_id}_ses-01_T1w_si.nii.gz \
${strPathOut}${str_sub_id}_ses-01_T1w_si.nii.gz

cp \
${strPathIn}${str_sub_id}_ses-01_PD.nii.gz \
${strPathOut}${str_sub_id}_ses-01_PD.nii.gz
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Register anatomical images to first session

# Loop through sessions (e.g. "ses-02", "ses-03"), skipping the first session,
# because sessions are registered to first session.
for idx_ses_id in ${ary_ses_id[@]:1}
do

	# Apply across-sessions transformation to T1 image:
	flirt \
	-interp trilinear \
	-in ${strPathIn}${str_sub_id}_${idx_ses_id}_T1w_si \
	-ref ${strPathIn}${str_sub_id}_ses-01_T1w_si \
	-applyxfm -init ${strPathPrnt}04_reg_across_ses/n_02_${str_sub_id}_${idx_ses_id}_to_ses-01_fsl_transform.mat \
	-out ${strPathOut}${str_sub_id}_${idx_ses_id}_T1w_si

	# Apply across-sessions transformation to PD image:
	flirt \
	-interp trilinear \
	-in ${strPathIn}${str_sub_id}_${idx_ses_id}_PD \
	-ref ${strPathIn}${str_sub_id}_ses-01_T1w_si \
	-applyxfm -init ${strPathPrnt}04_reg_across_ses/n_02_${str_sub_id}_${idx_ses_id}_to_ses-01_fsl_transform.mat \
	-out ${strPathOut}${str_sub_id}_${idx_ses_id}_PD

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Calculate across-sessions mean T1 image

# Counter that is used to divide the sum of all images by N:
var_cnt_div=$((0))

# Name of across-sessions mean image:
strSessMne="${strPathOut}${str_sub_id}_T1w_si_mean"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

	# Name of the session image:
	strTmp01="${strPathIn}${str_sub_id}_${idx_ses_id}_T1w_si"

  # For first session, don't append (there's nothing to append to yet), but
  # copy the first session.
	if [ "${var_cnt_div}" -eq "0" ]
	then

    # The starting point for the mean image is the first mean image. The
    # other individual mean images are subsequently added.
		cp ${strTmp01}.nii.gz ${strSessMne}.nii.gz

  else

		fslmaths ${strSessMne} -add ${strTmp01} ${strSessMne}

	fi

	# Increment run counter:
	var_cnt_div=$((var_cnt_div+1))

done

# Divide sum of all individual mean images by N:
fslmaths ${strSessMne} -div ${var_cnt_div} ${strSessMne}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Calculate across-sessions mean PD image

# Counter that is used to divide the sum of all images by N:
var_cnt_div=$((0))

# Name of across-sessions mean image:
strSessMne="${strPathOut}${str_sub_id}_PD_mean"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

	# Name of the session image:
	strTmp01="${strPathIn}${str_sub_id}_${idx_ses_id}_PD"

  # For first session, don't append (there's nothing to append to yet), but
  # copy the first session.
	if [ "${var_cnt_div}" -eq "0" ]
	then

    # The starting point for the mean image is the first mean image. The
    # other individual mean images are subsequently added.
		cp ${strTmp01}.nii.gz ${strSessMne}.nii.gz

  else

		fslmaths ${strSessMne} -add ${strTmp01} ${strSessMne}

	fi

	# Increment run counter:
	var_cnt_div=$((var_cnt_div+1))

done

# Divide sum of all individual mean images by N:
fslmaths ${strSessMne} -div ${var_cnt_div} ${strSessMne}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Calcualte ratio image

# Ratio image (T1 / PD) may be used for segmentation.
fslmaths \
${strPathOut}${str_sub_id}_T1w_si_mean \
-mul 100 \
-div ${strPathOut}${str_sub_id}_PD_mean \
${strPathOut}${str_sub_id}_ratio_T1_PD
#------------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Smoothing

# Perform anisotropic diffusion based smoothing in order to enhance tissue
# contrast.

# Activate segmentator conda environment:
source activate py_segmentator

# File name:
strPthTmp01="${strPathOut}${str_sub_id}_ratio_T1_PD"

# Perform smoothing:
segmentator_filters \
    ${strPthTmp01}.nii.gz \
    --smoothing cCED \
    --nr_iterations 7 \
    --save_every 7

# Rename output:
mv -T ${strPthTmp01}*cCED*.nii.gz ${strPthTmp01}_smooth.nii.gz

# Switch back to default conda environment:
source activate py_main
# -----------------------------------------------------------------------------
