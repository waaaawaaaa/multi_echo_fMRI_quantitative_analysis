% % List of open inputs
% nrun = 1; % enter the number of runs here
% jobfile = {'D:\proprecess\sub-001\step3_1_job.m'};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(0, nrun);
% for crun = 1:nrun
% end
% spm('defaults', 'FMRI');
% spm_jobman('run', jobs, inputs{:});
%对解剖像的处理 分割以及配准  我觉得配一次就够了，配准到rest1


ID={'001','002','003','004','005','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28

% ID={'001','002','003','004','005','006','007','010','011','012','013','015','016','017','018','019','020'};   %没有08 09 14 28
% ID={'021','022','023'};
% ID={'021','022','023','024','025','026','027','029','030','031','032'};

file_root = 'F:\rt-me-fMRI\';
task={'rest_run-2'};
% combined_data={'t2starFIT','TE_combined','echo2'};
% task={'fingerTapping','emotionProcessing','fingerTappingImagined','emotionProcessingImagined'};
parfor i=1:length(ID)
    for j=1:length(task)
%     for j=1:length(combined_data)
%     filepath = ['D:\proprecess\sub-' ID{i} '\fingerTapping\t2starFIT.nii'];
        matlabbatch = step31(file_root,ID{i},task{j});
        spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
    end
end


function matlabbatch = step31(file_root,ID,task)
    anat_path=[file_root 'sub-' ID '\anat\sub-' ID '_T1w.nii'];
    mean_path=[file_root 'sub-' ID '\func\meansub-' ID '_task-' task '_echo-2_bold.nii,1'];
    matlab_dir= 'D:\matlab\';
    %-----------------------------------------------------------------------
    % Job saved on 22-Mar-2023 10:16:57 by cfg_util (rev $Rev: 7345 $)
    % spm SPM - SPM12 (7771)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'raw';
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{anat_path}};
    matlabbatch{2}.spm.spatial.coreg.estimate.ref = {mean_path};
    matlabbatch{2}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Named File Selector: raw(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
    matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    matlabbatch{3}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Named File Selector: raw(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
    matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{3}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {[matlab_dir 'toolbox\spm12\tpm\TPM.nii,1']};
    matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {[matlab_dir 'toolbox\spm12\tpm\TPM.nii,2']};
    matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {[matlab_dir 'toolbox\spm12\tpm\TPM.nii,3']};
    matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {[matlab_dir 'toolbox\spm12\tpm\TPM.nii,4']};
    matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {[matlab_dir 'toolbox\spm12\tpm\TPM.nii,5']};
    matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {[matlab_dir 'toolbox\spm12\tpm\TPM.nii,6']};
    matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{3}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{3}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{3}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
end
