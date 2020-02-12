function ush = plot_uncertainty_scatter(x_data,y_data,varargin)

istabular = @(x) istable(x) || istimetable(x);
if istabular(x_data)
    x_data = x_data.Variables;
end

if istabular (y_data)
    y_data = y_data.Variables;
end
ush = uncertainty_scatter(x_data,y_data,varargin{:});
end