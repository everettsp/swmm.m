function [sine,cosine] = datetime2sinecosine(dt)


sine = nan(numel(dt),1);
cosine = nan(numel(dt),1);

for i2 = 1:numel(dt)
    sine(i2) = sin(2 * pi * (day(dt(i2),'dayofyear') - 1) ./ (yeardays(year(dt(i2))) - 1));
    cosine(i2) = cos(2 * pi * (day(dt(i2),'dayofyear') - 1) ./ (yeardays(year(dt(i2))) - 1));

end