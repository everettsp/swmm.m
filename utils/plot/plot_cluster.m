function plot_cluster(results, path_figs)

catchment = results.catchment;
x_tbl = results.x_tbl;
max_pcas = results.max_pcas;
pca_diff = results.pca_diff;

cls = get_class_config;
colmat = reshape([cls(1:4).col],[3,4])';


fh = figure('Name',['som_scatmat_',catchment]);
plot_gplotmat(x_tbl.Variables,x_tbl.class,x_tbl.Properties.VariableNames','colmat',colmat,'plotargs',{'LineWidth',1,'MarkerSize',1});

ahs = findall(gcf,'type','axes'); %axes handles
for i2 = 1:numel(ahs)
    ahs(i2).XLabel.Interpreter = 'tex';
    ahs(i2).YLabel.Interpreter = 'tex';
end

gh = gfx2('fh',fh);
gh.apply([gh.width.dc,gh.width.dc],'margins',0.05*ones([4,1]),'frame',[0.6,0.1,0.6,0.1]);
gh.save(path_figs);



fh = figure('Name',['pca_effect','_',catchment]);
cols = colors('lassonde');
plot(1:max_pcas, pca_diff,'o-','LineWidth',2,'Color',cols.blue)
xlabel('number of principal components')
ylabel('total absolute difference in cluster result')
grid on
gh = gfx2('fh',fh);
gh.apply([gh.width.sc,gh.width.sc]);
gh.save(path_figs);






end