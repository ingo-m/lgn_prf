# -*- coding: utf-8 -*-
"""
Rename nii images (remove `_e1` suffix).

The dicom to nii conversion tool (dcm2niix) sometime appends a suffix (`_e1`)
to nii files. It does not seem to be possible to diable this, and it is not
clear under which circumstances the suffix is added. Thus, it has to be
removed.
"""

# Part of LGN pRF analysis pipeline.
# Copyright (C) 2018  Ingo Marquardt
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

import os
from os.path import isfile, join

# Load environmental variables defining the input data path, e.g.
# "/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/"
strDataPth = str(os.environ['str_data_path'])

# Load environmental variable representing the subject ID, e.g. "sub-02".
strSubId = str(os.environ['str_sub_id'])

# Load environmental variable defining session IDs (e.g. "ses-01 ses-02"). Bash
# does not (currently) support export of arrays. Therefore, we need to turn the
# arrays into strings, and export the strings. Here the string is converted
# into a python list.
strSesIds = str(os.environ['str_ses_id'])
lstSesIds = strSesIds.split(' ')

# Loop through sessions (for given subject). E.g. "ses-01", "ses-02", etc.
for idxSes in lstSesIds:

    # Full directory, e.g. '/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/
    # derivatives/sub-01/raw_data/ses-01/':
    strPathIn = (strDataPth
                 + 'derivatives/'
                 + strSubId
                 + '/raw_data/'
                 + idxSes
                 + '/')

    # Get list of files in results directory:
    lstFls = [f for f in os.listdir(strPathIn) if isfile(join(strPathIn, f))]

    # Rename nii files with '_e1' suffix:
    for strTmp in lstFls:
        if '_e1.' in strTmp:

            # Split into file path+name (without '_e1') and suffix (e.g.
            # 'nii.gz').
            strPth, strSuff = tuple(strTmp.split('_e1.'))

            # Rename file:
            os.rename((strPathIn + strTmp),
                      (strPathIn + strPth + '.' + strSuff))
