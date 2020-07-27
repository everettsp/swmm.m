function [nets, mw ,train_info] = train_bag(net,inp,tgt,m,varargin)

par = inputParser;
addParameter(par,'rsf',@resample_default)
parse(par,varargin{:})
rsf = par.Results.rsf;

nets = cell(m,1);
train_info = cell(m,1);

for i2 = 1:m
    [net2,inp2,tgt2] = rsf(net,inp,tgt);
    [nets{i2}, train_info{i2}] = train(net2,inp2,tgt2);
end
mw = ones(m,1);
end