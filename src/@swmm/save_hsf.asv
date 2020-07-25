function obj = save_hsf(obj,ffilename,prerun_duration)
% create a hotstart file for a simulation, for a simulation of
% a specified duration before START_DATETIME

options_original = obj.p.options; % save the simulation dates

% check the extention
[file_dir,file_name,file_ext] = fileparts(ffilename);
obj.dblog(['creating hotstart file:',file_name]);

assert(strcmp(file_ext,'.hsf'),"hotstart file must have extension .hsf");
assert(~isempty(file_dir),"hotstart filepath must be a full filepath");

% currently this function only supports a single file hotstart
% file specified in the SWMM INP file
idx = contains(obj.p.files.Type,'HOTSTART');

if any(idx)
    obj.p.files(idx,:) = [];
end

% add new file to swmm model
new_swmm_file = table({''},{'HOTSTART'},{''},'VariableNames',{'Usage','Type','Filename'});
obj.p.files = [obj.p.files; new_swmm_file];
idx = contains(obj.p.files.Type,'HOTSTART');

% set END DATE to original START DATE
% set the START DATE to 'prerun_duration' time prior to
% original start date


% datetime_start = obj.p.datestr2datetime(char(obj.p.options.START_DATE),char(obj.p.options.START_TIME));
datetime_start = obj.p.options.START_DATE;
datetime_start_prerun = datetime_start - prerun_duration;
obj.p.options.END_DATE = obj.p.options.START_DATE;
% obj.p.options.END_TIME = obj.p.options.START_TIME;

obj.p.options.START_DATE = datetime_start_prerun;
obj.p.options.REPORT_START_DATE = datetime_start_prerun;
% obj.p.options.START_TIME = datetime_start_prerun;
% obj.p.options.REPORT_START_TIME = datetime_start_prerun;

% set the name and usage for the hotstart file
obj.p.files.Filename(idx) = {['"',ffilename,'"']};
obj.p.files.Usage(idx) = {'SAVE'};

obj.write_inp; % push the changes to the SWMM file
obj.runsim; % run the simulation to generate the hotstart file

obj.p.options = options_original; % revert to the original dates
obj.p.files.Usage(idx) = {'USE'};
obj.write_inp; % push changes to revert to the original settings

msg = ['successfully created RFF file for: ',ffilename];
obj.dblog(msg);

end