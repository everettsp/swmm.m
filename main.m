
redo_setup = false;
redo_sensitivity = false;
redo_calibration = false;
redo_uncertainty = false;
redo_stacking = false;
redo_uniform = false;

% stacking_results = {};
clear mdl_summary
clear results_stacking results_sensitivity results_cal results_uncertainty results_uniform

results_stacking = struct();
results_sensitivity = struct();
results_cal = struct();
results_uncertainty = struct();
results_uniform = struct();
mdl_summary = struct();
cm = {};

ffile_cfg = 'results\cfg_mdls.mat';
cfg_mdls = main_setup(ffile_cfg, 'overwrite', redo_setup);

path_figs = 'results\figs\';
path_tbls = 'results\tbls\';

tbl_clusters(cfg_mdls,path_tbls)
%%
for k2 = 1:numel(cfg_mdls)

    % load catchment data
    dat = load(cfg_mdls(k2).ffile_data());
    unpack_struct(dat);
    
    catchment = cfg_mdls(k2).catchment;
    mdl.name = cfg_mdls(k2).catchment;

    dat = load(cfg_mdls(k2).ffile_events());
%     events_rr = dat.events_random;
    events_rr = dat.events_selected;

    mdl.dir_results = 'results\calibration\';
    results = load(cfg_mdls(k2).ffile_events());
    plot_cluster(results, path_figs);
    plot_pre(mdl,events_rr,path_figs, path_tbls)
    
    file_calibrate = [char(mdl.dir_results),char(catchment),'_se.mat'];
    results = main_calibrate(mdl,events_rr, file_calibrate,'overwrite',redo_calibration);
    results_cal(k2) = results;
    
    file_uncertainty = [char(mdl.dir_results),char(catchment),'_uncertainty.mat'];
    results = main_uncertainty(mdl,events_rr,'filename',file_uncertainty,'overwrite',redo_uncertainty);
    plot_uncertainty(results,path_figs)

    file_sensitivity = [char(mdl.dir_results),char(catchment),'_sensitivity.mat'];
    results = main_sensitivity(mdl,events_rr,'filename',file_sensitivity,'overwrite',redo_sensitivity);
    plot_sensitivity(results, path_figs)

    file_uniform = [char(mdl.dir_results),char(catchment),'_uniform.mat'];
    results = main_uniform(results_cal(k2).mdl,results_cal(k2).events,tt_flow,'overwrite',redo_uniform,'filename',file_uniform);
    plot_uniform(results, path_figs);
    results_uniform(k2) = results;

    file_stacking = [char(mdl.dir_results),char(catchment),'_stacking.mat'];
    results = main_stacking(results_cal(k2).mdl, results_cal(k2).events, tt_flow, tt_precip, results_uniform(k2).cv_obs, results_uniform(k2).cv_mod, results_uniform(k2).cv_mat,...
        'filename',file_stacking,'overwrite',redo_stacking,'num_combinations',10);
    plot_stacking(results, path_figs, path_tbls);
    results_stacking(k2) = results;

    mdl_summary(k2) = swmm_summarise(mdl);
    
    cm = main_mdl_cluster(results_cal(k2).mdl,results_cal(k2).events);
    tbl2tex(cm,[path_tbls,catchment,'_','cluster_acc.tex'],'hlines',true,'vlines',true)

    events_tbl = events_summary(events_rr);
    events_tbl = tex_round(events_tbl);
    events_tbl = tex_escape(events_tbl);

    tbl2tex(events_tbl,[path_tbls,catchment,'_events.tex']);

end

summary_tbl = rows2vars(struct2table(mdl_summary),'VariableNamesSource','name');
summary_tbl.Properties.VariableNames{1} = 'parameters';
summary_tbl.Properties.DimensionNames{2} = 'Variables';
parameter_units = {'[#]','[-]','[ha]','[ha]','[%]','[m]'};
summary_tbl.units = parameter_units';
summary_tbl = summary_tbl(:,[1,4,2,3]);

summary_tbl.Properties.VariableNames = strrep(summary_tbl.Properties.VariableNames,'_',' ');

tex = tex_tbl(summary_tbl);
tex = tex.escape();
tex.save([path_tbls,'mdl_summary.tex'])

tex = tex_funs();

fm = tex.fmat_init(summary_tbl);
