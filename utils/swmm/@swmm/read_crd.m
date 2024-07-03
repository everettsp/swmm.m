function obj = read_crd(obj)

swmm_shapes = struct();
utm_zone = 17;
classnames = {'subcatchments','junctions', 'outfalls', 'storage', 'conduits', 'outlets'};
shape_structs = struct();
geom_exists = true(numel(classnames),1);

% find the coordinates based on the polygons coordinate table contained in
% .INP and match them to their respective subcatchment based on the sc_name
% format coordinates to UTM and format struct for shapefile export


%% subcatchments

[sc_unique, ~] = unique(obj.p.polygons.Subcatchment);
num_sc = numel(sc_unique);
shape_centroids = NaN(num_sc,2);
swmm_table = obj.p.subcatchments;

for i2 = 1:num_sc
    idx = ismember(obj.p.polygons.Subcatchment,sc_unique{i2});
    swmm_shape = obj.p.polygons(idx,:);
    %     fill(swmm_shape.X_Coord, swmm_shape.Y_Coord, [.9 .9 .9])
    swmm_shapes(i2).Geometry = 'Polygon';
    swmm_shapes(i2).id = swmm_shape.Subcatchment{1};
    
    sc_attributes = swmm_table(contains(swmm_table.Name,sc_unique(i2)),:);
    
    % assign attributes using a loop, just in case order of subcatchments
    % is different between 'unique' list and subcatchment table
%     swmm_shapes(i2).('id') = sc_attributes.Name;
    for i3 = 1:numel(sc_attributes.Properties.VariableNames) %start at 2 to skip 'Name' field
        attribute_val = table2array(sc_attributes(:,i3));
        if iscell(attribute_val)
            attribute_val = char(attribute_val);
        end
        swmm_shapes(i2).(sc_attributes.Properties.VariableNames{i3}) = attribute_val;
    end
    
    
    %
    %     [swmm_shapes(i2).Y, swmm_shapes(i2).X] = utm2ll(...
    %         swmm_shape.X_Coord, swmm_shape.Y_Coord,...
    %         utm_zone);
    %
    swmm_shapes(i2).Y = swmm_shape.Y_Coord;
    swmm_shapes(i2).X = swmm_shape.X_Coord;
    
    % get centroid
    [x_center,y_center] = centroid(polyshape([swmm_shape.X_Coord,swmm_shape.Y_Coord]));
    
    %     [swmm_shapes(i2).Ycenter, swmm_shapes(i2).Xcenter] = utm2ll(...
    %             x_center,y_center,...
    %             utm_zone);
    
    swmm_shapes(i2).Xcenter = x_center;
    swmm_shapes(i2).Ycenter = y_center;
    
end
swmm_shapes_table = struct2table(swmm_shapes,'AsArray',true);
swmm_shapes_table = swmm_shapes_table(:,{'Name','Xcenter','Ycenter'});
swmm_shapes_table.Properties.VariableNames = {'Name','X','Y'};

swmm_coords_table = obj.p.coordinates;
swmm_coords_table.Properties.VariableNames = {'Name','X','Y'};

swmm_outlets_table = [swmm_shapes_table;swmm_coords_table];
swmm_outlets = table2struct(swmm_outlets_table);

for i2 = 1:num_sc
    idx_outlet = strcmp({swmm_outlets.Name},swmm_shapes(i2).Outlet);
    
    
    %     [swmm_shapes(i2).Youtlet, swmm_shapes(i2).Xoutlet] = utm2ll(...
    %             obj.coordinates(idx_outlet,'X_Coord').Variables,...
    %             obj.coordinates(idx_outlet,'Y_Coord').Variables,...
    %             utm_zone);
    swmm_shapes(i2).Xoutlet = swmm_outlets(idx_outlet).X;
    swmm_shapes(i2).Youtlet = swmm_outlets(idx_outlet).Y;
    
end
[swmm_shapes.id] = swmm_shapes.Name;
shape_structs.('subcatchments') = swmm_shapes;

swmm_shapes = shape_structs.subcatchments;

for i2 = 1:num_sc
    swmm_shapes(i2).Geometry = 'Line';
    swmm_shapes(i2).X = [swmm_shapes(i2).Xcenter, swmm_shapes(i2).Xoutlet];
    swmm_shapes(i2).Y = [swmm_shapes(i2).Ycenter, swmm_shapes(i2).Youtlet];
end
shape_structs.('connections') = swmm_shapes;

clear vars swmm_shape swmm_polys

%% points
classnames = {'junctions','outfalls','storage'};
for i3 = 1:numel(classnames)
    classname = classnames{i3};
    
    class_data = obj.p.(classname);
    if isempty(class_data)
        geom_exists(i3) = false;
        break
    else
        swmm_struct = table2struct(class_data);
        %         continue
    end
    
%     [swmm_struct.id] = {swmm_struct.Name};
    %     node_data{i3} = addvars(node_data{i3},NaN(height(node_data{i3}),1),NaN(height(node_data{i3}),1),'NewVariableNames',{'X_Coord','Y_Coord'});
    
    for i2 = 1:numel(swmm_struct)
        swmm_struct(i2).Geometry = 'MultiPoint';
        idx = strcmp(obj.p.coordinates.Node,swmm_struct(i2).Name);
        if ~any(idx)
            error(['could not find coordinates for node: ' swmm_struct.Name(i2)])
        end
        
        %         [swmm_struct(i2).Y, swmm_struct(i2).X] = utm2ll(...
        %             obj.coordinates.X_Coord(idx),obj.coordinates.Y_Coord(idx),...
        %             utm_zone);
        
        swmm_struct(i2).X = obj.p.coordinates.X_Coord(idx);
        swmm_struct(i2).Y = obj.p.coordinates.Y_Coord(idx);
        
        
    end
    shape_structs.(classname) = swmm_struct;
end


%% polylines

classnames = {'conduits', 'outlets'};
for i3 = 1:numel(classnames)
    classname = classnames{i3};
    class_data = obj.p.(classname);
    
    if isempty(class_data)
        geom_exists(i3) = false;
        break
    else
        swmm_struct = table2struct(class_data);
    end
    
    [swmm_struct.id] = swmm_struct.Name;
    
    num_connections = numel(swmm_struct);
    
    for i2 = 1:num_connections
        swmm_struct(i2).Geometry = 'Line';
        from_idx = strcmp(strtrim(obj.p.coordinates.Node),strtrim(swmm_struct(i2).FromNode));
        to_idx = strcmp(strtrim(obj.p.coordinates.Node),strtrim(swmm_struct(i2).ToNode));
        
        % add the polyline start point
        %         [swmm_struct(i2).Y(1), swmm_struct(i2).X(1)] = utm2ll(...
        %             obj.coordinates.X_Coord(from_idx),obj.coordinates.Y_Coord(from_idx),...
        %             utm_zone);
        
        swmm_struct(i2).X(1) = obj.p.coordinates.X_Coord(from_idx);
        swmm_struct(i2).Y(1) = obj.p.coordinates.Y_Coord(from_idx);
        
        if ~isempty(obj.p.vertices)
            % get the link vertices and add after start point
            vert_idx = strcmp(swmm_struct(i2).Name,obj.p.vertices.Link);
            obj.p.vertices(vert_idx,:);
            if sum(vert_idx) > 0
                %             [swmm_struct(i2).Y(1+(1:sum(vert_idx))), swmm_struct(i2).X(1+(1:sum(vert_idx)))] = utm2ll(...
                %                 obj.vertices.X_Coord(vert_idx),obj.vertices.Y_Coord(vert_idx),...
                %                 utm_zone);
                
                swmm_struct(i2).X(1+(1:sum(vert_idx))) = obj.p.vertices.X_Coord(vert_idx);
                swmm_struct(i2).Y(1+(1:sum(vert_idx))) = obj.p.vertices.Y_Coord(vert_idx);
                
            end
        end
        % add the polyline end point
        %         [swmm_struct(i2).Y(end+1),swmm_struct(i2).X(end+1)] = utm2ll(...
        %             obj.coordinates.X_Coord(to_idx),obj.coordinates.Y_Coord(to_idx),...
        %             utm_zone);
        
        swmm_struct(i2).X(end+1) = obj.p.coordinates.X_Coord(to_idx);
        swmm_struct(i2).Y(end+1) = obj.p.coordinates.Y_Coord(to_idx);
        
    end
    shape_structs.(classname) = swmm_struct;
    
end

obj.shapes = shape_structs;

end
