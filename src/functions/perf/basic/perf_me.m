function mae = perf_me(x,y,type)
if nargin < 3
    type = 'abs';
    disp(["input arg 'type' not specified, using " type])
end
ind = ~(isnan(x) | isnan(y));
x = x(ind);
y = y(ind);
n = numel(x);
switch lower(type)
    case {'rel','relative'}
        mae = sum((x - y) ./ x) / n;
    case {'abs','absolute'}
        mae = sum(x - y) / n;
    otherwise
        disp([type " not recognized, try 'rel' or 'abs'"])
end
end