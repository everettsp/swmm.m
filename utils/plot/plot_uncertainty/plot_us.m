function ush = plot_us(x_data,y_data,varargin)
% plot uncertainty scatterplot
% scatterplot with errorbars

[x_rows,x_cols] = size(x_data);
[y_rows,y_cols] = size(y_data);

if x_rows == 1 || y_rows == 1
    x_data = x_data';
    y_data = y_data';
end


istabular = @(x) istable(x) || istimetable(x);
if istabular(x_data)
    x_data = x_data.Variables;
end


if istabular (y_data)
    y_data = y_data.Variables;
end

ush = uncertainty_scatter(x_data,y_data,varargin{:});
end