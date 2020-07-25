function obj = dblog(obj,msg)

obj.debug_log{end+1} = strjoin({char(datetime),char(msg)},'\t\t');

%     if ~exist(obj.dir_report,'dir')
%         mkdir(obj.dir_report)
%     end
%     ffile_log = [obj.dir_report,'debug_log.txt'];
%     % if input message is 'clear', delete file
%     if any(strcmpi({'clear','clr','delete','new','overwrite'},(msg))) && exist(ffile_log)
%         delete(ffile_log)
%     end
%     fid = fopen(ffile_log,'a+');
%         msg_time = char(datetime);
%         disp([msg_time,'        ',char(msg)])
%         fprintf(fid, [msg_time,'\t\t',char(msg),'\n']);
% 
%     fclose(fid);
end