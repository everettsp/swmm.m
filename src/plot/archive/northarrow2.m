function nh = northarrow2(location)
%NORTHARROW2 Summary of this function goes here
%   Detailed explanation goes here
ahs  = gca;

frac = 0.9;
for i2 = 1:numel(ahs)
    ah = ahs(i2);
    
    x_span = ah.XLim(2) - ah.XLim(1);
    x_datum = ah.XLim(1);
    y_span = ah.YLim(2) - ah.YLim(1);
    y_datum = ah.YLim(1);
    
    if contains(lower(location),'north')
        y_loc = y_datum + y_span * frac;
    elseif contains(lower(location),'south')
        y_loc = y_datum + y_span * (1 - frac);
    else
        error('location must include north or south')
    end
    
    if contains(lower(location),'east')
        x_loc = x_datum + x_span * frac;
    elseif contains(lower(location),'west')
        x_loc = x_datum + x_span * (1 - frac);
    else
        error('location must include north or south')
    end
    
    nh = northarrow('latitude', x_loc, 'longitude', y_loc);
    
end

