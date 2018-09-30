#!/bin/bash


###############################################################################
# Calculate field maps for distortion correction from opposite-phase-polarity #
# data. The input data need to be motion-corrected beforehands. A modified    #
# topup configuration may be used.                                            #
###############################################################################


echo "---Distortion correction"


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Data directory:
strPathParent="${str_data_path}derivatives/${str_sub_id}/"

# Name of configuration file:
strPathCnf="${str_data_path}analysis/${str_sub_id}/01_preprocessing/n_05b_highres.cnf"

# Path for 'datain' text file with acquisition parameters for topup (see TOPUP
# documentation for details):
strDatain01="${str_data_path}analysis/${str_sub_id}/01_preprocessing/n_05c_datain_topup.txt"

# Path of images to be undistorted (input):
strPathFunc="${strPathParent}func_reg/"

# Path of opposite-phase encode images (input):
strPathOpp="${strPathParent}func_op_reg/"

# Path for merged opposite-phase encode pair (intermediate output):
strPathMerged="${strPathParent}func_distcorMerged/"

# Path for bias field (intermediate output):
strPathRes01="${strPathParent}func_distcorField/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Merge opposite-phase-polarity images within runs

echo "---Merge opposite-phase-polarity images within runs"
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

    # Path of functional run:
    strTmp01="${strPathFunc}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

		# Get first five volumes of functional run:
		fslroi ${strTmp01} ${strTmp01}_5vols 0 5

		# Path of opposite phase encoding run:
		strTmp02="${strPathOpp}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

		# Ouput path for merged images:
		strTmp03="${strPathMerged}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

		# Merge first five volumes of functional run with opposite-phase encoding
		# run:
		fslmerge -t ${strTmp03} ${strTmp02} ${strTmp01}

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done

#------------------------------------------------------------------------------
# Merge opposite-phase-polarity images across runs

echo "---Merge opposite-phase-polarity images across runs & sessions"
date

# Session counter:
var_cnt_ses=0

# Output path for across runs & sessions file:
strAllMerged="${strPathMerged}${str_sub_id}_func_topup_merged"

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
  # etc.). Note that the number of runs may not be identical throughout
  # sessions.
	for idx_num_run in $(seq -f "%02g" 1 ${ary_num_runs[var_cnt_ses]})
  do

		# Path of input image (merged OP run + functional run):
		strTmp04="${strPathMerged}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

		# Merge current run to across-runs/sessions image:
		fslmerge -t ${strAllMerged} ${strAllMerged} ${strTmp04}

  done

	# Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Swap dimensions

# Topup can only be performed on the first or second dimensions. Because phase
# encode direction is head-foot (third dimensions), we have to swap dimensions.

# Swap dimensions for topup:
fslswapdim ${strAllMerged} z x y ${strAllMerged}_swapped
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Calculate field map:

echo "------Calculate field maps"
date

topup \
--imain=${strAllMerged}_swapped \
--datain=${strDatain01} \
--config=${strPathCnf} \
--out=${strPathRes01}${str_sub_id}

date
#------------------------------------------------------------------------------
