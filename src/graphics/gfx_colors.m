function col = gfx_colors(col_name)
col = struct();

col.white = [1 1 1];
col.black = [0 0 0];

switch lower(col_name)
    case {'lassonde','york','yorku','soe'}
        %[red (york) purple red blue turquoise yellow)]
            col.red2 = [227 24 55]./255;
            col.purple = [132 0 85]./255;
            col.red = [206 21 63]./255;
            col.blue = [0 53 95]./255;
            col.green = [43 167 144]./255;
            col.yellow = [253 183 19]./255;
        
    case {'iwater','iw','researchgroup','khan','eldyasi'}
        %[green turquoise blue grey red(york col)]
            col.green = [0 159 68]./255;
            col.turquoise = [9 149 170]./255;
            col.blue = [4 122 179]./255;
            col.green2 = [61 74 82]./255;
            col.red2 = [227 24 55]./255;
        
    case {'sm','sarah'}
        %[blue orange yellow red green lightblue]
            col.blue = [44 64 161]./255;
            col.orange = [194 103 85]./255;
            col.yel = [233 166 85]./255;
            col.red = [184 49 63]./255;
            col.green = [48 72 72]./255;
            col.blue2 = [143 165 212]./255;
        
            
    case {'civica','civi'}
        col.green = [187,212,48]./255;
        col.blue = [64,183,233]./255;
        col.yellow = [251,193,29]./255;
    otherwise
        
        colz = colormap(lines(10));
        col.blue = colz(1,:);
        col.orange = colz(2,:);
        col.yellow = colz(3,:);
        col.green = colz(4,:);
        col.purple = colz(5,:);
        
        disp('using default colour scheme...')
end
end