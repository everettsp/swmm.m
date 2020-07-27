function te = perf_te(t,y)
%% Timing Error (maximum time-shifted NSE Value)
shifts = -5:5; %shift amounts
nseFun = @(x,y) 1 - sum((x-y).^2) / sum((x-mean(x)).^2);
nse_shifted = nan(size(shifts));

for ii = 1:numel(shifts)
    y_shifted = nan(size(y));
    shift = shifts(ii);
        if shift > 0 %right shift
            y_shifted(1+shift:end) = y(1:end-shift);
        elseif shift < 0 %left shift
            y_shifted(1:end+shift) = y(1-shift:end);
        elseif shift == 0
            y_shifted = y;
        end

    ind = ~(isnan(t) | isnan(y_shifted)); %remove nans after time-shifting
    nse_shifted(ii) = nseFun(t(ind),y_shifted(ind));
end
[~,nse_max] = max(nse_shifted);
te = shifts(nse_max);