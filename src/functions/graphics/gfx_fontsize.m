function [font_width,font_height] = gfx_fontsize(cs,fs,fn,fu)
% get the width and height of a list (cells) of strings based on font size,
% name, and units. default units are centimeters.

if nargin < 4
    fu = 'centimeters';
end

if ~iscell(cs)
    cs = {cs};
end

num_str = numel(cs);
cs_dims = NaN(num_str,2);

for i2 = 1:num_str
    figure('Name','temp_fs','NumberTitle','off')
    temp = uicontrol('Style', 'text','String',cs{i2},'FontSize',fs,'FontName',fn,'Units',fu);
    dims = get(temp,'Extent');
    cs_dims(i2,:) = dims(3:4);
    clear vars temp dims
    close('temp_fs')
end

font_width = max(cs_dims(:,1));
font_height = max(cs_dims(:,2));
    
end

