#!/bin/bash


###############################################################################
# Parallelised across-runs, within-session SPM motion correction (several     #
# sessions at once).                                                          #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Path of template SPM file:
strTmplt="${str_anly_path}${str_sub_id}/01_preprocessing/n_09b_spm_create_moco_batch_template.m"

# Target directory for SPM files to create from template:
strTrgt="${str_anly_path}${str_sub_id}/01_preprocessing/spm_moco_batches/"

# Get parallelisation factor from environmental variable:
varPar=`bc <<< ${var_par_moco}+1`
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Prepare SPM files

echo "------Prepare SPM files for motion correction"

# SPM files for motion correction are prepared from template (text replacement
# of placeholder variables).

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # File name for new SPM file (to be created):
  strTmpSpm="${strTrgt}${idx_ses_id}_acr_runs.m"

  # Copy template SPM file:
  cp ${strTmplt} ${strTmpSpm}

  # Replace placeholder with session ID (e.g. "ses-01"):
  sed -i "s|PLACEHOLDER_SES_ID|${idx_ses_id}|g" ${strTmpSpm}

  # Replace placeholder with number of runs for this session (e.g. "9"):
  sed -i "s|PLACEHOLDER_NUM_RUNs|${ary_num_runs[var_cnt_ses]}|g" ${strTmpSpm}

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#-------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Run SPM motion correction

# Parallelisation is not limited, because number of sessions is assumed to be
# small (e.g. three).

echo "------Run SPM motion correction, within sessions, across runs"
date

# Session counter:
var_cnt_ses=0

# Loop through sessions (e.g. "ses-01"):
for idx_ses_id in ${ary_ses_id[@]}
do

  # Run SPM moco:
  /opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${strTrgt}${idx_ses_id}_acr_runs.m &

  # Wait for SPM startup:
  sleep 20

done
wait
date
#------------------------------------------------------------------------------
