clc;clear;
ID={'001','002','003','004','005','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 12 14 28
% ID={'001'};
% ID={'012'}; %这个数据有问题，无法load
file_root = 'F:\rt-me-fMRI\';
% file_root = 'D:\rt-me-fMRI\';

task={'fingerTapping'};    %后面均写成了task{1} 

TE = [0.014 0.028 0.042];

% %先重采样分割后影像
% for i=1:length(ID)
%     matlabbatch = resample1(file_root,ID{i},task{1});
%     spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
%    
% end

%第二步，多回波合并，使用三个分别是echo2，TEcombined T2*FIT
for i=1:length(ID)
    save_path=[file_root 'sub-' ID{i} '\' task{1}];
    mkdir(save_path)
    %读取finger tapping文件，共三个回波
    nii_dir = [file_root 'sub-' ID{i} '\func\arsub-' ID{i} '_task-' task{1} '_'];
    %回波1
    nii_dir_echo1 = [nii_dir 'echo-1_bold.nii'];
    nii_echo1 = load_nii(nii_dir_echo1);
    data_4D_echo1 = double(nii_echo1.img);   %将单精度转换为了双精度
    
    %回波2
    nii_dir_echo2 = [nii_dir 'echo-2_bold.nii'];
    nii_echo2 = load_nii(nii_dir_echo2);
    data_4D_echo2 = double(nii_echo2.img);
    
    %回波3
    nii_dir_echo3 = [nii_dir 'echo-3_bold.nii'];
    nii_echo3 = load_nii(nii_dir_echo3);
    data_4D_echo3 = double(nii_echo3.img);
    
    %整合三个回波，便于后边的for循环
    func_data(:,:,:,:,1) = data_4D_echo1;
    func_data(:,:,:,:,2) = data_4D_echo2;
    func_data(:,:,:,:,3) = data_4D_echo3;
    
    [Ni, Nj, Nk, Nt] = size(data_4D_echo1);
    masksSPM = fmrwhy_util_loadMasksSPM(file_root, ID{i});
    I_mask = masksSPM.brain_mask_I;
    t2sFIT_fn = fullfile(save_path, '\t2starFIT_bold.nii');

    for t = 1:Nt

        func_data_pv = {};
        for e = 1:numel(TE)
            func_data_pv{e} = squeeze(func_data(:,:,:,t,e));
        end

        me_params = fmrwhy_realtime_estimateMEparams(func_data_pv, TE, I_mask);
% 
%         func_pv = zeros([template_dim numel(TE)]);
%         for e = 1:3
%             func_pv(:,:,:,e) = func_data_pv{e};
%         end

%         combined_t2sFIT_3D = fmrwhy_me_combineEchoes(func_pv, TE, 0, 1, me_params.T2star_3D_thresholded);
% 
%         new_spm_combined_t2sFIT(t).fname = combined_t2sFIT_fn;
%         new_spm_combined_t2sFIT(t).private.dat.fname = combined_t2sFIT_fn;
%         spm_write_vol(new_spm_combined_t2sFIT(t), combined_t2sFIT_3D);

%         new_spm_t2sFIT(t).fname = t2sFIT_fn;
%         new_spm_t2sFIT(t).private.dat.fname = t2sFIT_fn;
%         new_spm_t2sFIT(t).pinfo(1) = 1;
%         spm_write_vol(new_spm_t2sFIT(t), me_params.T2star_3D_thresholded);
% 
%         new_spm_s0FIT(t).fname = s0FIT_fn;
%         new_spm_s0FIT(t).private.dat.fname = s0FIT_fn;
%         spm_write_vol(new_spm_s0FIT(t), me_params.S0_3D_thresholded);
        t2sFIT(:,:,:,t) = me_params.T2star_3D_thresholded;


    end
    t2starFIT = {};
    t2starFIT.img=t2sFIT;     %将较小的值放大
    t2starFIT.hdr = nii_echo1.hdr;

    save_nii(t2starFIT,[save_path '\t2starFIT111.nii'])%保存为.nii文件
end



function matlabbatch = resample1(file_root,ID,task)
%将解剖分割得到的影像重采样到功能像大小
    %-----------------------------------------------------------------------
    % Job saved on 29-Mar-2023 18:44:19 by cfg_util (rev $Rev: 7345 $)
    % spm SPM - SPM12 (7771)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    ref_dir=[file_root 'sub-' ID '\func\sub-' ID '_task-' task '_echo-2_bold.nii,1'];%是参考图像的大小，我认为随便输一个功能像就行
    c1=[file_root 'sub-' ID '\anat\c1sub-' ID '_T1w.nii,1'];
    c2=[file_root 'sub-' ID '\anat\c2sub-' ID '_T1w.nii,1'];
    c3=[file_root 'sub-' ID '\anat\c3sub-' ID '_T1w.nii,1'];
    matlabbatch{1}.spm.spatial.coreg.write.ref = {ref_dir};
    matlabbatch{1}.spm.spatial.coreg.write.source = {
                                                     c1
                                                     c2
                                                     c3
                                                     };
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
end
