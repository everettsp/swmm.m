function ffile_child = swmm_initialize(ffile_parent,folder_child)
% (1) creates a batch file that runs EPASWMM.exe
% (2) creates a copy of the SWMM input file
% will overwrite SWMM child
% name_model = path_split{end};

[path_parent,name_parent,ext_parent] = fileparts(ffile_parent);

if ~contains(ffile_parent,'.inp')
    ffile_parent = [ffile_parent,'.inp'];
end

name_child = [name_parent,'_','edited'];
    
if nargin < 2
    folder_child = [path_parent,name_child,'\'];
    mkdir(folder_child);
end

ffile_child = [folder_child,name_child];

if 2 == exist(ffile_parent,'file')
    if 2 == exist([ffile_child,'.inp'],'file')
        
        % if a child exists, delete it
        delete([ffile_child,'.inp'])
        disp('existing child model found, deleting...')
    end
    
    % copy the parent swmm file to the child folder
    [status,msg] = copyfile(ffile_parent,[ffile_child,'.inp'],'f');
    if status
        disp('parent model found, creating copy of .inp file...')
    elseif ~status
        error(msg)
    else
        error('this error should never come up...')
    end
else
    error(["can't find parent .INP file for model: " name_parent]);
end

% write/rewrite .bat file
ffile_bat = [folder_child,name_child,'.bat'];

content = ['"' 'C:\Program Files (x86)\EPA SWMM 5.1.013\swmm5.exe' '" ',...
    '"',folder_child,name_child,'.inp','" ',...
    '"',folder_child,name_child,'.rpt','"'];

fid = fopen(ffile_bat,'w+');
fprintf(fid,'%s',content);
fclose(fid);

% call the .bat file
% sys_cmd = ['call "' path_bat '"' '>NUL'];
% system(sys_cmd);
end