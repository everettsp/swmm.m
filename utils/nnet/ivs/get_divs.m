function [ind_fold] = get_divs(method,N,k)

switch method
    case {'kfcv'}
%         N = 1000;
%         k = 9;
        n_fold = floor(N/k);
        ind_fold = NaN(1,N);
        
        for i2 = 1:k
            ind_fold((i2 - 1) * n_fold + (1:n_fold)) = i2;
        end
        
        % calculate relative amount of unused sample points
        remainder = (N - k * n_fold) / N;
        if remainder > 0.01
            warning(['fold partition produces remainder >1% (',num2str(remainder),')'])
        end
    case{'block'}
        
    otherwise
        error(["method '",method,"' not recognized"])
end



end