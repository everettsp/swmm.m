function mainclass = swmm_mainclass(subclass)
% matches subclasses (i.e., infiltration) to the main class (i.e.,
% subcatchment)

switch lower(subclass)
    case {'subcatchments','subareas','infiltration'}
        mainclass = 'subcatchments';
    case {'junctions'}
        mainclass = 'junctions';
    case {'weris','conduits'}
        mainclass = 'conduits';
    otherwise
        mainclass = subclass;
end
end

