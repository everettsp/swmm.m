function y = cell2num(x)
y = x;


somenumeric = find(~isnan(str2double(x(1,:))));

allnumeric = all(~isnan(str2double(x(:,somenumeric))),1);
y(:,somenumeric(allnumeric)) = num2cell(str2double((x(:,somenumeric(allnumeric)))));

end