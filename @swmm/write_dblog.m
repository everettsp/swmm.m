function write_dblog(obj)
    ffile_dblog = [obj.dir_results,'log.txt'];
    
    % write content to file
    fid = fopen(ffile_dblog, 'w+');
    for i2 = 1:numel(obj.debug_log)
        fprintf(fid,'%s\n',obj.debug_log{i2,:});
    end
    fclose(fid);
    
end