


names_tt = {'tt16', 'tt17', 'tt18', 'tt19', 'tt21', 'tt22', 'tt27', 'tt62', 'tt68', 'tt71', 'tt79', 'tt8', 'tt80', 'tt85', 'tt92', 'tt93', 'tt94'};
names_tt = {'tt12', 'tt14', 'tt2', 'tt35', 'tt37', 'tt38', 'tt39', 'tt41', 'tt5', 'tt53', 'tt54', 'tt55', 'tt6', 'tt64', 'tt67', 'tt7', 'tt76', 'tt78', 'tt83', 'tt87', 'tt88', 'tt96', 'tt97'};

varname = 'WL';
num_ts = numel(names_tt);
clf
for i2 = 1:num_ts
    
    tt = eval(names_tt{i2});
    if ~contains(tt.Properties.VariableNames,varname)
        continue
    end
    ldx = ~isnan(tt(:,varname).Variables);
    y = i2 * ones(size(tt(:,varname)));
    plot(tt.Properties.RowTimes(ldx),y(ldx),'sq','Color','g')
    plot(tt.Properties.RowTimes(~ldx),y(~ldx),'sq','Color','r')
    
    hold on
end
yticks(1:num_ts);
yticklabels(names_tt)