function [idx_train,idx_val,idx_test] = partition_kfcv2(tt_inp,num_folds,i2)%,ynPlot)
%% this code isn't pretty, but it's good enough, max 2 timestep roundoff error

% if nargin < 4; i = 1; end

range_start = tt_inp.Properties.RowTimes(1);

% fold_len = 2;
% fold_num = 5;

fold_len = numel(tt_inp.Properties.RowTimes) / num_folds;

start_test = datetime(datestr(addtodate((range_start),fold_len * mod((i2 - 1),fold_num),'month')));
end_test = datetime(datestr(addtodate(datenum(start_testdatenum),fold_len,'month')));

start_val = datetime(datestr(addtodate(datenum(range_start),fold_len * mod((i2 - 2),fold_num),'month')));
end_val = datetime(datestr(addtodate(datenum(start_val),fold_len,'month')));

ldx_test = tt_inp.Properties.RowTimes >= start_test & tt_inp.Properties.RowTimes < end_test;
ldx_val = tt_inp.Properties.RowTimes >= start_val & tt_inp.Properties.RowTimes < end_val;
ldx_train = ~(ldx_test | ldx_val);

idx_train = find(ldx_train);
idx_val = find(ldx_val);
idx_test = find(ldx_test);

end