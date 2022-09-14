function elements = classes2elements(mdl,ga_vars)
% function creates a table of optimisation variables based on a list of
% table of SWMM classes and constraints
% the table of variables contains a complete list of specific elements to
% be optimised

% ga_vars = ga_vars(~ismember(ga_vars.attribute,{'Suction','Ksat','IMD','N_Perv'}),:); % filter insensitive parameters
num_cal_vars = height(ga_vars);

elements = table();

% for each calibration parameter, calculate uncertainty and store in table
for i2 = 1:num_cal_vars
    class_name = lower(ga_vars.class{i2});
    field_name = ga_vars.attribute{i2};
    num_elements = height(mdl.p.(class_name));
    
    vals = mdl.p.(class_name)(:,ga_vars.attribute{i2}).Variables;
    
    % calculate the uncertainty limits based the initial value from SWMM,
    % the relative uncertainty value, and the constraints
    uncertainty_lims = vals .* (1 + [-1,1] .* ga_vars.uncertainty(i2));
    uncertainty_lims(uncertainty_lims(:,1) < ga_vars.constraint_lower(i2),1) = ga_vars.constraint_lower(i2);
    uncertainty_lims(uncertainty_lims(:,1) > ga_vars.constraint_upper(i2),1) = ga_vars.constraint_upper(i2);
    
    % store data in a table
    dt_temp = table(...
        mdl.p.(class_name)(:,1).Variables,...
        repmat({class_name},[num_elements,1]),...
        repmat({field_name},[num_elements,1]),...
        vals,...
        vals,...
        repmat([ga_vars.constraint_lower(i2),ga_vars.constraint_upper(i2)],[num_elements,1]),...
        uncertainty_lims,...
        'VariableNames',{'name','class','attribute','val_uncal','val','constraints','lims'});
    elements = [elements; dt_temp];
end