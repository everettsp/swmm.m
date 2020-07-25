function obj = runsim(obj)
% run a SWMM simulation by writing a temporary .bat file
% simulation results are output to .rpt file in same directory as SWMM .inp
% file

    ffile_bat = [tempdir,obj.name,'.bat'];
    content = ['"' 'C:\Program Files (x86)\EPA SWMM 5.1.013\swmm5.exe' '" ',...
        '"',obj.inp,'" ',...
        '"',obj.rpt,'"'];
    fid = fopen(ffile_bat,'w+');
    fprintf(fid,'%s',content);
    fclose(fid);

    % call the .BAT file to run SWMM
    sys_cmd = ['call "' ffile_bat '"' '>NUL'];
    system(sys_cmd);
    delete(ffile_bat);
end