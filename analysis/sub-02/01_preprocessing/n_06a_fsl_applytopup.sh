#!/bin/bash


###############################################################################
# Apply distortion correction.                                                #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Data directory:
strPathParent="${str_data_path}derivatives/${str_sub_id}/"

# Path for 'datain' text file with acquisition parameters for applytopup (see
# TOPUP documentation for details):
strDatain02="${str_data_path}analysis/${str_sub_id}/01_preprocessing/n_06b_datain_applytopup.txt"

# Path of images to be undistorted (input):
strPathFunc="${strPathParent}func_reg/"

# Path for bias field (input):
strPathRes01="${strPathParent}func_distcorField/"

# Path for undistorted images (output):
strPathRes02="${strPathParent}func_distcorUnwrp/"

# Parallelisation factor:
varPar=5
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Apply distortion correction:

echo "---Apply distortion correction"
date

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

    # Path of functional run - input:
    strTmp01="${strPathFunc}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # Path of functional run - output:
    strTmp02="${strPathRes02}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    applytopup \
  	--imain=${strTmp01} \
  	--datain=${strDatain02} \
  	--inindex=1 \
  	--topup=${strPathRes01}${str_sub_id} \
  	--out=${strTmp02} \
  	--method=jac &

    # Check whether it's time to issue a wait command (if the modulus of the
  	# index and the parallelisation-value is zero):
  	if [[ $((${idxRun} + 1))%${varPar} -eq 0 ]]
  	then
  		# Only issue a wait command if the index is greater than zero (i.e.,
  		# not for the first segment):
  		if [[ ${idxRun} -gt 0 ]]
  		then
  			wait
  			echo "------Progress: $((${idxRun} + 1)) runs out of" \
  				"${varNumRun}"
  		fi
  	fi

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
wait
date
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Swap dimensions

# Topup can only be performed on the first or second dimensions. Because phase
# encode direction is head-foot (third dimensions), we have to swap dimensions.

# Swap dimensions for topup:
# fslswapdim ${strAllMerged} z x y ${strAllMerged}_swapped
#------------------------------------------------------------------------------
