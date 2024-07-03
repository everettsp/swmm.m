function tbl_clusters(cfg, path_tbls)
for i2 = 1:numel(cfg)
    dat = load(cfg(i2).ffile_events);
    centroids = dat.centroids;
    catchment = dat.catchment;
    x_tbl = dat.x_tbl;

    cluster_tbl = array2table(centroids','VariableNames',{[catchment,' cluster 1'], [catchment,' cluster 2']},'RowNames',x_tbl.Properties.VariableNames(1:12));

    %     cluster_tbl.Properties.RowNames ={'cluster 1', 'cluster 2'};
    for i3 = 1:size(cluster_tbl,2)
        cluster_tbl{'num\_events',i3} = sum(x_tbl.class == i3);
    end

    cfg(i2).cluster_tbl = cluster_tbl;

end
    cluster_tbl = [cfg(1).cluster_tbl,cfg(2).cluster_tbl];

    tex = tex_tbl(cluster_tbl);
    for i3 = 1:numel(cluster_tbl.Properties.RowNames)
        cluster_tbl.Properties.RowNames(i3) = tex.styles.math{1}(cluster_tbl.Properties.RowNames{i3});
    end

    tex.save([path_tbls,'tbl_cluster_summary'])
end