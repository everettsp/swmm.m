function rm4e = perf_rm4e(x,y)%% root mean quad error
%% number of non-nan samples
ind = ~(isnan(x) | isnan(y));
x = x(ind);
y = y(ind);
n = numel(x);
m4e = sum((x-y).^4) / n;
rm4e = m4e^(1/4);