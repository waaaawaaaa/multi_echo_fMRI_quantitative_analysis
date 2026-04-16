%朱梦莹 2023.04.14
%将经过自监督模型生成的.mat格式的文件保存为.nii格式，进而做下一步的后处理
% % 
ID={'001','002','003','004','005','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28
% % task={'fingerTapping','emotionProcessing','fingerTappingImagined','emotionProcessingImagined'};
% % ID={'001'};   %没有08 09 14 28
% task={'rest_run-2'};
file_root='F:\rt-me-fMRI\t2s_relax_mat\';
% parfor id=1:length(ID)
%     for i=1:length(task)
%         file_mat_dir=[file_root 'sub-' ID{id} '_task-' task{i} '.mat'];
%         data_mat=load(file_mat_dir);
%         data = data_mat.output;
% %         限制一下范围试试
%         data(data<0 | data>0.2)=0;
% %         data(data>0.2)=0;
%         % imshow3D(data,[0,0.2])        %T2*查看范围，其他值可能就不是脑组织产生的T2值了
%         save_path=['F:\rt-me-fMRI\sub-' ID{id} '\' task{i}];
%         nii_path=[save_path '\echo2.nii'];
%         nii_echo2=load_nii(nii_path);
%         data_echo2 = double(nii_echo2.img);
% 
%         MASK = data_echo2./max(data_echo2(:));     %加一个mask是去除噪声
%         MASK = im2bw(MASK,0.05);
%         denoised_data=data.*MASK;
%         new_nii = {};
%         new_nii.img=denoised_data;     
%         new_nii.hdr = nii_echo2.hdr;
% %         save_path=['F:\rt-me-fMRI\sub-' ID{id} '\' task{i} '\t2s_relax.nii'];
%         save_nii(new_nii,[save_path '\t2s_relax.nii'])%保存为.nii文件
%     end
% end

%画一下T2*RELAX

task={'rest_run-2'};
id=25;i=1;
file_mat_dir=[file_root 'sub-' ID{id} '_task-' task{i} '.mat'];
data_mat=load(file_mat_dir);
data = data_mat.output;
%         限制一下范围试试
data1=data;
data1(data1<0 | data1>0.2)=0;
%         data(data>0.2)=0;
% imshow3D(data,[0,0.2])        %T2*查看范围，其他值可能就不是脑组织产生的T2值了
save_path=['F:\rt-me-fMRI\sub-' ID{id} '\' task{i}];
nii_path=[save_path '\echo2.nii'];
nii_echo2=load_nii(nii_path);
data_echo2 = double(nii_echo2.img);

MASK = data_echo2./max(data_echo2(:));     %加一个mask是去除噪声
MASK = im2bw(MASK,0.05);
denoised_data=data1.*MASK;

% subtitle={'自监督训练', '取0-0.2','加mask'};
% figure;subplot(2,2,1);imshow(rot90(squeeze(data(:,:,17,1))),[]);tltle=(subtitle{1});
% subplot(2,2,2);imshow(rot90(squeeze(data1(:,:,17,1))),[]);tltle=(subtitle{2});
% subplot(2,2,3);imshow(rot90(squeeze(denoised_data(:,:,17,1))),[]);colormap;colorbar;tltle=(subtitle{3});

data_all1=ones(64,129);
data_all1(1:64,1:64)=rot90(squeeze(data1(:,:,17,1)));
data_all1(1:64,66:129)=rot90(squeeze(denoised_data(:,:,17,1)));
imshow(data_all1,[0,0.2]);colormap;colorbar;

%画出四个时间序列的图，但代码有错
% save_path=['F:\rt-me-fMRI\sub-' '001' '\' 'fingerTapping'];
% nii_path=[save_path '\echo2.nii'];
% nii_echo2=load_nii(nii_path);
% data_echo2 = double(nii_echo2.img);
% 
% nii_path=[save_path '\TE_combined.nii'];
% nii_TE_combined=load_nii(nii_path);
% data_TE_combined = double(nii_TE_combined.img);
% 
% nii_path=[save_path '\t2starFIT.nii'];
% nii_t2starFIT=load_nii(nii_path);
% data_t2starFIT = double(nii_t2starFIT.img);
% 
% nii_path=[save_path '\t2s_relax.nii'];
% nii_t2s_relax=load_nii(nii_path);
% data_t2s_relax = double(nii_t2s_relax.img);
% 
% subtitle={'Echo 2', 'TE-combined', 'T2*FIT', 'T2*relax'};
% figure;subplot(2,2,1);imshow(data_echo2(:,:,17,1));tltle=subtitle{1};
% subplot(2,2,2);imshow(data_TE_combined(:,:,17,1));tltle=subtitle{2};
% subplot(2,2,3);imshow(data_t2starFIT(:,:,17,1));tltle=subtitle{3};
% subplot(2,2,4);imshow(data_t2starFIT(:,:,17,1));tltle=subtitle{4};