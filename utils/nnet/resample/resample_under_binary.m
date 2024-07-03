function [net2,inp,tgt] = resample_under_binary(net,inp,tgt,varargin)


par = inputParser;
addParameter(par,'replacement',true)
parse(par,varargin{:})
replacement = par.Results.replacement;

net2 = net;

for s2 = {'train','val'}
    ind = net.divideParam.([char(s2),'Ind']);
    x1 = inp(:,ind);
    y1 = tgt(ind);
    

    ihf = (y1); % high flow inds
    itf = (~y1); % typical flow inds
    n = sum(ihf);
    ihf2 = randsample(ind(logical(ihf)),n,replacement); % resample number of high flows
    itf2 = randsample(ind(logical(itf)),n,replacement);

    net2.DivideParam.([char(s2),'Ind']) = [ihf2(:);itf2(:)]; % update the training indices
end
end