classdef boxplot2 < handle
    %BOXPLOT2 Enhanced boxplot plots
    %
    % h = boxplot2(y)
    % h = boxplot2(y,x)
    % h = boxplot2(..., p1, v1, ...)
    %
    % I don't like the original boxplot function... it messes with axis
    % dimensions, replaces tick labels with text (even if no rotation is
    % needed), and in general hijacks the axis too much.  Plus it doesn't
    % return the handles to the plotted objects in an easy-to-use way (I can
    % never remember which row corresponds to which part of the boxplot).  This
    % version creates more light-handed boxplots, assuming that any cosmetic
    % changes (color, tick labels, line specs, etc) can be added by the user
    % afterwards if necessary.  It also allows one to create clustered
    % boxplots, similar to an unstacked bar graph.
    %
    % Input variables:
    %
    %   y:              either a ndata x nx array (as in boxplot) or nx x ny x
    %                   ndata array where nx indicates the number of
    %                   x-clusters, ny the number of boxes per cluster, and
    %                   ndata the number of points per boxplot.
    %
    %   x:              vector of x locations for each box cluster
    %
    % Optional input variables (passed as parameter/value pairs)
    %
    %   notch:          'on' or 'off' ['off']
    %
    %   orientation:    'vertical' or 'horizontal' ['vertical']
    %
    %   barwidth:       Barwidth value used to position boxes (see bar) [0.8]
    %
    %   whisker:        whisker length factor (see boxplot) [1.5]
    %
    %   axes:           axis to plot to [gca]
    %
    % Output variables:
    %
    %   h:              structure of handles to boxplot, with the following
    %                   fields:
    %                   'box':      box
    %                   'ladj':     lower adjacent value
    %                   'lwhis':    lower whisker
    %                   'med':      median
    %                   'out':      outliers
    %                   'uadj':     upper adjacent value
    %                   'uwhis':    upper whisker
    %
    
    % Copyright 2012 Kelly Kearney
    
    % Parse input
    properties
        box
        ladj
        lwhis
        med
        out
        uadj
        uwhis
        NumMembers
        NumGroups
        
    end
    
    properties (Dependent=true)
        GroupColors
        MemberColors
        Color
    end
    methods
        
        function obj = boxplot2(varargin)
            In = obj.check_inputs(varargin{:});
            
            In.notch = validatestring(In.notch, {'on', 'off'});
            In.orientation = validatestring(In.orientation, {'vertical', 'horizontal'});
            if ndims(In.y) == 2
                In.y = permute(In.y, [2 3 1]);
            end
            [nx, ny, ndata] = size(In.y);
            
            if isempty(In.x)
                In.x = 1:nx;
            end
            
            ybox = reshape(In.y, [], ndata)';
            
            % Use bar graph to get x positions
            
            figtmp = figure('visible', 'off');
            try
                hax = axes;
                hb = bar(In.x, In.y(:,:,1), In.barwidth);
                for ib = 1:length(hb)
                    if verLessThan('matlab','8.4.0')
                        xbar = get(get(hb(ib), 'children'), 'xdata');
                        xb(:,ib) = mean(xbar,1);
                    else
                        xb(:,ib) = hb(ib).XData + hb(ib).XOffset;
                    end
                end
                if verLessThan('matlab', '8.4.0')
                    boxwidth = diff(boxplot2_minmax(xbar(:,1)));
                else
                    if ny > 1
                        boxwidth = diff([hb(1:2).XOffset])*In.barwidth;
                    else
                        mindx = min(diff(In.x));
                        boxwidth = mindx .* In.barwidth;
                    end
                end
                delete(hb);
                
                boxplot(ybox, 'positions', xb(:), ...
                    'notch', In.notch, ...
                    'orientation', In.orientation, ...
                    'symbol', '+', ...
                    'widths', boxwidth, ...
                    'whisker', In.whisker);
                
                h.box   = copyobj(findall(hax, 'tag', 'Box'), In.axes);
                h.ladj  = copyobj(findall(hax, 'tag', 'Lower Adjacent Value'), In.axes);
                h.lwhis = copyobj(findall(hax, 'tag', 'Lower Whisker'), In.axes);
                h.med   = copyobj(findall(hax, 'tag', 'Median'), In.axes);
                h.out   = copyobj(findall(hax, 'tag', 'Outliers'), In.axes);
                h.uadj  = copyobj(findall(hax, 'tag', 'Upper Adjacent Value'), In.axes);
                h.uwhis = copyobj(findall(hax, 'tag', 'Upper Whisker'), In.axes);
                
                close(figtmp);
            catch ME
                close(figtmp);
                rethrow(ME);
            end
            
            h = structfun(@(x) reshape(flipud(x), ny, nx), h, 'uni', 0);
            
            obj.box   = h.box;
            obj.ladj  = h.ladj;
            obj.lwhis = h.lwhis;
            obj.med   = h.med;
            obj.out   = h.out;
            obj.uadj  = h.uadj;
            obj.uwhis = h.uwhis;
            
            obj.NumGroups = nx;
            obj.NumMembers = ny;
            
            if not(isempty(In.MemberColors))
                obj.MemberColors = In.MemberColors;
            end
            
            if not(isempty(In.GroupColors))
                obj.GroupColors = In.GroupColors;
            end
            
        end
        
        
        function set.MemberColors(obj, Colors)
            assert(size(Colors,1) >= obj.NumMembers,'number of colours provided << number of group members')
            for i2 = 1:obj.NumMembers
                for lh = {'box','ladj','lwhis','med','out','uadj','uwhis'}
                    set(obj.(char(lh))(i2,:),'color',Colors(i2,:));
                    set(obj.(char(lh))(i2,:),'markeredgecolor',Colors(i2,:));
                end
            end
        end
        
        function Colors = get.MemberColors(obj)
            Colors = NaN(obj.NumMembers,3);
            for i2 = 1:obj.NumMembers
                Colors(i2,:) = obj.box(i2,1).Color;
            end
        end
        
        function set.GroupColors(obj, Colors)
            assert(size(Colors,1) >= obj.NumGroups,'number of colours provided << number of group members')
            for i2 = 1:obj.NumGroups
                for lh = {'box','ladj','lwhis','med','out','uadj','uwhis'}
                    set(obj.(char(lh))(:,i2),'color',Colors(i2,:));
                    set(obj.(char(lh))(:,i2),'markeredgecolor',Colors(i2,:));
                end
            end
        end
        
        function Colors = get.GroupColors(obj)
            Colors = NaN(obj.NumGroups,3);
            for i2 = 1:obj.NumGroups
                Colors(i2,:) = obj.box(i2,1).Color;
            end
        end
        
        function set.Color(obj, Color)
            for lh = {'box','ladj','lwhis','med','out','uadj','uwhis'}
                set(obj.(char(lh)),'color',Color);
                set(obj.(char(lh)),'markeredgecolor',Color);
            end
        end
        
        function Color = get.Color(obj)
            for i2 = 1:obj.NumMembers
                Color = obj.box.Color;
            end
        end
        
        
        function obj = LineProp(obj,LineParam,LineVal)
            for lh = {'box','ladj','lwhis','med','out','uadj','uwhis'}
                set(obj.(char(lh)),LineParam,LineVal);
            end
        end
    end
    
    methods (Access=private)
        function In = check_inputs(obj, varargin)
            
            p = inputParser;
            p.addRequired('y', @isnumeric);
            p.addOptional('x', [], @isnumeric);
            p.addParamValue('notch', 'off', @ischar);
            p.addParamValue('orientation', 'vertical', @ischar);
            p.addParamValue('axes', gca, @(x) isscalar(x) && ishandle(x) && strcmp(get(x,'type'),'axes'));
            p.addParamValue('barwidth', 0.8, @(x) isscalar(x) && x > 0 && x <= 1);
            % p.addParamValue('boxwidth', [], @(x) isscalar(x));
            p.addParamValue('whisker', 1.5, @(x) isscalar(x));
	
            iscolor = @(x) (isnumeric(x) & size(x,2) == 3);
            p.addParameter('GroupColors', [], iscolor);
            p.addParameter('MemberColors', [], iscolor);
            p.addParameter('Color', [], iscolor);
            p.parse(varargin{:});
            
            In = p.Results;
            
        end
    end
    
    
end