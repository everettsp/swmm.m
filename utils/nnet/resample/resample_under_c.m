function [net2,inp,tgt] = resample_under_c(net,inp,tgt,p,varargin)

if p < 1
    p = p .* 100;
end

par = inputParser;
addParameter(par,'replacement',true)
parse(par,varargin{:})
replacement = par.Results.replacement;


net2 = net;

for s2 = {'train','val'}
    ind = net.divideParam.([char(s2),'Ind']);
    x1 = inp(:,ind);
    y1 = tgt(ind);
    
    hft = prctile(y1,p);
    ihf = y1 >= hft; % high flow inds
    itf = y1 < hft; % typical flow inds
    n = sum(ihf);
    ihf2 = randsample(ind(ihf),n,replacement); % resample number of high flows
    itf2 = randsample(ind(itf),n,replacement);

    net2.DivideParam.([char(s2),'Ind']) = [ihf2(:);itf2(:)]; % update the training indices
end
end