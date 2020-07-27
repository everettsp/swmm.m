function mse = perf_mse(x,y)
%% mean squared error
ind = ~(isnan(x) | isnan(y));
x = x(ind);
y = y(ind);
n = numel(x);
mse = sum((x - y).^2) / n;