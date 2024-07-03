function [net2,inp,tgt] = resample_weightfun(net,inp,tgt,rf)

net2 = net;

for s2 = {'train','val'}
    ind = net.divideParam.([char(s2),'Ind']);
%     x1 = inp(:,ind);
    y1 = tgt(ind);    
    ihf2 = randsample(ind,numel(ind),true,rf(y1)); % resample based on example weighting

    net2.DivideParam.([char(s2),'Ind']) = ihf2; % update the training indices
end
end