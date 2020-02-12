


path_rainfall = 'C:\Users\everett\Hydrometric\YUData\';
list_files = dir(path_rainfall);
list_files = list_files([list_files.isdir] == 0);
num_files = numel(list_files);


for i2 = 1:num_files
    ffilename = [path_rainfall list_files(i2).name];
    opts = detectImportOptions(ffilename,'Delimiter',','); % preview(file_precip,opts)
    data = readtable(ffilename,opts);
    data = data(:,[3 1 2 4]);
    data.TimeStamp = datetime(data.TimeStamp,...
        'InputFormat','yyyy-MM-dd HH:mm:ss.SSSSSSS)% Z','TimeZone','America/New_York');
    
    name_subcatchment = list_files(i2).name;
    name_subcatchment = replace(name_subcatchment,'Catchment_','');
    name_subcatchment = replace(name_subcatchment,'.csv','');
    
    idx_value = contains(data.Properties.VariableNames,'Value');
    data.Properties.VariableNames{idx_value} = name_subcatchment;
    
    tt = table2timetable(data);
    idx_value = contains(tt.Properties.VariableNames,name_subcatchment);

    if i2 == 1
        tt_precip = tt(:,idx_value);
    else
        tt_precip = synchronize(tt_precip,tt(:,idx_value));
    end
end