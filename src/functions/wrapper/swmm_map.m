function shape_structs = swmm_map(swmm)

swmm_shapes = struct();
utm_zone = 17;
classnames = {'subcatchments','junctions', 'outfalls', 'storage', 'conduits', 'outlets'};
shape_structs = struct();
swmm_exists = true(numel(classnames),1);

% find the coordinates based on the polygons coordinate table contained in
% .INP and match them to their respective subcatchment based on the sc_name
% format coordinates to UTM and format struct for shapefile export


%% subcatchments

[sc_unique, ~] = unique(swmm.polygons.Subcatchment);
num_sc = numel(sc_unique);
shape_centroids = NaN(num_sc,2);
swmm_table = swmm.subcatchments;
for i2 = 1:num_sc
    idx = ismember(swmm.polygons.Subcatchment,sc_unique{i2});
    swmm_shape = swmm.polygons(idx,:);
    %     fill(swmm_shape.X_Coord, swmm_shape.Y_Coord, [.9 .9 .9])
    swmm_shapes(i2).Geometry = 'Polygon';
    swmm_shapes(i2).id = swmm_shape.Properties.RowNames{1};
    
    sc_attributes = swmm_table(contains(swmm_table.Name,sc_unique(i2)),:);
    
    % assign attributes using a loop, just in case order of subcatchments
    % is different between 'unique' list and subcatchment table
    
    swmm_shapes(i2).('id') = char(sc_attributes.Properties.RowNames);
    for i3 = 1:numel(sc_attributes.Properties.VariableNames) %start at 2 to skip 'Name' field
        attribute_val = table2array(sc_attributes(:,i3));
        if iscell(attribute_val)
            attribute_val = char(attribute_val);
        end
        swmm_shapes(i2).(sc_attributes.Properties.VariableNames{i3}) = attribute_val;
    end
    
    [swmm_shapes(i2).Y, swmm_shapes(i2).X,] = utm2ll(...
        swmm_shape.X_Coord, swmm_shape.Y_Coord,...
        utm_zone);
    
    %     [swmm_shapes(i2).Ycenter, swmm_shapes(i2).Xcenter] = utm2ll(...
    %         mean(swmm_shape.X_Coord), mean(swmm_shape.Y_Coord),...
    %         utm_zone);
    
end
shape_structs.('subcatchments') = swmm_shapes;

clear vars swmm_shape swmm_polys

%% polylines
swmm_coords = swmm.coordinates;
for i3 = 2:4
    classname = classnames{i3};
    swmm_table = swmm.(classname);

    if isempty(swmm_table)
        swmm_exists(i3) = false;
        break
%         continue
    end
    swmm_struct = table2struct(swmm_table);
    [swmm_struct.id] = swmm_table.Properties.RowNames{:};
    %     node_data{i3} = addvars(node_data{i3},NaN(height(node_data{i3}),1),NaN(height(node_data{i3}),1),'NewVariableNames',{'X_Coord','Y_Coord'});
    
    for i2 = 1:numel(swmm_struct)
        swmm_struct(i2).Geometry = 'Multipoint';
        idx = strcmp(swmm_coords.Node,swmm_struct(i2).Name);
        if ~any(idx)
            error(['could not find coordinates for node: ' swmm_struct.Name(i2)])
        end
        [swmm_struct(i2).Y, swmm_struct(i2).X] = utm2ll(...
            swmm_coords.X_Coord(idx),swmm_coords.Y_Coord(idx),...
            utm_zone);
    end
    shape_structs.(classname) = swmm_struct;
end


%% points
for i3 = 5:6
    classname = classnames{i3};
    swmm_table = swmm.(classname);
    
    if isempty(swmm_table)
        swmm_exists(i3) = false;
        break
    end
    swmm_struct = table2struct(swmm_table);
    [swmm_struct.id] = swmm_table.Properties.RowNames{:};
    
    num_connections = numel(swmm_struct);
    
    for i2 = 1:num_connections
        swmm_struct(i2).Geometry = 'Line';
        from_idx = strcmp(swmm_coords.Node,swmm_struct(i2).From_Node);
        to_idx = strcmp(swmm_coords.Node,swmm_struct(i2).To_Node);
        
        [swmm_struct(i2).Y(1), swmm_struct(i2).X(1)] = utm2ll(...
            swmm_coords.X_Coord(from_idx),swmm_coords.Y_Coord(from_idx),...
            utm_zone);
        
        [swmm_struct(i2).Y(2),swmm_struct(i2).X(2)] = utm2ll(...
            swmm_coords.X_Coord(to_idx),swmm_coords.Y_Coord(to_idx),...
            utm_zone);
        
    end
    shape_structs.(classname) = swmm_struct;
    
end


path_gis = [swmm.dir_main,'\shapefiles\'];
if 7 ~= exist(path_gis,'dir')
    mkdir(path_gis)
end

for i2 = 1:numel(shape_structs)
    classname = classnames{i2};
    if swmm_exists(i2)
        
        shapewrite(shape_structs.(classname), [path_gis classnames{i2} '.shp'])
    end
end

end
