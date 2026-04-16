%计算组合图像
function combined_data = me_combineEchoes(func_data, TE, method, weight_data)
    
    % INPUTS:
    % func_data - 5D [4D x E] timeseries or 4D [3D x E] volume data to be combine 输入的是一个5维的数据
    % TE - vector of echo times (ms) in order of acquisition, e.g. [14 28 42]
    % method - method used for combination of echoes:
    %         1 = T2*-weighted average, using T2* map provided in the "weight_data"
    %         2 = tSNR-weighted average, using tSNR map provided in the "weight_data"
    %         3 = TE-weighted average, using echo times in TE (ignores"weight_data"）
    %         4 = User value-weighted average, using weights in TE (ignores"weight_data"）
    
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
            % User specified vector of weights, same size as TE
    
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
                weights{e} = TE(e) .* weight_data(:, :, :, e);
            case 3
                % TE-weighted
                weights{e} = TE(e);
            case 4
                %
                weights{e} = weight_data(e);
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