function main_deploy2(ffile_input)
close('all')
%% initialize global variables
global gbl_pop % save the populations after each generation
global gbl_obj % save the objective function scores for each generation
global gbl_mod % mod. timeseries, saved after each SWMM call [#pop,#gen]
global gbl_obs
global gbl_event_options
global swmm
global gbl_dt
global gbl_out

gbl_pop = {};
gbl_obj = [];

cols = gfx_colors('civica');

% parse excel sheet
if nargin < 1
    ffile_input = 'C:\Users\everett\Google Drive\02_phd\00_projects_major\02_swmm_calibration\data\swmm\example\calibration_input.xlsx';
end

% filepaths
fp = readtable(ffile_input,'Sheet','filepaths','ReadRowNames',true);
path_main = char(fp('main','path').Variables);                       % folder to save calibration files
ffile_parent = char(fp('swmm','path').Variables);                       % uncalibrated swmm file (.inp)
path_calibration = char(fp('save_dir','path').Variables);


% create a SWMM object and copy .INP file to a new directory then read the
% model data
swmm = swmm_model(ffile_parent);
swmm.dblog('clear');
msg = 'starting model calibration';
swmm.dblog(msg);
swmm = swmm.copy(path_calibration);
msg = 'copying parent swmm file';
swmm.dblog(msg);
swmm = swmm.pull;

%%

% set up the working directory
path_report = [path_calibration, '\report\'];
path_results = [path_calibration, '\results\'];
% mkdir(path_calibration)
cd(path_calibration);
mkdir(path_report)
mkdir(path_results)

% if 2 == exist(ffile_log,'file')
%     delete(ffile_log)
% end

% copy the original .INP file and create the .BAT file
msg = 'begining swmm calibration';
swmm_log(msg)

% set simulation dates to the first event for the prelim run
swmm.raingages.Filename(:) = strcat('"',fp('raingage','path').Variables,'"');
swmm.storage.InitDepth(:) = 0;

%%
%{
parse the GA hyperparameters (need number of generations and population
size to parameterize variables)
%}

% parse the GA inputs, default values for population size and number of
% generations

ip = readtable(ffile_input,'Sheet','ga_hyperparameters');
ip_arg = reshape(table2cell(ip)',[numel(ip),1]);
par = inputParser();
isscalarnumber = @(x) (isnumeric(x) & isscalar(x));
par.addParameter('PopulationSize',20,isscalarnumber)
par.addParameter('MaxGenerations',5,isscalarnumber)
par.KeepUnmatched = true;
par.parse(ip_arg{:});
pop_size = par.Results.PopulationSize;
num_gens = par.Results.MaxGenerations;

%% 
%{
read calibration parameters from Excel and calculate uncertainty, upper/lower limits...
%}

% read the list of calibration parameters from Excel
cp = readtable(ffile_input,'Sheet','calibration_parameters');
cp.constraints = [cp.constraint_lower, cp.constraint_upper];
num_cal_params = height(cp);
dt = table();

% for each calibration parameter, calculate uncertainty and store in table
for i2 = 1:num_cal_params
    class_name = lower(cp.class{i2});
    field_name = cp.attribute{i2};
    num_elements = height(swmm.(class_name));
    
    vals = swmm.(class_name)(:,cp.attribute{i2}).Variables;
    
    % calculate the uncertainty limits based the initial value from SWMM,
    % the relative uncertainty value, and the constraints
    uncertainty_lims = vals .* (1 + [-1,1] .* cp.uncertainty(i2));
    uncertainty_lims(uncertainty_lims(:,1) < cp.constraint_lower(i2),1) = cp.constraint_lower(i2);
    uncertainty_lims(uncertainty_lims(:,1) > cp.constraint_upper(i2),1) = cp.constraint_upper(i2);
    
    % store data in a table
    dt_temp = table(...
        swmm.(class_name)(:,1).Variables,...
        repmat({class_name},[num_elements,1]),...
        repmat({field_name},[num_elements,1]),...
        vals,...
        vals,...
        repmat([cp.constraint_lower(i2),cp.constraint_upper(i2)],[num_elements,1]),...
        uncertainty_lims,...
        'VariableNames',{'name','class','attribute','val_init','val','constraints','lims'});
    dt = [dt; dt_temp];
end

gbl_dt = dt;

num_vars = height(dt);
pop_init = (rand([height(dt),pop_size]) .* (dt.lims(:,2) - dt.lims(:,1)) + dt.lims(:,1))';


% output parameters
op = readtable(ffile_input,'Sheet','output_parameters');
ffile_qobs = [char(fp('data','path').Variables),char(op.filename)];               % file containing observed flow for calibration (.csv)

tt_obs = readtimetable(ffile_qobs);
make_regular = @(ttx) retime(ttx,'regular','fillwithmissing','TimeStep',ttx.Properties.RowTimes(2) - ttx.Properties.RowTimes(1));
tt_obs = make_regular(tt_obs);
gbl_out = op;

%%
%{
read the calibration event(s) from Excel
run the model on each event and plot the results
initialize global event table and cell array of timetables for GA 
%}

gbl_event_options = readtable(ffile_input,'Sheet','simulation_parameters','ReadVariableNames',true,'ReadRowNames',true);
num_events = height(gbl_event_options);
tt_mods = cell(num_events,1);
gbl_mod = cell(num_gens+1,num_events);

figure('Name','uncalibrated versus observed flows')
tic;

for i7 = 1:num_events
    
    % write the dates to SWMM .INP
    for i2 = 1:width(gbl_event_options)
        idx = strcmp(swmm.options.Option,gbl_event_options.Properties.VariableNames(i2));
        swmm.options.Value(idx) = gbl_event_options(i7,i2).Variables;
    end
    swmm.push;
    swmm.sim;
    swmm.dblog(['executing pre-calibration simulaiton for event ',num2str(i7)])
    
    % read modelled flow and synchronize time indices of observed flow
    tt_mod = swmm.tt(gbl_out.class(1), gbl_out.name(1));
    tt_mods{i7} = tt_mod(:,gbl_out.attribute(1));
    gbl_obs{i7} = retime(tt_obs,tt_mods{i7}.Properties.RowTimes);
    
    % plot initial model performance
    subplot(num_events,1,i7)
    plot(gbl_obs{i7}.Properties.RowTimes,gbl_obs{i7}.Variables,...
        'DisplayName','observed','Color',cols.black)
    hold on
    plot(tt_mod.Properties.RowTimes,tt_mod(:,gbl_out.attribute(1)).Variables,...
        'DisplayName','modelled','Color',cols.blue)
    ylabel('cms')
    xlabel('time')
    
    % initialize empty timetables in cell array
    for i2 = 1:(num_gens+1)
        gbl_mod{i2,i7} = timetable(gbl_obs{i7}.Properties.RowTimes);
    end
end
time_sim_events = toc;

legend('Location','best')
save_fig(swmm.dir_report,{'png'})

%%
%{
set up GA options and functions, run the GA function
%}

opts = optimoptions('ga',...
    'OutputFcn',@swmm_ga_outfun2,...
    'InitialPopulationMatrix',pop_init,...
    ip_arg{:});

optfun = @swmm_ga_optfun2;
time_sim_events_hours = hours(seconds(time_sim_events));
swmm.dblog(['simulating events took ',num2str(time_sim_events_hours),' hours']);

time_gen = pop_size .* time_sim_events_hours;
time_full = time_gen .* num_gens;
swmm.dblog(['estimated ',num2str(time_gen),' hours per generation']);
swmm.dblog(['estimated ',num2str(time_full),' for all generations']);

swmm.dblog('starting genetic algorithm')
[~,~,flag,~] = ga(optfun,num_vars,[],[],[],[],gbl_dt.lims(:,1),gbl_dt.lims(:,2),[],opts);
flags = {1,"Average cumulative change in value of the fitness function over MaxStallGenerations generations is less than FunctionTolerance, and the constraint violation is less than ConstraintTolerance.";3,"Value of the fitness function did not change in MaxStallGenerations generations and the constraint violation is less than ConstraintTolerance.";4,"Magnitude of step smaller than machine precision and the constraint violation is less than ConstraintTolerance.";5,"Minimum fitness limit FitnessLimit reached and the constraint violation is less than ConstraintTolerance.";0,"Maximum number of generations MaxGenerations exceeded.";-1,"Optimization terminated by an output function or plot function.";-2,"No feasible point found.";-4,"Stall time limit MaxStallTime exceeded.";-5,"Time limit MaxTime exceeded."};
msg = lower(flags{[flags{:,1}] == flag,2});
swmm.dblog(msg);

%%
%{
find the best perfoming model in the final generation
parameterize SWMM model with optimum parameter values
%}

[best_perf,best_perf_idx] = max(gbl_obj{end});
swmm.dblog(['selecting model with highest nse (',num2str(best_perf),')...']);

gbl_dt.val = gbl_pop{end}(best_perf_idx,:)';

for i3 = 1:height(gbl_dt)
    swmm.(gbl_dt.class{i3})(strcmp(swmm.(gbl_dt.class{i3})(:,1).Variables,gbl_dt.name{i3}),gbl_dt.attribute{i3}).Variables = gbl_dt.val(i3);
end

swmm.dblog(['writing optimum parameter set to swmm']);
swmm.push;
swmm.sim;

%%
%{
plot the objective function and timeseries results of the GA
%}

figure('Name','ga objsective function');
plot_uncertainty_envelope([gbl_obj{:}]',0:num_gens,'Color',cols.green,'ShowMean',true,'ShowOutliers',true);
xlabel('generations')
ylabel('nash-sutcliffe efficiency')
set(gca,'XGrid','on')
set(gca,'YGrid','on')
save_fig(swmm.dir_report,{'png'})

figure('Name','observed and predicted (ga init, ga opt) hydrographs');
for i7 = 1:num_events
    subplot(num_events,1,i7)
    hold 'on'
    descr = cell(num_gens+1,1);
    descr{1} = 'ga init';
    descr{num_gens+1} = 'ga opt';
    plot_uncertainty_envelope(gbl_obs{i7},'DisplayName','observed','Color',cols.black,'MedStyle','-');
    
    cols_gen = {cols.yellow,cols.green};
    col_counter = 1;
    for i2 = [1,num_gens+1]
        plot_uncertainty_envelope(gbl_mod{i2,i7},'DisplayName',descr{i2},...
            'Color',cols_gen{col_counter});
        col_counter = col_counter + 1;
    end
    
    set(gca,'XGrid','on')
    set(gca,'YGrid','on')
    set(gca,'YMinorGrid','on')
    xlabel('datetime')
    ylabel(gbl_out.attribute)
end
legend('Location','best');
save_fig(swmm.dir_report,{'png'});

