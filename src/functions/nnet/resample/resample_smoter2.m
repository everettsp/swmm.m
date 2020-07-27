function [net2,x2,y2] = resample_smoter(net,inp,tgt,rf,rth,N,k)

x2 = inp;
y2 = tgt;
net2 = net;

for s2 = {'train','val'}
    ind = net.divideParam.([char(s2),'Ind']);
    x1 = inp(:,ind);
    y1 = tgt(ind);
    [xsynth, ysynth] = smoter(x1',y1',rf,rth,N,k);
    
    n_orig = numel(y2);
    n_synth = numel(ysynth);

    net2.DivideParam.([char(s2),'Ind']) = [net.DivideParam.([char(s2),'Ind']); (n_orig + (1:n_synth))']; % update the training indices
    
    x2 = [x2,xsynth'];
    y2 = [y2,ysynth'];
end
end