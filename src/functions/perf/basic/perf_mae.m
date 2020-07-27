function mae = perf_mae(x,y)
% ensure row-wise elements
if size(x,1) == 1
    x = x';
    y = y';
end

assert(size(x,1) == size(y,1));

ind = ~(isnan(x) | any(isnan(y),2));
x = x(ind);
y = y(ind,:);

n = numel(x);
mae = sum(abs(x - y))/n;