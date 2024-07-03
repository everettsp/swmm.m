function [nets,ww,info] = train_stacking(net, inp, obs, m)
info = struct();
ww = nan(m,1);
nets = cell(m,1);
info.trns = cell(m,1);
    for i2 = 1:m
        [nets{i2}, info.trns{i2}, ww] = train(net,inp,obs);
    end
end