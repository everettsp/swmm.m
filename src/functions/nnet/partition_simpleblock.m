function [ind_train,ind_val,ind_test] = partition_simpleblock(data_fracs,x,t)%,ynPlot)

%% get the number of t/v/t timesteps - dump roundoff to test split
idx = ~(any(isnan(x),2) | isnan(t));
n = sum(idx);


num_train = floor(n * data_fracs(1));
num_val = floor(n * data_fracs(2));
num_test = n - num_train - num_val;


ind_data = 1:n;


ind_train2 = 1:num_train;
ind_val2 = num_train + (1:num_val);
ind_test2 = num_train + num_val + (1:num_test);


ind_actual = find(idx);
ind_train = ind_actual(ind_train2);
ind_val = ind_actual(ind_val2);
ind_test = ind_actual(ind_test2);

end