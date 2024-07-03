function tt_out = fill_gaps(tt_in, max_dur)
% tt_in = tt_in(~isnan(tt_in.Variables),:);

% idx = diff(tt_in.Properties.RowTimes) > max_dur;
for i2 = 1:size(tt_in,2)

    x = tt_in(:,i2).Variables;
    x = isnan(x);
    xu = nan(size(x));
    xu(1:(end-1)) = x(2:end);
    xd = nan(size(x));
    xd(2:end) = x(1:(end-1));

    nw2 = find((x - xu) == 1); % last point in nan section
    nw1 = find((x - xd) == 1); % first point in nan section

    if isnan(tt_in{end,i2})
        nw2 = [nw2;numel(x)];
    end
    if isnan(tt_in{1,i2})
        nw1 = [1;nw1];
    end

    tt_out = tt_in;
    padding = 1; % buffer of non-nan values to use for more sophisitacted (non-linear) retiming methods

    for kk = 1:length(nw1)

        start_interp = (nw1(kk) - padding);
        end_interp = (nw2(kk) + padding);
        ind_interp = start_interp:end_interp;
        if (start_interp >= 1) && (end_interp <= size(tt_in,1)) && ((end_interp - start_interp) < (max_dur + 2* padding))

            tt_out(ind_interp,i2) = retime(tt_in(ind_interp,i2),'regular','linear','TimeStep',hours(1));
        end
    end
end

end