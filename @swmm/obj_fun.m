function [obj1] = obj_fun(mdl,pop,vars,evnts)

% AFAIK ga() only does minimization, so we optimize -NSE which has a range of [-1 inf]

% fun_obj1 = @(x,y) (1 - (sum((x - y).^2) / sum((x - mean(x)).^2))); %NSE
fun_obj1 = @perf_kge;

% fun_obj1 = @(x,y) sum((x - y).^2); %SSE
% fun_obj2 = @(x,y) sum(x - y); %E

% get number of events
num_events = numel(evnts);

% set the calibration parameter values

% for i3 = 1:height(vars)
%     mdl.p.(vars.class{i3})(strcmp(mdl.p.(vars.class{i3})(:,1).Variables,vars.name{i3}),vars.attribute{i3}).Variables = vars.val(i3);
% end

% classes = unique(vars.class);
% for i2 = 1:numel(classes)
%     attributes = unique(vars.attribute(strcmp(vars.class,classes{i2})));
%     for i3 = 1:numel(attributes)
%         % index of matching class and attribute
%         idx = strcmp(vars.class,classes{i2}) & strcmp(vars.attribute,attributes{i3});
%         [~,ind] = ismember(mdl.p.(classes{i2})(:,1).Variables,vars.name(idx));
%         pop2 = pop(idx);
%         mdl.p.(classes{i2}).(attributes{i3}) = pop2(ind)';
%     end
% end
% clear pop2 idx ind i2 i3

mdl = set_elements(mdl,vars,pop);

% itialize objective array based on number of events
objs1 = NaN(num_events,1);
for i7 = 1:num_events
    
    % write the dates to SWMM .INP
    mdl.p.options.START_DATE = evnts(i7).start_date;
    mdl.p.options.REPORT_START_DATE = evnts(i7).start_date;
    mdl.p.options.END_DATE = evnts(i7).end_date;
    
    mdl = mdl.use_hsf(evnts(i7).ffile_hs);
    mdl = mdl.use_rff(evnts(i7).ffile_rf);

%     mdl.write_inp;
    mdl.runsim;
    
    tt_fg = evnts(i7).tt_fg;
    
    % read simulated flow values
    
    stn_cell = split(tt_fg.Properties.VariableNames{1},'_'); stn_id = stn_cell{1}; stn_pram = stn_cell{2}; stn_units = stn_cell{3};
    tt_mod = mdl.results_tt;
    tt_mod = tt_mod(:,'inflow');
    
    tt_sync = synchronize(tt_mod,tt_fg);
    tt_mod = tt_sync(:,1);
    tt_fg = tt_sync(:,2);
%     tt_mod.Properties.VariableNames = {strcat('mod','_',char(tt_fg.Properties.VariableNames),'_g',num2str(gbl_state.gen_idx - 1),'p',num2str(gbl_state.pop_idx))};
%     gbl_mod{gbl_state.gen_idx,i7} = tt_mod;%[gbl_mod{gbl_state.gen_idx,i7},tt_mod];
    
%     disp(gbl_state)
    % convert observed and modelled flows to arrays, calculate performance
%     t = gbl_obs.tt_events{i7}.Variables;
    t = evnts(i7).tt_fg.Variables;
    y = table2array(tt_mod);
    
    assert(numel(t) == numel(y),'number of observed and modelled points do not match, re-check timeseries synchronization')
    objs1(i7) = -fun_obj1(t,y);
    
    % not sure if this is correct
end

% gbl_obj{gbl_state.gen_idx}(:,gbl_state.pop_idx) = {-objs1};
% gbl_state.pop_idx = gbl_state.pop_idx + 1;

% average performance
% across events
obj1 = mean(objs1);



end