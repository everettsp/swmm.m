function [obj1] = swmm_ga_optfun2(pop)
global gbl_dt % field-mapping to assign parameters to PCSWMM
global gbl_obs % observed values to calculate SSE in optimizaiton function
global gbl_out
global gbl_mod
global gbl_obj
global swmm
global gbl_event_options

% AFAIK ga() only does minimization, so we optimize -NSE which has a range of [-1 inf]
fun_obj1 = @(x,y) -(1 - (sum((x - y).^2) / sum((x - mean(x)).^2))); %NSE
% fun_obj1 = @(x,y) sum((x - y).^2); %SSE
% fun_obj2 = @(x,y) sum(x - y); %E


% get the generation numbers based on the objective function values
if isempty(gbl_obj)
    gen_itr = 1;
else
    gen_itr = numel(gbl_obj) + 1;
end

% get number of events
num_events = height(gbl_event_options);


% set the calibration parameter values
gbl_dt.val = pop';

for i3 = 1:height(gbl_dt)
    swmm.(gbl_dt.class{i3})(strcmp(swmm.(gbl_dt.class{i3})(:,1).Variables,gbl_dt.name{i3}),gbl_dt.attribute{i3}).Variables = gbl_dt.val(i3);
end

% push changes to swmm file and run
swmm.push;

% itialize objective array based on number of events
obj1_i2 = NaN(num_events,1);
for i2 = 1:num_events
    
    % write options for simulation start and end datetimes
    for i3 = 1:width(gbl_event_options)
        idx = strcmp(swmm.options.Option,gbl_event_options.Properties.VariableNames(i3));
        swmm.options.Value(idx) = gbl_event_options(i2,i3).Variables;
    end
    
    swmm.push;
    swmm.sim;
    % read simulated flow values
    tt_mod = swmm.tt(gbl_out.class(1), gbl_out.name(1));
    tt_mod = tt_mod(:,gbl_out.attribute(1));
    
    varname_mod = strcat('mod','_',gbl_out.attribute(1));
    tt_mod.Properties.VariableNames = varname_mod;
    
    
    % get the population member number for results metadata
    if isempty(gbl_mod{gen_itr,i2})
        pop_itr = 1;
    else
        pop_itr = numel(gbl_mod{gen_itr,i2}.Properties.VariableNames) + 1;
    end
    varname_mod = tt_mod.Properties.VariableNames;
    varname_itr = {[char(varname_mod),'_',num2str(pop_itr)]};
    gbl_mod{gen_itr,i2}(:,varname_itr) = tt_mod;
    
    % convert observed and modelled flows to arrays, calculate performance
    t = gbl_obs{i2}.Variables;
    y = table2array(tt_mod);
    assert(numel(t) == numel(y),'number of observed and modelled points do not match, re-check timeseries synchronization')
    obj1_i2(i2) = fun_obj1(t,y);
end

% average performance across events
obj1 = mean(obj1_i2);
end