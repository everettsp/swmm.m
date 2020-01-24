function elmnt_values = swmm_elements(ffile_swmm, elmnt_classes, elmnt_attributes, elmnt_names, elmnt_values_new)%elements, readwrite)
% get all the values corresponding to a specific swmm class
% return a table containing element IDs as rows and attributes as columns
% sample input data are as follows:
% input 'elements' is a SWMM class as defined by 'swmm_param.m' script;
% MATLAB class contained SWMM class, ID, and value to read/write

%SUBAREAS AND INFILTRATION BEING ABBREVIATED TO UNIQUE ID 'sc' ASSUMED THAT
%ELEMENTS ARE IN THE SAME ORDER IN BOTH SECTIONS. SO FAR THIS IS TRUE, BUT
%THERE COULD BE EXCEPTIONS! IF SO, IT WILL CAUSE A HARD TO FIND ERROR!

% specify the swmm input file
ffile_swmm_inp = [ffile_swmm '.inp'];

if nargin < 5
    overwrite_values = false;
else
    overwrite_values = true;
end

% read the content of the file
if overwrite_values
    fid = fopen(ffile_swmm_inp);
    content_cell = textscan(fid,'%s','Delimiter',{'\n'});
    fclose(fid);
    content = content_cell{1};
    clear content_cell
end

are_inputs_cells = isa(elmnt_classes,'cell') && isa(elmnt_attributes,'cell') && isa(elmnt_names,'cell');
if ~are_inputs_cells
    error('element tripled not formatted correctly, should be cell arrays of equal size with class, attribute, and id')
end
    


% exception for polygons, since not upper case for some reason
num_elements = numel(elmnt_attributes);

%% get the class data in tables, stored in a cell array of size equal to the number of classes
% for j1 = 1:num_elements
%     elements(j1) = elements(j1);
% types_list{j1} = elements(j1).class;
% end

class_tables = swmm_class(ffile_swmm, elmnt_classes);
classes_unique = unique(elmnt_classes);

elmnt_values = cell(num_elements,1);

%% for each element,
for j1 = 1:num_elements
    
    elmnt_class = elmnt_classes{j1};
    elmnt_attribute = elmnt_attributes{j1};
    elmnt_name = elmnt_names{j1};
    
    % grab the indexes SWMM data tables
    if iscell(class_tables)
        ldx_class = strcmp(classes_unique,elmnt_class);
        class_data = class_tables{ldx_class};
    else
        class_data = class_tables;
    end
    

    idx_elmnt = strcmp(class_data.Name,elmnt_name);

    
    
    
    
    line_elmnt = class_data(idx_elmnt,:).line_num;
%     line_element = class_data(elmnt_id,:).line_num;
    ldx_attribute = contains(class_data.Properties.VariableNames,elmnt_attribute);
    idx_attribute = find(ldx_attribute);
    
    elmnt_values{j1} = table2array(class_data(idx_elmnt,ldx_attribute));
    
    
    %     switch lower(readwrite)
    %         case {'r','read'}
    %             elements(j1).init_val = table2array(class_data(elements(j1).id,ldx_attribute));
    
    %         case {'w','write'}
    
    %             if isempty(elements(j1).new_val)
    %                 error(['new value for ' elements(j1).class ' ' elements(j1).id ' not assigned'])
    %             end
    
    if overwrite_values
        
        elmnt_line_old = content{line_elmnt};
        [elmnt_line_parsed, ~] = strsplit(elmnt_line_old, '\t');
        
        % identify character location of the new attribute
        char_start = numel([elmnt_line_parsed{1 : (idx_attribute - 1)}]) + (idx_attribute - 1);
        
        % replace the existing attribute value with the new value, adding padding
        
        val_str_old = elmnt_line_parsed{ldx_attribute};
        
        %%
        elmnt_value_new = elmnt_values_new(j1);
        
        elmnt_value_new = round(elmnt_value_new,4,'significant');
        if elmnt_value_new < 0.001
            elmnt_value_new = round(elmnt_value_new,6,'decimal');
        end
        
        val_str_new = num2str(elmnt_value_new);
        
        
        %             elements(j1) = elements(j1).sigfigs; %sigfigs class function
        %             val1_str = num2str(elements(j1).new_val);
        padding = numel(val_str_old) - numel(val_str_new);
        if padding < 0
            error('new value is too long')
        end
        val_str_new = [val_str_new blanks(padding)];
        
        % insert the new attribute value into the string of attribute values
        elmnt_line_new = elmnt_line_old;
        elmnt_line_new(char_start + (1:numel(val_str_new))) = val_str_new;
        
        % intert the string of attribute values into the file content
        content{line_elmnt} = elmnt_line_new;
    end
end

if overwrite_values
    % write new content to file
    fid = fopen(ffile_swmm_inp,'w+');
    for i2 = 1:numel(content)
        fprintf(fid,'%s\n',content{i2,:});
    end
    fclose(fid);
end

end