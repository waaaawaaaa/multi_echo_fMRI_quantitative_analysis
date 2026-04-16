ID={'001','002','003','004','005','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28
% task={'fingerTapping','emotionProcessing','fingerTappingImagined','emotionProcessingImagined'};
% ID={'001'};   %没有08 09 14 28
task={'rest_run-2'};
% task={'fingerTapping'};
time_series={'echo2','TE_combined','t2starFIT_no10','t2s_relax'};
excel_weizhi={'B','C','D','E'};
% tsnr_mean=zeros(64,64,34);
file_root = 'F:\rt-me-fMRI\';
xls_dir = [file_root 'result_44_c'];    %保存路径
excel_tSNR = [xls_dir '\batch_tSNR.xlsx'];
xlswrite(excel_tSNR,{'sub','echo2','TEcombined','T2*FIT','t2*relax'},1,'A1');
xlswrite(excel_tSNR,ID',1,'A2');    %竖着写一行ID


% % figure;
% % tiledlayout(4,4,'TileSpacing','none','Padding','tight');
% for time_s=1:length(time_series)
%     tsnr_mean=zeros(64,64,34);
%     for id=1:length(ID)
% %     for time_s=1:length(time_series)
%         for i=1:length(task)
%             root_path=['F:\rt-me-fMRI\sub-' ID{id} '\' task{i}];
%             nii_dir = [root_path '\' time_series{time_s} '.nii'];
%             nii = load_nii(nii_dir);
%             data_nii = double(nii.img);   %将单精度转换为了双精度
%             tSNR_3D = caculate_tsnr(data_nii);
%             tsnr_mean =tsnr_mean+tSNR_3D;
%             sub_mean_tsnr=nanmean(tSNR_3D(:));
% %             nexttile;
% %             imshow(tsnr_mean(:,:,18),[0 250]);
%     
%        
%         end
%         xlswrite(excel_tSNR,sub_mean_tsnr,1,[excel_weizhi{time_s} num2str(i+1)]);
% 
%         tsnr_all(:,:,:,time_s)=tsnr_mean/length(ID);
% 
%     end
% %     tsnr_mean=tsnr_mean/27;
% 
% end
% data_all=zeros(128,128);
% for s =1:length(slice)
%     data_all(1:64,1:64)=rot90(squeeze(tsnr_all(:,:,17,1)));
%     data_all(1:64,65:128)=rot90(squeeze(data_TE_combined(:,:,17,2)));
%     data_all(65:128,1:64)=rot90(squeeze(data_t2starFIT(:,:,17,3)));
%     data_all(65:128,65:128)=rot90(squeeze(data_t2s_relax(:,:,17,4)));
% %        nexttile;
% %        t.TileSpacing='none';
% %        t.Padding='tight';
% %         t.TileSpacing='compact';
% %         t.Padding='compact';
% %         tiledlayout(4,4);
% %         subplot(16,time_s,s);
% %     imshow(rot90(tsnr_mean(:,:,17)),[0 250]);
% end
% figure;
% imshow(data_all,[0 250]);
% 
% colormap hot;
% cb=colorbar;
% cb.Laout.Tile='east';

% slice = [6,8,10,18];
% figure(1);
% subplot(16,1,1);imshow(tSNR_echo2(:,:,slice),[0 250]); % 选择echo2的slice6进行输出
% colormap hot;colorbar;title('echo2');
% subplot(6,1,2);imshow(tSNR_tSNR_combined(:,:,slice),[0 250]); % 选择echo2的slice6进行输出
% colormap hot;colorbar;title('tSNR_combined');
% subplot(6,1,3);imshow(tSNR_TE_combined(:,:,slice),[0 250]); % 选择echo2的slice6进行输出
% colormap hot;colorbar;title('TE_combined');
% subplot(6,1,4);imshow(tSNR_T2star_combined(:,:,slice),[0 250]); % 选择echo2的slice6进行输出
% colormap hot;colorbar;title('T2star_combined');
% subplot(6,1,5);imshow(tSNR_T2starFIT_combined(:,:,slice),[0 250]); % 选择echo2的slice6进行输出
% colormap hot;colorbar;title('T2starFIT_combined');
% subplot(6,1,6);imshow(tSNR_T2starFIT(:,:,slice),[0 250]); % 选择echo2的slice6进行输出
% colormap hot;colorbar;title('T2starFIT');
% saveas(gcf, 'TSNR.bmp');    %gcf自动获取当前的figure
% 
for i=1:length(ID)
%     save_path=['F:\rt-me-fMRI\sub-' ID{i} '\' task{1}];
%     nii_path=[save_path '\echo2.nii'];
%     nii_echo2=load_nii(nii_path);
%     data_echo2 = double(nii_echo2.img);
% 
%     MASK = data_echo2./max(data_echo2(:));     %加一个mask是去除噪声
%     mask_brain_3D = im2bw(MASK,0.05);

    mask_fn = fullfile(['F:\NEUFEPME_data_BIDS\derivatives\fmrwhy-preproc\sub-',ID{i},'\anat'], ['sub-' ID{i} '_space-individual_desc-brain_mask.nii']);
    mask_brain_3D=spm_read_vols(spm_vol(mask_fn));
    [Ni,Nj,Nk]=size(mask_brain_3D);
    mask_brain_2D=reshape(mask_brain_3D,Ni*Nj*Nk,1);
    brain_mask_I=find(mask_brain_2D);
    brain_mask_I=brain_mask_I';

    root_path=['F:\me_fmri_t2\sub-' ID{i} '\' 'rest_run-2\'];
    %读入影像
    t2sfit_nii_dir = [root_path 'echo2.nii'];
    t2sfit_nii = load_nii(t2sfit_nii_dir);
    echo2 = double(t2sfit_nii.img);
    
    TEcom_nii_dir = [root_path 'TE_combined.nii'];
    TEcom_nii = load_nii(TEcom_nii_dir);
    TEcom = double(TEcom_nii.img);
    
    t2sfit_nii_dir = [root_path 't2starFIT_rt.nii'];
    t2sfit_nii = load_nii(t2sfit_nii_dir);
    t2sfit = double(t2sfit_nii.img);
    
    
    t2srelax_nii_dir = [root_path 't2s_relax.nii'];
    t2srelax_nii = load_nii(t2srelax_nii_dir);
    t2srelax = double(t2srelax_nii.img);
    
    tSNR_echo2 = caculate_tsnr(echo2);
    % tSNR_tSNR_combined = caculate_tsnr(tSNR_combined);
    tSNR_TE_combined = caculate_tsnr(TEcom);
    % tSNR_T2star_combined = caculate_tsnr(T2star_combined);
    tSNR_T2srelax = caculate_tsnr(t2srelax);
    t2_re=find(tSNR_T2srelax>1000);
    tSNR_T2srelax(t2_re)=0;
    tSNR_T2starFIT = caculate_tsnr(t2sfit);
    
    tSNR_echo2_mean=nanmean(tSNR_echo2( brain_mask_I));
    tSNR_tSNR_TE_combined=nanmean(tSNR_TE_combined( brain_mask_I));
    tSNR_tSNR_T2srelax=nanmean(tSNR_T2srelax( brain_mask_I));

    tSNR_tSNR_T2starFIT=nanmean(tSNR_T2starFIT( brain_mask_I));


    xlswrite(excel_tSNR,tSNR_echo2_mean,1,['B' num2str(i+1)]);
    xlswrite(excel_tSNR,tSNR_tSNR_TE_combined,1,['C' num2str(i+1)]);
    xlswrite(excel_tSNR,tSNR_tSNR_T2srelax,1,['E' num2str(i+1)]);
    xlswrite(excel_tSNR,tSNR_tSNR_T2starFIT,1,['D' num2str(i+1)]);
end




function tSNR_3D = caculate_tsnr(data_4D)
    [Ni, Nj, Nk, Nt] = size(data_4D); % data_4D:64*64*34*210
    data_2D = reshape(data_4D, Ni * Nj * Nk, Nt); % [voxels, time] data_2D:13926
    data_2D = data_2D'; % [time, voxels]
    
    % 数据去线性趋势处理
    data_2D_detrended = fmrwhy_util_detrend(data_2D, 2);
    
    % 计算tSNR
    data_2D_mean = nanmean(data_2D_detrended);
    data_2D_stddev = std(data_2D_detrended);
%     stddev=find(data_2D_stddev>10000);
%     data_2D_stddev(stddev)
    % data_2D_var = var(data_2D_detrended);
    tSNR_2D = data_2D_mean ./ data_2D_stddev;
    tSNR_2D (tSNR_2D<0)=0;
    
    % 将2D数据转为3D/4D
    tSNR_3D = reshape(tSNR_2D, Ni, Nj, Nk);
end
