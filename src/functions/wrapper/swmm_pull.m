function [obj] = swmm_pull(obj)
% get all the values corresponding to a specific swmm class
% return a table containing element IDs as rows and attributes as columns
% sample input data are as follows:
% class_name = '[SUBCATCHMENTS]';

%SUBAREAS AND INFILTRATION BEING ABBREVIATED TO UNIQUE ID 'sc' ASSUMED THAT
%ELEMENTS ARE IN THE SAME ORDER IN BOTH SECTIONS. SO FAR THIS IS TRUE, BUT
%THERE COULD BE EXCEPTIONS! IF SO, IT WILL CAUSE A HARD TO FIND ERROR!

abbrev_dict = {...
    '[OPTIONS]',                'opt';...
    '[RAINGAGES]',              'rg';...
    '[SUBCATCHMENTS]',          'sc';...
    '[SUBAREAS]',               'sa';...
    '[INFILTRATION]',           'infl';...
    '[JUNCTIONS]',              'j';...
    '[OUTFALLS]',               'of';...
    '[STORAGE]',                'su';...
    '[OUTLETS]',                'ol';...
    '[ORIFICES]',               'or';...
    '[WEIRS]',                  'wrs';...
    '[CONDUITS]',               'c';...
    '[XSECTIONS]',              'xs';...
    '[TRANSECTS]',              'trsc';...
    '[COORDINATES]',            'xy';...
    '[VERTICIES]',              'vert';...
    '[Polygons]',               'poly';...
    '[SYMBOLS]',                'sym';...
    };

msg = 'completed class read';


% read the content of the file
fid = fopen(obj.inp);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);
content = content_cell{1};
clear content_cell


class_list = obj.class_list;

num_classes = numel(class_list);
data_tables = struct();

for i5 = 1:numel(class_list)
    classname = class_list{i5};
    classname_formatted = ['[' classname ']'];
    
    % for some reason polygons has an upper case P but the rest is lower case,
    % so format it...
    if strcmpi(classname_formatted,'[polygons]')
        classname_formatted = lower(classname_formatted);
        classname_formatted(2) = upper(classname_formatted(2));
    else
        classname_formatted = upper(classname_formatted);
    end
    
    %     if ~any(contains(swmm_list_classes(file_swmm),classname))
    %         msg = strcat("error: swmm class '",classname,"' not recognized");
    %         return
    %     end
    %
    
    
    % identify attributes corresponding to the element type
    line_start = find(contains(content',classname_formatted));
    
    if isempty(line_start)% && any(contains(abbrev_dict(:,1),classname_formatted))
        % if the class type isn't in the file, but is a possible class
        data_table = table();
        data_tables.(classname) = data_table;
        continue
%     elseif isempty(line_start)
        % typo...
%         error(['type ' classname_formatted ' not recognized, check spelling'])
        
    end
    % find the set of lines corresponding element_type section
    switch lower(classname)
        case 'options'
            lines_section = line_start + [(2:8),(10:23),(25:36)];
        otherwise
            line_cycle = line_start + 3;
            while ~isempty(content{line_cycle})
                line_cycle = line_cycle + 1;
            end
            line_end = line_cycle - 1;
            clear line_cycle
            lines_section = (line_start + 3):line_end;
    end
    
    num_lines = numel(lines_section);
    
    % get the list of element identifiers
    element_ids = cell(num_lines,1);
    for i2 = 1:num_lines
        line_idx = lines_section(i2);
        element_line = strsplit(content{line_idx},'\t');
        if strcmp(element_line{1}(1),';')
            lines_section(i2) = NaN;
            element_ids{i2} = NaN;
            continue
        end
        element_ids{i2} = strtrim(element_line{1});
    end
    element_ids = element_ids(~isnan(lines_section));
    lines_section = lines_section(~isnan(lines_section));
    num_elements = numel(element_ids);
    % get the attribute headers
    headers = strsplit(content{line_start + 1}, '\t');
    assert(numel(headers) ~= 1,'No tab delimitation, ensure to enable tab-delimited files under SWMM>Tools>Program Preferences>Tab Delimited Program File')
    num_attributes = numel(headers);
    
    % tidy up the attribute headers
    for i2 = 1:num_attributes
        headers{i2} = headers{i2}(~ismember(headers{i2},';'));
        headers{i2} = replace(headers{i2},'%','Percent');
        headers{i2} = replace(headers{i2},'-','_');
        headers{i2} = replace(headers{i2},'/','_');
        headers{i2} = replace(headers{i2},'\','_');
        headers{i2} = replace(headers{i2},'Elev.','Elev');
        headers{i2} = replace(headers{i2},'Coeff.','Coeff');
        headers{i2} = strtrim(headers{i2});
        headers{i2} = replace(headers{i2},' ','_');
    end
    
    % the raingage file format is fucking terrible...
    % append extra attributes that aren't listed for some reason
    switch classname_formatted
        case '[RAINGAGES]'
            first_row = strsplit(content{lines_section(1)},'\t');
            switch strtrim(lower(char(first_row(contains(headers,'Source')))))
                case 'file'
                    headers((end+1):(end+3)) = {'Filename','StationID','RainUnits'};
                case 'timeseries'
                    headers(end+1) = {'TimeseriesName'};
            end
            num_attributes = numel(headers);
    end
    
    
    % store all values (as a cell array)
    element_lines = cell(num_elements,num_attributes);
    num_chars = nan([1,num_attributes]);
    for i2 = 1:num_elements
        
        line_idx = lines_section(i2);
        element_line = strsplit(content{line_idx},'\t');
        
        
        for i3 = 1:numel(element_line)
            
            % on the first pass, store the number of characters for each
            % attribute value
            if i2 == 1
                num_chars(i3) = numel(element_line{i3});
            end
            
            element_line{i3} = strtrim(element_line{i3});
        end
        
        % this is for a special case, where the [SUBAREAS] PctRouted parameter
        % does not have a value, hence no tab between the value and the
        % previous
        % workaround is to pad the end of the line of values with empty cell
        % arrays
        % this will NOT WORK if the missing tab is not rightmost
        
        while num_attributes > numel(element_line)
            element_line = [element_line {''}];
        end
        
        element_lines(i2,:) = element_line;
    end
    
    % create unique IDs for table column names
    table_ids = cell(num_elements,1);
    type_name_abbrev = char(abbrev_dict(strcmp(abbrev_dict(:,1), classname_formatted),2));
    table_ids = {};
    for i2 = 1:num_elements
        table_ids{i2} = [type_name_abbrev '_' num2str(i2)];
    end
    % column-wise, store values in a table
    % if numeric, convert; otherwise, store as text
    data_table = table();
    
    % get the data for each attribute
    for i3 = 1:num_attributes
        values = element_lines(:,i3);
        if ~any(isnan(str2double(values)))
            values = str2double(values);
        end
        values = table(values);
        data_table(table_ids, headers{i3}) = values;
    end
    
    % add the line of the .INP file that the element appears on
    data_table(table_ids, {'line_num'}) = table(lines_section');
    num_chars(end+1) = NaN;
    data_table.Properties.Description = classname;
    data_table = addprop(data_table,'num_chars','Variable');
    data_table.Properties.CustomProperties.num_chars = num_chars;
    
    if strcmp(data_table.Properties.Description,'[INFILTRATION]') || strcmp(data_table.Properties.Description,'[SUBAREAS]')
        data_table.Name = data_table.Subcatchment;
    end
    
    obj.(classname) = data_table;
    
end
end