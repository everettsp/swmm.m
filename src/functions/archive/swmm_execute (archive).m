function swmm_execute(ffile_model)
% call a batch file that runs EPASWMM.exe
% if project name is input, script will update batch file
% otherwise, existing project will be used

ffile_bat = [ffile_model '.bat'];
% call the .bat file
sys_cmd = ['call "' ffile_bat '"' '>NUL'];
system(sys_cmd);
end