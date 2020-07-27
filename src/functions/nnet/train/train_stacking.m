function [nets,ww,info] = train_stacking(net, inp, obs, m)
info = struct();
ww = nan(m,1);
nets = cell(m,1);
info.trns = cell(m,1);
    for i2 = 1:m
        [nets{i2}, info.trns{i2}, ww] = train(net,inp,obs);
        y(i2,:) = nets{i2}(inp);
    end
    
idx = (~any(isnan(y),1)) & ismember((1:numel(obs)),[net.DivideParam.trainInd;net.DivideParam.valInd]);
ww = (y(:,idx)')\(obs(idx)');
end