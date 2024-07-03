function net = apply_datapart(net,inp,tgt,ratios)
    % set block data partitionas for train val test (chronological)
    % partitions
    
    assert(size(inp,2) == size(tgt,2),'input and targets must have samples along dim 2')
    assert(sum(ratios) == 1, 'sum of ratios must equal 1')
    
    idx = ~any(isnan([inp;tgt])); % nans
    ind = find(idx); %indices of non-nan samples
    
    n = nnz(idx); % number of non-nan sample points
    
    n_train = floor(ratios(1) * n);   % number of train points
    n_val = floor(ratios(2) * n);       % "" val
    n_test = floor(ratios(3) * n);     % "" test
    
    net.divideFcn = 'divideind';    % Divide data by indices
    net.divideMode = 'sample';      % Divide up every sample
    
    net.divideParam.trainInd = ind(1:n_train);
    net.divideParam.valInd = ind(n_train + (1:n_val));
    net.divideParam.testInd = ind(n_train + n_val + (1:n_test));
end