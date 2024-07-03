function ccf = tt_ccf(tt1,tt2,lags)

assert(size(tt1,2) == 1);
assert(size(tt2,2) == 1);

tt0 = synchronize(tt1,tt2);
tt1 = tt0(:,1);
tt2 = tt0(:,2);


ccf = nan(size(lags));

for i2 = 1:numel(lags)
    lg = lags(i2);
    tt2lag = lag(tt2,lg);
    x = tt1.Variables;
    y = tt2lag.Variables;
    ind = isnan(x) | isnan(y);
    cctemp = corrcoef(x(~ind),y(~ind));
    ccf(i2) = cctemp(1,2);
end