function [ccs,lags] = perf_sliding(x,y,varargin)
    
    p = inputParser;
    addParameter(p,'num_lags',50)
    addParameter(p,'obj_fun','cc')
    parse(p,varargin{:})
    num_lags = p.Results.num_lags;
    obj_fun = p.Results.obj_fun;
    
    lag_array = (-num_lags):num_lags;
    ccs = nan(numel(lag_array),1);

    for ii = 1:numel(lag_array)
        
        lag_val = lag_array(ii);
        y_shifted = nan(size(y));
        
        if lag_val == 0
            y_shifted = y;
        elseif lag_val > 0
            y_shifted((1+lag_val):end) = y(1:(end-lag_val));
        elseif lag_val < 0
            y_shifted(1:(end+lag_val)) = y((1-lag_val):end);
        else
            error('fix it')
        end
        
        
        notnan = ~(isnan(x) | isnan(y_shifted));
        
        
        switch lower(obj_fun)
            case {'corr','correlation'}
                corrmat = corrcoef(x(notnan),y_shifted(notnan));
                ccs(ii) = corrmat(2,1);
            otherwise
                ccs(ii) = eval(['perf_' obj_fun '(x(notnan),y_shifted(notnan))']);
        end
    end
%     stem(lags,ccs)
end