%跑完所有受试者所有任务数据，包括第一步：头动校正和时间层矫正，第二步，多回波组合
%朱梦莹   2022.04.06

ID={'001','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};   %没有08 09 14 28
% ID={'012'}; %这个数据有问题，无法load
% ID={'001','002','003','004','005',};
file_root = 'F:\rt-me-fMRI\';
% file_root = 'D:\rt-me-fMRI\';
% task={'fingerTapping'};
task={'emotionProcessing','rest_run-2','fingerTappingImagined','emotionProcessingImagined'};    
% ID={'015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032'};
% ID={'021','022','023','024','025','026','027','029','030','031','032'};

% %%
% %第一步，预处理，包括头动校正和时间校正
% echo={'echo-1','echo-2','echo-3'};
% for i=1:length(ID)
%     for j=1:length(echo)
%         for z=1:length(task)
%             file_name=[file_root 'sub-' ID{i} '\func\sub-' ID{i} '_task-' task{z} '_' echo{j} '_bold.nii'];
%             matlabbatch = step1(file_name);
%             spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
%         end
%     end
% end
% %%

%%
%第二步，多回波合并，使用三个分别是echo2，TEcombined T2*FIT
for i=1:length(ID)
    for z=1:length(task)
        save_path=[file_root 'sub-' ID{i} '\' task{z}];
        mkdir(save_path)
        %读取finger tapping文件，共三个回波
        nii_dir = [file_root 'sub-' ID{i} '\func\arsub-' ID{i} '_task-' task{z} '_'];
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
        %%
        %计算t2starFIT
        minimum = 0;maxT2 = 0.6;
        level = 0.1;TE = [0.014 0.028 0.042];
         for k = 1:Nk      %并行for循环
            for t = 1:Nt
                MASK = data_4D_echo1(:,:,k,t);
                MASK = MASK./max(MASK(:));     %加一个mask是去除噪声
                MASK = im2bw(MASK,level);
                [Map ~] = T2Map(squeeze(func_data(:,:,k,t,:)), TE, minimum, maxT2);
                t2s(:,:,k,t) = Map(:,:,2).*MASK;
            end
    %         disp(['Finished slice ',num2str(k)]);
        end
        t2starFIT = {};
        t2starFIT.img=uint16(t2s * 8000 + 10);     %将较小的值放大
        t2starFIT.hdr = nii_echo1.hdr;
    
        save_nii(t2starFIT,[save_path '\t2starFIT.nii'])%保存为.nii文件
         
        save_nii(nii_echo2,[save_path '\echo2.nii'])%echo2保存为.nii文件
        disp(ID{i});
    
        %计算TEcombined
    
        %  3——TE加权
        method=3;  weight_data=0;
        TE_combined_data = me_combineEchoes(func_data, TE, method, weight_data); 
      
    %     TE_combined_data_nii = make_nii(TE_combined_data);
    %     save_nii(TE_combined_data_nii,[save_path '\TE_combined.nii'])
        TE_combined = {};
        TE_combined.img=TE_combined_data;     
        TE_combined.hdr = nii_echo1.hdr;
        save_nii(TE_combined,[save_path '\TE_combined.nii'])%echo2保存为.nii文件
    end
end

% 
% %%
% %第三步，数据后处理，包括配准，分割
% combined_data={'t2starFIT','TE_combined','echo2'};
% 
% for i=1:length(ID)
% %     for j=1:length(combined_data)
% %     filepath = ['D:\proprecess\sub-' ID{i} '\fingerTapping\t2starFIT.nii'];
%     matlabbatch = step31(file_root,ID{i},task{1});
%     spm_jobman('run',matlabbatch);  %让上述设置好的参数以及流程跑起来
% %     end
% end

%%

% %%
% %step4 计算指标tSNR, tvalue, PSC, tPSC, tCNR
% 
% Resliced_ROI_dir = [file_root 'ROI\Resliced_roi_57.nii'];
% Resliced_ROI_file = load_nii(Resliced_ROI_dir);
% Resliced_ROI = double(Resliced_ROI_file.img);    %读入重采样好的ROI
% xls_dir = [file_root 'result\'];
% Ni = 45;Nj = 55;Nk = 45;
% %block块设计，以OFF开头和结束，共采集210个volumes
% contrast_zeros = zeros(1,10);
% contrast_ones = ones(1,10);
% contrast_vector = [];
% for i = 1:10
%     contrast_vector = [contrast_vector contrast_zeros contrast_ones];
% end
% contrast_vector = logical([contrast_vector contrast_zeros]);




%第一步，预处理，包括头动校正和时间层校正
function matlabbatch = step1(file_name)
%-----------------------------------------------------------------------
% Job saved on 11-Mar-2023 22:18:48 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%     prefix_func = ['F:\朱梦莹毕业设计\rt-me-fMRI\sub-' ID '\func\sub-' ID];
%     'F:\朱梦莹毕业设计\proprecess\sub-001\func\sub-001_task-emotionProcessingImagined_echo-1_bold.nii'
    
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'raw';
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{file_name}};
    matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Named File Selector: raw(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    matlabbatch{3}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
    matlabbatch{3}.spm.temporal.st.nslices = 34;
    matlabbatch{3}.spm.temporal.st.tr = 2;
    matlabbatch{3}.spm.temporal.st.ta = 1.94;
    matlabbatch{3}.spm.temporal.st.so = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34];
    matlabbatch{3}.spm.temporal.st.refslice = 17;
    matlabbatch{3}.spm.temporal.st.prefix = 'a';
end

%%
%第二步，计算多回波组合，T2*FIT，echo2,TE

%用来计算T2*FIT,有一些体素点做不了，要跳过
function [Map thresh] = T2Map(indata, tes, minimum, maxT2, display )
    % Calculate 1/exponential decay rate for T2 (or T1 by ULFMRI)
    %
    % indata is assumed to be dimensioned as X * Y * te - i.e., same slice, multiple te
    %
    % tes is a vector of the te values in msec.  之前的TE值，以秒为单位
    %
    % minimum sets the minimum pixel intensity on the input data that will be fitted
    %
    % maxT2 impose limits on the fitted T2 values, as an outlier suppression
    %
    % display is set to 0 or 1 to either display the results, or not.
    %
    % I also created a MATLAB version - though I haven't looked recently at the
    % code. This script assumes that you have gotten the data into a MATLAB matrix. 
    % As I glance at it now, it is a bit rough, as it seems to have minimal useful comments (see below). 
    % It looks to me like it was set up to look at 2D images. You would have to either modify the 
    % indexing, or call this function in a loop (by slice location) to do this to a volume.
     
    if nargin < 5    %输入参数个数，如果小于几个，就按默认指标
        display = false;
    end
    if nargin < 4
        maxT2 = 2000;
    end
    if nargin < 3
        minimum = 0;
    end
     
    if nargin < 2
        disp(sprintf('function [Map thresh] = %s( inData, tes, minimum, maximum, display )',mfilename) );
        disp('Image 1: rho   Image 2: T2   Image 3: R^2');
        return;
    end
     
    global stop;
    rows = size(indata,1);
    cols = size(indata,2);
    N    = size(indata,3);
    ly   = length(tes);
    tes = reshape(tes, ly, 1);  % must be a columns vector  转置   tes'
     
    Map = zeros(rows,cols,2);   %SLL: there are two maps because...
    Map(:,:,:) = 0;
    tes = [ones(ly,1), tes];  % first columns is ones to allow fit of intercept (rho)  3*2且第一列全为1
        
    indata = abs(indata);
     
    % Threshold images before fitting
    thresh = ones(rows,cols);
    %在三个回波每一像素点都不为0处，阈值设为1
    thresh = sum( (abs(indata(:,:,:)) > minimum), 3) > (N-1);  %sum返回一个沿三维求和，返回64*64，
     
    inData = abs(indata);   % in case user has input complex data
     
    stop = false;
    SkippedPixels = 0;
     
    % h = waitbar(0, 'Fitting T2...','CreateCancelBtn','global stop; stop = true;' );
    % set(h,'Name','T2fit Progress');
    % tic;
     
    minR2 = 1/maxT2;
    AvgCutoff = minimum * sqrt(ly); % Operationally define a cutoff based on vector length
    for r=1:rows
        if stop
            break;
        end
        for c=1:cols
            if stop
                break;
            end
            ydata = inData(r,c,:);   %某一位置处，三回波对应的像素值
            ydata = reshape(ydata,N,1);
            if thresh(r,c) && ( mean(ydata) > AvgCutoff )   %全部比0大
                lfit = tes \ log(ydata);            %lfit=-1/T2
                % res = glmfit(tes,log(ydata),[],'constant','on');
                if( lfit(2) < 0 && -lfit(2) > minR2 )
                    Map(r,c,1) = lfit(1);
                    Map(r,c,2) = -1/lfit(2);
                    % Map(r,c,3) = stats(1);
                elseif(-lfit(2) < minR2)
                    Map(r,c,1) = lfit(1);
                    Map(r,c,2) = maxT2;
                else
                    thresh(r,c) = 0;
                    SkippedPixels = SkippedPixels + 1;
                end
            else
                thresh(r,c) = 0;
                SkippedPixels = SkippedPixels + 1;
            end
        end
    %    rate = toc/r;
    %    remaining = (rows-r) * rate;
    %     update_string = sprintf('%0.1f s/row for %d rows. Remaining ~ %d min %d s. %0.1f%% pixels used', ...
    %         rate, r, floor(remaining/60), round(mod(remaining,60)), 100*(1-SkippedPixels/(r*cols)) );
    %     waitbar(r/rows, h, update_string, 'CreateCancelBtn', 'stop = true;');
    end
     
     
    if exist('h')
        delete(h);
        clear h;
    end
     
    if stop
        disp('Calculations canceled by user.');
        return;
    end
     
    Map(:,:,1) = exp(Map(:,:,1));
     
    if display
        clf;
        subplot(3,1,1);
        image(thresh,'CDataMapping','scaled');
        colorbar;
        axis image;
        subplot(3,1,2);
        image(abs(Map(:,:,1)),'CDataMapping','scaled');colormap jet;
        axis image;
        colorbar
        subplot(3,1,3);
        image(abs(Map(:,:,2)),'CDataMapping','scaled');colormap jet;
        axis image;
        colorbar
    end
end

    
%计算组合图像
function combined_data = me_combineEchoes(func_data, TE, method, weight_data)
    
    % INPUTS:
    % func_data - 5D [4D x E] timeseries or 4D [3D x E] volume data to be combine 输入的是一个5维的数据
    % TE - vector of echo times (ms) in order of acquisition, e.g. [14 28 42]
    % method - method used for combination of echoes:
    %         1 = T2*-weighted average, using T2* map provided in the "weight_data"
    %         2 = tSNR-weighted average, using tSNR map provided in the "weight_data"
    %         3 = TE-weighted average, using echo times in TE (ignores"weight_data"）
    %         4 = T2*FIT组合加权,weight_data使用上面计算出的t2starFIT_4D
    
    % THEORY:
    % Weighted average = {sum(data x weights)} / {sum(weights)}
    % If data = X and weights = W:
    % Weighted average = (x1w1 + x2w2 + ... + xnwn)/(w1+w2+...+wn)
    
    sz = size(func_data);
    Ne = numel(TE);   %判断有几个回波，可以通过TE的数量判断，和5维数据的最后一位
    
    % Check if dimensions agree for number of echos in data and TE vector  判断回波数量是否正确
    if Ne ~= sz(end)
        disp('error '); % TODO: raise error
        return
    end
    
     % Check validity of weight_data based on combination method
    switch method
        case 1
            % Posse T2*-weighted
            % weight_data should be a single 3D image same size as first three di
            % isequal(size(A), size(B)) || (isvector(A) && isvector(B) && numel(A
        case 2
            % Poser PAID tSNR-weighted
            % weight_data should be a 3D x E matrix of tSNR images, where E equal
        case 3
            % TE-weighted
    
        case 4
            %T2*FIT组合加权,weight_data使用上面计算出的t2starFIT_4D
    
        otherwise
            disp('error '); % TODO: raise error
    end
    
    data = {};
    weights = {};
    weighted_data = {};
    sum_weights = 0;
    sum_weighted_data = 0;
    
    % 计算combined图像
    for e = 1:Ne
        if numel(sz) == 4
            data{e} = func_data(:, :, :, e);
        else % numel(sz) = 5
            data{e} = func_data(:, :, :, :, e);
        end
    
        switch method
            case 1
                % Posse T2*-weighted
    
                weights{e} = TE(e) .* exp(-TE(e) ./ weight_data);
            case 2
                % Poser PAID tSNR-weighted
                weights{e} = TE(e) .* weight_data(:,:,:,e);
            case 3
                % TE-weighted
                weights{e} = TE(e);
            case 4
                %
                weights{e} = TE(e) .* exp(-TE(e) ./ weight_data);
            otherwise
                disp('Unknown combinaion method'); % TODO: raise error
        end
        % x1w1, x2w2, ..., xnwn
        weighted_data{e} = data{e} .* weights{e};
        % w1 + w2 + wn
        sum_weights = sum_weights + weights{e};
        % x1w1 + x2w2 + ... + xnwn
        sum_weighted_data = sum_weighted_data + weighted_data{e};
    end
    % (x1w1 + x2w2 + ... + xnwn)/(w1+w2+...+wn)
    combined_data = sum_weighted_data ./ sum_weights; % a 4D timeseries [3D x t]
end
%%

%%
%第三步，后处理  配准和分割
function matlabbatch = step31(file_root,ID,task)
    anat_path=[file_root 'sub-' ID '\anat\sub-' ID '_T1w.nii'];
    mean_path=[file_root 'sub-' ID '\func\meansub-' ID '_task-' task '_echo-2_bold.nii,1'];
    matlab_dir= 'D:\matlab\';
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
