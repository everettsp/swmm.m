function cm = main_mdl_cluster(mdls,events)

% mdl.dir_results = '01_multi_event\results\calibration\';
%     dir_figs = '01_multi_event\results\figs\';
catchment = mdls(1).name;


cluster_features = [];

events_tbl = struct2table(events);
% 
% %%
% x_tbl = events_tbl(:,{'total','intensity_peak','intensity_mean','duration_hours','date_rad','qp','q_vol','q_cy','q_ct','p_cy','p_ct'});
% x = x_tbl.Variables;
% num_clusters = 2;
% [x_classes, centroids] = cluster_som(x,[1,num_clusters]);
% 



for i2 = 1:numel(mdls)
    mdl = mdls(i2);
    opt_vals = mdl.classes2elements(load_opt_classes).val;
    cluster_features(:,i2) = opt_vals;
end

net = selforgmap([1,2]);
net.trainparam.showwindow = false;
[net,tr] = train(net,cluster_features);

outputs = net(cluster_features);
mdl_clusters = ((1:2) * outputs)';


event_clusters = [events.class]';

acc = sum(mdl_clusters == event_clusters) ./ numel(event_clusters);

% if acc below half, switch cluster IDs 1 and 2
if acc < 0.50
    mdl_clusters(mdl_clusters == 1) = 99;
    mdl_clusters(mdl_clusters == 2) = 1;
    mdl_clusters(mdl_clusters == 99) = 2;
end


cm = array2table(zeros(2,2));
cm.Properties.VariableNames = {'class 1 model','class 2 model'};
cm.Properties.RowNames = {'class 1 event','class 2 event'};

cm{'class 1 event','class 1 model'} = sum(mdl_clusters == 1 & event_clusters == 1);
cm{'class 2 event','class 1 model'} = sum(mdl_clusters == 1 & event_clusters == 2);
cm{'class 1 event','class 2 model'} = sum(mdl_clusters == 2 & event_clusters == 1);
cm{'class 2 event','class 2 model'} = sum(mdl_clusters == 2 & event_clusters == 2);

acc1 = diag(cm{:,:})' ./ sum(cm{:,:});
acc2 = diag(cm{:,:}) ./ sum(cm{:,:},2);
cm{'acc',:} = acc1;
acc2(end+1) = sum(mdl_clusters == event_clusters) ./ numel(event_clusters);
cm{:,'acc'} = acc2;



end