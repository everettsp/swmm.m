function nse = perf_nse(x,y)
%% Nasch-Sutcliffe CE

% ensure row-wise elements
if size(x,1) == 1
    x = x';
    y = y';
end

assert(size(x,1) == size(y,1));

ind = ~(isnan(x) | any(isnan(y),2));
x = x(ind);
y = y(ind,:);

nse = 1 - sum((x - y).^2) / sum((x - mean(x)).^2); %Nash-Sutcliffe CE