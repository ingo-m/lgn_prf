# -*- coding: utf-8 -*-

"""
Calculate nii temporal correlation.

Calculate and plot the correlations between 3D nii image (reference, e.g.
temporal mean) and 4D nii files. Result Can be used to assess data quality.

(C) Ingo Marquardt, 2016
"""


# *** Import modules

import os
import numpy as np
import nibabel as nb
import matplotlib
# Configure matplotlib for use in docker container (i.e. without display):
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# *** Define parameters

# Load environmental variables defining the input data path:
strDataPath = str(os.environ['str_data_path'])
strSubId = str(os.environ['str_sub_id'])

# Load environmental variable defining session IDs (e.g. "ses-01 ses-02"). Bash
# does not (currently) support export of arrays. Therefore, we need to turn the
# arrays into strings, and export the strings. Here the string is converted
# into a python list.
strSesIds = str(os.environ['str_ses_id'])
lstSesIds = strSesIds.split(' ')

# Get list of number of runs per session.
strNumRuns = str(os.environ['str_num_runs'])
lstNumRuns = strNumRuns.split(' ')
lstNumRuns = [int(x) for x in lstNumRuns]

# Lists for input file paths:
lstPathIn = []

# Create lists of input and output files
for idxSes in range(len(lstSesIds)):
    for idxRun in range(lstNumRuns[idxSes]):

        # Current run (plus one, because runs are coutned from one, an
        # zero-filled.
        strTmpRun = (str(idxRun + 1)).zfill(2)

        # Path to images to be swapped.
        lstPathIn.append((strDataPath
                          + 'derivatives/'
                          + strSubId
                          + '/func_reg_across_ses/'
                          + strSubId
                          + '_'
                          + lstSesIds[idxSes]
                          + '_run_'
                          + strTmpRun
                          + '.nii.gz'))

# Minimum acceptable correlation coefficient. If the mean correlation
# coefficient of any run is below this value, the run is highlighted in the
# graph.
varThr = 0.90

# The path of the 3D reference images (subject ID left open):
strPathRef = (strDataPath
              + 'derivatives/'
              + strSubId
              + '/func_reg_across_ses_tsnr/'
              + strSubId
              + '_mean.nii.gz')

# The output directory & name (for the plot; subject ID left open twice):
strPathOut = (strDataPath
              + 'derivatives/'
              + strSubId
              + '/reg_across_ses/'
              + strSubId
              + '_correlation_plot_refweight.png')

# Use mask? If yes, only voxels that are greater than zero in the mask
# image are considered. The reason for using the mask is that if
# registration was performed using reference weighting, it makes sense to
# assess the quality of the registration only at those voxels that were
# weighted highly. (Subject ID left open twice.)
lgcMsk = False
if lgcMsk:
    strPathMsk = (strDataPath
                  + 'derivatives/'
                  + strSubId
                  + '/spm_reg_across_runs/ref_weighting/'
                  + 'n_09b_'
                  + strSubId
                  + '_spm_refweight.nii')


# *** Loop through runs

print('---Spatial correlation')

# Get number of input files:
varNumInRef = len(lstPathIn)

for idxRun in range(varNumInRef):

    print('------Reference image:')
    print('---------' + strPathRef)

    # *** Load reference image

    # Load reference nii file (this doesn't load the data into memory yet):
    niiTmpRef = nb.load(strPathRef)

    # Load the data into memory:
    aryTmpRef = niiTmpRef.get_data()
    aryTmpRef = np.array(aryTmpRef)

    # Use reference mask?
    if lgcMsk:
        print('------Applying mask:')
        print('---------' + strPathMsk)
        niiTmpMsk = nb.load(strPathMsk)
        # Load data into memory:
        aryTmpMsk = niiTmpMsk.get_data()
        aryTmpMsk = np.array(aryTmpMsk)
        # Flatten the array into a vector:
        vecTmpMsk = aryTmpMsk.flatten(order='C')

    # In order to use the np.corrcoef function, the data have to be
    # arranged in columns. I.e. we rearrange the data so that there is
    # one column, with one row per voxel:
    aryTmpRef = aryTmpRef.flatten(order='C')

    # *** Load time series:

    # Path of timeseries of current run:
    strPathInTmp = lstPathIn[idxRun]

    print('------Time series image:')
    print('---------' + strPathInTmp)

    # Load 4D nii file (this doesn't load the data into memory yet):
    niiTmpSrc = nb.load(strPathInTmp)
    # Load the data into memory:
    aryTmpSrc = niiTmpSrc.get_data()
    aryTmpSrc = np.array(aryTmpSrc)
    # Get the shape of the 4D file:
    vecTmpShape = aryTmpSrc.shape

    # Get the number of volumes in the 4D file (assuming that the 4th
    # image dimension corresponds to time):
    varTmpNumVols = vecTmpShape[3]
    if idxRun == 0:
        # On the first iteration of the loop, we create a list that will
        # be filled with the correlation coefficients of all volumes:
        lstCorr = [None] * varNumInRef

    # Array for correlation coefficients of all volumes of current run:
    aryTmpCorr = np.zeros(varTmpNumVols)

    # *** Secondary loop (volumes in 4D file)

    for idxVol in range(varTmpNumVols):

        # Get 3D file:
        aryTmpSrc_3D = aryTmpSrc[:, :, :, idxVol]
        # Flatten the array into a vector:
        aryTmpSrc_3D = aryTmpSrc_3D.flatten(order='C')

        # *** Replace NaNs with zeros

        # Replace NaNs with zeros in the reference image:
        aryTmpRef = np.nan_to_num(aryTmpRef)
        # Replace NaNs with zeros in the source image:
        aryTmpSrc_3D = np.nan_to_num(aryTmpSrc_3D)

        # *** Exclude zero-elements

        # We have to exclude all datapoints that have a zero as a value in
        # both of the images. We first add both vectors. In the resulting
        # vector, datapoints that are zero in both images remain zero. All
        # other datapoints are non-zero.
        vecTmpSum = np.absolute(aryTmpRef) + np.absolute(aryTmpSrc_3D)

        # Use mask?
        if lgcMsk:
            # Apply mask:
            vecTmpSum = np.multiply(vecTmpSum,
                                    vecTmpMsk)
        # We create an array with the indices of the non-zero elements:
        vecTmpIdxNonzero = np.array(np.nonzero(vecTmpSum))

        # print('---------Volume: ' +
        #       str(idxVol) +
        #       ' Number of nonzero voxels: ' +
        #       str(vecTmpIdxNonzero.size))

        # We create a temporary vector with the non-zero elements for each
        # of the images:
        vecTmpNonzeroRef = aryTmpRef[vecTmpIdxNonzero]
        vecTmpNonzeroSrc = aryTmpSrc_3D[vecTmpIdxNonzero]

        # *** Calculate correlations

        # Calculate correlation coefficient. The output is a covariance
        # matrix:
        aryTmpCov = np.corrcoef(vecTmpNonzeroRef,
                                vecTmpNonzeroSrc)
        # Access correlation between reference image and source image:
        aryTmpCorr[idxVol] = aryTmpCov[0][1]

    # Put correlation values of current run into list:
    lstCorr[idxRun] = aryTmpCorr

    # *** Print results

    # Print mean correlation coefficient for this time series:
    varTmpCorrMean = np.mean(aryTmpCorr)
    print('------Mean correlation coefficient:    ' +
          str(varTmpCorrMean))
    # Print minimum correlation coefficient for this time series:
    varTmpCorrMin = np.min(aryTmpCorr)
    print('------Minimum correlation coefficient: ' +
          str(varTmpCorrMin))
    # Print standard deviation of the correlation coefficient for this
    # time series:
    varTmpCorrSd = np.std(aryTmpCorr)
    print('------Standard deviation of the correlation coefficient: ' +
          str(varTmpCorrSd))

# *** Plot correlations:

print('---Creating plot')

# Concatenate correlation arrays
aryCorr = np.concatenate(lstCorr[:], axis=0)

# x-axis:
# varXmax = aryCorr.shape[0]

# Figure & axes:
fig01 = plt.figure()

# First axis:
axs01 = fig01.add_subplot(111)

# x-min and x-max of first run:
varXmin = 0
varXmax = lstCorr[0].shape[0]

# Loop through runs and plot:
for idxRun in range(0, varNumInRef):

    # Vector for x-axis:
    vecXaxis = range(varXmin, varXmax, 1)

    # Mean correlation coefficient for this time series:
    varTmpCorrMean = np.mean(lstCorr[idxRun])

    # Decide on colour of line dependent on whether the mean correlation
    # coefficient for the current run is below or above the threshold:
    if np.greater_equal(varTmpCorrMean, varThr):
        strColour = 'blue'
    else:
        strColour = 'red'

    # Plot moco param 1:
    pltTmp = axs01.plot(vecXaxis,
                        lstCorr[idxRun],
                        color=strColour,
                        # label=('Correlation with reference volume'),
                        linewidth=0.6,
                        antialiased=True)

    # Increment minimum x value for the next run:
    varXmin = varXmax
    # Increment maximum x value for the next run, if the last run has not
    # been reached yet:
    if np.less((idxRun + 1), varNumInRef):
        varXmax = varXmax + lstCorr[idxRun + 1].shape[0]

# *** Adjust the axis, add title and legend, save the figure:

# Limits of the x-axis:
axs01.set_xlim([0, varXmax])

# Limits of the y-axis:
# varYmin = np.floor(np.min(aryTmpCorr * 10)) / 10
# varYmax = np.ceil(np.max(aryTmpCorr))
varYmin = 0.8
varYmax = 1.0
axs01.set_ylim([varYmin, varYmax])

# We add a text that displays the parameters across runs
# The mean correlation:
varCorrMean = np.average(aryCorr)
# The minimum correlation:
varCorrMin = np.min(aryCorr)
# The standard deviation of the correlation:
varCorrSd = np.std(aryCorr)
# Create string:
strTmp = (
          'Mean:      ' +
          str(np.round(varCorrMean, 3)) +
          '\n' +
          'Minimum: ' +
          str(np.round(varCorrMin, 3)) +
          '\n' +
          'SD: ' +
          str(np.round(varCorrSd, 3))
          )
axs01.text((varXmax * 0.2), ((varYmax - varYmin) * 0.1 + varYmin),
           strTmp,
           fontsize=10)

# Adjust labels for axis 1:
axs01.tick_params(labelsize=12)
axs01.set_xlabel('Volume number', fontsize=12)
axs01.set_ylabel('Correlation coefficient', fontsize=12)
axs01.set_title('Correlation with reference volume after motion ' +
                'correction',
                fontsize=14)

# axs01.legend(loc=1, prop={'size':7})

# Array for values on the x-axis that will be labelled:
vecXticks = np.zeros(varNumInRef)

# Add vertical grid lines between runs & get indicies for labels:
for idxRun in range(0, varNumInRef):

    # Get number of volumes in current run:
    varTmpNumVol = lstCorr[idxRun].shape[0]

    # The x-position of the grid line will be labelled:
    if idxRun < 1:
        # For the first run, the label position will be equal to the number
        # of volumes in that run:
        vecXticks[idxRun] = varTmpNumVol
    else:
        # For all subsequent runs, the label position will be that of the
        # previous label plus the number of volumes in the current run:
        vecXticks[idxRun] = (vecXticks[(idxRun - 1)] + varTmpNumVol)

    # Add vertical line:
    axs01.axvline(vecXticks[idxRun],
                  color=(0.5, 0.5, 0.5),
                  linewidth=0.2,
                  linestyle='-')

# Array with labels for the y-axis:
vecYticks = np.arange(varYmin, (varYmax + 0.01), 0.1)
# Create a list with the labels for the x-axis:
lstStrYticks = [format(x) for x in vecYticks]
# Set the labels for axis 1:
axs01.set_yticks(vecYticks)
axs01.set_yticklabels(lstStrYticks)

# Array with labels for the x-axis:
vecXticklabels = vecXticks
# Create a list with the labels for the x-axis:
lstStrXticks = [format(x) for x in vecXticklabels]
# Set the labels for axis 1:
axs01.set_xticks(vecXticks)
axs01.set_xticklabels(lstStrXticks)

# Save figure:
fig01.savefig(strPathOut,
              dpi=120,
              facecolor='w',
              edgecolor='w',
              transparent=False,
              frameon=None)

print('---Done.')
