%------------------------------------------------------------------------------
% Create a 'batch' file for SPM motion correction. First round of moco, within
% runs, without refweight.
%------------------------------------------------------------------------------
% Ingo Marquardt, 2017
%------------------------------------------------------------------------------
%% Define variable parameters:
clear;
% Get environmental variables (for input & output paths):
strSubId = getenv('str_sub_id');
% strAnalyPth = getenv('str_anly_path');
strDataPth = getenv('str_data_path');
varNumRuns = int16(str2num(getenv('var_num_runs')));
% Path of the SPM moco directory:
strPathParent = strcat(strDataPth, 'derivatives/', strSubId, '/spm_reg_within_runs_op/');
%------------------------------------------------------------------------------
%% Loop through runs:
for idxRun = 1:varNumRuns
  % Name of the 'SPM batch' to be created:
  strPathOut = [ ...
      strPathParent, ...
      'spm_moco_batch_0', ...
      num2str(idxRun), ...
      '.mat'];
  %----------------------------------------------------------------------------
  %% Prepare input - file lists of nii files:
  % The paths of the functional runs:
  cllPathFunc = cell(1);
  if idxRun < 10
      strTmp = strcat(strPathParent, ...
          '0', ...
          num2str(idxRun), ...
          '/');
  else
      strTmp = strcat(strPathParent, ...
          num2str(idxRun), ...
          '/');
  end
  cllPathFunc{1} = spm_select('ExtList', ...
      strTmp, ...
      '.nii', ...
      Inf);
  cllPathFunc{1} = cellstr(cllPathFunc{1});
  cllPathFunc{1} = strcat(strTmp, cllPathFunc{1});
  %----------------------------------------------------------------------------
  %% Prepare parameters for motion correction
  % Clear old batches:
  clear matlabbatch;
  % Here we determine the settings for the SPM registrations. See SPM manual
  % for details. First, the parameters for the estimation:
  matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 1.0;
  matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 0.9;
  matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 1.8;
  matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
  matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 7;
  matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
  % Secondly, the parameters for the reslicing:
  matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
  matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 7;
  matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
  matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
  matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
  % The cell array containing the input files. There are now several cell
  % arrays that include the input data. We need to combine those into one
  % cell array. Note: We only include the functional time series in this
  % array, not the reference weighting image. That one is entered separately.
  matlabbatch{1}.spm.spatial.realign.estwrite.data = ...
      [cllPathFunc]; %#ok<NBRAK>
  %----------------------------------------------------------------------------
  %% Save SPM batch file:
  save(strPathOut, 'matlabbatch');
  %----------------------------------------------------------------------------
  %% Perform motion correction
  % Initialise "job configuration":
  spm_jobman('initcfg');
  % Run 'job':
  spm_jobman('run', matlabbatch);
%------------------------------------------------------------------------------
%% Exit matlab
% Because this matlab scrit gets called from command line, we have to
% include an exit statement:
exit
%------------------------------------------------------------------------------
