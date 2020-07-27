function net = div_mixtv(net)

calInd = [net.DivideParam.trainInd,net.DivideParam.testInd];

% trainRatio = numel(net.DivideParam.trainInd) / numel(calInd);
% valRatio = numel(net.DivideParam.valInd) / numel(calInd);

trainInd2 = randsample(calInd,numel(net.DivideParam.trainInd),false);
valInd2 = calInd(~ismember(calInd,trainInd2));

net.DivideParam.trainInd = trainInd2;
net.DivideParam.valInd = valInd2;

end