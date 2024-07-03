function [net2,inp2,tgt2] = resample_over(net,inp,tgt,p,varargin)

if p < 1
    p = p .* 100;
end

par = inputParser;
addParameter(par,'replacement',true)
parse(par,varargin{:})
replacement = par.Results.replacement;

net2 = net;
inp2 = inp;
tgt2 = tgt;

for s2 = {'train','val'}
    ind = net.divideParam.([char(s2),'Ind']);
    x1 = inp(:,ind);
    y1 = tgt(ind);
    
    hft = prctile(y1,p);
    ihf = y1 >= hft; % high flow inds
    itf = y1 < hft; % typical flow inds
    n = sum(itf);
    ihf2 = randsample(ind(ihf),n,replacement); % resample number of high flows
    itf2 = randsample(ind(itf),n,replacement);
    
    n_total = numel(tgt2);
    
    inp_tf = inp(:,itf2);
    inp_hf = inp(:,ihf2);
    inp2 = [inp2,inp_tf,inp_hf];
    
    tgt_tf = tgt(itf2);
    tgt_hf = tgt(ihf2);
    tgt2 = [tgt2,tgt_tf,tgt_hf];
    
    n_new = n * 2;
    
    net2.DivideParam.([char(s2),'Ind']) = [n_total + (1:n_new)]; % update the training indices
    
end
end