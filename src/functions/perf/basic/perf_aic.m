function aic = perf_aic(x,y,p)
%% Akaike information criterion
ind = ~(isnan(x) | isnan(y));
x = x(ind);
y = y(ind);
n = numel(x);
mse = sum((x - y).^2) / n;
aic = n * log (mse) + (2 * p);