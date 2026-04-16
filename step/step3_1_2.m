ID={'001','002','003'};  %差不多45分钟跑一个受试者
% ID={'001','002','003','004','005','006','007','010','011','012','013','015','016','017','018','019','020'};   %没有08 09 14 28
% ID={'021','022','023'};
% ID={'021','022','023','024','025','026','027','029','030','031','032'};

file_root = 'D:\rt-me-fMRI\';
task={'fingerTapping'};
combined_data={'t2starFIT','TE_combined','echo2'};

%3.1配准和分割，针对于解剖像
for i=1:length(ID)
%     for j=1:length(combined_data)
%     filepath = ['D:\proprecess\sub-' ID{i} '\fingerTapping\t2starFIT.nii'];
    matlabbatch = step31(file_root,ID{i},task{1});
    spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
%     end
end


%3.2，归一化和GLM分析
for i=1:length(ID)
    for j=1:length(combined_data)
%     filepath = ['D:\proprecess\sub-' ID{i} '\fingerTapping\t2starFIT.nii'];
        matlabbatch = step32(file_root,ID{i},task{1},combined_data{j});
        spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
    end
end

function matlabbatch = step31(file_root,ID,task)
    anat_path=[file_root 'sub-' ID '\anat\sub-' ID '_T1w.nii'];
    mean_path=[file_root 'sub-' ID '\func\meansub-' ID '_task-' task '_echo-2_bold.nii,1'];
    matlab_dir= 'D:\Download\matlab2022\';
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



function matlabbatch = step32(file_root,ID,task,combined_data)
    %-----------------------------------------------------------------------
    % Job saved on 22-Mar-2023 13:21:33 by cfg_util (rev $Rev: 7345 $)
    % spm SPM - SPM12 (7771)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    func_path=[file_root 'sub-' ID '\' task '\' combined_data '.nii'];
    reference_path=[file_root 'sub-' ID '\anat\y_sub-' ID '_T1w.nii'];
    manat_path=[file_root 'sub-' ID '\anat\msub-' ID '_T1w.nii,1'];
    rp_path=[file_root 'sub-' ID '\func\rp_sub-' ID '_task-' task '_echo-2_bold.txt'];
    save_path=[file_root 'sub-' ID '\1st_' combined_data];
    mkdir(save_path)
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'raw';
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{func_path}};
    matlabbatch{2}.spm.spatial.normalise.write.subj.def = {reference_path};
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Named File Selector: raw(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
    matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              78 76 85];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [3.5 3.5 3.5];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = 'w';
    matlabbatch{3}.spm.spatial.normalise.write.subj.def = {reference_path};
    matlabbatch{3}.spm.spatial.normalise.write.subj.resample = {manat_path};
    matlabbatch{3}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              78 76 85];
    matlabbatch{3}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{3}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{3}.spm.spatial.normalise.write.woptions.prefix = 'w';
    matlabbatch{4}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{4}.spm.spatial.smooth.fwhm = [7 7 7];
    matlabbatch{4}.spm.spatial.smooth.dtype = 0;
    matlabbatch{4}.spm.spatial.smooth.im = 0;
    matlabbatch{4}.spm.spatial.smooth.prefix = 's';
    matlabbatch{5}.spm.stats.fmri_spec.dir = {save_path};
    matlabbatch{5}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{5}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{5}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond.name = 'FT';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond.onset = [20
                                                          60
                                                          100
                                                          140
                                                          180
                                                          220
                                                          260
                                                          300
                                                          340
                                                          380];
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond.duration = 20;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond.tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond.orth = 1;
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{5}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi_reg = {rp_path};
    matlabbatch{5}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{5}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{5}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{5}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{5}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{5}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{5}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{5}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{6}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{6}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{6}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{7}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{7}.spm.stats.con.consess{1}.tcon.name = 'FT';
    matlabbatch{7}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{7}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{7}.spm.stats.con.delete = 0;
    matlabbatch{8}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{8}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{8}.spm.stats.results.conspec.contrasts = 1;
    matlabbatch{8}.spm.stats.results.conspec.threshdesc = 'FWE';
    matlabbatch{8}.spm.stats.results.conspec.thresh = 0.05;
    matlabbatch{8}.spm.stats.results.conspec.extent = 0;
    matlabbatch{8}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{8}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{8}.spm.stats.results.units = 1;
    matlabbatch{8}.spm.stats.results.export{1}.ps = true;
end