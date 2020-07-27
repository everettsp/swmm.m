function check_data(x,y)
ind = ~(isnan(x) | isnan(y));
if ~isnumeric(x); error('observed data is not numeric'); end
if ~isnumeric(y); error('modelled data is not numeric'); end
if numel(x(ind)) < 5; error('observed data has too few samples'); end
if numel(y(ind)) < 5; error('modelled data has too few samples'); end