#!/bin/bash


###############################################################################
# Copy template FSF file for FEAT analysis, and replace placeholders with     #
# data paths.                                                                 #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Input directory:
strPathIn="${str_data_path}derivatives/${str_sub_id}/func_distcorUnwrp/"

# Output directory:
strPathOut="${str_data_path}derivatives/${str_sub_id}/feat_level_1/"

# Path of template FSF file:
strTmplt="${str_anly_path}${str_sub_id}/02_feat/level_1_fsf/feat_level_1_template.fsf"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Prepare FSF file:

# FSF files for FEAT analysis are prepared from template (text replacement of
# placeholder variables.

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

    # Input path for current run:
    strTmpIn="${strPathIn}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # Output path for current run:
    strTmpOt="${strPathOut}${str_sub_id}_${idx_ses_id}_run_${idx_num_run}"

    # File name for new FSF file:
    strTmpFsf="${str_anly_path}${str_sub_id}/02_feat/level_1_fsf/${str_sub_id}_${idx_ses_id}_run_${idx_num_run}.fsf"

    # Copy template FSF file:
    cp ${strTmplt} ${strTmpFsf}

    # Replace placeholder input path:
  	sed -i "s|PLACEHOLDER_INPUT_PATH|${strTmpIn}|g" ${strTmpFsf}

    # Replace placeholder output path:
  	sed -i "s|PLACEHOLDER_OUTPUT_PATH|${strTmpOt}|g" ${strTmpFsf}

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#-------------------------------------------------------------------------------
