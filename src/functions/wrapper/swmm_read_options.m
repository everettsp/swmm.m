function parameter_values = swmm_read_options(ffile_swmm, parameter_names)
% write a new value to a swmm input file based on on element and attribute
% name-value pairs
%
% MM/DD/YYYY
% parameter_names = {'START_DATE','REPORT_START_DATE','END_DATE'};
% parameter_values = {'01/01/2018','01/01/2018','01/01/2019'};

% specify the swmm input file
if ~contains(ffile_swmm,'.inp')
    ffile_swmm = [ffile_swmm '.inp'];
end

% read the content of the file
fid = fopen(ffile_swmm);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);
content = content_cell{1};
clear content_cell

content_new = content;

% parse the fields for the code below, which is used to index the parameter names
swmm_fields = cell(36,1);
lines_fields = 5:40;

for i1 = 1:numel(lines_fields)
    line_cycle = lines_fields(i1);
    temp = strsplit(content{line_cycle});
    swmm_fields{i1} = strtrim(temp{1});
end

n = numel(parameter_names);

parameter_values = cell(1,n);
for i1 = 1:n
    parameter_name = parameter_names{i1};
    % identify line containing parameter
    % search within the parsed fields as a means to handle exact matches
    parameter_line = 4 + find(contains_exactly(swmm_fields,parameter_name));
    parameter_str = content_new{parameter_line};
    [parameter_cell, ~] = strsplit(parameter_str, '\t');
    parameter_values{i1} = strtrim(parameter_cell{2});
    
end

end