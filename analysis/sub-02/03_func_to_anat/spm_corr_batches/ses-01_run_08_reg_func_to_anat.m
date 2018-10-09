%--------------------------------------------------------------------------
% Create a 'batch' file for SPM coregistration of functional to anatomical
% images.
%--------------------------------------------------------------------------
% NOTE: The input images have to be in UNCOMPRESSED nii format for SPM.
%--------------------------------------------------------------------------
% Ingo Marquardt, 2017
%--------------------------------------------------------------------------
%% Define variable parameters:
clear;
% Directory of reference image (anatomical image):
strPathRef = '/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/reg_func_to_anat/ses-01/run_08/anat/';
% Directory of source image (mean functional image):
strPathSrc = '/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/reg_func_to_anat/ses-01/run_08/mean_func/';
% Directory with other images to be registered along source image
% (functional time series):
strPathOtr = '/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/reg_func_to_anat/ses-01/run_08/func/';
% Name of the 'SPM batch' to be created:
strPathBatch = '/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/derivatives/sub-02/reg_func_to_anat/ses-01/run_08/spm_corr_batch_run_08.mat';
% Number of functional runs:
% varNumRuns = PLACEHOLDER_NUM_RUNS;
% Resolution of input images in mm (is assumed to be isotropic):
varRes = 0.7;
%--------------------------------------------------------------------------
%%% Prepare input - file lists of functional time series:
%% The paths of the functional runs:
%cllPathFunc = cell(1,varNumRuns);
%for index_01 = 1:varNumRuns
%    if index_01 < 10
%        strTmp = strcat(strPathOtr, ...
%            'run_0', ...
%            num2str(index_01), ...
%            '/');
%    else
%        strTmp = strcat(strPathOtr, ...
%            'run_', ...
%            num2str(index_01), ...
%            '/');
%    end
%    cllPathFunc{index_01} = spm_select('ExtList', ...
%        strTmp, ...
%        '.nii', ...
%        Inf);
%    cllPathFunc{index_01} = cellstr(cllPathFunc{index_01});
%    cllPathFunc{index_01} = strcat(strTmp, cllPathFunc{index_01});
%end
%%--------------------------------------------------------------------------
%%% Prepare input - file lists of functional time series:
%% The paths of the functional runs:
%cllPathFunc = cell(1);
%% Select nii files on input path:
%cllPathFunc{1} = spm_select('ExtList', ...
%    strPathOtr, ...
%    '.nii', ...
%    Inf);
%cllPathFunc{1} = cellstr(cllPathFunc{1});
%cllPathFunc{1} = strcat(strTmp, cllPathFunc{1});
%--------------------------------------------------------------------------
%% Prepare input - file lists of functional time series:
% Select nii files on input path:
cllPathFunc = spm_select('ExtList', ...
    strPathOtr, ...
    '.nii', ...
    Inf);
cllPathFunc = cellstr(cllPathFunc);
cllPathFunc = strcat(strPathOtr, cllPathFunc);
%--------------------------------------------------------------------------
%% Prepare input - referenec image:
% The cell array with the file name of the mean M0 image:
cllPathRef = spm_select('ExtList', ...
    strPathRef, ...
    '.nii', ...
    Inf);
% Place the cell array with the reference image file name in a cell array
% within the original cell array:
cllPathRef = cellstr(cllPathRef);
% Add the parent path:
cllPathRef = strcat(strPathRef, cllPathRef);
%--------------------------------------------------------------------------
%% Prepare input - source image:
% The cell array with the file name of the referecne image:
cllPathSrc = spm_select('ExtList', ...
    strPathSrc, ...
    '.nii', ...
    Inf);
% Place the cell array with the reference image file name in a cell array
% within the original cell array:
cllPathSrc = cellstr(cllPathSrc);
% Add the parent path:
cllPathSrc = strcat(strPathSrc, cllPathSrc);
%--------------------------------------------------------------------------
%% Prepare parameters for coregistration
% Clear old batches:
clear matlabbatch;
% Here we determine the settings for the SPM coregistration. See SPM
% manual for details. First, the parameters for the estimation:
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = cllPathRef;
matlabbatch{1}.spm.spatial.coreg.estwrite.source = cllPathSrc;
matlabbatch{1}.spm.spatial.coreg.estwrite.other = cllPathFunc;
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = ...
    [6*varRes, 5*varRes, 4*varRes, 3*varRes, 2*varRes, 1*varRes];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = ...
    [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = ...
    [7, 7];
% Secondly, the parameters for the reslicing:
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 7;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
%--------------------------------------------------------------------------
%% Save SPM batch file:
save(strPathBatch, 'matlabbatch');
%--------------------------------------------------------------------------
%% Perform registration
% Initialise "job configuration":
spm_jobman('initcfg');
% Run 'job':
spm_jobman('run', matlabbatch);
%--------------------------------------------------------------------------
%% Exit matlab
% Because this matlab scrit gets called from command line, we have to
% include an exit statement:
exit
%--------------------------------------------------------------------------
