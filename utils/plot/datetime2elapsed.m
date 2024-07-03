function ah = datetime2elapsed(ah,num_ts)

    durt = ah.XLim(2) - ah.XLim(1); % duration/time
    durh = hours(durt); % duration/hours
    timesteps = [1,2,4,6,12,24,24*7,30*24]; % common timestep increments
    ts_diff = durh ./ timesteps  - (num_ts); % number of timesteps along axis
    ts_diff(ts_diff<0) = NaN; % we want to round up, to not cutoff graph
    [~,ind] = min(ts_diff);
    ts = timesteps(ind);
    num_ts = numel(0:ts:(durh+ts));
    ah.XTick = ah.XLim(1) : (durt / (num_ts - 1)) : ah.XLim(2);
    ah.XTickLabels = 0:ts:(durh+ts);
    
end