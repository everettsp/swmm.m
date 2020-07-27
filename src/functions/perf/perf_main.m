for partition = {'all'}%'cal','test'}
    clear nnp
    clear pr
    
    perf = struct();
    pr = struct();
    
    for i2 = 1:numel(nnc)
        vms = true;
        [perf(i2),pr(i2)] = perf_exe(cfg(i2),dat(i2),'partition',char(partition),...
            'pd',vms,'sd',vms,'hm',vms);
    end
    
    save([path_save 'performance_' char(partition) '-dataset.mat'],'nnp','pr')
    perf_table = perf_summary(cfg,perf,'filter',{'tIds','yIds'});
    filename = [char(partition) '_summary.xlsx'];
    writetable(splitvars(perf_table),[path_save filename]);
end