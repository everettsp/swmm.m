%%
path_root = 'C:\Users\everett\Google Drive\02_phd\00_research\projects_main\swmm_calibration\';
path_data = [path_root 'data\raw\'];
file_precip = [path_data '14MileCreekDRMT' '.csv'];
opts = detectImportOptions(file_precip); % preview(file_precip,opts)
data = readtable(file_precip,opts);
data.Properties.VariableNames = {'date','time','precip'};

tt = timetable(data.date + data.time,data.precip,'VariableNames',{'rg_1'});
tt.Properties.VariableDescriptions = {'precipitation'};
tt.Properties.VariableUnits = {'mm'};
plot(tt.Time,tt.rg_1)

%%


file_flow = [path_data '14MileCreekFlow' '.csv'];
opts = detectImportOptions(file_flow); % preview(file_precip,opts)
data = readtable(file_flow,opts);
data.Properties.VariableNames = {'datetime','flow'};

tt = timetable(data.datetime,data.flow,'VariableNames',{'flow'});
tt.Properties.VariableDescriptions = {'flow at 14 mi creek outlet (HYDAT: 02HB027) (J1816.580, EPASWMM)'};
tt.Properties.VariableUnits = {'cms'};
plot(tt.Time,tt.flow)


%%

