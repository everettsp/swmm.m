
% events = summarize_events(ffile_parent,tt_precipitation,hours(24));

event_ranks = [2,3,5,9];
dates = [[events(event_ranks).t_start];[events(event_ranks).t_end]];

dates.Format = 'MM/dd/uuuu';
swmm_dates = dates';

dates.Format = 'HH:mm:ss';
swmm_times = dates';