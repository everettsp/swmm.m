function [tt_inp, tt_obs, tt_cal] = prep_io(description,lead_timesteps,max_lag)
load('C:\Users\everett\Google Drive\02_phd\00_projects_major\02_swmm_calibration\results\cal_event3_good\continuous_uncal.mat');
load('C:\Users\everett\Google Drive\02_phd\00_projects_major\02_swmm_calibration\results\cal_event3_good\continuous_cal.mat');

tt_precip_mean = timetable(tt_event.Properties.RowTimes,mean(tt_event.Variables,2));

tt_precip_mean.Properties.VariableNames = {'precip_radar'};
tt_obs.Properties.VariableNames = {'flow_obs'};
tt_cal.Properties.VariableNames = {'flow_swmm'};

rt = tt_cal.Properties.RowTimes;
switch lower(description)
    case {'swmm','hybrid','hm'}
        tt_inp_unlagged = [tt_obs(rt,:), tt_precip_mean(rt,:), tt_cal(rt,:)];
    case {'ddm','data-driven','data','ann'}
        tt_inp_unlagged = [tt_obs(rt,:), tt_precip_mean(rt,:)];%, tt_cal(rt,:)];
    otherwise
        error("input description not recognized, try 'hybrid' or 'ddm'")
end

tt_inp = timetable(rt);

num_inp_unlagged = size(tt_inp_unlagged,2);
for i3 = 0:max_lag
    
    % if the lag is smaller than the lead time, don't lag the observed values
    % since the observed flow is always the first, turn it off while lag
    % time is too small
    idx = true(num_inp_unlagged,1);
    if i3 < lead_timesteps
        idx(1) = false;
    end
    
    tt_temp = lag(tt_inp_unlagged(:,idx),i3);
    for i4 = 1:numel(tt_temp.Properties.VariableNames)
        tt_temp.Properties.VariableNames{i4} = [tt_inp_unlagged(:,idx).Properties.VariableNames{i4} '_' num2str(i3)];
    end
    tt_inp = [tt_inp, tt_temp];
    clear tt_temp;
end
end