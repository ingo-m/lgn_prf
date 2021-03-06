# -*- coding: utf-8 -*-
"""
Deface anatomical images.

Images are anonymised (i.e. 'defaced') by setting anterior voxels to zero.
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
import numpy as np
import nibabel as nb

# ------------------------------------------------------------------------------
# ### Function definitions


def load_nii(strPathIn, varSzeThr=5000.0):
    """
    Load nii file.

    Parameters
    ----------
    strPathIn : str
        Path to nii file to load.
    varSzeThr : float
        If the nii file is larger than this threshold (in MB), the file is
        loaded volume-by-volume in order to prevent memory overflow. Default
        threshold is 1000 MB.

    Returns
    -------
    aryNii : np.array
        Array containing nii data. 32 bit floating point precision.
    objHdr : header object
        Header of nii file.
    aryAff : np.array
        Array containing 'affine', i.e. information about spatial positioning
        of nii data.

    Notes
    -----
    If the nii file is larger than the specified threshold (`varSzeThr`), the
    file is loaded volume-by-volume in order to prevent memory overflow. The
    reason for this is that nibabel imports data at float64 precision, which
    can lead to a memory overflow even for relatively small files.

    """
    # Load nii file (this does not load the data into memory yet):
    objNii = nb.load(strPathIn)

    # Get size of nii file:
    varNiiSze = os.path.getsize(strPathIn)

    # Convert to MB:
    varNiiSze = np.divide(float(varNiiSze), 1000000.0)

    # Load volume-by-volume or all at once, depending on file size:
    if np.greater(varNiiSze, float(varSzeThr)):

        # Load large nii file

        print(('---------Large file size ('
              + str(np.around(varNiiSze))
              + ' MB), reading volume-by-volume'))

        # Get image dimensions:
        tplSze = objNii.shape

        # Create empty array for nii data:
        aryNii = np.zeros(tplSze, dtype=np.float32)

        # Loop through volumes:
        for idxVol in range(tplSze[3]):
            aryNii[..., idxVol] = np.asarray(
                  objNii.dataobj[..., idxVol]).astype(np.float32)

    else:

        # Load small nii file

        # Load nii file (this doesn't load the data into memory yet):
        objNii = nb.load(strPathIn)

        # Load data into array:
        aryNii = np.asarray(objNii.dataobj).astype(np.float32)

    # Get headers:
    objHdr = objNii.header

    # Get 'affine':
    aryAff = objNii.affine

    # Output nii data (as numpy array), header, and 'affine':
    return aryNii, objHdr, aryAff


# ------------------------------------------------------------------------------
# ### Deface anatomical images

print('---Deface anatomical images')

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

    # Full input data path:
    strPathIn = (strDataPth
                 + 'bids/'
                 + strSubId
                 + '/'
                 + idxSes
                 + '/anat/')

    # The number of anatomical images per session may vary (especially the
    # number of PD images). Therefore, we don't hard code filenames here, but
    # get a list of nii files in the target directory.
    lstFls = [f for f in os.listdir(strPathIn) if isfile(join(strPathIn, f))]

    # Delete results of test:
    for strPthTmp in lstFls:

        # Only nii files (or nii.gz):
        if '.nii' in strPthTmp:

            print(('------Defacing: ' + strPthTmp))

            # Load image:
            aryNiiTmp, objHdrTmp, aryAffTmp = load_nii((strPathIn + strPthTmp))

            # Set anterior voxels to zero:
            aryNiiTmp[:, 215:, :] = 0.0

            # Create output nii object:
            niiOut = nb.Nifti1Image(aryNiiTmp,
                                    aryAffTmp,
                                    header=objHdrTmp
                                    )
            # Save nii:
            nb.save(niiOut, (strPathIn + strPthTmp))
# ------------------------------------------------------------------------------
