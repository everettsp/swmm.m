function [events] = events_summarize(tt_precip,interevent_period,varargin)
% script to discritize rainfall data into deperate events based on a
% minimum interevet period.

p = inputParser;
addParameter(p,'event_threshold',0,@isnumeric)
addParameter(p,'change_start',hours(0),@isduration)
addParameter(p,'change_end',hours(0),@isduration)
addParameter(p,'weights',[])
parse(p,varargin{:});

event_threshold = p.Results.event_threshold;
change_start = p.Results.change_start;
change_end = p.Results.change_end;
rg_weights = p.Results.weights;

if ~isduration(interevent_period)
    error('interevent_period must be a duration [e.g. hours(12)]')
end

fprintf('\n\n\n')
fprintf('begining statistical analysis of precipitation data\n')

if isempty(rg_weights)
    rg_weights = ones([width(tt_precip),1]);
end

tt_precip_mean = timetable(tt_precip.Variables * rg_weights,'VariableNames',{'precip'},'RowTimes',tt_precip.Properties.RowTimes);

interevent_timesteps = interevent_period / tt_precip_mean.Properties.TimeStep;

% some rainfall data has a bit of noise in it -> need to filter the noise
% before checking interevent periods
interevent_threshold = .1;

precip_clean = tt_precip_mean.Variables;
precip_clean(tt_precip_mean.Variables <= interevent_threshold) = 0;

event_tf = any(movmax(precip_clean, [interevent_timesteps,0]) ~= 0, 2);


%%

n = numel(event_tf);

% encode events with a unique numeric value
k_encoder = 0;
event_encoder = zeros(numel(tt_precip_mean.Properties.RowTimes),1);

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

% num_stations = size(tt_precip,2);
% get the subcatchment areas to calculate weighted areal rainfall
% sc = mdl.p.subcatchments;
% 
% % query the total area associated with each rg
% sc_area = zeros(num_stations,1);
% fprintf('rain gages: ')
% for i2 = 1:num_stations
%     rg_name = tt_precip.Properties.VariableNames{i2};
%     ldx = contains(strcat('rg_',sc.RainGage), rg_name);
%     if ~any(ldx)
%         fprintf('%s, not found within subcatchment, omitting from calcs\n',rg_name);
%         sc_area(i2) = 0;
%     else
%         sc_area(i2) = sum(table2array(sc(ldx,'Area')));
%     end
% end
% % fprintf(' not found within subcatchment, omitting from calcs\n')
% 
% % calculate the weighted average precipitation
% tt_precip = timetable(tt_precip.Properties.RowTimes,(tt_precip.Variables * sc_area) ./ sum(sc_area),...
%     'VariableNames',{'precip'});

tt_precip_mean(:,'intensity') = timetable(tt_precip_mean.Properties.RowTimes,tt_precip_mean.precip ./ hours(tt_precip_mean.Properties.TimeStep));
% tt_precip(:,'cumsum') = timetable(tt_precip.Properties.RowTimes,cumsum(tt_precip.precip));


num_events = max(event_encoder);
fprintf('%2d events identified based on %2dhr interevent period\n',num_events,hours(interevent_period))


events = struct();

% for each event, calculate basic statistical properties and key times
i3 = 1;
for i2 = 1:num_events
    idx = i2 == event_encoder;
    idx_temp = find(idx);

    % add/remove timesteps to start of event
    change_start_ts = (change_start / tt_precip_mean.Properties.TimeStep);
    if change_start_ts < 0
        idx(idx_temp(1:abs(change_start_ts))) = false;
    elseif change_start_ts > 0
        idx((1:change_start_ts) - idx_temp(1)) = true;
    else
    end
    
    % add/remove timesteps to end of event
    change_end_ts = (change_end / tt_precip_mean.Properties.TimeStep);
    if change_end_ts < 0
        idx(idx_temp((end-abs(change_end_ts)):end)) = false;
    elseif change_end_ts > 0
        idx((1:change_end_ts) + idx_temp(end)) = true;
    else
    end
    
    if sum(idx) ~= 0
        
%         
%     	idx = find(idx);
%         idx = (idx(1) - (3*12*24)) : idx(end);
%         idx = idx(idx > 0);
%         
        
    events(i3).id = i3;
%     events(i3).timesteps = tt_precip.Properties.RowTimes(idx);
    events(i3).idx = idx;
    events(i3).tt = tt_precip_mean(idx,:);
%     events(i3).tt = tt_precip(idx,:);
    events(i3).total = sum(tt_precip_mean(idx,'precip').Variables);
    [pp, tp] = max(tt_precip_mean(idx,'precip').Variables);
    temp = find(idx);
    tp = temp(tp);
    events(i3).tt_rg = tt_precip(idx,:);
    events(i3).intensity_peak = pp ./ hours(tt_precip_mean.Properties.TimeStep);
    events(i3).intensity_mean = mean(tt_precip_mean(idx,'precip').Variables ./ hours(tt_precip_mean.Properties.TimeStep));
    events(i3).tp_date = tt_precip_mean.Properties.RowTimes(tp);
    events(i3).tp_time = tt_precip_mean.Properties.RowTimes(tp) - events(i3).tt.Properties.RowTimes(1);
    events(i3).tp_hours = hours(events(i3).tp_time);
    events(i3).start_date = events(i3).tt.Properties.RowTimes(1);
    events(i3).end_date = events(i3).tt.Properties.RowTimes(end);
    events(i3).month = events(i3).start_date;
    events(i3).month.Format = 'MMM';
    events(i3).month_num = month(events(i3).month);    
    events(i3).date_rad = datetime2rho(events(i3).start_date);
    [events(i3).date_sine,events(i3).date_cosine] = datetime2sinecosine(events(i3).start_date);
    events(i3).month = char(events(i3).month);
    events(i3).year = events(i3).start_date;
    events(i3).year.Format = 'yyyy';
    events(i3).year = str2double(char(events(i3).year));
    events(i3).timerange = timerange(min(events(i3).tt.Properties.RowTimes),max( events(i3).tt.Properties.RowTimes));
    events(i3).duration = max( events(i3).tt.Properties.RowTimes) - min(events(i3).tt.Properties.RowTimes) - interevent_period;
    events(i3).duration_hours = hours(events(i3).duration);
    i3 = i3 + 1;
    end
end

% filter events below the threshold
fprintf('%2d events fall below %2dmm threshold -> removed \n%2d events remaining\n\n',sum([events.total] < event_threshold),event_threshold,numel(events)-sum([events.total] < event_threshold))

events = events([events.total] > event_threshold);
num_events = numel(events);


[~,ind] = sort([events.total],'descend');

for i3 = 1:num_events
    events(ind(i3)).rank = i3;
end

events = events(ind);







% plot_tt(tt_precip(:,'precip'),'Color',0.5*ones(3,1));
% for i2 = 1:numel(events)
%     plot_tt(events(i2).tt_precip(:,'precip'))
% end

% disp(head(struct2table(events)))
end
