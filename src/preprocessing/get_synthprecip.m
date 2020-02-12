function tt_event = get_synthprecip(total_precip)

if nargin < 1
    total_precip = 100;
    fprintf('total precip. not provided, using default value of %dmm\n',total_precip)
end

scs_type = 'typeII';
start_date = datetime(2000,1,1);

ffilename = 'data/precipitation_synthetic/scs_24hr.xlsx';
opts = detectImportOptions(ffilename);
scs_events = readtable(ffilename,opts);

tt_scs = timetable(scs_events.time * hours(1), scs_events(:,scs_type).Variables, 'VariableName',{scs_type});
tt_scs((2:end),:).Variables = diff(tt_scs(:,:).Variables);
tt_scs(1,:).Variables = 0;

tt_event = tt_scs;
tt_event.Variables = total_precip * tt_scs.Variables;
tt_event.Properties.RowTimes = tt_event.Properties.RowTimes + start_date;
tt_event.Properties.VariableNames = {'rg_1'};
% tt_event = retime(tt_event,'regular','linear','timestep',minutes(5));
end