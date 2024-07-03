function [date_array,time_array] = swmm_datetime2datestr(datetime_array)

assert(isdatetime(datetime_array),'input must be datetime or datetime array')

datetime_array.Format = 'MM/dd/uuuu';
date_array = cellstr(datetime_array);

datetime_array.Format = 'HH:mm:ss';
time_array = cellstr(datetime_array);

end