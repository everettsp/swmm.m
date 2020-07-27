function [obj] = read_inp(obj)
% read a SWMM .inp file and populate obj.p
% this function is automatically called when initializing a new SWMM obj

msg = 'completed class read';

celltrim = @(x) cellfun(@strtrim,x,'UniformOutput',false);

% read the content of the file
fid = fopen(obj.inp);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);
content = content_cell{1};
clear content_cell
lines_empty = find(cellfun(@isempty,content));

% identify all comments in file (lines begining with ';;')
content_double = double(char(content));

assert(any(any(content_double == 9)),'No tab delimitation, ensure to enable tab-delimited files under SWMM>Tools>Program Preferences>Tab Delimited Program File')

lines_semicols = find(all(content_double(:,1) == [59],2));

% all sections in file have headings englosed by sq brackets '[...]'
% sections in INP files are inconsistent, as sections will only be written
% if those elements exist in the model...
idx = contains(content,'[') & contains(content,']');
list_sections = content(idx);

% create a table of classes includes in the INP file
% this will also store the start/end lines of each class section in the
% file
class_table = table(list_sections,'VariableNames',{'classname_original'});

% remove the case and bracket formatting from the section classname
list_sections = lower(list_sections);
list_sections  = replace(list_sections,'[','');
list_sections = replace(list_sections,']','');
list_sections = strtrim(list_sections);
class_table.classname = list_sections;

% find the start and end lines in the file
line_class = find(idx);
line_end = nan(size(line_class));
line_end(1:(end-1)) = line_class(2:end) - 2;
line_end(end) = numel(content);
class_table.line_class = line_class;
class_table.line_end = line_end;
lines_empty = find(cellfun(@isempty,content));
% figure out which lione the data starts on (there's a variable number of
% lines between the classname and the first row of data)
for i5 = 1:height(class_table)
    
    line_start = class_table.line_class(i5) + 1;
    while any(line_start == lines_semicols)
        line_start = line_start + 1;
    end
    
    class_table.line_start(i5) = line_start;
    lines = class_table.line_start(i5):class_table.line_end(i5);
    lines = lines(~ismember(lines,lines_empty));
    class_table.lines_section(i5) = {lines};
    
end

% variable to store the data contained in each section

obj.class_info = class_table;
data_tables = struct();

class_dict = obj.dict('attributes');
for i2 = 1:height(class_table)
    classname = char(class_table(i2,:).classname);
        headings = class_dict.(classname);
        
    if strcmp(classname,'infiltration')
        headings = headings.(lower(obj.p.options.INFILTRATION));
    end
    
    lines = class_table.lines_section{i2};
    data_cells1 = cellfun(@(x) strsplit(x,'\t','CollapseDelimiters',false),content(lines),'UniformOutput',false);
    data_numvals = cellfun(@numel,data_cells1);
    switch classname
        
    case {'title'}
            y = [];
            
    case {'options'}
        data_cell_subs = cell(numel(headings),1);
        for i3 = 1:numel(lines)
            data_cell_subs{i3,1} = data_cells1{i3,:}{2};
        end
        

        
        
        y = cell2struct(strtrim(data_cell_subs),headings,1);
        
       for opt_name = {'START','REPORT_START','END'}
            datetime_val = swmm_datestr2datetime(y.([char(opt_name),'_DATE']),y.([char(opt_name),'_TIME']));
            y.([char(opt_name),'_DATE']) = datetime_val;
            y.([char(opt_name),'_TIME']) = "ONLY USE DATE FIELDS";
            y.([char(opt_name),'_DATE']).Format = 'MM/dd/uuuu HH:mm:ss';
%             y.([char(opt_name),'_TIME']).Format = 'HH:mm:ss';
        end
        
        case {'lid_controls'}
            
            data_cell_subs = struct();
            [lid_names,lid_name_ida,lid_name_idc] = unique(cellfun(@(x) x{1},data_cells1,'UniformOutput',false));
            lid_types = cellfun(@(x) x{2},data_cells1(cellfun(@numel,data_cells1) == 2),'UniformOutput',false);
            [lid_types_unique,lid_type_ida,lid_type_idc] = unique(lid_types);
            
            lid_types_unique = lower(strtrim(lid_types_unique));
            
            
            y = init_struct(lower(cellstr(class_dict.lid_controls.types)),[]);
            
            
            k3 = zeros(numel(lid_types_unique),1);
            
            for i3 = 1:numel(lid_names) % each unique LID control
                lid_type = cellfun(@(x) x{2},data_cells1(lid_name_ida(i3)),'UniformOutput',false);
                lid_type = char(lower(strtrim(lid_type)));
                
                type_idx = strcmpi(lid_type,lid_types_unique);
                
                k3 = k3 + type_idx;
                
                data_cell_subs = data_cells1(i3 == lid_name_idc);
                lid_params = cellfun(@(x) x{2}, data_cell_subs, 'UniformOutput',false);
                
                y.(lid_type)(k3(type_idx)).name = strtrim(lid_names{i3});
                
                for i4 = 2:numel(data_cell_subs) % lid layers
                    lid_param = lower(strtrim(lid_params{i4}));
                    
                    attributes = cellstr(class_dict.(classname).(lid_param));
                    vals = cell2num(strtrim(data_cell_subs{i4}(3:end)));
                    if numel(fields(y.(lid_type))) == 1
                        y.(lid_type).(lid_param) = cell2struct(vals',attributes'); % scalar struct
                    else
                        y.(lid_type)(k3(type_idx)).(lid_param) = cell2struct(vals',attributes'); % non-scalar struct
                    end
                end
            end

        case {'map','snowpacks','report'}
            y = content(lines);
            
        otherwise
            data_cell_subs = cell(numel(lines),numel(headings));
            for i3 = 1:numel(lines)
                data_cell_subs(i3,1:data_numvals(i3)) = (data_cells1{i3});
            end
%             notempty = ~all(cellfun(@isempty,data_cell_subs));
%             data_cell_subs(notempty) = celltrim(data_cell_subs(notempty));
            data_cell_subs = strtrim(data_cell_subs);
            if ~isempty(data_cell_subs)
                data_cell_subs = cell2num(data_cell_subs);
                y = cell2table(data_cell_subs,'VariableNames',headings);
            else
                y = array2table(zeros(0,numel(headings)), 'VariableNames',headings);
            end
    end
    obj.p.(classname) = y;
end

end