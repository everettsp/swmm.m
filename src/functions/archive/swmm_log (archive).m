function swmm_log(msg)
ffile_log = [cd,'\report\','calibration_log.txt'];
fid = fopen(ffile_log,'a+');
msg_time = char(datetime);
fprintf(fid, [msg_time,'\t\t',char(msg),'\n']);
fclose(fid);
end