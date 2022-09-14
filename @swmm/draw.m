function obj = draw(obj)
obj = obj.read_crd;
sym_dict = obj.dict('map');
shapenames = fields(obj.shapes);
for i2 = 1:numel(shapenames)
    
    classname = shapenames{i2};
    sym = sym_dict.(shapenames{i2});
    try
        mapshow(obj.shapes.(classname),'SymbolSpec',sym);
    catch
    end
    hold on
end
end
