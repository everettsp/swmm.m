function obj = colors(obj)
c = struct();

c.white = [1 1 1];
c.black = [0 0 0];

switch lower(obj.theme)
    case {'lassonde','york','yorku','soe'}
        %[red (york) purple red blue turquoise yellow)]
            c.red2 = [227 24 55]./255;
            c.purple = [132 0 85]./255;
            c.red = [206 21 63]./255;
            c.blue = [0 53 95]./255;
            c.green = [43 167 144]./255;
            c.yellow = [253 183 19]./255;
            
            % colour gradients
            c.rwb = colorgrad({c.red, c.white, c.blue});
            c.rpb = colorgrad({c.red, c.purple, c.blue});
            c.byg = colorgrad({c.blue, c.yellow, c.green});
            c.bgy = colorgrad({c.blue, c.green, c.yellow});
            
    case {'iwater','iw','researchgroup','khan','eldyasi'}
        %[green turquoise blue grey red(york col)]
            c.green = [0 159 68]./255;
            c.turquoise = [9 149 170]./255;
            c.blue = [4 122 179]./255;
            c.green2 = [61 74 82]./255;
            c.red2 = [227 24 55]./255;
            
            
    case {'civica','civi'}
        c.green = [187,212,48]./255;
        c.blue = [64,183,233]./255;
        c.yellow = [251,193,29]./255;
    otherwise
        
        colz = colormap(lines(10));
        c.blue = colz(1,:);
        c.orange = colz(2,:);
        c.yellow = colz(3,:);
        c.green = colz(4,:);
        c.purple = colz(5,:);
        
        
        
%         disp('using default colour scheme...')
end
obj.c = c;
end