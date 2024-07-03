function [mdl,state] = swmm_ga(mdl,events,varargin)

global gbl_state
gbl_state = [];

% make sure events struct has all the required information...
events_test(events)

par = inputParser;
addParameter(par,'var_classes',load_opt_classes("normal")) % classes to optimise (with uncertainty and constraints)
parse(par,varargin{:});

var_classes = par.Results.var_classes;

% genetic algorithm hyperparameters
ga_hp = struct();
ga_hp.PopulationSize = 100;
ga_hp.MaxGenerations = 40;
ga_hp.MaxStallGenerations = 5;
ga_hp.FunctionTolerance = 0.0001;
ga_hp_args = reshape([fieldnames(ga_hp),struct2cell(ga_hp)]',[numel(fieldnames(ga_hp)).*2,1]);

% get complete list of elements to edit during calibration
vars = mdl.classes2elements(var_classes);

% create initial population
pop = (rand([height(vars),ga_hp.PopulationSize]) .* (vars.lims(:,2) - vars.lims(:,1)) + vars.lims(:,1))';

% cost function - SWMM model, variable list, and event information are
% passed into function handle such that it has the form obj=f(pop)
cost_function = @(pop) mdl.obj_fun(pop,vars,events);

% more ga parameters
ga_opts = optimoptions('ga',...
    'OutputFcn',@ga_state_fun,...
    'InitialPopulationMatrix',pop,...
    ga_hp_args{:});

% start timer and call GA
tic
[x,fval,exitflag,output,population,scores] = ga(cost_function,size(pop,2),[],[],[],[],vars.lims(:,1),vars.lims(:,2),[],ga_opts);

mdl = set_elements(mdl,vars,mean(population));

% clear global state variable, replace with local variable returned by the
% function
state = gbl_state;
clear gbl_state
end