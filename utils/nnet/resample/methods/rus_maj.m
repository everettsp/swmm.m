function [x_rs,y_rs] = rus_maj(x,y, varargin)

par = inputParser;
addParameter(par,'p',5)
addParameter(par,'fun_binary','')
parse(par,varargin{:})

p = par.Results.p; % undersampling rate, used to calculate N
fun_binary = par.Results.fun_binary; % function to project continious data into binary
n_resample = []; % nuber of points to resample


% if y isn;t binary, project to binary
is_binary = all(y == 0 | y == 1 | isnan(y));
if is_binary
    y_binary = y;
else
    if ~isa(fun_binary, 'function_handle')
        error("'fun_binary' input must be a function with input 'y' and output 'y' in binary")
    end
    y_binary = fun_binary(y);
end

num_positive = sum(y_binary == 1);
num_negative = sum(y_binary == 0);


if isa(p,'function_handle')
    n_resample = p(num_positive);
elseif isnumeric(p)
    if p < 1 % convention should be 2 means 200% undersample meaning N/2
        % if param smaller than 1, like 0.5, fix it since otherwise it will
        % be oversampling
        p = 1/p;
    end
    
    n_resample = floor(num_negative ./ p);
    else
        error("rus_p parameter must be function handle or numeric")
end


% n = numel(y);
% ind = 1:n;

if islogical(y)
    y = double(y);
end

idx = isnan(y) | any(isnan(x),2);


x = x(~idx,:);
y = y(~idx);

ind_maj = find(y_binary == 0);
ind_min = find(y_binary == 1);

ind_rs = randsample(ind_maj,n_resample,false); % resample number of high flows

x_rs = x([ind_rs;ind_min],:);
y_rs = y([ind_rs;ind_min]);

end