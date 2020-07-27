function rho = datetime2rho(dt)


rho = nan(numel(dt),1);
for i2 = 1:numel(dt)
    rho(i2) = 2 * pi * day(dt(i2),'dayofyear') ./ yeardays(year(dt(i2)));
end