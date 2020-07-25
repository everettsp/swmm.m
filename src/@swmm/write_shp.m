function obj = write_shp(obj)
% write shapefiles for objects in SWMM file
% shapefiles will be written to \dir_main\shapefiles\

obj = obj.read_crd;

path_gis = [obj.dir_main,'\shapefiles\'];
if 7 ~= exist(path_gis,'dir')
    mkdir(path_gis)
end

shape_structs = obj.shapes;

% classnames = {'subcatchments','connections','junctions', 'outfalls', 'storage', 'conduits', 'outlets'};
classnames = fields(obj.shapes);
for i2 = 1:numel(classnames)
    classname = classnames{i2};
%     if geom_exists(i2)

    % remove empty attribtues since shapewrite throwing error with emtpy
    % attributes.... ??
    
    flds = fieldnames(shape_structs.storage);
    idx_empty_attributes = all(cellfun(@isempty,struct2cell(shape_structs.storage)'));
    shape_structs.storage = rmfield(shape_structs.storage,flds(idx_empty_attributes));
    
    shapewrite(shape_structs.(classname), [path_gis,classnames{i2},'.shp'])
%     end
end

end
