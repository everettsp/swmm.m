function ah = apply_trimticks(ah,varargin)
%trim the outer tick labels for more compact subplots
% optional inputs x and y if you only want to trim one axis

par = inputParser;
addParameter(par,'x',true)
addParameter(par,'y',true)

parse(par,varargin{:})

trim_x = par.Results.x;
trim_y = par.Results.y;

if nargin < 1
    ah = gca;
end

if trim_x
    ah.XTickLabels{1} = '';
    ah.XTickLabels{end} = '';
end
if trim_y
    ah.YTickLabels{1} = '';
    ah.YTickLabels{end} = '';
end
end

