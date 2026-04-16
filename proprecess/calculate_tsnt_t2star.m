clc;clear;
%从第一个rest状态的三个回波数据，计算先验数据包括tsnr和t2star

% 读取文件，共三个回波
%回波1
nii_dir_echo1 = 'F:\朱梦莹毕业设计\proprecess\sub-001\func\sub-001_task-rest_run-1_echo-1_bold.nii';
nii_echo1 = load_nii(nii_dir_echo1);
data_4D_echo1 = double(nii_echo1.img);   %将单精度转换为了双精度

%回波2
nii_dir_echo2 = 'F:\朱梦莹毕业设计\proprecess\sub-001\func\sub-001_task-rest_run-1_echo-2_bold.nii';
nii_echo2 = load_nii(nii_dir_echo2);
data_4D_echo2 = double(nii_echo2.img);

%回波3
nii_dir_echo3 = 'F:\朱梦莹毕业设计\proprecess\sub-001\func\sub-001_task-rest_run-1_echo-3_bold.nii';
nii_echo3 = load_nii(nii_dir_echo3);
data_4D_echo3 = double(nii_echo3.img);

%整合三个回波，便于后边的for循环
func_data(:,:,:,:,1) = data_4D_echo1;
func_data(:,:,:,:,2) = data_4D_echo2;
func_data(:,:,:,:,3) = data_4D_echo3;



save('sub001_func_data','func_data');


for i=1:3
    [Ni, Nj, Nk, Nt] = size(func_data(:,:,:,:,i)); % data_4D:64*64*34*210   图像大小64×64，34层，210个全脑图像
    data_2D = reshape(func_data(:,:,:,:,i), Ni * Nj * Nk, Nt); % [voxels, time] data_2D:139264  将原来四维图像转换为二维139264*210
    data_2D = data_2D'; % [time, voxels]  210*139264  去线性趋势函数要求time point*columns
    
    % 数据去线性趋势处理  去除预处理部分产生或没有去干净的线性漂移和二次趋向
    data_2D_detrended = fmrwhy_util_detrend(data_2D, 2);   % 1: linear trend  2: linear trend + quadratic trend
    
   
    % 计算tSNR 均值/标准差
    data_2D_mean(:,:,i) = nanmean(data_2D_detrended);   %除去nan值后计算，在时间上取了均值
    data_2D_stddev = std(data_2D_detrended);    %标准差
    % data_2D_var = var(data_2D_detrended);       %方差
    tSNR_2D = data_2D_mean(:,:,i) ./ data_2D_stddev;
    % 如果有全脑，灰质，白质，CSF的MASK则此处还可以计算在不同MASK下的tSNR图
    % tSNR_mean_brain = nanmean(tSNR_2D(masks.brain_mask_I));
    % tSNR_mean_GM = nanmean(tSNR_2D(masks.GM_mask_I));
    % tSNR_mean_WM = nanmean(tSNR_2D(masks.WM_mask_I));
    % tSNR_mean_CSF = nanmean(tSNR_2D(masks.CSF_mask_I));
    
    % 将2D数据转为3D/4D
    % data_3D_mean = reshape(data_2D_mean, Ni, Nj, Nk);
    % data_3D_var = reshape(data_2D_var, Ni, Nj, Nk);
    % data_3D_stddev = reshape(data_2D_stddev, Ni, Nj, Nk);
    tSNR_3D = reshape(tSNR_2D, Ni, Nj, Nk);   %在转为原来的数据格式
    
    % 展示图片
%     figure(1);imshow3D(tSNR_3D); % 图片为灰度图  显示三维图像
    % 展示特定切片的图片
    % tSNR_slice6 = tSNR_3D(:,:,6);
    % figure(2);imshow3D(tSNR_slice6);

    save_path=['sub-001_echo' num2str(i)];
    
    save([save_path '_tSNR'],'tSNR_3D');   %保存为mat文件

    %计算出的tsnr是64*64*34，有三个回波，这里将tsnr保存为64*64*34*3
    tSNR_4D(:,:,:,i) = tSNR_3D;

end
%%
save sub-001_tSNR_4D tSNR_4D

%%
%计算t2star  文献中说三个回波的时间均值计算
% calculate T2* (voxel-size)
TE1 = 14e-3;TE2 = 28e-3;TE3 = 42e-3;
A = pinv([1,-TE1;1,-TE2;1,-TE3]);

[Ni, Nj, Nk, Nt, Ne] = size(func_data);
t2star_3D = zeros(Ni, Nj, Nk);

for e=1:Ne  %利用前面计算tsnr时计算的时间均值图像
    tmean_per_echo_3D(:,:,:,e) = reshape(data_2D_mean(:,:,e), Ni, Nj, Nk);
end

%挨个像素的计算t2star
for i = 1:Ni
    for j = 1:Nj
        for k = 1:Nk

            S_TE1 = tmean_per_echo_3D(i,j,k,1);
            S_TE2 = tmean_per_echo_3D(i,j,k,2);
            S_TE3 = tmean_per_echo_3D(i,j,k,3);
            B = [log(S_TE1);log(S_TE2);log(S_TE3)];
            C = A*B;
            T2star = 1/C(2);
            t2star_3D(i,j,k) = T2star;
         
        end
    end
end
save('sub-001_t2star','t2star_3D');
%%


% %%
% %计算t2starFIT
% % calculate T2* (voxel-size)
% TE1 = 14e-3;TE2 = 28e-3;TE3 = 42e-3;
% A = pinv([1,-TE1;1,-TE2;1,-TE3]);
% 
% [Ni, Nj, Nk, Nt, Ne] = size(func_data);
% t2star_4D = zeros(Ni, Nj, Nk, Nt);
% 
% %挨个像素的计算t2star
% for i = 1:Ni
%     for j = 1:Nj
%         for k = 1:Nk
%             for t = 1:Nt
%                 S_TE1 = func_data(i,j,k,t,1);
%                 S_TE2 = func_data(i,j,k,t,2);
%                 S_TE3 = func_data(i,j,k,t,3);
%                 B = [log(S_TE1);log(S_TE2);log(S_TE3)];
%                 C = A*B;
%                 T2star = 1/C(2);
%                 t2star_4D(i,j,k,t) = T2star;
%             end
%         end
%     end
% end
% save('sub001__t2star','t2star_4D');
% 
% 
%%
