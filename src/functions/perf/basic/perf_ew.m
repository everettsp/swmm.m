function [mse,mseLin,mseExp,mseGrad,mseInform] = perf_ew(t,y)

ewStrs = {'none','ewNorm','ewExp','ewGrad','ewInform'};
mseArray = zeros(numel(ewStrs,1));

for ii = 1:numel(ewStrs)
ewStr = ewStrs{ii};
switch ewStr
    case 'none'
        ew = ones(length(t),1);
    otherwise
        fh = str2func(ewStr);
        [ew] = fh(t);
        ew = normalize(ew,'range');
end
if ~all(size(ew) == size(t)); ew = ew'; end %if dim's wrong, transpose

ni = ~(isnan(y) | isnan(t) | isnan(ew));
n = numel(y(ni));
mseArray(ii) = sum(ew(ni) .* ((t(ni) - y(ni)).^2)) / n;

end
mse = mseArray(1);
mseLin = mseArray(2);
mseExp = mseArray(3);
mseGrad = mseArray(4);
mseInform = mseArray(5);
end