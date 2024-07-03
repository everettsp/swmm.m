function rd = rd_funs()

% if nargin < 2
%     rd_string = 'uniform';
% end

rd = struct();
rd.grad = @rd_grad;
rd.inform = @rd_inform;
rd.logi = @rd_logi;
rd.linear = @rd_linear;
rd.invprob = @rd_invprob;
rd.uniform = @rd_uniform;
rd.invfreq = @rd_invfreq;
end

function [w] = rd_grad(t,L)
if nargin < 2
    L = 1;
end
tl = nan(size(t));
tl((1+L):end) = t(1:(end-L));
w = abs(t - tl) ./ L;
w = normalize(w,'range');
w(isnan(w)) = 0;
% rd = rd.^0.4;
end

function [w] = rd_inform(t)
[w] = get_information(t,50);
w = normalize(w,'range');
w(isnan(w)) = 0;
end

function [w] = rd_logi(t)
w = 1./(1+exp(-16*(t-nanmean(t))));
w = normalize(w,'range');
w(isnan(w)) = 0;
end

function [w] = rd_linear(t)
w = normalize(t,'range');
w(isnan(w)) = 0;
end

function [w] = rd_invprob(t)
[wi,fi] = ksdensity(t,'Bandwidth',0.001,'NumPoints',1000,'BoundaryCorrection','log');
wi = wi / sum(wi);
w = 1./interp1(fi,wi,t,'nearest');
w(isnan(w)) = 0;
w = normalize(w,'range');
% histogram(randsample(x,numel(x),true,w))
% w = ones(size(t));
end

function [w] = rd_invfreq(t)
nb = 10;
[wi,~] = histcounts(t,nb,'Normalization','probability');
[ind,~] = discretize(t,nb);

idx = ~isnan(t);
w = nan(size(t));
w(idx) = wi(ind(idx));
w(idx) = 1./w(idx);
w(~idx) = 0;

w = normalize(w,'range');
% histogram(randsample(x,numel(x),true,w))
% w = ones(size(t));
end

function [w] = rd_uniform(t)
w = ones(size(t));
w(isnan(w)) = 0;
end