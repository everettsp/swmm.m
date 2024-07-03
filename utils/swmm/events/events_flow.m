function events2 = events_flow(tt_obs,events)

events2 = events;
num_events = numel(events);

for i3 = 1:num_events
%     tr = events2(i3).timerange;
    rt = events2(i3).tt_rg.Properties.RowTimes;
    events2(i3).tt_fg = tt_obs(rt,:);
    flow = events2(i3).tt_fg.Variables;
    
    events2(i3).tt_fg = addprop(events2(i3).tt_fg,'VariableStationID','variable');
    events2(i3).tt_fg = addprop(events2(i3).tt_fg,'VariableClass','variable');
    
    [max_q,max_ind] = max(flow);
    events2(i3).qp = max_q;
    events2(i3).qp_time = events2(i3).tt_fg.Properties.RowTimes(max_ind);
    events2(i3).q_mean = nanmean(flow);
    events2(i3).q_vol = nansum(flow .* seconds(tt_obs.Properties.TimeStep));
    events2(i3).q_ratio = flow(end) ./ flow(1);
    events2(i3).slope_rise = (max_q - flow(1)) / (max_ind - 1);
    events2(i3).slope_recede = (flow(end) - max_q) / (numel(flow) - max_ind);
    
end


% remove events with incomplete flow records
ind = false([numel(events2),1]);
for i3 = 1:num_events
    if all(~isnan(events2(i3).tt_fg.Variables))
        ind(i3) = true;
    else
        ind(i3) = false;
    end
end

events2 = events2(ind);
clear ind i3

end