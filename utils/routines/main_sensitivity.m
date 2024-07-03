function results = main_sensitivity(mdl,events_rr, varargin)
% 

par = inputParser;
addParameter(par,'filename','')
addParameter(par,'overwrite',false)
parse(par,varargin{:})

filename = par.Results.filename;
overwrite = par.Results.overwrite;


if ~isfile(filename) || overwrite

catchment = mdl.name;



path_figs = 'C:\Users\everett\Google Drive\02_phd\00_projects_major\02_swmm_calibration\01_multi_event\results\figs\';
gp = gfx('tex','lassonde');


num_changes = 10;
sa_prams = ga_load_vars();
sa_prams.changes = zeros(height(sa_prams),num_changes);
sa_prams.out1_i = zeros(height(sa_prams),num_changes);
sa_prams.out2_i = zeros(height(sa_prams),num_changes);
sa_prams.mu1_i = zeros(height(sa_prams),num_changes);
sa_prams.mu2_i = zeros(height(sa_prams),num_changes);
sa_prams.changes2 = zeros(height(sa_prams),num_changes);
sa_prams.min = NaN(height(sa_prams),1);
sa_prams.med = NaN(height(sa_prams),1);
sa_prams.mean = NaN(height(sa_prams),1);
sa_prams.max = NaN(height(sa_prams),1);
sa_prams.var = NaN(height(sa_prams),1);

for i4 = 1:height(sa_prams)
    change_step = sa_prams.uncertainty(i4) / (num_changes/2);
    
    sa_prams(i4,'changes') = table([-sa_prams.uncertainty(i4):change_step:(0-change_step),...
        (0+change_step):change_step:sa_prams.uncertainty(i4)]);
    classname = lower(sa_prams.class{i4});
    attribute = sa_prams.attribute{i4};
    
    sa_prams(i4,'min') = table(min(mdl.p.(classname)(:,attribute).Variables));
    sa_prams(i4,'med') = table(median(mdl.p.(classname)(:,attribute).Variables));
    sa_prams(i4,'mean') = table(mean(mdl.p.(classname)(:,attribute).Variables));
    sa_prams(i4,'max') = table(max(mdl.p.(classname)(:,attribute).Variables));
    sa_prams(i4,'var') = table(var(mdl.p.(classname)(:,attribute).Variables));
    
end

pf = perf_funs;

for i3 = 1:numel(events_rr)
    
    tt_mod = mdl.eval(events_rr(i3));
    
    tt_mod = mdl.results_tt();
    
    %     t = tt_obs(tt_mod.Properties.RowTimes,:).Variables;
    y_0 = tt_mod(:,'inflow').Variables;
    out1_0 = sum(y_0);
    out2_0 = max(y_0);
    
    % initialize empty variables
    changes2 = nan(height(sa_prams),num_changes);
    out1_i = nan(height(sa_prams),num_changes);
    out2_i = nan(height(sa_prams),num_changes);
    mu1_i = nan(height(sa_prams),num_changes);
    mu2_i = nan(height(sa_prams),num_changes);
    
    sa_prams = sa_prams;
    
    for i4 = 1:height(sa_prams)
        classname = lower(sa_prams.class{i4});
        attribute = sa_prams.attribute{i4};
        changes = sa_prams(i4,'changes').Variables;
        constrs = sa_prams(i4,{'constraint_lower','constraint_upper'}).Variables;
        
        mdl2 = mdl;
        for i5 = 1:num_changes
            rel_change = changes(i5);
            mdl2.p.(classname)(:,attribute).Variables = (1+rel_change) .* mdl.p.(classname)(:,attribute).Variables;
            
            % apply lower and upper physically-based constraints to changed
            % parameter values
            idx = mdl2.p.(classname)(:,attribute).Variables < constrs(1);
            mdl2.p.(classname)(idx,attribute).Variables = repmat(constrs(1),sum(idx),1);
            idx = mdl2.p.(classname)(:,attribute).Variables > constrs(2);
            mdl2.p.(classname)(idx,attribute).Variables = repmat(constrs(2),sum(idx),1);
            
            % since some changes won't be the full amount (due to constraints),
            % calculate effective change
            rel_change_actual = (mdl2.p.(classname)(:,attribute).Variables - mdl.p.(classname)(:,attribute).Variables) ./ mdl.p.(classname)(:,attribute).Variables;
            rel_change_actual(isnan(rel_change_actual)) = 0; % can't divide by zero
            rel_change_mean = sum(rel_change_actual .* (mdl2.p.('subcatchments').Area ./ sum(mdl2.p.('subcatchments').Area)));
            changes2(i4,i5) = rel_change_mean;
            clear vars rel_change_actual rel_change_mean
            
%             mdl2.write_inp; % write the changes to the INP file
            tt_mod = mdl2.eval(events_rr(i3));
%             tt_mod = mdl2.results_tt();
            
            y = tt_mod(:,'inflow').Variables;
            
            % calc model outputs and sens
            out1_i(i4,i5) = sum(y);
            out2_i(i4,i5) = max(y);
            mu1_i(i4,i5) = ((out1_0 - out1_i(i4,i5))./out1_0) ./ changes2(i4,i5);
            mu2_i(i4,i5) = ((out2_0 - out2_i(i4,i5))./out2_0) ./ changes2(i4,i5);
        end
        clear vars mdl2 classname attribute changes constrs
    sa_prams(i4,'out1_0') = table(out1_0);
    sa_prams(i4,'out2_0') = table(out2_0);
    end
    
    % store calc'd arrays in table
    sa_prams.changes2 = changes2;
    sa_prams.out1_i = out1_i;
    sa_prams.out2_i = out2_i;
    sa_prams.mu1_i = mu1_i;
    sa_prams.mu2_i = mu2_i;
    
    % calculate mean sens and ranks
    sa_prams.mu1 = mean(abs(sa_prams.mu1_i),2);
    sa_prams.mu2 = mean(abs(sa_prams.mu2_i),2);
    sa_prams.rnk1 = get_rank(sa_prams.mu1,'descend');
    sa_prams.rnk2 = get_rank(sa_prams.mu2,'descend');
    
    % calculate correlation between volume sens and peak flow sens
    [cc,ccp] = corr(sa_prams.mu1,sa_prams.mu2);
    
    % store results in 'events' struct
    events_sa(i3).prams = sa_prams;
    events_sa(i3).out_cc = cc;
    events_sa(i3).out_ccp = ccp;
end


num_events = numel(events_sa);
num_params = height(sa_prams);


data = nan(num_params,2,numel(events_rr));



for i3 = 1:numel(events_rr)
    data(:,:,i3) = [events_sa(i3).prams.mu1,events_sa(i3).prams.mu2];
end

ecl = setup_eventclass(events_rr);
data = [];

results.catchment = catchment;
results.mdl = mdl;
results.events_sa = events_sa;
results.sa_prams = sa_prams;
results.events_rr = events_rr;

save(filename,'-struct','results')

elseif isfile(filename)
    results = load(filename);
else
    error()
end
end
