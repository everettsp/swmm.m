function obj = runsim(obj,ffile_rpt)
% run a SWMM simulation
% writes temporary .BAT and .INP files
% a simulation report is saved to the default filepath (obj.rpt) or a
% location specified in model input
% if a report filename is specified, the default filepath (obj.rpt) will be changed

ffile_inp = [tempdir,'swmmm.inp'];
ffile_bat = [tempdir,'swmm.bat'];


% if no reporting file is specified, use the default located in obj
if nargin < 2
    ffile_rpt = obj.rpt;
else
    obj.rpt = ffile_rpt; % if reporting file specified, change the obj (so that the results functions know where to look)
end

[~,~,ffile_rpt_ext] = fileparts(ffile_rpt);
assert(strcmp(ffile_rpt_ext,'.rpt'),"model output file must have extension'.RPT'");


obj.write_inp(ffile_inp);

content = ['"' 'C:\Program Files (x86)\EPA SWMM 5.1.013\swmm5.exe' '" ',...
    '"',ffile_inp,'" ',...
    '"',ffile_rpt,'"'];


fid = fopen(ffile_bat,'w+');
fprintf(fid,'%s',content);
fclose(fid);

% call the .BAT file to run SWMM
sys_cmd = ['call "' ffile_bat '"' '>NUL'];
system(sys_cmd);

delete(ffile_bat);
delete(ffile_inp)

disp(['simulation complete, writing report to: ',ffile_rpt])
end