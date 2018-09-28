#!/bin/bash


###############################################################################
# Convert DICOMs to nii.                                                      #
###############################################################################


# Bash does not currently support export of arrays. Therefore, arrays (e.g.
# with session IDs) are turned into strings before export. Here, we turn them
# back into arrays.
IFS=" " read -r -a ary_ses_id <<< "$str_ses_id"
IFS=" " read -r -a ary_date_id <<< "$str_date_id"

# Number of sessions.
var_num_ses=${#ary_ses_id[@]}

# Subtract one (because indexing starts from zero).
var_num_ses=`bc <<< ${var_num_ses}-1`

# Loop through sessions (separate source and target folders per session).
for idx_num_ses in $(seq 0 $var_num_ses)
do
  # Conversion of dicom to nii
  dcm2niix \
  -6 \
  -b y \
  -ba y \
  -f PROTOCOL_%p_SERIES_%3s \
  -g n \
  -i n \
  -m n \
  -o "${str_data_path}derivatives/${str_sub_id}/raw_data/${ary_ses_id[idx_num_ses]}" \
  -p n \
  -s n \
  -t n \
  -v 0 \
  -x n \
  -z y \
  "${str_data_path}sourcedata/dicoms/${ary_date_id[idx_num_ses]}/"
done
