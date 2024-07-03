function [net2,inp,tgt] = resample_weighted_c(net,inp,tgt,ww)

if nargin < 4
    ww = ones(size(tgt));
end

net2 = net;

n_train = numel(net2.divideparam.trainind);
n_val = numel(net2.divideparam.valind);
ind = [net2.divideparam.trainind;net2.divideparam.valind];

ind_train = [];
ind_val = [];
while (sum(tgt(ind_train)) < 1) && (sum(tgt(ind_val)) > 1)
ind_train = randsample(ind,n_train,true,ww(ind));
ind_val = randsample(ind(~ismember(ind,ind_train)),n_val,true,ww(ind(~ismember(ind,ind_train))));



net2.divideparam.trainind = ind_train;
net2.divideparam.valind = ind_val;

end
% 
% for s2 = {'train','val'}
%     ind = net.divideParam.([char(s2),'Ind']);
%     ihf2 = randsample(ind,numel(ind),true,ww(ind)); % resample based on example weighting
%     net2.DivideParam.([char(s2),'Ind']) = ihf2; % update the training indices
% end
% end


% % % if nargin < 4
% % %     ww = ones(size(tgt));
% % % end
% % % 
% % % net2 = net;
% % % for s2 = {'train','val'}
% % %     ind = net.divideParam.([char(s2),'Ind']);
% % %     ihf2 = randsample(ind,numel(ind),true,ww(ind)); % resample based on example weighting
% % %     net2.DivideParam.([char(s2),'Ind']) = ihf2; % update the training indices
% % % end
% % % end