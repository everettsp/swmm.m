function tbl = tex_round(tbl,digits)
if nargin == 1
    digits = 3;
end

for i2 = 1:width(tbl)
    colname = char(tbl(:,i2).Properties.VariableNames);
    if all(isnumeric(tbl(:,i2).Variables))
        tbl.(colname) = compose('%.3g',(round(tbl(:,i2).Variables,digits,'significant')));
    elseif all(isdatetime(tbl(:,i2).Variables))
        tbl.(colname) = cellstr(datestr(tbl(:,i2).Variables,'dd-mmm-yy HH:MM'));
        
    end
end