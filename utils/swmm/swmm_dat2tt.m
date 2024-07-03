function tt = swmm_dat2tt(ffilename)
% writes a .dat raingauge file based on a filename (with full path)
% and a timetable
% raingauge ID must be specified by timetable variable name

% temp = load(path_tt);
tt = timetable();

[filepath,name,ext] = fileparts(ffilename);
assert(strcmp(ext,'.dat'))

fid = fopen(ffilename);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);
content = content_cell{1};
clear content_cell
idx = ~contains(content,';'); 
data = content(idx);

if contains(lower(data{1}),lower("Station"))
    data_start = 2;
else
    data_start = 1;
end

for i2 = data_start:size(data,1)
    data_str = data{i2};
    data_parsed = strsplit(data_str,'\t');
    timeval = datetime(strjoin(data_parsed(2:6),'-'),'InputFormat','yyyy-MM-dd-HH-mm');
%     id = ['rg_',data_parsed{1}];
    id = data_parsed{1};
    val = str2double(data_parsed{7});
    tt(timeval,id) = table(val);
end

end