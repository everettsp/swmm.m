function obj = write_inp(obj,ffilename)%elements, readwrite)
% write a SWMM .inp file from data contained in obj.p
% this function overwrites the .inp file situated in obj.inp
% changes to obj.p made without calling this function will not be reflected
% in simulation results

msg = "SWM model is locked for editing... unlock by creating a copy using 'initialize' function or manually setting .locked class property to true";
assert(obj.read_only == false,msg)

new_content = {};

idx_class_exists = find(~structfun(@isempty, obj.p));
class_list = fields(obj.p); % classes are listed alphebetically
class_list = class_list(idx_class_exists);

% classes must be written to swmm in a sort of specific order (e.g.,
% subcatchments must appear before subears, etc.)
% todo: complete priority list (need SWMM file with every type of element)
% these are based on fmc model but there might be more dependencies with
% more complex swmm models

class_priority = {'title','options','files','evaporation','raingages','subcatchments','subareas','infiltration','junctions','outfalls','storage','conduits','orifices','weirs','xsections','timeseries','lid_controls','pollutants','report','map','coordinates','vertices','polygons','symbols','coverages','landuses','buildup','washoff','loadings','transects','losses','curves','tag'};

% class_priority = obj.class_info.classname;

for i2 = fliplr(1:numel(class_priority))
    idx = ismember(lower(class_list),lower(class_priority{i2}));
    if any(idx)
        idx2 = 1:numel(class_list);
        class_list = class_list([find(idx),idx2(~idx)]);
    end
end
clear vars idx idx2

for i2 = 1:numel(idx_class_exists)

    classname = class_list{i2};
    content_class = {['[',upper(class_list{i2}),']']};
    
    data = obj.p.(classname);
    
    % writing class data to .INP file is pretty straightforward, but there
    % are some special cases (options, lid_controls, etc.) where we have to
    % hard-code a bit
    switch  classname
        case {'title'}
        case {'report'}
            y = [];
            flds = fields(data);
            for i3 = 1:numel(flds)
                data_line = [flds{i3},data.(flds{i3})];
                content_class{end + 1} = strjoin(data_line,'\t');
            end
        case {'options'}
            
            for opt_name = {'START','REPORT_START','END'}
                [date_str, time_str] = swmm_datetime2datestr(data.([char(opt_name),'_DATE']));
                data.([char(opt_name),'_DATE']) = char(date_str);
                data.([char(opt_name),'_TIME']) = char(time_str);
            end
            data_cell = struct2cell(data);
            data_cell = cellfun(@num2str, data_cell,'UniformOutput',false);
            data_fields = fields(data);
            for i3 = 1:size(data_cell,1)
                content_class{end + 1} = strjoin({data_fields{i3},data_cell{i3}},'\t');
            end
            
        case {'lid_controls'}
            lid_types = fields(data);
            for i3 = 1:numel(lid_types) % each lid type
                lid_type = lid_types{i3}; % store the lid type
                for i4 = 1:numel(data.(lid_types{i3})) % each lid instance
                    lid_name = data.(lid_types{i3})(i4).name;
                    lid_layer_fields = fields(data.(lid_types{i3})(i4)); % lid layer names
                    content_class = [content_class;strjoin({lid_name,upper(lid_type)},'\t')];
                    
                    for i5 = 2:numel(lid_layer_fields) % each lid layer
                        lid_layer_field = lid_layer_fields{i5}; % store layer name
                        data_cell_num = [upper(lid_layer_field);struct2cell(data.(lid_types{i3})(i4).(lid_layer_fields{i5}))];
                        data_cell = [lid_name;cellfun(@num2str,data_cell_num,'UniformOutput',false)];
                        content_class = [content_class;strjoin(data_cell,'\t')];
                    end
                    content_class = [content_class;{''}];
                end
            end
            
        otherwise
            
            % some data is just way too complicated to format into a table,
            % and I don't need to mess with it, so it's just stored as a
            % big text block (cell array)
            if iscell(data)
                content_class(end + (1:numel(data))) = data;
                
            % most data is stored as a table; writing is straightforward
            elseif istable(data)
                
                data_cell0 = table2cell(data);
                data_cell = cell(size(data));

                for j3 = 1:width(data)
                    try
                        data_cell(:,j3) = cellfun(@num2str, data_cell0(:,j3),'UniformOutput',false);
                    catch
                        data_cell(:,j3) = data_cell0(:,j3);
                    end
                end
                
                for i3 = 1:size(data_cell,1)
                    content_class = [content_class; strjoin(data_cell(i3,:),'\t')];
                end
            end
    end
    
    new_content(end + (1:numel(content_class))) = content_class;
    new_content(end+1) = {''};
end

% write content to file
fid = fopen(ffilename,'w+');
for i2 = 1:numel(new_content)
    fprintf(fid,'%s\n',new_content{i2});
end
fclose(fid);

end