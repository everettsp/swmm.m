function tbl = events_summary(events)

tbl = struct2table(events);

summary_vars = {'start_date','duration_hours','total','intensity_peak','qp','class'};
summary_units = {'dd-mm-yy HHMM','hrs','mm','mm/hr','cms','-'};

tbl = tbl(:,summary_vars);
tbl.start_date.Format = 'dd-MMM-uu HH:mm';
for i2 = 1:width(tbl)
    tbl.Properties.VariableNames{i2} = [tbl.Properties.VariableNames{i2},' [',summary_units{i2},']'];
end
end