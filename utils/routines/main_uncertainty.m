function results = main_uncertainty(mdl,events,varargin)

par = inputParser;
addParameter(par,'filename','')
addParameter(par,'overwrite',false)
parse(par,varargin{:})

filename = par.Results.filename; %results filename
overwrite = par.Results.overwrite; %whether to overwrite saved results file

% load(mdl.ffile_data)

catchment = mdl(1).name;

if ~isfile(filename) || overwrite

    % find the events in each class with min distance to cluster centroid
    idx_events = nan([2,1]);
    for event_class = unique([events.class])
        events2 = events([events.class] == event_class);
        [~,argmin_ed] = mink([events2.class_ed],2);
        idx = events2(argmin_ed(2)).id;
        idx_events(event_class) = find(idx == [events.id]);
        clear idx argmin_ed events2
    end

    scenarios = {'normal','high_sensitivity','low_sensitivity','high_uncertainty'};
    labels = {'baseline','sensitivie','insensitive','double uncertainty'};
    results = struct();

%         mdl_ga = swmm.empty;
mdl_ga = {};
        ga_info = {};
        
    for i3 = 1:numel(idx_events)

        j3 = idx_events(i3);
        % calibrate model to each single cal. event

        for i2 = 1:numel(scenarios)
            [mdl_ga{i2,i3},ga_info{i2,i3}] = swmm_ga(mdl,events(j3),'var_classes',ga_load_vars(scenarios{i2}));
        end
    end

    results.mdl = mdl_ga;
    results.ga_info = ga_info;
    results.events_rr = events(idx_events);
    results.scenarios = scenarios;
    results.labels = labels;
    results.catchment = catchment;

    save(filename,'-struct','results')


elseif isfile(filename)
    results = load(filename);
else
    error('this should never come up')
end
