function obj = enumerate(obj, varargin)
% enumerates subplots based on some functions
% currently supports 4 positions
par = inputParser;
addParameter(par,'format_function',@(x) ['(',alphabet(x,'lower'),')']) % subplot number to text
addParameter(par,'offset',0.02) % relative factor
addParameter(par,'location','northwest')
addParameter(par,'textargs',{})

parse(par,varargin{:})

format_function = par.Results.format_function;
offset = par.Results.offset;
location = par.Results.location;
textargs = par.Results.textargs;

ind = reshape(obj.posmat',[1,numel(obj.ahs)]);
for i2 = 1:numel(obj.ahs)
    sp_id = ind(i2);
    set(obj.fh, 'CurrentAxes', obj.ahs(sp_id))
    %     obj.ahs(sp_id).Title.String = format_function(i2);
    ah = gca;
    p = 90;
    x_range = ah.XLim(2) - ah.XLim(1);
    y_range = ah.YLim(2) - ah.YLim(1);
    
    
    if contains(location,'north')
        y_loc = ah.YLim(2) - offset * y_range;
        va = 'top';
    elseif contains(location,'south')
        y_loc = ah.YLim(1) + offset * y_range;
        va = 'bottom';
    else
        error('location must contain north or south');
    end
    
    if contains(location,'west')
        x_loc = ah.XLim(1) + offset * x_range;
        ha = 'left';
    elseif contains(location,'east')
        x_loc = ah.XLim(2) - offset * x_range;
        ha = 'right';
    else
        error('location must contain west or east');
    end
    
    
    text(x_loc,y_loc,format_function(i2),'HorizontalAlignment',ha,'VerticalAlignment',va,textargs{:})
end


end