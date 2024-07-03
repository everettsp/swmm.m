function [state, options,optchanged] = ga_state_fun(options,state,flag)
%displays the function eval value at each iteration. You can change this
% disp(state.Population);
global gbl_state

optchanged = false;

% load global varables (for saving results between generations)
% global gbl_pop
% global gbl_obj
% global gbl_mod
% global gbl_vars
% global gbl_time
% global gbl_state
% 
% global gbl_events
% global gbl_mdl

% disp(gbl_state.gen_idx);
% 

% state.Population
% state.Generation

% gbl_state.gen_idx = gbl_state.gen_idx + 1;
% gbl_state.pop_idx = 1;

gen_idx = state.Generation + 1;
state_copy = state;
state_copy.toc = toc;
if isempty(gbl_state)
    gbl_state = state_copy;
else
    gbl_state(gen_idx) = state_copy;
end
[~,pop_size] = size(state.Population);
% gbl_mod{gen} = timetable(gbl_obs.Properties.RowTimes);

% gbl_obj{gen_idx} = -state.Score;

% save([gbl_mdl.dir_results,'\','ga_statesave.mat'],'gbl_events','gbl_mod','gbl_pop','gbl_obj','gbl_vars','gbl_mdl','gbl_time');
fprintf('\ngeneration %i complete, starting next generation...\n',state.Generation)

fprintf('%2.2fhrs since starting the script\n',hours(seconds(toc)))
fprintf('%2.2fhrs average per generation\n',hours(seconds(toc))/(gen_idx))
switch flag
 case 'init'
        msg = 'starting the algorithm';
%         gbl_mdl = gbl_mdl.dblog(msg);
        tic;
    case {'iter','interrupt'}
        msg = ['completed generation ',num2str(gen_idx-1),', sarting next generation'];
%         gbl_mdl = gbl_mdl.dblog(msg);

    case 'done'
        msg = 'performing final task';
%         gbl_mdl = gbl_mdl.dblog(msg);
end
        
% gbl_pop{gen_idx} = state.Population;
% gbl_time(gen_idx) = toc;

end