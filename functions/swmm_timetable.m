function tts = swmm_timetable(file_swmm_out,name_classes,name_elmnts)

if ~contains(file_swmm_out,'.rpt')
    file_swmm_out = [file_swmm_out '.rpt'];
end

fid = fopen(file_swmm_out);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);

content = content_cell{1};
clear content_cell

% element_id = 'sc_1';

if ~iscell(name_classes)
    name_classes = {name_classes};
end

if ~iscell(name_elmnts)
    name_elmnts = {name_elmnts};
end

assert(numel(name_classes) == numel(name_elmnts),'number of class names must be equal to number of elements')

for i2 = 1:numel(name_classes)
    
    name_class = name_classes{i2};
    name_elmnt = name_elmnts{i2};
    
    % provide some flexible input, since timetables are only categorized by
    % node, link, and subcatchment
    switch lower(name_class)
        case {'conduits','conduit','links','storage','outlets'}
            name_class = 'link';
        case {'junction','outfalls','nodes'}
            name_class = 'node';
        case {'catchment','sc','subcatchments'}
    end
    
    if ~any(contains({'subcatchment','node','link'},lower(name_class)))
        error("element type recognized, try 'subcatchment', 'node', or 'link'")
    end
    
    name_class = string_format(name_class);
    
    line_start = find(contains(content',['<<< ' name_class ' ' name_elmnt ' >>>']));
    
    if ~any(contains(content','<<< '))
        error('SWMM run unsuccessful, ensure all parameters are within range and configured correctly')
    end
    
    if isempty(line_start)
        error('cannot locate specific element in output file, check ID and ensure all values are being reported in EPASWMM')
    end
    
    trim_datetime = @(x) contains(lower(x),'date') + contains(lower(x),'time') + cellfun(@isempty,x);

    headers_str = content{line_start + 2};
    headers = strsplit(headers_str);
    headers_remove = trim_datetime(headers);
    num_variables = sum(~headers_remove); % first two headers are for 'Date' and 'Time'
    clear headers_str
    
    units_str = content{line_start+3};
    units = strsplit(units_str);
    units_remove = trim_datetime(units);
    clear units_str
    
    line_cycle = line_start + 5; % data setarts 5 rows from header, start cycling there
    
    date_array = {};
    variable_array = [];
    
    while ~isempty(content{line_cycle})
        index = line_cycle - line_start - 5 + 1; % tare line_cycle such that it is indexed 1,2,3,...
        
        values = strsplit(content{line_cycle});
        
        % can't initialize these since number of timesteps is not known
        date_array{index,1} = char(join([values{1}," ",values{2}]));
        variable_array(index,:) = str2double(values(3:end));
        
        line_cycle = line_cycle + 1;
    end
    
    tt = timetable();
    tt.Properties.Description = name_elmnt;
    
    for i1 = 1:num_variables
        
        % add variables to timetable (UGLY -> it won't let me make a timetable with a
        % matrix for some reason, need to go column by colum...)
        
        if i1 == 1
            tt = timetable(datetime(date_array,'InputFormat','MM/dd/yyyy HH:mm:ss'),variable_array(:,i1));
        else
            tt = addvars(tt,variable_array(:,i1));
        end
        
    end
    
    % remove period from header name and make lower case
    %     name_elmnt = (strrep(name_elmnt,'.',''));
    
    for i1 = 1:numel(headers)
        headers{i1} = lower(headers{i1});
        headers{i1} = (strrep(headers{i1},'.',''));
        headers{i1} = (strrep(headers{i1},'/',''));
    end
    
    tt.Properties.VariableNames = headers(~headers_remove);
    
    %     for i1 = 1:numel(units)
    %         units{i1} = lower(headers{i1});
    %         units{i1} = (strrep(headers{i1},'.',''));
    %         units{i1} = (strrep(headers{i1},'/',''));
    %     end
    tt.Properties.VariableUnits = units(~units_remove);
    
    
    tts{i2} = tt;
end

% if there's only one class/element pair, remove cell format
if numel(name_classes) == 1
    tts = tts{1};
end

    function string_out = string_format(string_in)
        string_out = lower(string_in);
        string_out(1) = upper(string_out(1));
    end

end
