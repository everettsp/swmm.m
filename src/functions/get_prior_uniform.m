function prior = get_prior_uniform(value, n , uncertainty, uncertainty_type, varargin)
% simple function makes a uniform prior distribution based on the following
% parameters:
%
% [value]            initial discrete value
% [n]                number of samples
% [uncertainty]      uni- or bi-directional uncertainty value
% [uncertainty_type] type of uncertainty (percentage, absolute, etc.)
%

par = inputParser;
addParameter(par,'constraints',false)
parse(par,varargin{:})
constraints = par.Results.constraints;


if numel(uncertainty) == 1
    uncertainty_lower = uncertainty;
    uncertainty_upper = uncertainty;
elseif numel(uncertainty) == 2
    uncertainty_lower = uncertainty(1);
    uncertainty_upper = uncertainty(2);
else
    error('relative uncertainty should have one (unidirectional) or two (upper and lower) values')
end

range = NaN(2,1);

switch uncertainty_type
    case {'percent','percentage','pc','%'}
        range(1) = value * (100 - uncertainty_lower);
        range(2) = value * (100 + uncertainty_upper);
        
    case {'fraction','frac','decimal','floating','float','f'}
        range(1) = value * (1 - uncertainty_lower);
        range(2) = value * (1 + uncertainty_upper);
        
    case {'absolute','abs'}
        range(1) = value - uncertainty_lower;
        range(2) = value + uncertainty_upper;
        
    otherwise
        error('uncertainty type not recognized among cases')
end

% constrain range to values that can exist physically, work in SWMM
if range(1) < constraints(1)
    range(1) = constraints(1);
end

if range(2) > constraints(2)
    range(2) = constraints(2);
end

prior = range(1) + (range(2) - range(1)) .* rand(n,1);

% histogram(distribution)