function obj = train(obj, inp, tgt)
% m = obj.m;
% obj.m = m;

% resample_fun = obj.resample_fun;
train_fun = obj.train_fun;

net = obj.nets{1};
% [net2,inp2,tgt2] = resample_fun(net,inp,tgt);
[obj.nets, obj.mw, ~] = train_fun(net, inp, tgt, obj.m);

if contains(func2str(train_fun),{'grad','stacking'})
    obj.combine_method = 'weighted sum';
end

end