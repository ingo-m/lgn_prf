#!/bin/bash


###############################################################################
# Parallelised within-run SPM motion correction (several runs at once).       #
###############################################################################


#------------------------------------------------------------------------------
# Define session IDs & paths

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Path of template SPM file:
strTmplt="${str_anly_path}${str_sub_id}/01_preprocessing/n_03b_spm_create_moco_batch_template.m"

# Get parallelisation factor from environmental variable:
varPar=`bc <<< ${var_par_moco}+1`
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Prepare SPM files

echo "------Prepare SPM files for motion correction"

# SPM files for motion correction are prepared from template (text replacement
# of placeholder variables).

# Counter for total number of runs (across sessions). Because moco is with SPM,
# we count from one (matlab convention).
var_cnt_run=1

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

    # Zero pad the counter for SPM directory name:
    strTmpSpmCnt=`printf %02d ${var_cnt_run}`

    # File name for new SPM file:
    strTmpSpm="${str_anly_path}${str_sub_id}/01_preprocessing/spm_moco_batches/run_${strTmpSpmCnt}.m"

    # Copy template SPM file:
    cp ${strTmplt} ${strTmpSpm}

    # Replace placeholder with run number (e.g. "01"):
    sed -i "s|PLACEHOLDER_RUN|${strTmpSpmCnt}|g" ${strTmpSpm}

    # Increment run counter:
    var_cnt_run=`bc <<< ${var_cnt_run}+1`

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#-------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Run SPM motion correction

echo "------Run SPM motion correction"
date

# Session counter:
var_cnt_ses=0

# Subtract one from run counter (because bash sequence includes endpoint):
var_cnt_run=`bc <<< ${var_cnt_run}-1`

# Loop through runs (e.g. "run_01"); i.e. zero filled indices ("01", "02",
# etc.).
for idx_num_run in $(seq -f "%02g" 1 ${var_cnt_run})
do

  # Run SPM moco:
  /opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${str_anly_path}${str_sub_id}/01_preprocessing/spm_moco_batches/run_${idx_num_run}.m &

  # Wait for SPM startup:
  sleep 20

  # Check whether it's time to issue a wait command (if the modulus of the
  # index and the parallelisation-value is zero). The purpose of the prefix
  # "10#" is to interpret the zero-filled run number (e.g. "08") as a decimal
  # number, and not as an octal number.
  if [[ $((10#${idx_num_run} + 1))%${varPar} -eq 0 ]]
  then
    # Only issue a wait command if the index is greater than zero (i.e.,
    # not for the first segment):
    if [[ 10#${idx_num_run} -gt 0 ]]
    then
      wait
      echo "------Progress: $((10#${idx_num_run})) runs out of ${var_cnt_run}"
    fi
  fi
done
wait

date
#------------------------------------------------------------------------------
