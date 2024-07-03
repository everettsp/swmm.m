function datetime_array = swmm_datestr2datetime(date_array,time_array)

% make sure input is cell array or string
assert(format_correct(date_array),'date and time array inputs must be cell arrays or strings');
assert(format_correct(time_array),'date and time array inputs must be cell arrays or strings');

% if string, convert to single value cell array
date_cell_array = if_str_make_cell(date_array);
time_cell_array = if_str_make_cell(time_array);

assert(numel(date_cell_array) == numel(date_cell_array),'date and time array inputs should have the same format and same number of elements');

num_datetimes = numel(date_cell_array);

datetime_array = NaT(size(date_cell_array));
for i2 = 1:num_datetimes
    datetime_array(i2) = datetime(strjoin({date_cell_array{i2},time_cell_array{i2}},' '),'InputFormat','MM/dd/yyyy HH:mm:ss');
end

    function x_cell = if_str_make_cell(x)
        if ischar(x)
            x_cell = {x};
        else
            x_cell = x;
        end
    end

    function tf = format_correct(x)
        tf = iscell(x) | ischar(x);
    end
end