#!/bin/bash


###############################################################################
# Parallelised across-runs, within-session SPM motion correction (several     #
# sessions at once).                                                          #
###############################################################################


#------------------------------------------------------------------------------
# ### Define session IDs & paths

# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_num_runs <<< "$str_num_runs"

# Path of template SPM file:
strTmplt="${str_anly_path}${str_sub_id}/03_func_to_anat/n_02b_spm_create_corr_template.m"

# Target directory for SPM files to create from template:
strTrgt="${str_anly_path}${str_sub_id}/03_func_to_anat/spm_corr_batches/"

# Directory with data to register (basepath, followed by session ID, e.g.
# "ses-01").
strPthSpm="${str_data_path}derivatives/${str_sub_id}/reg_func_to_anat/"

# Get parallelisation factor from environmental variable:
varPar=`bc <<< ${var_par_moco}+1`
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Prepare SPM files

echo "------Prepare SPM files for registration (functional to anatomical)"

# SPM files for registration are prepared from template (text replacement of
# placeholder variables).

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

    # File name for new SPM file (to be created):
    strTmpSpm="${strTrgt}${idx_ses_id}_run_${idx_num_run}_reg_func_to_anat.m"

    # Copy template SPM file:
    cp ${strTmplt} ${strTmpSpm}

    # Replace placeholder with path of reference image:
    strPthTmp="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/anat/"
    sed -i "s|PLACEHOLDER_PATH_ANAT|${strPthTmp}|g" ${strTmpSpm}


    # Replace placeholder with path of source image (to be registered):
    strPthTmp="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/mean_func/"
    sed -i "s|PLACEHOLDER_PATH_MEAN_FUNC|${strPthTmp}|g" ${strTmpSpm}

    # Replace placeholder with path of other images to be registered:
    strPthTmp="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/func/"
    sed -i "s|PLACEHOLDER_PATH_FUNC_RUNS|${strPthTmp}|g" ${strTmpSpm}

    # Replace placeholder with path of SPM batch to create:
    strPthTmp="${strPthSpm}${idx_ses_id}/run_${idx_num_run}/spm_corr_batch_run_${idx_num_run}.mat"
    sed -i "s|PLACEHOLDER_PATH_BATCH|${strPthTmp}|g" ${strTmpSpm}

    # Replace placeholder with number of runs:
    # strPthTmp="${ary_num_runs[var_cnt_ses]}"
    # sed -i "s|PLACEHOLDER_NUM_RUNS|${strPthTmp}|g" ${strTmpSpm}

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Run SPM registration (functional to anatomical)

# Parallelisation is not limited, because number of sessions is assumed to be
# small (e.g. three).

echo "------Run SPM registration (functional to anatomical)"
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

    # Run SPM registration:
    /opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${strTrgt}${idx_ses_id}_run_${idx_num_run}_reg_func_to_anat.m &

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
        echo "------Progress: $((10#${idx_num_run})) runs out of ${var_num_runs}"
      fi
    fi

  done

  # Increment session counter:
  var_cnt_ses=`bc <<< ${var_cnt_ses}+1`

done
wait
date
#------------------------------------------------------------------------------
