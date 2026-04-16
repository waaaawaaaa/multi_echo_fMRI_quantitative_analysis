% % List of open inputs
% nrun = X; % enter the number of runs here
% jobfile = {'F:\毕业设计\proprecess\pichuli01_job.m'};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(0, nrun);
% for crun = 1:nrun
% end
% spm('defaults', 'FMRI');
% spm_jobman('run', jobs, inputs{:});


% ID={'001','002','003'};  %差不多45分钟跑一个受试者
% ID={'001','002','003','004','005','006','007','010','011','012','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28
ID={'015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};
% ID={'021','022','023','024','025','026','027','029','030','031','032'};

for i=1:length(ID)
    matlabbatch = preproc(ID{i});
    spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
end


function matlabbatch = preproc(ID)

%-----------------------------------------------------------------------
% Job saved on 28-Feb-2023 17:03:02 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%可能要改文件名，slice timing信息序列不变就不改
%定义一个MATLABbatch
%-----------------------------------------------------------------------

    prefix_func = ['F:\朱梦莹毕业设计\rt-me-fMRI\sub-' ID '\func\sub-' ID];
   % prefix_anat = ['D:\rt-me-fMRI\sub-' ID '\anat\sub-' ID];
%     jsonslicetiming=[prefix_func '_task-rest_run-1_echo-2_bold.json'];

    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'raw';
    
    % 1 2 3对应的是预处理的步骤
    %%
    %路径和文件名需要修改
    
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {
                                                                         {
                                                                         [prefix_func '_task-emotionProcessing_echo-1_bold.nii']
                                                                         [prefix_func '_task-emotionProcessing_echo-2_bold.nii']
                                                                         [prefix_func '_task-emotionProcessing_echo-3_bold.nii']
                                                                         [prefix_func '_task-fingerTapping_echo-1_bold.nii']
                                                                         [prefix_func '_task-fingerTapping_echo-2_bold.nii']
                                                                         [prefix_func '_task-fingerTapping_echo-3_bold.nii']
                                                                         [prefix_func '_task-rest_run-1_echo-1_bold.nii']
                                                                         [prefix_func '_task-rest_run-1_echo-2_bold.nii']
                                                                         [prefix_func '_task-rest_run-1_echo-3_bold.nii']
                                                                         }
                                                                         {
                                                                         [prefix_func '_task-emotionProcessingImagined_echo-1_bold.nii']
                                                                         [prefix_func '_task-emotionProcessingImagined_echo-2_bold.nii']
                                                                         [prefix_func '_task-emotionProcessingImagined_echo-3_bold.nii']
                                                                         [prefix_func '_task-fingerTappingImagined_echo-1_bold.nii']
                                                                         [prefix_func '_task-fingerTappingImagined_echo-2_bold.nii']
                                                                         [prefix_func '_task-fingerTappingImagined_echo-3_bold.nii']
                                                                         [prefix_func '_task-rest_run-2_echo-1_bold.nii']
                                                                         [prefix_func '_task-rest_run-2_echo-2_bold.nii']
                                                                         [prefix_func '_task-rest_run-2_echo-3_bold.nii']
                                                                         }
                                                                         }';
    %%
     %头动校正
    matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Named File Selector: raw(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
    matlabbatch{2}.spm.spatial.realign.estwrite.data{2}(1) = cfg_dep('Named File Selector: raw(2) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{2}));
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

 %slicetiming
    matlabbatch{3}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
    matlabbatch{3}.spm.temporal.st.scans{2}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 2)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','rfiles'));
    matlabbatch{3}.spm.temporal.st.nslices = 34;
    matlabbatch{3}.spm.temporal.st.tr = 2;
    matlabbatch{3}.spm.temporal.st.ta = 1.94;
    %     %可以读入每一个图像的slicetiming，但所有切片时间序列一样，可以不用
%     json = jsondecode(fileread(jsonslicetiming));%读json文件
%     matlabbatch{2}.spm.temporal.st.so = json.SliceTiming';
    matlabbatch{3}.spm.temporal.st.so = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34];
    matlabbatch{3}.spm.temporal.st.refslice = 17;
    matlabbatch{3}.spm.temporal.st.prefix = 'a';
    
end
