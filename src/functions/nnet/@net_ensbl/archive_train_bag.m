function obj = train_bag(obj, x, t, resample_fun)
obj.resample_method = 'bagging';
    for i2 = 1:obj.m
        net = obj.nets{i2};
        [net_rs, x2, t2] = resample_fun(net, x, t);
        [obj.nets{i2}, obj.trns{i2}] = train(net_rs, x2, t2);
    end
end