function results = main_calibrate(mdl,events,filename, varargin)

par = inputParser;
addParameter(par,'overwrite',false)
parse(par,varargin{:})

overwrite = par.Results.overwrite; %whether to overwrite saved results file

kill
% path_figs = '01_multi_event\results\figs\';

mdl_se = swmm.empty;
ga_info_se = cell(numel(events),1);

if ~isfile(filename) || overwrite
    for i2 = 1:numel(events)
        [mdl_se(i2),ga_info_se{i2}] = swmm_ga(mdl,events(i2),'var_classes',load_opt_classes('high_uncertainty'));
    end
    
results = struct();
results.mdl = mdl_se;
results.ga_info = ga_info_se;
results.events = events;

save(filename,'-struct','results')
else
    results = load(filename);
end

end