function obj = save_dat(obj,ffilename)




msg = 'module only supports use of a single .dat raingegage file';
assert(numel(unique(swmm.raingages.Filename)) == 1, msg)

filename_dat = char(unique(obj.raingages.Filename));

[filepath,filename,ext] = fileparts(filename_dat)

start_datetime = swmm.datestr2datetime(swmm.options("START_DATE","Value").Variables,swmm.options("START_TIME","Value").Variables)



tt = obj.dat2mat(filename_dat)


save()





% create a hotstart file for a simulation, for a simulation of
% a specified duration before START_DATETIME

%             % if no 'prerun_duration' is specified, use 48 hours
%             if varargin < 3
%                 prerun_duration = hours(48);
%             end

% currently this function only supports a single file hotstart
% file specified in the SWMM INP file
idx_hotstart = contains(obj.files.Type,'HOTSTART');
assert(sum(idx_hotstart) == 1, 'ensure swmm file only has 1 hotstart file because i am bad ad coding')

% check the extention
[~,~,model_ext] = fileparts(filename);
assert(strcmp(model_ext,'.hsf'),"hotstart file must have extension .hsf");

% set END DATE to original START DATE
% set the START DATE to 'prerun_duration' time prior to
% original start date

datetime_start = obj.datestr2datetime(char(obj.options('START_DATE','Value').Variables),char(obj.options('START_TIME','Value').Variables));
datetime_start_prerun = datetime_start - prerun_duration;
options_original = obj.options; % save the simulation dates
obj.options('END_DATE','Value') = obj.options('START_DATE','Value');
obj.options('END_TIME','Value') = obj.options('START_TIME','Value');

[datestr_start_prerun,timestr_start_prerun] = obj.datetime2datestr(datetime_start_prerun);
obj.options('START_DATE','Value') = datestr_start_prerun;
obj.options('REPORT_START_DATE','Value') = timestr_start_prerun;
obj.options('START_TIME','Value') = datestr_start_prerun;
obj.options('REPORT_START_TIME','Value') = timestr_start_prerun;

% set the name and usage for the hotstart file
obj.files.Filename(idx_hotstart) = {['"',filename,'"']};
obj.files.Usage(idx_hotstart) = {'SAVE'};

obj.push; % push the changes to the SWMM file
obj.sim; % run the simulation to generate the hotstart file

obj.options = options_original; % revert to the original dates
obj.files.Usage(idx_hotstart) = {'USE'};
obj.push; % push changes to revert to the original settings

end