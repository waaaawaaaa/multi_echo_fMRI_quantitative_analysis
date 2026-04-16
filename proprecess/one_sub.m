% % List of open inputs
% nrun = X; % enter the number of runs here
% jobfile = {'F:\朱梦莹毕业设计\proprecess\sub-001\one_task_job.m'};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(0, nrun);
% for crun = 1:nrun
% end
% spm('defaults', 'FMRI');
% spm_jobman('run', jobs, inputs{:});
% sub-001_task-fingerTappingImagined_echo-2_bold
% sub-001_task-emotionProcessingImagined_echo-3_bold
% sub-001_task-emotionProcessing_echo-2_bold
% sub-001_task-rest_run-2_echo-3_bold
% sub-001_task-fingerTapping_echo-3_bold

% ID={'001','002','003','004','005','006','007','010','011','012','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28
% ID={'015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};
% ID={'021','022','023','024','025','026','027','029','030','031','032'};

task={'fingerTapping','emotionProcessing','rest_run-2','fingerTappingImagined','emotionProcessingImagined'};
echo={'echo-1','echo-2','echo-3'};
for i=1:length(task)
    for j=1:length(echo)
        file_name=['F:\朱梦莹毕业设计\proprecess\sub-001\func\sub-001_task-' task{i} '_' echo{j} '_bold.nii'];
        matlabbatch = preproc(file_name);
        spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
    end
end

function matlabbatch = preproc(file_name)
%-----------------------------------------------------------------------
% Job saved on 11-Mar-2023 22:18:48 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%     prefix_func = ['F:\朱梦莹毕业设计\rt-me-fMRI\sub-' ID '\func\sub-' ID];
%     'F:\朱梦莹毕业设计\proprecess\sub-001\func\sub-001_task-emotionProcessingImagined_echo-1_bold.nii'
    
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'raw';
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{file_name}};
    matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Named File Selector: raw(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    matlabbatch{3}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
    matlabbatch{3}.spm.temporal.st.nslices = 34;
    matlabbatch{3}.spm.temporal.st.tr = 2;
    matlabbatch{3}.spm.temporal.st.ta = 1.94;
    matlabbatch{3}.spm.temporal.st.so = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34];
    matlabbatch{3}.spm.temporal.st.refslice = 17;
    matlabbatch{3}.spm.temporal.st.prefix = 'a';
end