function ah = smoothhist(x,num_bins, varargin)
%     histogram(x,'Normalization','probability')

if ischar(num_bins)
    varargin{end+1} = '';
    varargin(2:end) = varargin(1:(end-1));
    varargin{1} = num_bins;
    
    num_bins = 10;
end

hh = histfit(x,num_bins,'kernel');
% hh(2).YData = hh(2).YData/sum(~isnan(x));
hh(2).YData = hh(2).YData / sum(hh(2).YData);
delete(hh(1))
ah = hh(2);
for i2 = 1:2:numel(varargin)
    set(hh(2),varargin{i2:(i2+1)});
end
end