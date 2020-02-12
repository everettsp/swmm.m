function [obj1] = swmm_ga_optfun(pop)
global gbl_opt % field-mapping to assign parameters to PCSWMM
global gbl_obs % observed values to calculate SSE in optimizaiton function
global gbl_out
global gbl_mod
global gbl_obj
global ffile_model
global gbl_event_options

% AFAIK ga() only does minimization, so we optimize -NSE which has a range of [-1 inf]
fun_obj1 = @(x,y) -(1 - (sum((x - y).^2) / sum((x - mean(x)).^2))); %NSE
% fun_obj1 = @(x,y) sum((x - y).^2); %SSE
% fun_obj2 = @(x,y) sum(x - y); %E

%%
% num_pop = length(x.pop);
% num_params = numel(gbl_params);

[~, num_params] = size(pop);

if isempty(gbl_obj)
    gen_itr = 1;
else
    gen_itr = numel(gbl_obj) + 1;
end

% obj1 = NaN(num_pop,1);
% obj2 = NaN(num_pop,1);
num_events = height(gbl_event_options);
obj1_i2 = NaN(num_events,1);

for i2 = 1:num_events
    
    
    options_argin = reshape([gbl_event_options.Properties.VariableNames;gbl_event_options(i2,:).Variables],12,1);
    [~,msg] = swmm_options(ffile_model,options_argin{:});

% for i2 = 1:num_pop
    
    %update the swmm parameter in the parameter class to next value from
    %population
    
    for i3 = 1:num_params
        gbl_opt(i3).new_val = pop(i3);
    end
    
    %update swmm parameters
    swmm_elements(ffile_model, {gbl_opt.class},{gbl_opt.attribute},{gbl_opt.name},[gbl_opt.new_val]);
    swmm_execute(ffile_model);
    
    tt_mod = swmm_timetable(ffile_model, gbl_out.class, gbl_out.name);
    varname_mod = gbl_out.attribute;
    tt_mod = tt_mod(:,varname_mod);
%     tt_mod = retime(tt_mod,gbl_obs.Properties.RowTimes);
    tt_mod.Properties.VariableNames = {[gbl_out.id,'_',gbl_out.attribute]};
    
    t = gbl_obs{i2}.Variables;
    y = table2array(tt_mod);


    if isempty(gbl_mod{gen_itr,i2})
        pop_itr = 1;
    else
        pop_itr = numel(gbl_mod{gen_itr,i2}.Properties.VariableNames) + 1;
    end
    
    varname_itr = {[char(varname_mod),'_',num2str(pop_itr)]};
    gbl_mod{gen_itr,i2}(:,varname_itr) = tt_mod;
    
    if ~(numel(t) == numel(y))
        error('number of observed and modelled points do not match, re-check timeseries synchronization')
    end
    
    obj1_i2(i2) = fun_obj1(t,y);
end

obj1 = mean(obj1_i2);
    
%     obj2(i2) = fun_obj2(t,y);
% end

end