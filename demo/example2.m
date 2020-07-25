% [filepath,name,ext] = fileparts(which('example_simple'));
% filepath_model = strjoin({filepath,'simple.inp'},'\');

mdl = swmm([cd,'\models\rahma\BergTest.inp']);

mdl.draw;

%%

% % create a copy of the model to enable editing
% dir_model_copy = 'test\';
% mdl = mdl.new_copy(dir_model_copy, 'overwrite',true);
% mdl.read_inp
% % view SWMM class data
% disp(mdl.subcatchments)
% disp(mdl.conduits)
% % draw the model elements on a map
% figure('Name','model_layout')
% mdl = mdl.draw;
% 