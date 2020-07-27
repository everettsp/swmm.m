function [information] = get_information(x,num_bins)
%     h = histogram(T,'Normalization','probability');
if nargin < 2
    [bins_prob,bins] = histcounts(x,'Normalization','probability');
%     disp(['estimating probability based on ' num2str(numel(binsP)) ' (default) bins'])
else
    [bins_prob,bins] = histcounts(x,num_bins,'Normalization','probability');
%     disp(['estimating probability based on ' num2str(num2bins) ' bins'])
end
    bins_left = bins(1:(end-1)); %left values of bins
    bins_right = bins(2:end); %right values of bins
    n = length(x);
    p = zeros(n,1); %x probability P(x)
%     I = zeros(n,1);
    
        for ii = 1:n
%             try
                ind = x(ii) > bins_left & x(ii) <= bins_right; %find bin (logical index)
                if ~isnan(x(ii))
                p(ii) = bins_prob(ind); %get probabiltiy (no need for /N since hist already P(x))
                elseif isnan(x(ii))
                    p(ii) = nan;
                end
%                 I(ii) = log(1/p(ii));
%             catch
%                 P(ii) = NaN;
%                 I(ii) = NaN;
%             end
                
        end
        
        information = log(1./p);
        
%         entropy = -sum(p(ii) .* log(p(ii)));
end