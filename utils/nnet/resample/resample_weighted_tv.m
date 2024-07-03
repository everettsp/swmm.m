function [net2,inp,tgt] = resample_weighted_tv(net,inp,tgt,ww)
% extension of 'resample_weighted()', combined training and val subsets and
% draws sample from combined set. Useful for things like bagging when not
% block-splitting first

net2 = net;

n_train = numel(net.divideparam.trainind);
n_val = numel(net.divideparam.valind);

% merge train and val inds
ind_cal = [net.divideparam.trainind;net.divideparam.valind];

% sample train inds
ind_train = randsample(ind_cal,n_train,true,ww(ind_cal));


% remove train inds from cal inds
ind_cal_no_train = ind_cal(~ismember(ind_cal,ind_train));
ind_val = randsample(ind_cal_no_train,n_val,true,ww(ind_cal_no_train));

% set net params
net2.DivideParam.trainInd = ind_train;
net2.DivideParam.valInd = ind_val;

end