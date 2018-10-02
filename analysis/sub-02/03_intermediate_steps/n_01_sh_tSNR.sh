#!/bin/bash


###############################################################################
# Calculate tSNR of functional time series before distortion correction.      #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory:
strPathFunc="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs/"

# Output directory:
strPathOut="${str_data_path}derivatives/${str_sub_id}/func_reg_across_runs_tsnr/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Calculate within-run mean & tSNR images after distortion correction:

echo "---Calculate single run mean & tSNR images after distortion correction"

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

    # Path of functional run:
    strTmp01="${strPathFunc}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"
    strTmp02="${strPathOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}_mean"
    strTmp03="${strPathOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}_sd"
    strTmp04="${strPathOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}_tSNR"

  	echo "------fslmaths ${strTmp01} -Tmean ${strTmp02}"
  	fslmaths ${strTmp01} -Tmean ${strTmp02}

  	echo "------fslmaths ${strTmp01} -Tstd ${strTmp03}"
  	fslmaths ${strTmp01} -Tstd ${strTmp03}

  	echo "------fslmaths ${strTmp02} -div ${strTmp03} ${strTmp04}"
  	fslmaths ${strTmp02} -div ${strTmp03} ${strTmp04}

  	echo "done"

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Calculate across-runs tSNR images (within session):

echo "---Calculate across-runs tSNR images (within session)"

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Counter that is used to divide the sum of all individual tSNR images by N
  # (within run):
  var_cnt_div=$((0))

  # Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
  # etc.). Note that the number of runs may not be identical throughout
  # sessions.
	for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
  do

    # Within-run tSNR image of current run (calculate above):
    strTmp04="${strPathOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}_tSNR"

    # For first run, don't append (there's nothing to append to yet), but copy
    # the first run.
		if [ "${idx_num_run}" -eq "1" ]
		then

      # The name of the across-runs, within-session tSNR image:
      strTmp05="${strPathOut}${str_sub_id}_${idx_ses_id}_tSNR"

      # The starting point for the mean tSNR image is the first individual tSNR
      # image. The other individual tSNR images are  subsequently added.
  		echo "------cp ${strTmp04}.nii.gz ${strTmp05}.nii.gz"
  		cp ${strTmp04}.nii.gz ${strTmp05}.nii.gz

    else

  		echo "------fslmaths ${strTmp05} -add ${strTmp04} ${strTmp05}"
  		fslmaths ${strTmp05} -add ${strTmp04} ${strTmp05}

  	fi

    # Increment run counter:
  	var_cnt_div=$((var_cnt_div+1))
  	echo "------Count: ${var_cnt_div}"

  done

  # Divide sum of all individual tSNR images by N:
  echo "------fslmaths ${strTmp05} -div ${var_cnt_div} ${strTmp05}"
  fslmaths ${strTmp05} -div ${var_cnt_div} ${strTmp05}

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`
done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Calculate across-runs mean images (within session):

echo "---Calculate across-runs mean images (within session)"

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Counter that is used to divide the sum of all individual mean images by N
  # (within run):
  var_cnt_div=$((0))

  # Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
  # etc.). Note that the number of runs may not be identical throughout
  # sessions.
	for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
  do

    # Within-run mean image of current run (calculate above):
    strTmp04="${strPathOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}_mean"

    # For first run, don't append (there's nothing to append to yet), but copy
    # the first run.
		if [ "${idx_num_run}" -eq "1" ]
		then

      # The name of the across-runs, within-session mean image:
      strTmp05="${strPathOut}${str_sub_id}_${idx_ses_id}_mean"

      # The starting point for the mean image is the first individual mean
      # image. The other individual mean images are  subsequently added.
  		echo "------cp ${strTmp04}.nii.gz ${strTmp05}.nii.gz"
  		cp ${strTmp04}.nii.gz ${strTmp05}.nii.gz

    else

  		echo "------fslmaths ${strTmp05} -add ${strTmp04} ${strTmp05}"
  		fslmaths ${strTmp05} -add ${strTmp04} ${strTmp05}

  	fi

    # Increment run counter:
  	var_cnt_div=$((var_cnt_div+1))
  	echo "------Count: ${var_cnt_div}"

  done

  # Divide sum of all individual mean images by N:
  echo "------fslmaths ${strTmp05} -div ${var_cnt_div} ${strTmp05}"
  fslmaths ${strTmp05} -div ${var_cnt_div} ${strTmp05}

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`
done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Calculate across-sessions tSNR images:

echo "---Calculate across-sessions tSNR images"

# Counter that is used to divide the sum of all images by N:
var_cnt_div=$((0))

# Name of across-sessions mean tSNR image:
strSessTsnr="${strPathOut}${str_sub_id}_tSNR"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

	# The name of the across-runs, within-session tSNR image:
	strTmp05="${strPathOut}${str_sub_id}_${idx_ses_id}_tSNR"

  # For first session, don't append (there's nothing to append to yet), but
  # copy the first session.
	if [ "${idx_num_run}" -eq "1" ]
	then

    # The starting point for the mean tSNR image is the first tSNR image. The
    # other individual tSNR images are  subsequently added.
		echo "------cp ${strTmp05}.nii.gz ${strSessTsnr}.nii.gz"
		cp ${strTmp05}.nii.gz ${strSessTsnr}.nii.gz

  else

		echo "------fslmaths ${strSessTsnr} -add ${strTmp05} ${strSessTsnr}"
		fslmaths ${strSessTsnr} -add ${strTmp05} ${strSessTsnr}

	fi

	# Increment run counter:
	var_cnt_div=$((var_cnt_div+1))
	echo "------Count: ${var_cnt_div}"

done

# Divide sum of all individual tSNR images by N:
echo "------fslmaths ${strSessTsnr} -div ${var_cnt_div} ${strSessTsnr}"
fslmaths ${strSessTsnr} -div ${var_cnt_div} ${strSessTsnr}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Calculate across-sessions mean images:

echo "---Calculate across-sessions mean images"

# Counter that is used to divide the sum of all images by N:
var_cnt_div=$((0))

# Name of across-sessions mean image:
strSessMne="${strPathOut}${str_sub_id}_mean"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

	# The name of the across-runs, within-session mean image:
	strTmp05="${strPathOut}${str_sub_id}_${idx_ses_id}_mean"

  # For first session, don't append (there's nothing to append to yet), but
  # copy the first session.
	if [ "${idx_num_run}" -eq "1" ]
	then

    # The starting point for the mean image is the first mean image. The
    # other individual mean images are subsequently added.
		echo "------cp ${strTmp05}.nii.gz ${strSessMne}.nii.gz"
		cp ${strTmp05}.nii.gz ${strSessMne}.nii.gz

  else

		echo "------fslmaths ${strSessMne} -add ${strTmp05} ${strSessMne}"
		fslmaths ${strSessMne} -add ${strTmp05} ${strSessMne}

	fi

	# Increment run counter:
	var_cnt_div=$((var_cnt_div+1))
	echo "------Count: ${var_cnt_div}"

done

# Divide sum of all individual mean images by N:
echo "------fslmaths ${strSessMne} -div ${var_cnt_div} ${strSessMne}"
fslmaths ${strSessMne} -div ${var_cnt_div} ${strSessMne}
#------------------------------------------------------------------------------
