function cc = perf_cc(x,y)
%% correlation coefficient
ind = ~(isnan(x) | isnan(y));
x = x(ind);
y = y(ind);
temp = corrcoef(x,y,'Rows','Complete'); 
cc = temp(2,1); 
clear temp

