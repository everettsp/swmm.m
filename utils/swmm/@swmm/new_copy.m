function obj_copy = new_copy(obj,path_copy_model,varargin)
% copy an existing SWM model to a specified filepath
% creates two copies, one backup and one for editing
% also initializes directories [data, debug, results]
% returns swmm object of copied model

% par = inputParser;
% addParameter(par,'overwrite',false)
% parse(par,varargin{:})
% overwrite = par.Results.overwrite;

if isfolder(path_copy_model)
    prompt = ['overwrite folder:',path_copy_model,'? [y/n] '];
    overwrite = input(prompt,'s');
    switch lower(overwrite)
        case {'y',true}
            rmdir(path_copy_model,'s');
        case {'n',false}
            disp('overwrite permission denied, specify new model path')
            return
        otherwise
            error('user input not recognized')
    end
end


if ~strcmp(path_copy_model(end),'\')
    path_copy_model = [path_copy_model,'\'];
end

[status,msg] = mkdir(path_copy_model);

% dir_data_parent = [obj.dir_main,'\data\'];

ffilename_edited = [path_copy_model,obj.name,'_editing','.inp'];
% ffilename_backup = [path_copy_model,obj.name,'_backup','.inp'];

% copyfile(obj.inp,ffilename_backup,'f');
copyfile(obj.inp,ffilename_edited,'f');

obj_copy = swmm(ffilename_edited);

obj_copy.read_only = false;

obj_copy.dir_data = [obj_copy.dir_main,'\data\'];
obj_copy.dir_results = [obj_copy.dir_main,'\results\'];

mkdir(obj_copy.dir_data)
mkdir(obj_copy.dir_results)


% if isfolder(dir_data_parent)
%     obj_copy.dir_data_parent = dir_data_parent;
% else
%     disp("couldn't find parent data directory... this directory is to store large climate files that aren't worth copying over and over again for each calibration routine...")
% end

end