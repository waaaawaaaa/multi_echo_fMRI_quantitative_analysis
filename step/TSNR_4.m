%% 计算组合后（6种）图像的tSNR数据（记得保存）,只能使用静息态数据
clc;clear;
% 1.绘制出受试001，在-rest_run-2时slice6，6种组合的tSNR图
% 读取文件
filr_root='F:\rt-me-fMRI\sub-001\rest_run-2\';
%读入影像
t2sfit_nii_dir = [filr_root 'echo2.nii'];
t2sfit_nii = load_nii(t2sfit_nii_dir);
echo2 = double(t2sfit_nii.img);

TEcom_nii_dir = [filr_root 'TE_combined.nii'];
TEcom_nii = load_nii(TEcom_nii_dir);
TEcom = double(TEcom_nii.img);

t2sfit_nii_dir = [filr_root 't2starFIT.nii'];
t2sfit_nii = load_nii(t2sfit_nii_dir);
t2sfit = double(t2sfit_nii.img);

t2srelax_nii_dir = [filr_root 't2s_relax.nii'];
t2srelax_nii = load_nii(t2srelax_nii_dir);
t2srelax = double(t2srelax_nii.img);
% 
% file_path='F:\朱梦莹毕业设计\proprecess\sub-001\rest_run-2\';
% tSNR_combined = load([file_path,'tSNR_combined.mat']).tSNR_combined_data;
% TE_combined = load([file_path,'TE_combined.mat']).TE_combined_data;
% T2star_combined = load([file_path,'T2star_combined.mat']).T2star_combined_data;
% T2starFIT_combined = load([file_path,'T2starFIT_combined.mat']).T2starFIT_combined_data;
% T2starFIT = load([file_path,'t2starFIT.mat']).t2starFIT_4D;

tSNR_echo2 = caculate_tsnr(echo2);
% tSNR_tSNR_combined = caculate_tsnr(tSNR_combined);
tSNR_TE_combined = caculate_tsnr(TEcom);
% tSNR_T2star_combined = caculate_tsnr(T2star_combined);
tSNR_T2srelax = caculate_tsnr(t2srelax);
tSNR_T2starFIT = caculate_tsnr(t2sfit);
t2_re=find(tSNR_T2starFIT>250);
tSNR_T2starFIT(t2_re)=0;

% slice = 17;
% figure(1);
% subplot(2,2,1);imshow(rot90(tSNR_echo2(:,:,slice)),[0 250]); % 选择echo2的slice6进行输出
% % colormap hot;colorbar;
% title('echo2');
% % subplot(6,1,2);imshow(tSNR_tSNR_combined(:,:,slice),[0 250]); % 选择echo2的slice6进行输出
% % colormap hot;colorbar;title('tSNR_combined');
% subplot(2,2,2);imshow(rot90(tSNR_TE_combined(:,:,slice)),[0 250]); % 选择echo2的slice6进行输出
% % colormap hot;colorbar;
% title('TE combined');
% % subplot(6,1,4);imshow(tSNR_T2star_combined(:,:,slice),[0 250]); % 选择echo2的slice6进行输出
% % colormap hot;colorbar;title('T2star_combined');
% subplot(2,2,3);imshow(rot90(tSNR_T2starFIT(:,:,slice)),[0 250]); % 选择echo2的slice6进行输出
% % colormap hot;colorbar;
% title('T2starFIT');
% subplot(2,2,4);imshow(rot90(tSNR_T2srelax(:,:,slice)),[0 250]); % 选择echo2的slice6进行输出
% colormap hot;colorbar;
title('T2starRELAX');
data_all=zeros(128,128);
data_all(1:64,1:64)=rot90(squeeze(tSNR_echo2(:,:,17)));
data_all(1:64,65:128)=rot90(squeeze(tSNR_TE_combined(:,:,17)));
data_all(65:128,1:64)=rot90(squeeze(tSNR_T2starFIT(:,:,17)));
data_all(65:128,65:128)=rot90(squeeze(tSNR_T2srelax(:,:,17)));
imshow(data_all,[0 250]);


colormap hot;hot=colorbar;
saveas(gcf, 'TSNR.bmp');    %gcf自动获取当前的figure


tSNR_mean= nanmean(tSNR_T2starFIT(:));    %求分布图，取平均


% [Ni, Nj, Nk, Nt] = size(data_4D); % data_4D:64*64*34*210
% data_2D = reshape(data_4D, Ni * Nj * Nk, Nt); % [voxels, time] data_2D:13926
% data_2D = data_2D'; % [time, voxels]
% 
% % 数据去线性趋势处理
% data_2D_detrended = fmrwhy_util_detrend(data_2D, 2);
% 
% % 计算tSNR
% data_2D_mean = nanmean(data_2D_detrended);
% data_2D_stddev = std(data_2D_detrended);
% % data_2D_var = var(data_2D_detrended);
% tSNR_2D = data_2D_mean ./ data_2D_stddev;
% 
% % 将2D数据转为3D/4D
% tSNR_3D_echo2 = reshape(tSNR_2D, Ni, Nj, Nk);
% 
% % % 展示图片
% % imshow3D(tSNR_3D_echo2); % 图片为灰度图
% % % 展示特定切片的图片
% % tSNR_slice6_echo2 = tSNR_3D_echo2(:,:,6);
% % imshow3D(tSNR_slice6_echo2);
% 

% 
% % 2.绘制出受试001，slice6，**TE combined**的tSNR图
% 
% % % 读取3个回波的数据，整合到一起
% % nii_dir_echo1 = 'D:\MyData\fMRI\rt-me-fMRI-study\sub-001\func\sub-001_task-r
% % nii1 = load_nii(nii_dir_echo1);
% % data_4D_echo1 = double(nii1.img);
% % [Ni, Nj, Nk, Nt] = size(data_4D_echo1); % data_4D:64*64*34*210
% % nii_dir_echo2 = 'D:\MyData\fMRI\rt-me-fMRI-study\sub-001\func\sub-001_task-r
% % nii2 = load_nii(nii_dir_echo2);
% % data_4D_echo2 = double(nii2.img);
% % nii_dir_echo3 = 'D:\MyData\fMRI\rt-me-fMRI-study\sub-001\func\sub-001_task-r
% % nii3 = load_nii(nii_dir_echo3);
% % data_4D_echo3 = double(nii3.img);
% % func_data(:,:,:,:,1) = data_4D_echo1;
% % func_data(:,:,:,:,2) = data_4D_echo2;
% % func_data(:,:,:,:,3) = data_4D_echo3;
% 
% % 根据加权方法合成TEcombined数据
% TE = [14 28 42];
% combined_data = me_fMRI_combineEchoes(func_data, TE, 3);
% 
% % TEcombined数据像echo2一样处理，便可得到tSNR图像
% data_2D_TEcom = reshape(combined_data, Ni * Nj * Nk, Nt); % [voxels, time] d
% data_2D_TEcom = data_2D_TEcom'; % [time, voxels]
% 
% % 数据去线性趋势处理
% data_2D_detrended_TEcom = fmrwhy_util_detrend(data_2D_TEcom, 2);
% 
% % 计算tSNR
% data_2D_mean_TEcom = nanmean(data_2D_detrended_TEcom);
% data_2D_stddev_TEcom = std(data_2D_detrended_TEcom);
% data_2D_var_TEcom = var(data_2D_detrended_TEcom);
% tSNR_2D_TEcom = data_2D_mean_TEcom ./ data_2D_stddev_TEcom;
% 
% % 将2D数据转为3D/4D
% tSNR_3D_TEcom = reshape(tSNR_2D_TEcom, Ni, Nj, Nk);
% 
% % % 展示图片
% % imshow3D(tSNR_3D_TEcom); % 图片为灰度图
% % % 展示特定切片的图片
% % tSNR_slice6_TEcom = tSNR_3D_TEcom(:,:,6);
% % imshow3D(tSNR_slice6_TEcom);
% 
% 
% % 3.绘制出受试001，slice6，**T2star**的tSNR图
% % 鉴于之前已经把受试001，slice6，**T2star**的tSNR数据保存到'D:\1-积累\My Github\
% % 故只需加载该数据即可进行绘制。
% load 'D:\1-积累\My Github\rt-me-fMRI-rePro\sub001_T2star_tSNR.mat'; % 加载出的
% % load 'D:\1-积累\My Github\rt-me-fMRI-rePro\sub001_T2star.mat' % 这里保存的是
% 
% % 记得用save函数保存得出的数据，因为复现其他内容的时候可能会用到
% % save sub001_echo2_tSNR tSNR_3D_echo2
% % save sub001_TEcombined combined_data
% % save sub001_TEcombined_tSNR tSNR_3D_TEcom
% 
% %% 绘制echo2,TEcombined,T2star的tSNR图像
% 
% % 受试1，tSNR图
% slice = 6;
% 
% subplot(3,1,1);
% imshow(tSNR_3D_echo2(:,:,slice),[10 200]); % 选择echo2的slice6进行输出
% colormap hot;
% colorbar;
% title('tSNR-Standard EPI');
% 
% subplot(3,1,2);
% imshow(tSNR_3D_TEcom(:,:,slice),[10 200]); % 选择echo2的slice6进行输出
% colormap hot;
% colorbar;
% title('tSNR-TE combined');
% 
% subplot(3,1,3);
% imshow(tSNR_3D_T2star(:,:,slice),[10 200]); % 选择echo2的slice6进行输出
% colormap hot;
% colorbar;
% title('tSNR-t2star');
% 
% % suptitle('sub001-slice6');
%% 保存结果图片



function tSNR_3D = caculate_tsnr(data_4D)
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
end