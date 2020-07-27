function pf = perf_funs
pf = struct();
pf.nse = @perf_nse;         % nash-sutcliffe efficiency
pf.ce = @perf_nse;          % nash-sutcliffe efficiency (pseudonym)
pf.pi = @perf_pi;           % persistence index
pf.pi2 = @perf_pi2;         % persistence index (variant)
pf.mse = @perf_mse;         % mean squared error
pf.rmse = @perf_rmse;       % root mean squared error
pf.wmse = @perf_wmse;       % weighted mean squared error
pf.wrmse = @perf_wrmse;     % weighted root mean squared error
pf.aic = @perf_aic;         % aikike information criterion
pf.cc = @perf_cc;           % correlation coeff
pf.hm = @perf_hm;           % hydrograph matchig algorithm
pf.sse = @perf_sse;         % sum squared error
pf.se = @perf_se;           % squared error
pf.mve = @perf_mve;         % mean volume error
pf.pfe = @perf_pfe;         % peak flow error

    function [x,y] = check_inputs(x,y)
        % checks data structure of x/y
        % ensure row-wise samples
        
        if size(x,1) < size(x,2)
            x = x';
            y = y';
        end
        
        assert(size(x,1) == size(y,1)); %assert same number of samples
%         assert(size(x,2) == 1); %assert only 1 x observation variable
    end

    function nse = perf_nse(x,y)
        %% Nasch-Sutcliffe CE
        [x,y] = check_inputs(x,y);
        ind = ~(isnan(x) | any(isnan(y),2));
        x = x(ind);
        y = y(ind,:);
        nse = 1 - sum((x - y).^2) / sum((x - mean(x)).^2); %Nash-Sutcliffe CE
    end

    function pi = perf_pi(x,y,lead)
        [x,y] = check_inputs(x,y);
        xl = nan(size(x)); %target station
        xl((lead+1):end) = x(1:(end-lead)); %lag target station by the lead time
        ind = ~(isnan(x) | any(isnan(y),2) | isnan(xl));
        x = x(ind);
        xl = xl(ind);
        y = y(ind,:);
        
        f = sum((x - y).^2);
        
        if lead ~= 0
            fp = sum((x - xl).^2);
            pi = 1 - f./fp;
        else
            m = size(y,2);
            pi = ones(1,m);
        end
    end

    function pi = perf_pi2(x,y)
        % variation of PI where x is contains vectors x and xl
        [x,y] = check_inputs(x,y);
        ind = ~(any(isnan(x),2) | any(isnan(y),2));
        x = x(ind,:);
        y = y(ind,:);
        assert(size(x,2) == 2);
        
        f = sum((x(:,1) - y).^2);
        
%         if lead ~= 0
            fp = sum((x(:,1) - x(:,2)).^2);
            pi = 1 - f./fp;
%         else
%             m = size(y,2);
%             pi = ones(1,m);
%         end
    end

    
    function se = perf_se(x,y)
        %% squared error
        [x,y] = check_inputs(x,y);
        ind = ~(isnan(x) | any(isnan(y),2));
        x = x(ind);
        y = y(ind,:);
        se = (x - y).^2;
    end

    function sse = perf_sse(x,y)
        %% sum squared error
        sse = sum(perf_se(x,y));
    end

    function mse = perf_mse(x,y)
        %% mean squared error
        mse = mean(perf_se(x,y));
    end

    function rmse = perf_rmse(x,y)
        %% root mean squared error
        rmse = perf_mse(x,y).^2;
    end

    function mve = perf_mve(x,y,rel_or_abs)
        %% mean volume error
        
        % relative or absolute error
        if nargin < 3 ;rel_or_abs = 'rel'; end % default is relative
        [x,y] = check_inputs(x,y);
        ind = ~(isnan(x) | any(isnan(y),2));
        x = x(ind);
        y = y(ind,:);
        
        switch lower(rel_or_abs)
            case {'rel','relative'}; mve = abs(sum((x - y)))./sum(x);
            case {'abs','absolute'}; mve = abs(sum((x - y)));
        end
    end

    function mfe = perf_mfe(x,y,rel_or_abs)
        %% max flow error (peak flow, time indifferent)
        
        % relative or absolute error
        if nargin < 3 ;rel_or_abs = 'rel'; end % default is relative
        [x,y] = check_inputs(x,y);
        ind = ~(isnan(x) | any(isnan(y),2));
        x = x(ind);
        y = y(ind,:);
        
        switch lower(rel_or_abs)
            case {'rel','relative'}; mfe = (max(x) - max(y)) ./ max(x);
            case {'abs','absolute'}; mfe = (max(x) - max(y));
        end
    end


    function wmse = perf_wmse(x,y,ww)
        %% weighted mean squared error
        [x,y] = check_inputs(x,y);
        ind = ~(isnan(x) | any(isnan(y),2));
        x = x(ind);
        y = y(ind,:);
        ww = ww(ind);
        n = numel(x);
        wmse = sum(ww .* (x - y).^2) / n;
    end

    function rmse = perf_wrmse(x,y,ww)
        rmse = perf_wmse(x,y,ww).^2;
    end

    function aic = perf_aic(x,y,p)
        %% Akaike information criterion
        [x,y] = check_inputs(x,y);
        ind = ~(isnan(x) | any(isnan(y),2));
        x = x(ind);
        y = y(ind,:);
        n = numel(x);
        aic = n * log (perf_mse(x,y)) + (2 * p);
    end

    function cc = perf_cc(x,y)
        %% correlation coefficient
        [x,y] = check_inputs(x,y);
        ind = ~(isnan(x) | any(isnan(y),2));
        x = x(ind);
        y = y(ind,:);
        m = size(y,2);
        cc = nan(1,m);
        for i2 = 1:m
            temp = corrcoef(x,y(:,i2),'Rows','Complete');
            cc(i2) = temp(2,1);
            clear temp
        end
        
    end
end