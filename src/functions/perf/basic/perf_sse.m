function mse = perf_sse(x,y)
%% mean squared error
ind = ~(isnan(x) | isnan(y));
x = x(ind);
y = y(ind);
n = numel(x);
mse = sum((x - y).^2);