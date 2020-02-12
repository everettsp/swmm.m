function [events] = summarize_events(swmm,tt_precip,interevent_period,varargin)
% script to discritize rainfall data into deperate events based on a
% minimum interevet period.


p = inputParser;
addParameter(p,'event_threshold',0,@isnumeric)
parse(p,varargin{:});

event_threshold = p.Results.event_threshold;

if ~isduration(interevent_period)
    error('interevent_period must be a duration [e.g. hours(12)]')
end

fprintf('\n\n\n')
fprintf('begining statistical analysis of precipitation data\n')

interevent_timesteps = interevent_period / tt_precip.Properties.TimeStep;
event_tf = any(movmax(tt_precip.Variables, interevent_timesteps) ~= 0, 2);

%%

n = numel(event_tf);

% encode events with a unique numeric value
k_encoder = 0;
event_encoder = zeros(numel(tt_precip.Properties.RowTimes),1);

for i3 = 2:(n-1)
    if event_tf(i3) == false
        event_encoder(i3) = 0;
    elseif event_tf(i3-1) == false && event_tf(i3) == true
        
        k_encoder = k_encoder + 1;
        event_encoder(i3) = k_encoder;
    elseif event_tf(i3) == true
        event_encoder(i3) = k_encoder;
    end
end

num_stations = size(tt_precip,2);
% get the subcatchment areas to calculate weighted areal rainfall
sc = swmm.subcatchments;

% query the total area associated with each rg
sc_area = zeros(num_stations,1);
fprintf('rain gages: ')
for i2 = 1:num_stations
    rg_name = tt_precip.Properties.VariableNames{i2};
    ldx = contains(sc.Rain_Gage, rg_name);
    if ~any(ldx)
        fprintf('%s, ',rg_name);
        sc_area(i2) = 0;
    else
        sc_area(i2) = sum(table2array(sc(ldx,'Area')));
    end
end
fprintf(' not found within subcatchment, omitting from calcs\n')

% calculate the weighted average precipitation
tt_mean = timetable(tt_precip.Properties.RowTimes,(tt_precip.Variables * sc_area) ./ sum(sc_area),...
    'VariableNames',{'mean_precip'});

num_events = max(event_encoder);
fprintf('%2d events identified based on %2dhr interevent period\n',num_events,hours(interevent_period))


events = struct();

% for each event, calculate basic statistical properties and key times
for i3 = 1:num_events
    idx = i3 == event_encoder;
    events(i3).id = i3;
    events_precipitation = tt_mean(idx,:).Variables;
    events(i3).timesteps = tt_precip.Properties.RowTimes(idx);
    events(i3).idx = idx;
    events(i3).tt_mean = tt_mean(idx,:);
    events(i3).tt = tt_precip(idx,:);
    events(i3).sum = sum(events_precipitation);
    [pp, tp] = max(events_precipitation);
    temp = find(idx);
    tp = temp(tp);
    events(i3).peak = pp ./ hours(tt_precip.Properties.TimeStep);
    events(i3).tp_date = tt_precip.Properties.RowTimes(tp);
    events(i3).tp_duration = tt_precip.Properties.RowTimes(tp) - events(i3).timesteps(1);
    events(i3).tp_hours = hours(events(i3).tp_duration);
    events(i3).t_start = events(i3).timesteps(1);
    events(i3).t_end = events(i3).timesteps(end);
    events(i3).timerange = timerange(min(events(i3).timesteps),max( events(i3).timesteps));
    events(i3).duration = max( events(i3).timesteps) - min(events(i3).timesteps);
end

% filter events below the threshold
fprintf('%2d events fall below %2dmm threshold -> removed \n%2d events remaining\n\n',sum([events.sum] > event_threshold),event_threshold,numel(events)-sum([events.sum] > event_threshold))

events = events([events.sum] > event_threshold);
num_events = numel(events);
[~,ind] = sort([events.sum],'descend');

for i3 = 1:num_events
    events(ind(i3)).rank = i3;
end

events = events(ind);
disp(head(struct2table(events)))
end
