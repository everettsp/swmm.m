function  insert_zoombox(fh,zXLim,zYLim,normSz)

    if nargin < 4
        disp('zoom window normalized size not provided, using default values')
        normSz = [.25 .25];
    end

ahs = findall(fh,'type','axes'); %axes handles
    nsf = numel(ahs); %number of subfigures
    for ii = 0:(nsf-1)
        
        iii = numel(ahs)-ii;
        ah = ahs(iii);
        XLim = ah.XLim;
        YLim = ah.YLim;
%         zYLim = [40 60];
%         zXLim = [15 35];
        zoomCol = .1 * ones(3,1);

        zoomSz = [normSz(1) * ah.Position(3) normSz(2) * ah.Position(4)];
        
        %origin + width - zoom width
        zoomPos = [...
            ah.Position(1) + ah.Position(3) - zoomSz(1),...
            ah.Position(2) + ah.Position(4) - zoomSz(2),...
            zoomSz(1),...
            zoomSz(2)];

        %% create zoom axes handle
        zah = copyobj(ah,fh);
        zah.Position = zoomPos;

        uistack(zah, 'top')

        %add limits
        box on
        zah.Title.String = '';
        zah.XLim = zXLim;
        zah.YLim = zYLim;
        zah.XTickLabel = '';
        zah.YTickLabel = '';
        
        %% reselect original size axe and add projection area and lines
        set(fh,'CurrentAxes',ah)
        rectangle('Position',[zXLim(1) zYLim(1) zXLim(2)-zXLim(1) zYLim(2)-zYLim(1)],...
            'EdgeColor',zoomCol);
        
        line([zXLim(2) XLim(2)-normSz(1)*(XLim(2)-XLim(1))],...
            [zYLim(1) YLim(2)-(normSz(2)*(YLim(2)-YLim(1)))],...
            'color',zoomCol,'LineStyle',':',...
            'HandleVisibility','off')

        line([zXLim(2) XLim(2)-normSz(1)*(XLim(2)-XLim(1))],...
            [zYLim(2) YLim(2)],...
            'color',zoomCol,'LineStyle',':',...
            'HandleVisibility','off')
        
        % update the ahs pointers
        ahs = findall(fh,'type','axes'); %axes handles

    end
end