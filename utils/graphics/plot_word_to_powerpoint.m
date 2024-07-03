


path_figs = 'C:\Users\everett\Google Drive\02_phd\00_projects_major\02_swmm_calibration\03_uncertainty\results\figs_dr\';


gp = gfx('tex','lassonde');
fh = gcf;
ahs = findall(fh,'type','axes'); %axes handles
lh = findall(fh,'type','legend'); %axes handles
% fh.Name = [fh.Name,'_presentation'];
lh.Location = 'southwest';

% gp.apply([29.21/gp.pgw,12.09/gp.pgh],'margins',[.1,.1,.15,.15],'leg_pos','bottom-mid','bottom',2.5,'left',1.5,'xlabel_placement','mid')



% gp.apply([12.09,12.09],'margins',[0.01,0.01,0.01,0.01],'bottom',1,'left',1,'right',0.1,'top',0.1)
gp.apply([1,0.5],'margins','comfortable')

save_fig(path_figs)






