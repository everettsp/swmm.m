function tts = eval(obj,event,element_queries)
    obj = obj.use_hsf(event.ffile_hs);
    obj = obj.use_rff(event.ffile_rf);
    
    obj.p.options.START_DATE = event.start_date;
    obj.p.options.REPORT_START_DATE = event.start_date;
    obj.p.options.END_DATE = event.end_date;
    
    obj.runsim;
    
    if nargin < 3
        tts = obj.results_tt;
    else
        tts = obj.results_tt(element_queries);
    end
    
end