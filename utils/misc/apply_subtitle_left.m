function ah = apply_subtitle_left(ah,varargin)
%APPLY_SUBTITLE_LEFT Summary of this function goes here
%   Detailed explanation goes here
if nargin < 1
    ah = gca;
end


par = inputParser;
addParameter(par,'outside',true)

parse(par,varargin{:})

outside = par.Results.outside;

ah.Title.Units = 'centimeters';
ah.Title.HorizontalAlignment = 'left';
ah.Title.Position(1) = 0.1;
if ~outside
ah.Title.VerticalAlignment = 'top';
end
end

