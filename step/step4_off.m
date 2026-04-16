ID={'001','002','003','004','005','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28
% ID={'001'};
% ID={'012'}; %这个数据有问题，无法load
% file_root = 'F:\朱梦莹毕业设计\rt-me-fMRI\';
file_root = 'F:\rt-me-fMRI\';
task={'fingerTapping'};    %后面均写成了task{1}
combined_data={'t2starFIT','TE_combined','echo2'};
% mkdir([file_root 'result']);

%step4 计算指标tSNR, tvalue, PSC, tPSC, tCNR

Resliced_ROI_dir = [file_root 'ROI\Resliced_roi_57.nii'];
Resliced_ROI_file = load_nii(Resliced_ROI_dir);
Resliced_ROI = double(Resliced_ROI_file.img);    %读入重采样好的ROI
xls_dir = [file_root 'result_off'];    %保存路径
mkdir(xls_dir);
Ni = 45;Nj = 55;Nk = 45;
%block块设计，以OFF开头和结束，共采集210个volumes
contrast_zeros = zeros(1,10);
contrast_ones = ones(1,10);
contrast_vector = [];
for i = 1:10
    contrast_vector = [contrast_vector contrast_zeros contrast_ones];
end
contrast_vector = logical([contrast_vector contrast_zeros]);

% initial excel files to save tvalue, PSC, tPSC, tCNR of echo2, TEcombined, 

excel_t_test = [xls_dir '\batch_tvalue.xlsx'];
excel_PSC = [xls_dir '\batch_PSC.xlsx'];
excel_tPSC = [xls_dir '\batch_tPSC.xlsx'];
excel_functional_contrast = [xls_dir '\batch_functional_contrast.xlsx'];
excel_tCNR = [xls_dir '\batch_tCNR.xlsx'];

xlswrite(excel_t_test,{'sub','echo2','TEcombined','T2*FIT'},1,'A1');
xlswrite(excel_t_test,ID',1,'A2');    %竖着写一行ID

xlswrite(excel_PSC,{'sub','echo2','TEcombined','T2*FIT'},1,'A1');
xlswrite(excel_PSC,ID',1,'A2');

xlswrite(excel_tPSC,{'type','echo2'}',1,'A1');
xlswrite(excel_tPSC,{'TEcombined'}',1,'A29');  %27个受试者
xlswrite(excel_tPSC,{'T2*FIT'}',1,'A56');
xlswrite(excel_tPSC,{'sub'},1,'B1');
xlswrite(excel_tPSC,ID',1,'B2');
xlswrite(excel_tPSC,ID',1,'B29');
xlswrite(excel_tPSC,ID',1,'B56');
xlswrite(excel_tPSC,{'tPSC(1:210)'},1,'C1');

% xlswrite(excel_functional_contrast,{'type','echo2'}',1,'A1');
% xlswrite(excel_functional_contrast,{'TEcombined'}',1,'A29');  %27个受试者
% xlswrite(excel_functional_contrast,{'T2*FIT'}',1,'A56');
% xlswrite(excel_functional_contrast,{'sub'},1,'B1');
% xlswrite(excel_functional_contrast,ID',1,'B2');
% xlswrite(excel_functional_contrast,ID',1,'B29');
% xlswrite(excel_functional_contrast,ID',1,'B56');
% xlswrite(excel_functional_contrast,{'tPSC(1:210)'},1,'C1');
xlswrite(excel_functional_contrast,{'sub','echo2','TEcombined','t2*'},1,'A1');
xlswrite(excel_functional_contrast,ID',1,'A2');

xlswrite(excel_tCNR,{'sub','echo2','TEcombined','t2*'},1,'A1');
xlswrite(excel_tCNR,ID',1,'A2');

for i = 1:length(ID)
    
    file_dir=[file_root 'sub-' ID{i} '\1st_'];
    % 4.1 calculate t value 读入T值图，ROI中取均值
    tmap_echo2_dir = [file_dir combined_data{3} '\spmT_0001.nii'];
    mean_tvalue_echo2 = calculate_t_value(tmap_echo2_dir,Resliced_ROI);
    xlswrite(excel_t_test,mean_tvalue_echo2,1,['B' num2str(i+1)]);
    tmap_TEcom_dir = [file_dir combined_data{2} '\spmT_0001.nii'];
    mean_tvalue_TEcom = calculate_t_value(tmap_TEcom_dir,Resliced_ROI);
    xlswrite(excel_t_test,mean_tvalue_TEcom,1,['C' num2str(i+1)]);
    tmap_t2starFIT_dir = [file_dir combined_data{1} '\spmT_0001.nii'];
    mean_tvalue_t2starFIT = calculate_t_value(tmap_t2starFIT_dir,Resliced_ROI);
    xlswrite(excel_t_test,mean_tvalue_t2starFIT,1,['D' num2str(i+1)]);

    % 4.2 calculate and save PSC file  β条件除以β常数

    bata_dir_echo2 =  [file_dir combined_data{3}];
    mean_PSC_echo2 = calculate_PSC(bata_dir_echo2,Resliced_ROI);
    xlswrite(excel_PSC,mean_PSC_echo2,1,['B' num2str(i+1)]);
    
    beta_dir_TEcom = [file_dir combined_data{2}];
    mean_PSC_TEcom = calculate_PSC(beta_dir_TEcom,Resliced_ROI);
    xlswrite(excel_PSC,mean_PSC_TEcom,1,['C' num2str(i+1)]);
    
    beta_dir_t2s = [file_dir combined_data{1}];
    mean_PSC_t2s = calculate_PSC(beta_dir_t2s,Resliced_ROI);
    xlswrite(excel_PSC,mean_PSC_t2s,1,['D' num2str(i+1)]);
    disp(['Finished PSC Calaulated : ' ID{i} ]);

    % 4.3 calculate realtime tPSC and tCNR
    %tPSC
    
    smoothed_dir_echo2 = [file_root 'sub-' ID{i} '\' task{1} '\swecho2.nii'];    %平滑后的影像
    realtime_tPSC_echo2 = calculate_realtime_tPSC(smoothed_dir_echo2,Resliced_ROI);
    xlswrite(excel_tPSC,realtime_tPSC_echo2,1,['C' num2str(1+i)]);

    mean_functional_contrast_echo2 = calculate_functional_contrast(realtime_tPSC_echo2,contrast_vector);
    xlswrite(excel_functional_contrast,mean_functional_contrast_echo2,1,['B' num2str(i+1)]);
    mean_tCNR_echo2 = calculate_tCNR(realtime_tPSC_echo2,mean_functional_contrast_echo2);
    xlswrite(excel_tCNR,mean_tCNR_echo2,1,['B' num2str(i+1)]);

    
    smoothed_dir_TE_com = [file_root 'sub-' ID{i} '\' task{1} '\swTE_combined.nii'];    %平滑后的影像
    realtime_tPSC_TE_com = calculate_realtime_tPSC(smoothed_dir_TE_com,Resliced_ROI);
    xlswrite(excel_tPSC,realtime_tPSC_TE_com,1,['C' num2str(28+i)]);

    mean_functional_contrast_TE_com = calculate_functional_contrast(realtime_tPSC_TE_com,contrast_vector);
    xlswrite(excel_functional_contrast,mean_functional_contrast_TE_com,1,['C' num2str(i+1)]);
    mean_tCNR_TE_com = calculate_tCNR(realtime_tPSC_TE_com,mean_functional_contrast_TE_com);
    xlswrite(excel_tCNR,mean_tCNR_TE_com,1,['C' num2str(i+1)]);


    smoothed_dir_t2starFIT = [file_root 'sub-' ID{i} '\' task{1} '\swt2starFIT.nii'];    %平滑后的影像
    realtime_tPSC_t2starFIT = calculate_realtime_tPSC(smoothed_dir_t2starFIT,Resliced_ROI);
    xlswrite(excel_tPSC,realtime_tPSC_t2starFIT,1,['C' num2str(55+i)]);

    mean_functional_contrast_t2starFIT = calculate_functional_contrast(realtime_tPSC_t2starFIT,contrast_vector);
    xlswrite(excel_functional_contrast,mean_functional_contrast_t2starFIT,1,['D' num2str(i+1)]);
    mean_tCNR_t2starFIT = calculate_tCNR(realtime_tPSC_t2starFIT,mean_functional_contrast_t2starFIT);
    xlswrite(excel_tCNR,mean_tCNR_t2starFIT,1,['D' num2str(i+1)]);

end


function mean_tSNRvalue = caculate_tsnr(data_dir)
    data_4D=double(load_nii(data_dir).img);
    [Ni, Nj, Nk, Nt] = size(data_4D); % data_4D:64*64*34*210
    data_2D = reshape(data_4D, Ni * Nj * Nk, Nt); % [voxels, time] data_2D:13926
    data_2D = data_2D'; % [time, voxels]
    
    % 数据去线性趋势处理
    data_2D_detrended = fmrwhy_util_detrend(data_2D, 2);
    
    % 计算tSNR
    data_2D_mean = nanmean(data_2D_detrended);
    data_2D_stddev = std(data_2D_detrended);
    % data_2D_var = var(data_2D_detrended);
    tSNR_2D = data_2D_mean ./ data_2D_stddev;
    
    % 将2D数据转为3D/4D
    tSNR_3D = reshape(tSNR_2D, Ni, Nj, Nk);
    re_tSNRvalue = sort(reshape(tSNR_3D, 1, Ni * Nj * Nk)); % 从小到大排序
    tSNRvalue = re_tSNRvalue(re_tSNRvalue>0);      %找到大于0的部分，并求平均
    mean_tSNRvalue = mean(tSNRvalue); % mean_tvalue即为所求
end


function mean_tvalue = calculate_t_value(t_map_dir,ROI)  %计算T值，找到roi中的t值求平均
    Ni = 45;Nj = 55;Nk = 45;
    tmap_file = load_nii(t_map_dir);
    tmap = double(tmap_file.img);
    calculate_tvalue = ROI.*tmap;
    re_tvalue = sort(reshape(calculate_tvalue, 1, Ni * Nj * Nk)); % 从小到大排
    tvalue = re_tvalue(re_tvalue>0);
    mean_tvalue = mean(tvalue); % mean_tvalue即为所求
end


function mean_PSC = calculate_PSC(beta_dir,Resliced_ROI)    %β条件除以β常数乘以SF
 % calculate PSC

     beta_condition_dir = [beta_dir '\beta_0001.nii'];
     beta_constant_dir = [beta_dir '\beta_0022.nii'];
     spmmat_dir = [beta_dir '\SPM.mat'];
    
     spm = load(spmmat_dir);
     ntime = 20*(1/spm.SPM.xBF.dt);
     reference_block = conv(ones(1,ntime),spm.SPM.xBF.bf(:,1))';
     SF = max(reference_block); % SF
    
     nii_beta_condition = load_nii(beta_condition_dir);
     beta_vals = double(nii_beta_condition.img);
     nii_beta_constant = load_nii(beta_constant_dir);
     const_vals = double(nii_beta_constant.img);
    
     PSC_vals = beta_vals * SF ./ const_vals * 100;
     % save PSC
     new_fn = [beta_dir '\PSC_0001.nii'];
     no_scaling = 1;
     if ~exist(new_fn)
%         fmrwhy_util_saveNifti(new_fn, PSC_vals, beta_condition_dir, no_scaling)
        new_nii = struct;
        new_nii.hdr = nii_beta_condition.hdr;
        new_nii.img = PSC_vals;
        new_nii.hdr.aux_file = '';
        new_nii.hdr.file_name = new_fn;
        if no_scaling
            new_nii.hdr.scl_slope = [];
            new_nii.hdr.scl_inter = [];
        end
    
        save_nii(new_nii, new_fn);
     end
    % calculate mean of PSC in ROI
    calculate_PSC = Resliced_ROI.*PSC_vals;
    [Ni,Nj,Nk] = size(PSC_vals);
    re_PSC = sort(reshape(calculate_PSC, 1, Ni * Nj * Nk)); % 从小到大排序
    PSCvalue = re_PSC(re_PSC>0);
    mean_PSC = mean(PSCvalue); % mean_tvalue即为所求
end

function realtime_tPSC = calculate_realtime_tPSC(smoothed_data_dir,Resliced_ROI)
   
     nii = load_nii(smoothed_data_dir);
     data_4D = double(nii.img);
     [Ni, Nj, Nk, Nt] = size(data_4D); % [Ni x Nj x Nk x Nt]
     data_2D = reshape(data_4D, Ni * Nj * Nk, Nt); % [voxels, time]
     data_2D = data_2D'; % [time, voxels]
     % Remove linear and quadratic trend per voxel
     data_2D_detrended = fmrwhy_util_detrend(data_2D, 2); % [time, voxels]
     % Calculate mean
%      data_2D_mean = nanmean(data_2D_detrended); % [1, voxels]

%      data_2D_mean = nanmean(data_2D_detrended(1:10,:)); % [1, voxels]

     off=[];
     for z=1:11
         off=[off,2*(z-1)*10+1:2*(z-1)*10+10];
     end
     data_2D_mean = nanmean(data_2D_detrended(off,:));
     % Calculate standard deviation
%      data_2D_stddev = std(data_2D_detrended); % [1, voxels]
     % Calculate percentage signal change: [I(t) - mean(I)]/mean(I)*100
     data_2D_psc = 100 * (data_2D_detrended ./ data_2D_mean) - 100;   %（相当于除以均值-1 ）×100% [time, voxels]
     data_2D_psc(isnan(data_2D_psc)) = 0;  %将Nan值改为0
     F_2D_psc = data_2D_psc';   % [voxels, time]
     % Order voxels
     ROI_signals = F_2D_psc(logical(reshape(Resliced_ROI, Ni * Nj * Nk, 1)'),:); % 将ROI变为[voxels, time]
     realtime_tPSC = mean(ROI_signals, 1);
end

function mean_functional_contrast = calculate_functional_contrast(tPSC,contrast_vector)    
% ON tPSC - OFF tPSC
     ON_volumes = contrast_vector;
     OFF_volumes = ~contrast_vector;
     mean_functional_contrast = mean(abs(tPSC(ON_volumes))) - mean(tPSC(OFF_volumes));
 end


 function mean_tCNR = calculate_tCNR(tPSC,mean_functional_contrast)
     std_tPSC = std(tPSC);
     mean_tCNR = mean_functional_contrast / std_tPSC;
 end