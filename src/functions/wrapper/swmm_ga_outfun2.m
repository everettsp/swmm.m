function [state, options,optchanged] = swmm_ga_outfun2(options,state,flag)
%displays the function eval value at each iteration. You can change this
% disp(state.Population);
optchanged = false;

% load global varables (for saving results between generations)
global gbl_pop
global gbl_obj
global gbl_mod
global gbl_obs
global dt
global swmm

% state.Population
% state.Generation
gen = state.Generation + 1;
[~,pop_size] = size(state.Population);
% gbl_mod{gen} = timetable(gbl_obs.Properties.RowTimes);
gbl_pop{gen} = state.Population;
gbl_obj{gen} = -state.Score;

save([cd,'\results\','ga_statesave.mat'],'gbl_obs','gbl_mod','gbl_pop','gbl_obj','dt','swmm');
fprintf('\n\nsaving global variables\n')
fprintf('%2.2fhrs since starting the script\n',hours(seconds(toc)))
fprintf('%2.2fhrs average per generation\n',hours(seconds(toc))/(gen))
switch flag
 case 'init'
        msg = 'starting the algorithm';
        swmm.dblog(msg)
    case {'iter','interrupt'}
        msg = ['completed generation ',num2str(gen-1),', sarting next generation'];
        swmm.dblog(msg)

    case 'done'
        msg = 'performing final task';
        swmm.dblog(msg)

end