function obj = save_rff(obj,ffilename)
% create a binary rainfall file for a simulation

% check the extention
[file_dir,~,file_ext] = fileparts(ffilename);
assert(strcmp(file_ext,'.rff'),"rainfall file must have extension .hsf");
assert(~isempty(file_dir),"rainfall filepath must be a full filepath");

% options_original = obj.p.options; % revert to the original dates

% currently this function only supports a single file hotstart
% file specified in the SWMM INP file
if ~isempty(obj.p.files)
    idx = strcmp(obj.p.files.Type,'RAINFALL') & strcmp(obj.p.files.Usage,'SAVE');
else
    idx = [];
end

if sum(idx) == 0
    % add new file to swmm model
    new_swmm_file = table({'SAVE'},{'RAINFALL'},{['"',ffilename,'"']},'VariableNames',{'Usage','Type','Filename'});
    obj.p.files = [obj.p.files; new_swmm_file];
    idx = strcmp(obj.p.files.Type,'RAINFALL') & strcmp(obj.p.files.Usage,'SAVE');
elseif sum(idx) == 1
elseif sum(idx) > 1
    error('too many rainfall files specified, please only list 1')
end

% set the name and usage for the rainfall file
% obj.p.files.Filename(idx) = {['"',ffilename,'"']};
% obj.p.files.Usage(idx) = {'SAVE'};

% obj.write_inp; % push the changes to the SWMM file
obj.runsim; % run the simulation to generate the hotstart file

% obj.p.options = options_original; % revert to the original dates
obj.p.files.Usage(idx) = {'USE'};
% obj.write_inp; % push changes to revert to the original settings

msg = ['successfully created RFF file for: ',ffilename];
obj.dblog(msg);

end