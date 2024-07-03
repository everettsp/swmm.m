function ga_vars = load_opt_classes(scenario)

ga_vars = table( {},{},[],[],[],...
    'VariableNames',{'class','attribute','uncertainty','constraint_lower','constraint_upper'});

if nargin < 1
    scenario = 'normal';
end

switch lower(scenario)
    case 'normal'
        ga_vars((end+1),:) = {'subcatchments',       'Width',                2.00,     0,      1E6};
        ga_vars((end+1),:) = {'subcatchments',       'PercentSlope',         0.25,     0,      5};
        ga_vars((end+1),:) = {'subcatchments',       'PercentImperv',        0.20,     0,      100};
        ga_vars((end+1),:) = {'subareas',            'N_Imperv',             0.10,     0,      0.024};
        ga_vars((end+1),:) = {'subareas',            'N_Perv',               0.50,     0,      0.8};
        ga_vars((end+1),:) = {'subareas',            'S_Imperv',             0.20,     0,      2.54};
        ga_vars((end+1),:) = {'subareas',            'S_Perv',               0.50,     0,      7.62};
        ga_vars((end+1),:) = {'infiltration',        'Suction',              0.50,     0,      320};
        ga_vars((end+1),:) = {'infiltration',        'Ksat',                 0.50,     0,      120};
        ga_vars((end+1),:) = {'infiltration',        'IMD',                  0.25,     0,      0.4};
        % ga_vars((end+1),:) = {'CONDUITS',            'Roughness',            0.25,     0,      1.0};
        case 'high_uncertainty'
        ga_vars((end+1),:) = {'subcatchments',       'Width',                4.00,     0,      1E6};
        ga_vars((end+1),:) = {'subcatchments',       'PercentSlope',         0.50,     0,      5};
        ga_vars((end+1),:) = {'subcatchments',       'PercentImperv',        0.40,     0,      100};
        ga_vars((end+1),:) = {'subareas',            'N_Imperv',             0.20,     0,      0.024};
        ga_vars((end+1),:) = {'subareas',            'N_Perv',               1.00,     0,      0.8};
        ga_vars((end+1),:) = {'subareas',            'S_Imperv',             0.40,     0,      2.54};
        ga_vars((end+1),:) = {'subareas',            'S_Perv',               1.00,     0,      7.62};
        ga_vars((end+1),:) = {'infiltration',        'Suction',              1.00,     0,      320};
        ga_vars((end+1),:) = {'infiltration',        'Ksat',                 1.00,     0,      120};
        ga_vars((end+1),:) = {'infiltration',        'IMD',                  0.50,     0,      0.4};
        % ga_vars((end+1),:) = {'CONDUITS',            'Roughness',            0.25,     0,      1.0};
        case 'high_sensitivity'
        ga_vars((end+1),:) = {'subcatchments',       'Width',                2.00,     0,      1E6};
        ga_vars((end+1),:) = {'subcatchments',       'PercentSlope',         0.25,     0,      5};
        ga_vars((end+1),:) = {'subcatchments',       'PercentImperv',        0.20,     0,      100};
        ga_vars((end+1),:) = {'subareas',            'N_Imperv',             0.10,     0,      0.024};
%         ga_vars((end+1),:) = {'subareas',            'N_Perv',               0.50,     0,      0.8};
        ga_vars((end+1),:) = {'subareas',            'S_Imperv',             0.20,     0,      2.54};
%         ga_vars((end+1),:) = {'subareas',            'S_Perv',               0.50,     0,      7.62};
%         ga_vars((end+1),:) = {'infiltration',        'Suction',              0.50,     0,      320};
%         ga_vars((end+1),:) = {'infiltration',        'Ksat',                 0.50,     0,      120};
%         ga_vars((end+1),:) = {'infiltration',        'IMD',                  0.25,     0,      0.4};
        % ga_vars((end+1),:) = {'CONDUITS',            'Roughness',            0.25,     0,      1.0};
        
    case 'low_sensitivity'
%         ga_vars((end+1),:) = {'subcatchments',       'Width',                2.00,     0,      1E6};
%         ga_vars((end+1),:) = {'subcatchments',       'PercentSlope',         0.25,     0,      5};
%         ga_vars((end+1),:) = {'subcatchments',       'PercentImperv',        0.20,     0,      100};
%         ga_vars((end+1),:) = {'subareas',            'N_Imperv',             0.10,     0,      0.024};
        ga_vars((end+1),:) = {'subareas',            'N_Perv',               0.50,     0,      0.8};
%         ga_vars((end+1),:) = {'subareas',            'S_Imperv',             0.20,     0,      2.54};
        ga_vars((end+1),:) = {'subareas',            'S_Perv',               0.50,     0,      7.62};
        ga_vars((end+1),:) = {'infiltration',        'Suction',              0.50,     0,      320};
        ga_vars((end+1),:) = {'infiltration',        'Ksat',                 0.50,     0,      120};
        ga_vars((end+1),:) = {'infiltration',        'IMD',                  0.25,     0,      0.4};
        % ga_vars((end+1),:) = {'CONDUITS',            'Roughness',            0.25,     0,      1.0};
        
    case 'high_uncertainty_sensitivity'
        ga_vars((end+1),:) = {'subcatchments',       'Width',                4.00,     0,      1E6};
        ga_vars((end+1),:) = {'subcatchments',       'PercentSlope',         0.50,     0,      5};
        ga_vars((end+1),:) = {'subcatchments',       'PercentImperv',        0.40,     0,      100};
        ga_vars((end+1),:) = {'subareas',            'N_Imperv',             0.20,     0,      0.024};
%         ga_vars((end+1),:) = {'subareas',            'N_Perv',               1.00,     0,      0.8};
        ga_vars((end+1),:) = {'subareas',            'S_Imperv',             0.40,     0,      2.54};
%         ga_vars((end+1),:) = {'subareas',            'S_Perv',               1.00,     0,      7.62};
%         ga_vars((end+1),:) = {'infiltration',        'Suction',              1.00,     0,      320};
%         ga_vars((end+1),:) = {'infiltration',        'Ksat',                 1.00,     0,      120};
%         ga_vars((end+1),:) = {'infiltration',        'IMD',                  0.50,     0,      0.4};
        % ga_vars((end+1),:) = {'CONDUITS',            'Roughness',            0.25,     0,      1.0};
    case 'double'
        ga_vars((end+1),:) = {'subcatchments',       'Width',                2.00,     0,      1E6};
        ga_vars((end+1),:) = {'subcatchments',       'PercentSlope',         0.25,     0,      5};
        ga_vars((end+1),:) = {'subcatchments',       'PercentImperv',        0.20,     0,      100};
        ga_vars((end+1),:) = {'subareas',            'N_Imperv',             0.10,     0,      0.024};
        ga_vars((end+1),:) = {'subareas',            'N_Perv',               0.50,     0,      0.8};
        ga_vars((end+1),:) = {'subareas',            'S_Imperv',             0.20,     0,      2.54};
        ga_vars((end+1),:) = {'subareas',            'S_Perv',               0.50,     0,      7.62};
        ga_vars((end+1),:) = {'infiltration',        'Suction',              0.50,     0,      320};
        ga_vars((end+1),:) = {'infiltration',        'Ksat',                 0.50,     0,      120};
        ga_vars((end+1),:) = {'infiltration',        'IMD',                  0.25,     0,      0.4};
        ga_vars((end+1),:) = {'subcatchments',       'Width',                2.00,     0,      1E6};
        
        ga_vars((end+1),:) = {'subcatchments',       'PercentSlope',         0.25,     0,      5};
        ga_vars((end+1),:) = {'subcatchments',       'PercentImperv',        0.20,     0,      100};
        ga_vars((end+1),:) = {'subareas',            'N_Imperv',             0.10,     0,      0.024};
        ga_vars((end+1),:) = {'subareas',            'N_Perv',               0.50,     0,      0.8};
        ga_vars((end+1),:) = {'subareas',            'S_Imperv',             0.20,     0,      2.54};
        ga_vars((end+1),:) = {'subareas',            'S_Perv',               0.50,     0,      7.62};
        ga_vars((end+1),:) = {'infiltration',        'Suction',              0.50,     0,      320};
        ga_vars((end+1),:) = {'infiltration',        'Ksat',                 0.50,     0,      120};
        ga_vars((end+1),:) = {'infiltration',        'IMD',                  0.25,     0,      0.4};

        % ga_vars((end+1),:) = {'CONDUITS',            'Roughness',            0.25,     0,      1.0};
    otherwise
        error(['scenario ',scenario,' not recognised'])
end

% head(ga_vars)
% 'SUBAREAS','SUBAREAS','SUBAREAS','SUBAREAS','INFILTRATION','INFILTRATION','INFILTRATION','CONDUITS'};
end
