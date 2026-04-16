% % %画四个时间序列
% ID={'001','002','003','004','005','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28
ID={'001'};
% 
% task={'rest_run-2'};
% file_root='F:\t2s\';
% id=25;i=1;
% % file_mat_dir=[file_root 'sub-' ID{id} '_task-' task{i} '.mat'];
% % data_mat=load(file_mat_dir);
% % data = data_mat.output;
% % %         限制一下范围试试
% % data1=data;
% % data1(data1<0 | data1>0.2)=0;
% %         data(data>0.2)=0;
% % imshow3D(data,[0,0.2])        %T2*查看范围，其他值可能就不是脑组织产生的T2值了
% save_path=['F:\rt-me-fMRI\sub-' ID{id} '\' task{i}];
% nii_path=[save_path '\echo2.nii'];
% nii_echo2=load_nii(nii_path);
% data_echo2 = double(nii_echo2.img);
% 
% MASK = data_echo2./max(data_echo2(:));     %加一个mask是去除噪声
% MASK = im2bw(MASK,0.05);
% denoised_data=data1.*MASK;
% 
% subtitle={'自监督训练', '取0-0.2','加mask'};
% figure;subplot(2,2,1);imshow(data(:,:,17,1),[]);tltle=(subtitle{1});
% subplot(2,2,2);imshow(data1(:,:,17,1),[]);tltle=(subtitle{2});
% subplot(2,2,3);imshow(denoised_data(:,:,17,1),[]);tltle=(subtitle{3});

% 画出四个时间序列的图，但代码有错
for i=1:length(ID)
    save_path=['F:\rt-me-fMRI\sub-' ID{i} '\' 'fingerTapping'];
    nii_path=[save_path '\echo2.nii'];
    nii_echo2=load_nii(nii_path);
    data_echo2 = double(nii_echo2.img);
    
    nii_path=[save_path '\TE_combined.nii'];
    nii_TE_combined=load_nii(nii_path);
    data_TE_combined = double(nii_TE_combined.img);
    
    nii_path=[save_path '\t2starFIT111.nii'];
    nii_t2starFIT=load_nii(nii_path);
    data_t2starFIT = double(nii_t2starFIT.img);
    data_t2starFIT(data_t2starFIT<0 | data_t2starFIT>0.2)=0;
    
    nii_path=[save_path '\t2s_relax.nii'];
    nii_t2s_relax=load_nii(nii_path);
    data_t2s_relax = double(nii_t2s_relax.img);
    % data_all=ones(143,153)*1024;
    % data_all(1:64,1:64)=rot90(squeeze(data_echo2(:,:,17,1)));
    % data_all(1:64,90:153)=rot90(squeeze(data_TE_combined(:,:,17,1)));
    % data_all(70:133,1:64)=rot90(squeeze(data_t2starFIT(:,:,17,1)));
    % data_all(70:133,70:133)=rot90(squeeze(data_t2s_relax(:,:,17,1)));
    % figure;imshow(data_all,[]);
    % fit_png='F:\me_fmri_t2\result_44_cacul\影像质量.png';
    % 
    % montage=fmrwhy_util_createStatsOverlayMontage(data_all,[],[],2,1,'','gray','off','max',[],[],rgb_ongray,false,fit_png);
    % 
%     subtitle={'Echo 2', 'TE-combined', 'T2*FIT', 'T2*relax'};
%     figure;subplot(2,2,1);imshow(rot90(squeeze(data_echo2(:,:,17,1))),[]);tltle=subtitle{1};
%     subplot(2,2,2);imshow(rot90(squeeze(data_TE_combined(:,:,17,1))),[]);tltle=subtitle{2};
%     subplot(2,2,3);imshow(rot90(squeeze(data_t2starFIT(:,:,17,1))),[0 0.2]);tltle=subtitle{3};
%     subplot(2,2,4);imshow(rot90(squeeze(data_t2s_relax(:,:,17,1))),[0 0.2]);tltle=subtitle{4};
    data_all1=zeros(64,128);
    data_all1(1:64,1:64)=rot90(squeeze(data_echo2(:,:,17,1)));
    data_all1(1:64,65:128)=rot90(squeeze(data_TE_combined(:,:,17,1)));
    subplot(2,1,1);imshow(data_all1,[]);colormap;colorbar;
    data_all2=zeros(64,128);
    data_all2(1:64,1:64)=rot90(squeeze(data_t2starFIT(:,:,17,1)));
    data_all2(1:64,65:128)=rot90(squeeze(data_t2s_relax(:,:,17,1)));
    subplot(2,1,2);imshow(data_all2,[0,0.2]);colormap;colorbar;

end