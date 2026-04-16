% % List of open inputs
% nrun = X; % enter the number of runs here
% jobfile = {'D:\proprecess\sub-001\physio_job.m'};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(0, nrun);
% for crun = 1:nrun
% end
% spm('defaults', 'FMRI');
% spm_jobman('run', jobs, inputs{:});

ID={'001','002','003','004','005','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28
% ID={'013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28

file_root = 'F:\rt-me-fMRI\';
% task={'fingerTapping'};
% combined_data={'t2starFIT','TE_combined','echo2'};
combined_data={'TE_combined'};
task={'fingerTapping','emotionProcessing','fingerTappingImagined','emotionProcessingImagined'};

parfor i=1:length(ID)
    for j=1:length(task)
%     filepath = ['D:\proprecess\sub-' ID{i} '\fingerTapping\t2starFIT.nii'];
        matlabbatch = physio_process(file_root,ID{i},task{j});
        spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
    end
end


function matlabbatch = physio_process(file_root,ID,task)
    save_dir = [file_root 'sub-' ID '\' task '\physio'];
    physio_files = [file_root 'sub-' ID '\func\sub-' ID '_task-' task '_physio.tsv'];
    gunzip([physio_files '.gz']);

    %-----------------------------------------------------------------------
    % Job saved on 26-Mar-2023 17:18:23 by cfg_util (rev $Rev: 7345 $)
    % spm SPM - SPM12 (7771)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    matlabbatch{1}.spm.tools.physio.save_dir = {save_dir};
    matlabbatch{1}.spm.tools.physio.log_files.vendor = 'BIDS';
    matlabbatch{1}.spm.tools.physio.log_files.cardiac = {physio_files};
    matlabbatch{1}.spm.tools.physio.log_files.respiration = {''};
    matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {''};
    matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
    matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = [];
    matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'first';
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = 34;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = 2;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = 210;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = 17;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = 0.0588235294117647;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = 0;
    matlabbatch{1}.spm.tools.physio.scan_timing.sync.scan_timing_log = struct([]);
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.no = struct([]);
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.max_heart_rate_bpm = 90;
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
    matlabbatch{1}.spm.tools.physio.preproc.respiratory.filter.passband = [0.05 2];
    matlabbatch{1}.spm.tools.physio.preproc.respiratory.despike = false;
    matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';
    matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio.mat';
    matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
    matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
    matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c = 3;
    matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r = 4;
    matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr = 0;
    matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.noise_rois.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.movement.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
    matlabbatch{1}.spm.tools.physio.verbose.level = 2;
    matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = '';
    matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;
end
