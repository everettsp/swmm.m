function [ah, hh] = plot_bp(domain,data,varargin)
% plot uncertainty envelope
% wrapper for plot() that adds an uncertainty envelope around the med or
% mean


% if 'data' input is a string, no domain = data, data = varargin{}
if exist('data','var') && ischar(data)
    varargin{end+1} = '';
    varargin(2:(end)) = varargin(1:(end-1));
    varargin{1} = data;
    has_xvals = false;
    data = domain;
    
% otherwise, if it exists and isn't a string, domain exists
elseif exist('data','var')
    has_xvals = true;
    
% if 'domain' is only function input...
else
    has_xvals = false;
    data = domain;
    clear domain
end

% if there's no x-values specified, make 1:n
if ~has_xvals
    n = size(data,1);
    domain = 1:n;
end

% ensure column-wise samples
if size(domain,1) == 1
    domain = domain';
end

if ~any(numel(domain) == size(data)) %if number of x vals not equal to either dimension, error
    error('x dimensions are not consistent with data dimensions')
elseif find(numel(domain) == size(data)) == 2    %if number of samples == number of columns, transpose
    data = data';
end

hh = boxplot2(data,domain,varargin{:});
ah = gca;
end
