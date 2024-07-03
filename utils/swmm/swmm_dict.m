function dict = swmm_dict(dict_name)
dict = struct();
switch lower(dict_name)
    case 'units'
        dict.precip = 'mm/hr';
        dict.losses = 'mm/hr';
        dict.runoff = 'cms';
end