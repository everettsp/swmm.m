function pi = perf_pi(x,y,lead)

% ensure row-wise elements
if size(x,1) == 1
    x = x';
    y = y';
end

assert(size(x,1) == size(y,1));

xl = nan(size(x)); %target station
xl((lead+1):end) = x(1:(end-lead)); %lag target station by the lead time

ind = ~(isnan(x) | any(isnan(y),2) | isnan(xl));

x = x(ind);
xl = xl(ind);
y = y(ind,:);

f = sum((x - y).^2);
fp = sum((x - xl).^2);

pi = 1 - f./fp;