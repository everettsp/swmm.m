function fix_legend(lh,varargin)


par = inputParser;
addParameter(par,'num_cols',numel(lh.String))
addParameter(par,'loc','center')
addParameter(par,'y_adjustment',0)

parse(par,varargin{:})
num_cols = par.Results.num_cols;
loc = par.Results.loc;
y_adjustment = par.Results.y_adjustment;

lh.NumColumns = num_cols;
%% add whitespace between legend entries
% for ii = 1:(numel(lh.String)-1)
%     lh.String{ii} = [lh.String{ii} '{   }'];
% end


fh = gcf;
ahs = findall(fh,'type','axes'); %axes handles

fW = fh.Position(3);
fH = fh.Position(4);

% lh = legend();
% lh = columnlegend(2,{'Observed','Predicted'});
set(lh,'units','centimeters')
lh.Position(3) = 1.2 * lh.Position(3);
lW = lh.Position(3);
lH = lh.Position(4);

nsf = size(ahs,1); %number of axis handles
if nsf == 0
    error('no axes found')
elseif nsf == 1
%     ahs(1).XLabel.Units = 'centimeters';
    
    ahs(1).XLabel.Units = 'points';
    adjustment = ahs(1).XLabel.Extent(4)/2 - ahs(1).XLabel.Margin;
    ahs(1).XLabel.VerticalAlignment = 'baseline';
    ahs(1).XLabel.Position(2) = ahs(1).XLabel.Position(2) - adjustment - 12;
    ahs(1).XLabel.Units = 'centimeters';
    abrX = ahs(1).Position(1);
    ablX = abrX;
    abrW = ahs(1).Position(3);
    lY = (ahs(1).Position(2) + ahs(1).XLabel.Extent(2));
else
    sfp = zeros(nsf,2); %subfigure positions [x,y]
    for ii = 1:nsf
        ahs(ii).Units = 'centimeters';
        sfp(ii,:) = ahs(ii).Position(1:2);
    end
    sfp = round(sfp * 5)/5; %round to nearest 0.2, since axes are not always nicely alligned...

    %% find the bottom left ax
    [~,ind] = sortrows(sfp,[2 1],{'ascend'}); %order from L->R then D->U
    ablX = ahs(ind(1)).Position(1); %position of bottom left origin (normalized)
    ablY = ahs(ind(1)).Position(2);

    %% find the bottom right ax
    [~,ind] = sortrows(sfp,[2 1],{'ascend','descend'}); %order from L->R then D->U
    abrX = ahs(ind(1)).Position(1); %position of bottom left origin (normalized)
    abrY = ahs(ind(1)).Position(2);
    abrW = ahs(ind(1)).Position(3); %position of bottom left origin (normalized)

    %% find the top right ax
    [~,ind] = sortrows(sfp,[2 1],{'descend','descend'}); %order from L->R then D->U
    % atrX = ahs(ind(1)).Position(1); %position of bottom left origin (normalized)
    atrY = ahs(ind(1)).Position(2);
    atrH = ahs(ind(1)).Position(4); %position of bottom left origin (normalized)

    %% find the ax directly below the top right ax (name ax mid)
    yDist = round((sfp(:,2) - atrY)*5)/5;
    ind0 = find((yDist ~= 0));
    [~,ind] = min(yDist(yDist ~= 0));
    plotbelowtopplotnumber = ind0(ind);
    amY = ahs(plotbelowtopplotnumber).Position(2);
    amH = ahs(plotbelowtopplotnumber).Position(4);

    %% use these coordinates to find the y margins (up and down)
    yu = fH - atrY - atrH;
    yd = atrY  - amY - yu - amH;


    footer = abrY - yd;
    lY = footer/2 - lH/2;

    if footer < lH
        error('legend heigh greater than margin provided, increase legend margin using fixMargins.m')
    end
end


switch lower(loc)
    case {'center','middle'}
        lX = fW/2 - lW/2;
    case {'l','left'}
        lX = ablX;
    case {'r','right'}
        lX = (abrX+abrW-lW);
    otherwise
        error(["legend location '" loc "' not recognized"])
end
lY = lY - y_adjustment;
set(lh,'position',[lX lY lW lH])
set(lh,'box','on')
