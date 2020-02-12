function [state, options,optchanged] = swmm_ga_outfun(options,state,flag)
%displays the function eval value at each iteration. You can change this
% disp(state.Population);
optchanged = false;

global gbl_pop
global gbl_obj
global gbl_mod
global gbl_opt
global gbl_obs
global gbl_out

% state.Population
% state.Generation
gen = state.Generation + 1;
[~,pop_size] = size(state.Population);
% gbl_mod{gen} = timetable(gbl_obs.Properties.RowTimes);
gbl_pop{gen} = state.Population;
gbl_obj{gen} = -state.Score;

save([cd,'\results\','ga_statesave.mat'],'gbl_obs','gbl_mod','gbl_pop','gbl_obj','gbl_out','gbl_opt');
fprintf('\n\nsaving global variables\n')
fprintf('%2.2fhrs since starting the script\n',hours(seconds(toc)))
fprintf('%2.2fhrs average per generation\n',hours(seconds(toc))/(gen))

switch flag
 case 'init'
        disp('starting the algorithm');
    case {'iter','interrupt'}
        fprintf('iterating generation %d...\n',gen)
    case 'done'
        disp('performing final task');
end