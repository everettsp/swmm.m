function straight_line(ah,varargin)

par = inputParser;
addParameter(par,'horz',true)
addParameter(par,'vert',true)
addParameter(par,'x_intercept',0)
addParameter(par,'y_intercept',0)
addParameter(par,'sym','k-')

parse(par,varargin{:})
horz = par.Results.horz;
vert = par.Results.vert;
x_intercept = par.Results.x_intercept;
y_intercept = par.Results.y_intercept;
sym = par.Results.sym;

% ahs = findall(fh,'type','axes'); %axes handles

% fh = gcf;
% for iii = 1:numel(ahs)
%     set(fh,'CurrentAxes',ah);
    hold on
    
    %save limits incase they auto adjust
    xlims = ah.XLim;
    ylims = ah.YLim;
    
    if horz
        plot([-9999 9999],[y_intercept,y_intercept],sym,'HandleVisibility','off')
    end
    
    if vert
        plot([x_intercept,x_intercept],[-9999 999],sym,'HandleVisibility','off')
    end
    
    %restore limits
    ah.XLim = xlims;
    ah.YLim = ylims;
    
    
end