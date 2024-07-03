function [t,y] = get_centroid(tt)
n = width(tt);

x = nan(n,1);
y = nan(n,1);
t = datetime;
for i2 = 1:n
    [x(i2),y(i2)] = centroid(polyshape([1,(1:numel(tt.Properties.RowTimes)),numel(tt.Properties.RowTimes)],...
        [0,tt{:,i2}',0]));
    
    rt = tt.Properties.RowTimes([1,1:height(tt),height(tt)]);
    t(i2) = rt(round(x(i2)) + 1);
end
end