function [net2,inp,tgt] = resample_weighted(net,inp,tgt,ww)
net2 = net;
for s2 = {'train','val'}
    ind = net.divideParam.([char(s2),'Ind']);
    ihf2 = randsample(ind,numel(ind),true,ww(ind)); % resample based on example weighting
    net2.DivideParam.([char(s2),'Ind']) = ihf2; % update the training indices
end
end