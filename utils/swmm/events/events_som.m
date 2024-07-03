function net = events_som(x)
% x = x_tbl.Variables';
dimension1 = 3;
dimension2 = 3;
net = selforgmap([dimension1 dimension2]);
net.trainParam.ShowWindow = false;
[net,tr] = train(net,x);
% y = net(x);

% 
% class_summary = struct();
% 
% for i2 = 1:num_classes
%     x2 = x(:,x_classes == i2);
%     class_summary(i2).mean = mean(x2,2);
% end