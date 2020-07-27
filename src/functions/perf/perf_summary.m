function nnp_summary = perf_summary(cfg,perf,varargin)

par = inputParser;
addParameter(par,'filter',{})
addParameter(par,'select',{})

parse(par,varargin{:})
input_filter = par.Results.filter;
input_select = par.Results.select;

fields_perf = fieldnames(perf);

if ~isempty(input_filter)
    fields_filter = ~contains(fields_perf,input_filter);
    fields_perf = fields_perf(fields_filter);
end

if ~isempty(input_select)
    fields_select = contains(fields_perf,input_select);
    fields_perf = fields_perf(fields_select);
end

clear vars nnp_summary val_summary

nnp_summary = table();

for ii = 1:numel(perf)
    nnp_summary(ii,1) = table({cfg(ii).experiment},...
        'VariableNames',{'description'});
end


for iii = 1:numel(fields_perf)
    for ii = 1:numel(perf)
        
        if size(perf(1).(fields_perf{iii}),1) == 1
            %% FOR STANDARD, NON EVENT-BASED PEROFMRNACE MEASURES
            val_summary(ii,:) = array2table(mean(perf(ii).(fields_perf{iii})),...
                'VariableNames',fields_perf(iii));
            
        else
            %% FOR EVENT-BASED PERFORMANCE MEASURES
            num_events = numel(mean(perf(ii).(fields_perf{iii}),2));
            var_subnames = cell(1,num_events);
            for iv = 1:num_events
                var_subnames{iv} = ['event_' num2str(iv)];
            end
            
            val_temp = array2table(mean(perf(ii).(fields_perf{iii}),2)',...
                'VariableNames',var_subnames);
            
            val_summary(ii,:) = table(val_temp,'VariableNames',fields_perf(iii));
            %             nnp_summary = [nnp_summary val_summary];
            %             nnp_summary.(perf_fields{iii}) = mean(nnp(ii).(perf_fields{iii}),2);
        end
    end
    
    nnp_summary = [nnp_summary val_summary];
    clear val_summary
    
end
end

