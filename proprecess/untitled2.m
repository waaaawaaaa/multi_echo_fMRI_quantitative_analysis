% plot tSNR image of t2star data
% load nii file
nii_dir1 = 'F:\毕业设计\proprecess\sub-001\func\sub-001_task-rest_run-1_echo-1_bold.nii';
nii_dir2 = 'F:\毕业设计\proprecess\sub-001\func\sub-001_task-rest_run-1_echo-2_bold.nii';
nii_dir3 = 'F:\毕业设计\proprecess\sub-001\func\sub-001_task-rest_run-1_echo-3_bold.nii';
nii1 = load_nii(nii_dir1);
data_4D_echo1 = double(nii1.img);
[Ni, Nj, Nk, Nt] = size(data_4D_echo1); % data_4D:64*64*34*210
nii2 = load_nii(nii_dir2);
data_4D_echo2 = double(nii2.img);
nii3 = load_nii(nii_dir3);
data_4D_echo3 = double(nii3.img);

% calculate S0 and t2star
minimum = 0;
maxT2 = 2.0;
TE=[0.014 0.028 0.042];
level = 0.1;

for k = 1:Nk
    for t = 1:Nt
        MASK = data_4D_echo1(:,:,k,t);    %mask为64*64
        MASK = MASK./max(MASK(:));    %转化为0~1之间
        MASK = im2bw(MASK,level);     %转换为二值图
        indata(:,:,1) = data_4D_echo1(:,:,k,t);
        indata(:,:,2) = data_4D_echo2(:,:,k,t);
        indata(:,:,3) = data_4D_echo3(:,:,k,t);
        [Map ~] = T2Map(indata, TE, minimum, maxT2, 0 );
        S0(:,:,k,t) = Map(:,:,1).*MASK;
        t2s(:,:,k,t) = Map(:,:,2).*MASK;
    end
end

% 数据去线性趋势处理
data_2D_t2star = reshape(t2s, Ni * Nj * Nk, Nt); % [voxels, time] data_2D:139
data_2D_t2star = data_2D_t2star'; % [time, voxels]
data_2D_detrended = fmrwhy_util_detrend(data_2D_t2star, 2);

% calculate tSNR
data_2D_mean = nanmean(data_2D_detrended);
data_2D_stddev = std(data_2D_detrended);
tSNR_2D = data_2D_mean ./ data_2D_stddev;

% transform 2D data into 3D/4D data
tSNR_3D_T2star = reshape(tSNR_2D, Ni, Nj, Nk);

% show T2star tSNR image of sub001
% imshow3D(tSNR_3D); % 图片为灰度图
% show T2star slice6 tSNR image of sub001
% tSNR_slice6 = tSNR_3D(:,:,6);
% imshow3D(tSNR_slice6);
% colormap hot;
