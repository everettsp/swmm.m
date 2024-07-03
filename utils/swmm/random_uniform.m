function results = random_uniform(mdl,events_rr,events_selected,tt_flow,varargin)

par = inputParser;
addParameter(par,'filename','')
addParameter(par,'overwrite',false)
parse(par,varargin{:})

filename = par.Results.filename;
overwrite = par.Results.overwrite;


pf = perf_funs;

%% Setup


if ~isfile(filename) || overwrite

% lag the flow by the forecast lead time
% was originally lagigng precip, since it was provided as a forecast, but
% now it's just at current time t, no need to lag


% setup dirs and load the single-event calibration outcome
% mdl.dir_results = '01_multi_event\results\calibration\';
catchment = mdl(1).name;

% dat = load(['01_multi_event\results\stacking\',catchment,'_se.mat']);
% events_rr = dat.events;
% mdl = dat.mdl_se;

n_events = numel(events_rr);

% load event formatting info
ecl = setup_eventclass(events_rr);
idx1 = ecl(1).idx;
idx2 = ecl(2).idx;

% initialise cross-validation matrix
cv_mat = nan(numel(events_rr));
cat_mods = [];
cv_mod = cell(numel(events_rr));
cv_obs = cell(numel(events_rr),1);
cv_precip = cell(numel(events_rr),1);
cat_obs = [];

% evaluate each event on each other event and save performance to nxn
% matrix where diagonal is the calibration performance

for i2 = 1:numel(events_rr)
    cat_mod = [];
    for i3 = 1:numel(events_selected)
        stn_cell = split(events_rr(i3).tt_fg.Properties.VariableNames{1},'_'); stn_id = stn_cell{1}; stn_pram = stn_cell{2}; stn_units = stn_cell{3};
        
        tt_mod = mdl(i2).eval(events_rr(i3),stn_id); % get mod. tt
        tt_mod = tt_mod(:,'inflow'); % select flow
        tt_obs = retime(tt_flow,tt_mod.Properties.RowTimes,'mean'); % retime obs. tt
        
        cat_mod = [cat_mod; tt_mod.Variables];
        
        cv_mat(i2,i3) = pf.kge(tt_obs.Variables,tt_mod.Variables);
        cv_mod{i2,i3} = tt_mod;
        cv_obs{i3} = tt_obs;
        cv_precip{i3} = retime(events_rr(i3).tt(:,'precip'),tt_mod.Properties.RowTimes,'sum');
        
    end
    
    cat_obs = [cat_obs; tt_obs.Variables];
    cat_mods = [cat_mods,cat_mod];
    
end

%% Compare number of models for SCMM and MCMM
% create a config. struct for the ensemble size comparison
% each index represents an ensemble prediction
% config contains multi-class and single class ensemble specifications

cfg = struct();
cfg.idx = [];

% number of event combinations to sample
num_event_idx_sample = 100;
for i2 = 1:(numel(events_rr)/2-1)
    cfg(i2).idx = get_idx_mat([idx1;idx2],numel(events_rr),i2,num_event_idx_sample);
    cfg(i2).class = 12;
    cfg(i2).num_mdl = i2 .* 2;
    
%     cfg(i2+9).idx = get_idx_mat(idx1,numel(events_rr),i2,num_event_idx_sample);
%     cfg(i2+9).class = 1;
%     cfg(i2+9).num_mdl = i2;
%     
%     cfg(i2+18).idx =  get_idx_mat(idx2,numel(events_rr),i2,num_event_idx_sample);
%     cfg(i2+18).class = 2;
%     cfg(i2+18).num_mdl = i2;
end

% calculate the multi-model performance for each idx combination
for i4 = 1:numel(cfg)
    perf_mat= nan(size(cfg(i4).idx,[1,2])); % array of size n validation events by m predictor event combintations
    perf = struct();
    perf_lbls = {'kge','pfe','mve'};
    
    % initialise empty perf mats
    for i5 = 1:numel(perf_lbls) 
        perf.(perf_lbls{i5}) = perf_mat;
    end
     perf.mse = perf_mat; perf.dbias = perf_mat; perf.dvar = perf_mat; perf.dcov = perf_mat;
     
    for i3 = 1:size(cfg(i4).idx,2)
        for i2 = 1:n_events
            idx = squeeze(cfg(i4).idx(i2,i3,:))';
            inp_test = tt_cat(cv_mod(idx,i2)')';
            tgt_test = tt_cat(cv_obs(i2))';
            mod_test_uni = mean(tt_cat(cv_mod(idx,i2)'),2);
            
            perf_mat(i2,i3) = pf.kge(tgt_test,mod_test_uni');
            for i5 = 1:numel(perf_lbls)
                perf_fun = pf.(perf_lbls{i5});
                perf.(perf_lbls{i5})(i2,i3) = perf_fun(tgt_test,mod_test_uni');
            end
        end
    end
    cfg(i4).kge = perf_mat;
    cfg(i4).perf = perf;
    cfg(i4).perf_mean = nanmean(perf_mat);
end

% copy the cross-val matrix and assign nans along diagonal (remove
% calibration performance)
cv_mat2 = cv_mat;
for i2 = 1:size(cv_mat,1)
    for i3 = 1:size(cv_mat,2)
        if i2 == i3
            cv_mat2(i2,i3) = nan;
        end
    end
end

% append single-model perofrmance to config. struct
cfg(end+1).lbl = 'so';
cfg(end).class = 0;
cfg(end).kge = cv_mat2;
cfg(end).perf_mean = nanmean(cv_mat2);

results = struct();
results.cv_mat = cv_mat;
results.cv_mod = cv_mod;
results.cv_obs = cv_obs;
results.cfg = cfg;
results.events_rr = events_rr;
results.catchment = catchment;
results.mdl = mdl;

save(filename,'-struct','results')
%% Evaluate and plot performance for SCMM and MCMM for fixed number of models

elseif isfile(filename)
        results = load(filename);
else
    error('this should never come up')
end