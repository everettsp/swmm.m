function [list_sections] = swmm_list_classes(ffile_model)
% lists all the classes contained in a SWMM .inp file
% ffile_model is the absolute path of the SWMM .inp file

% specify the swmm input file
if ~contains(ffile_model,'.inp')
    ffile_inp = [ffile_model '.inp'];
else
    ffile_inp = ffile_model;
end

fid = fopen(ffile_inp,'r');
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);
content = content_cell{1};

idx = contains(content,'[') & contains(content,']');
list_sections = content(idx);
end