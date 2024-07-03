function units = dict_units(unit_temporal,unit_amplitude,perf_metric)

switch lower(perf_metric)
    case {'mae','rmse','pda','sda','rm4e','hma'}
        units = unit_amplitude;
    case {'te','pdt','sdt','hmt'}
        units = unit_temporal;
    case {'mse','msec','mcev','mseb'}
        units = [unit_amplitude '^2'];
    case {'ce','nse','nrmse','pi','aic','r','r2','r^2','kge','epochs'}
        units = 'unitless';
    otherwise
        units = '';
        disp(['ERROR:' perf_metric 'performance measure not recognized, code better'])
end
if ~strcmp(units,'') %if not unitless, add brackets
    units = ['[' units ']'];
end
end