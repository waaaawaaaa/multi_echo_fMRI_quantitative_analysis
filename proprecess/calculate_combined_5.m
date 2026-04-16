clc;clear;
%在sub-001文件夹下生成五个状态的文件夹
task={'fingerTapping','emotionProcessing','rest_run-2','fingerTappingImagined','emotionProcessingImagined'};
for task_id=1:length(task)
    mkdir(['sub-001\' task{task_id}])

    %%
    % 读取finger tapping文件，共三个回波
    nii_dir = ['F:\朱梦莹毕业设计\proprecess\sub-001\func\arsub-001_task-',task{task_id}];
    %回波1
    nii_dir_echo1 = [nii_dir '_echo-1_bold.nii'];
    nii_echo1 = load_nii(nii_dir_echo1);
    data_4D_echo1 = double(nii_echo1.img);   %将单精度转换为了双精度
    
    %回波2
    nii_dir_echo2 = [nii_dir '_echo-2_bold.nii'];
    nii_echo2 = load_nii(nii_dir_echo2);
    data_4D_echo2 = double(nii_echo2.img);
    
    %回波3
    nii_dir_echo3 = [nii_dir '_echo-3_bold.nii'];
    nii_echo3 = load_nii(nii_dir_echo3);
    data_4D_echo3 = double(nii_echo3.img);
    
    %整合三个回波，便于后边的for循环
    func_data(:,:,:,:,1) = data_4D_echo1;
    func_data(:,:,:,:,2) = data_4D_echo2;
    func_data(:,:,:,:,3) = data_4D_echo3;
    %%
    
    
    % % 读取文件，前面在计算先验数据是整理保存为_func_data.mat文件
    % func_data = load('sub001_func_data.mat').func_data;
    % % echo1 = func_data(:,:,:,:,1);
    % % echo2 = func_data(:,:,:,:,2);
    % % echo3 = func_data(:,:,:,:,3);
    
    
    %%
    %计算t2starFIT
    % calculate T2* (voxel-size)
    TE1 = 14e-3;TE2 = 28e-3;TE3 = 42e-3;
    A = pinv([1,-TE1;1,-TE2;1,-TE3]);
    
    [Ni, Nj, Nk, Nt, Ne] = size(func_data);
    t2star_4D = zeros(Ni, Nj, Nk, Nt);
    
    %挨个像素的计算t2star
    for i = 1:Ni
        for j = 1:Nj
            for k = 1:Nk
                for t = 1:Nt
                    S_TE1 = func_data(i,j,k,t,1);
                    S_TE2 = func_data(i,j,k,t,2);
                    S_TE3 = func_data(i,j,k,t,3);
                    B = [log(S_TE1);log(S_TE2);log(S_TE3)];
                    C = A*B;
                    T2starFIT = 1/C(2);
                    t2starFIT_4D(i,j,k,t) = T2starFIT;
                end
            end
        end
    end
    save(['sub-001\' task{task_id} '\t2starFIT'],'t2starFIT_4D');
    
    t2starFIT_data_nii=make_nii(t2starFIT_4D);
    save_nii(t2starFIT_data_nii,['sub-001\' task{task_id} '\t2starFIT.nii'])
    %% 
    
    
    TE = [0.014,0.028,0.042];
    
    %  1——T2*加权
    method=1;  weight_data=load('sub-001_t2star').t2star_3D;
    T2star_combined_data = me_combineEchoes(func_data, TE, method, weight_data); 
    
    %  2——tSNR加权
    method=2;  weight_data=load('sub-001_tSNR_4D').tSNR_4D;
    tSNR_combined_data = me_combineEchoes(func_data, TE, method, weight_data);  
    
    %  3——TE加权
    method=3;  weight_data=0;
    TE_combined_data = me_combineEchoes(func_data, TE, method, weight_data); 
    
    %  4——T2*FIT组合加权
    method=4;  weight_data=t2starFIT_4D;
    T2starFIT_combined_data = me_combineEchoes(func_data, TE, method, weight_data); 
    
    
    % combined_data = me_combineEchoes(func_data, TE, method, weight_data)
    % method - method used for combination of echoes:
    %         1 = T2*-weighted average, using T2* map provided in the "weight_data"
    %         2 = tSNR-weighted average, using tSNR map provided in the "weight_data"
    %         3 = TE-weighted average, using echo times in TE (ignores"weight_data"）
    %         4 = T2*FIT组合加权,weight_data使用上面计算出的t2starFIT_4D
    
    %%
    %不调用函数，直接在这里计算加权图像
    % weights = {};
    % weighted_data = {};
    % sum_weights = 0;
    % sum_weighted_data = 0;
    % for eN = 1:3
    %     weights{eN} = TE(eN);
    % 
    %     % x1w1, x2w2, ..., xnwn
    %     weighted_data{eN} = func_data(:,:,:,:,eN).* weights{eN};     %加权后的数据
    %     % w1 + w2 + wn
    %     sum_weights = sum_weights + weights{eN};   %求和
    %     % x1w1 + x2w2 + ... + xnwn
    %     sum_weighted_data = sum_weighted_data + weighted_data{eN};
    % end
    % 
    % % (x1w1 + x2w2 + ... + xnwn)/(w1+w2+...+wn)
    % combined_data = sum_weighted_data ./ sum_weights; % a 4D timeseries [3D x t]
    %%
    
    save(['sub-001\' task{task_id} '\T2star_combined'],'T2star_combined_data');
    
    save(['sub-001\' task{task_id} '\tSNR_combined'],'tSNR_combined_data');
    
    save(['sub-001\' task{task_id} '\TE_combined'],'TE_combined_data');
    
    save(['sub-001\' task{task_id} '\T2starFIT_combined'],'T2starFIT_combined_data');
    
    % figure;imshow3D(combined_data);
    
    %%
    %保存为nii格式
    T2star_combined_data_nii = make_nii(T2star_combined_data);
    save_nii(T2star_combined_data_nii,['sub-001\' task{task_id} '\T2star_combined.nii'])
    
    tSNR_combined_data_nii=make_nii(tSNR_combined_data);
    save_nii(tSNR_combined_data_nii,['sub-001\' task{task_id} '\tSNR_combined.nii'])
    
    TE_combined_data_nii = make_nii(TE_combined_data);
    save_nii(TE_combined_data_nii,['sub-001\' task{task_id} '\TE_combined.nii'])
    
    t2starFIT_combined_data_nii=make_nii(T2starFIT_combined_data);
    save_nii(t2starFIT_combined_data_nii,['sub-001\' task{task_id} '\T2starFIT_combined.nii'])
end
%%

%%
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
