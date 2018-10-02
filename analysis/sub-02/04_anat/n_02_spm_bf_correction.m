%--------------------------------------------------------------------------
% SPM bias field correction of anatomical images.
%--------------------------------------------------------------------------
% Ingo Marquardt, 2018
%--------------------------------------------------------------------------
%% Define parameters
clear;
% Get environmental variables (for input & output path):
str_sub_id = getenv('str_sub_id');
str_anly_path = getenv('str_anly_path');
str_data_path = getenv('str_data_path');
% Path of the default SPM batch:
strPthDflt = strcat(str_anly_path, 'spm_metadata/spm_default_bf_correction_batch.mat');
% Directory with images to be corrected:
strPthIn = strcat(str_data_path, 'derivatives/', str_sub_id, '/anat/02_spm_bf_correction/');
%--------------------------------------------------------------------------
%% Prepare input cell array
% The cell array with the file name of the images to be bias field
% corrected:
cllPthIn = spm_select('ExtList', ...
    strPthIn, ...
    '.nii', ...
    Inf);
cllPthIn = cellstr(cllPthIn);
for idxIn = 1:length(cllPthIn)
    cllPthIn{idxIn} = strcat(strPthIn, cllPthIn{idxIn});
end
%--------------------------------------------------------------------------
%% Prepare SPM batch
clear matlabbatch;
matlabbatch{1}.spm.spatial.preproc.channel.vols = cllPthIn;
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [1, 1];
%--------------------------------------------------------------------------
%% Save SPM batch file
strOut = strcat(strPthIn, 'spm_bf_correction_batch');
save(strOut, 'matlabbatch');
%--------------------------------------------------------------------------
%% Bias field correction
% Initialise 'job configuration':
spm_jobman('initcfg');
% Run 'job':
spm_jobman('run', matlabbatch);
%--------------------------------------------------------------------------
%% Exit matlab
% Because this matlab scrit gets called from command line, we have to
% include an exit statement:
exit
%--------------------------------------------------------------------------
