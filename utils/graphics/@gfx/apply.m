function fh = apply(obj,width_height,varargin)
% resize and fix margins
% blank space for objects such as legends
% all length values are in [cm] so as to fascilitate matching document
% processing page layout margins

% frac_wdt / frac_hgt are the fractions of the width and height of the page size determined by the 'style' parameter
% marg_ are the four margins around each plot, required for tick and axes labels
% uniform margins are applied to all subplots
% right, left, bottom, top [length]: adds blank space to the respective side of the figure
% legend [binary]: display legend
% leg_placement [bottom-mid, northeast, etc.]: options are specified by cases in script
% style [ppt, word, pub]: sets the font, font size, and figure size
%
% notes: it's a lot easier having the legend placement in this script, since it
% can be placed at the midpoint of the blank space parameter above, this
% midpoint value is not easy to automatically determine for figures without
% subplots... (legacy fix_legend() script is no longer used)

par = inputParser;
addParameter(par,'fh',gcf)
addParameter(par,'margins','compact')
addParameter(par,'frame',[1,0.2,1,0.2])
addParameter(par,'right',0)
addParameter(par,'left',0)
addParameter(par,'bottom',0)
addParameter(par,'top',0)
addParameter(par,'leg_pos',false)
addParameter(par,'ylabel_placement','mid')
addParameter(par,'xlabel_placement','mid')

addParameter(par,'xlabel_single',false)
addParameter(par,'ylabel_single',false)

addParameter(par,'xlabel_adjust',[0,0])
addParameter(par,'ylabel_adjust',[0,0])

addParameter(par,'font_case','unchanged')
addParameter(par,'font_abbrev',false)
addParameter(par,'make_copy',false)

% addParameter(par,'font_name','Arial')
% addParameter(par,'font_size',12)
% addParameter(par,'style','word')
addParameter(par,'make_square',false)

addParameter(par,'match_x',false)
addParameter(par,'match_y',false)


parse(par,varargin{:})

fh = par.Results.fh;
right = par.Results.right;
left = par.Results.left;
bottom = par.Results.bottom;
top = par.Results.top;
marg = par.Results.margins;
frame = par.Results.frame;
leg_pos = par.Results.leg_pos;


ylabel_placement = par.Results.ylabel_placement;
xlabel_placement = par.Results.xlabel_placement;
font_abbrev = par.Results.font_abbrev;
font_case = par.Results.font_case;
% font_name = par.Results.font_name;
% font_size = par.Results.font_size;
% style = par.Results.style;
make_square = par.Results.make_square;
match_x = par.Results.match_x;
match_y = par.Results.match_y;
make_copy = par.Results.make_copy;

xlabel_single = par.Results.xlabel_single;
ylabel_single = par.Results.ylabel_single;

xlabel_adjust = par.Results.xlabel_adjust;
ylabel_adjust = par.Results.ylabel_adjust;


if make_copy
    fh0 = fh;
    fh = figure;
    a2 = copyobj(fh0,fh);
end



set(fh, 'Color', 'w');
set(fh,'Units','Centimeters');
set(fh,'PaperUnits','Centimeters');

%% get style properties

page_width = obj.pgw;
page_height = obj.pgh;
font_size = obj.fontsize;
font_name = obj.font;


% switch lower(style)
%     case {'ppt','ppt_body'}
%         page_width = 21.91;%33.867; %<-full screen%29.21; %figure width (16:9)
%         page_height = 12.09;%19.05; %<-full sreen %12.09; %figure height (16:9)
%         font_size = 14; %figure text size
%         font_name = 'SansSerif'; %figure font
%
%     case {'pptw_fs','pptw_fullscreen'} %slightly different margins for full screen (no title, logos, etc.)
%         page_width = 33.867;%33.867; %<-full screen%29.21; %figure width (16:9)
%         page_height = 19.05;%19.05; %<-full sreen %12.09; %figure height (16:9)
%         font_size = 14; %figure text size
%         font_name = 'Source Sans Pro'; %figure font
%
%     case {'pptw','pptw_body','ppt_wide'} %slightly different margins for full screen (no title, logos, etc.)
%         page_width = 29.21; %figure width (16:9)
%         page_height = 12.09; %figure height (16:9)
%         font_size = 14; %figure text size
%         font_name = 'Source Sans Pro'; %figure font
%
%     case {'publisher','poster','pub'}
%         page_width = 47.64 - 0.64;
%         page_height = 47.64 - 0.64;
%         font_size = 18;
%         font_name = 'Source Sans Pro'; %figure font
%
%     case {'word','doc','docx'}
%         page_width = 21.59 - 2*2.54;
%         page_height = 27.94 - 2*2.54;
%         font_size = 12; %text header
%         font_name = 'Times New Roman';
%
%     otherwise
%         error("style not recognized, try 'ppt_wide' or 'word'");
% end

%% grab figure handle
% set the font size and name for the entire figure
% fh = gcf;

set(findall(fh,'-property','FontSize'),'FontSize',font_size);
set(findall(fh,'-property','FontName'),'FontName',font_name);

%% apply formatting to strings within figure
%  cycleFigStrings will pass each string in the figure through a function
%  findall, which is used for the font size and name, is not sufficient -
%  hence the function below

switch lower(font_case)
    case {'lower','low'}
        fun_font = @(x) lower(x);
    case {'upper','up'}
        fun_font = @(x) upper(x);
    otherwise
        %do nothing
        fun_font = @(x) x;
end

% cycle_figstrings is function that applied anon. function to all text
% strings in figure
cycle_figstrings(fh,fun_font)

% font_abbrev is abbreviation pairings (i.e., {'water level','WL'})
% first make sure it is formatted correctly (cell matrix w 2 cols)
if iscell(font_abbrev) && size(font_abbrev,2) ~= 2
    error('font abbrev input incorrect: should have two columns for abbreviation combinations')
end

% apply abbreviations
if iscell(font_abbrev)
    fun_abbrev = @(str_long) abbrev(str_long,font_abbrev(:,1),font_abbrev(:,2));
    cycle_figstrings(fh,fun_abbrev)
end

%%
% get the figure dimensions, a fraction of the page dimensions

% if fig size is equal or below one, take as fraction of page dims
if all(width_height <= 1)
    fig_width = page_width * width_height(1);
    fig_height = page_height * width_height(2);
else
    fig_width = width_height(1);
    fig_height = width_height(2);
end


set(fh,'Position',[0 0 fig_width fig_height]);
set(fh,'PaperSize',[fig_width fig_height]);

%% get the number of axes handles, then find the subfigure positions
%the following uses an automated approach to finding axes positions, since
%children are listed inversely to the order they are plotted.
% this approach should work if axes are not plotted Top-left->right-down,
% however ONLY works if axes are plotted in a grid, does not hWandle cases
% such as subplot(2,2,1.5)

ahs = findall(fh,'type','axes'); %axes handles

for i2 = 1:numel(fh.Children)
    try
    fh.Children(i2).Units = 'centimeters';
    end
end
for i2 = 1:numel(ahs)
    ahs(i2).Title.Units = 'centimeters';
    for i3 = 1:numel(ahs(i2).YAxis)
        ahs(i2).YAxis(i3).Label.Units = 'centimeters';
    end
    for i3 = 1:numel(ahs(i2).XAxis)
        ahs(i2).XAxis(i3).Label.Units = 'centimeters';
    end
end

ahs = obj.ahs;
n_rows = obj.nrows;
n_cols = obj.ncols;
pos_mat = obj.posmat;



%% if numeric axis margins are provided, parse
% otherwise, detect margins based on font size
[font_width,font_height] = gfx_fontsize(ahs(1).YAxis(1).Label.String,ahs(1).YAxis(1).Label.FontSize,ahs(1).YAxis(1).Label.FontName,'centimeters');

if numel(marg) == 1 && isnumeric(marg)
    m_left = marg;
    m_right = marg;
    m_down = marg;
    m_up  = marg;
elseif numel(marg) == 4 && isnumeric(marg)
    m_left = marg(1);
    m_right = marg(2);
    m_down = marg(3);
    m_up  = marg(4);
    
% if margins not specified, or margin descriptor provided, try to
% auto-detect margins based on maximum distances beweeen subplots/labels
else
    m_left_all = NaN(n_rows,1);
    for i2 = 1:n_rows
        j2 = pos_mat(i2,1);
        [yal,~] = get_yaxis_loc(ahs(j2));
        m_left_all(i2) = abs(ahs(j2).YAxis(yal).Label.Position(1)) + font_height;
    end
    m_left = max(m_left_all);
    clear m_left_all
    
    m_up_all = NaN(n_cols,1);
    for i2 = 1:n_cols
        j2 = pos_mat(1,i2);
        
        if ~isempty(ahs(j2).Title.String) % if there's a title, margin is from top of plot to top of title
            [font_width,font_height] = gfx_fontsize(ahs(j2).Title.String,ahs(j2).Title.FontSize,ahs(j2).Title.FontName,'centimeters');
            m_up_all(i2) = ahs(j2).Title.Position(2) - ahs(j2).Position(4) + font_height;
            
        else % if there's no title, margin is half the font height
            try
                [font_width,font_height] = get_fontsize(ahs(j2).YTickLabels(end),ahs(j2).YLabel.FontSize,ahs(j2).YLabel.FontName,'centimeters');
            catch
                font_height = 0;
            end
            m_up_all(i2) = font_height/2;
        end
    end
    m_up = max(m_up_all);
    clear m_up_all font_width font_height
    
    m_down_all = NaN(n_cols,1);
    for i2 = 1:n_cols
        j2 = pos_mat(n_rows,i2);
        [font_width,font_height] = gfx_fontsize(ahs(j2).XLabel.String,ahs(j2).XLabel.FontSize,ahs(j2).XLabel.FontName,'centimeters');
        m_down_all(i2) = abs(ahs(j2).XLabel.Position(2)) + font_height;
    end
    m_down = max(m_down_all);
    clear m_down_all
    
    m_right_all = NaN(n_cols,1);
    for i2 = 1:n_rows
        j2 = pos_mat(i2,n_cols);
        
        % if there's a second y-axis, use that to determine right margin
        [~,yar] = get_yaxis_loc(ahs(j2));
        if ~isnan(yar)
            [font_width,font_height] = gfx_fontsize(ahs(j2).YAxis(yar).Label.String,ahs(j2).YAxis(yar).Label.FontSize,ahs(j2).YAxis(yar).Label.FontName,'centimeters');
            m_right_all(i2,2) = ahs(j2).YAxis(yar).Label.Position(1) - ahs(j2).Position(3) + font_height;
        end
        
        try
            [font_width,font_height] = gfx_fontsize(ahs(j2).XTickLabels(end),ahs(j2).XLabel.FontSize,ahs(j2).XLabel.FontName,'centimeters');
        catch
            font_width = 0;
        end
        m_right_all(i2,1) = font_width/2;
    end
    m_right = max(max(m_right_all));
    clear m_right_all
    
    % multiplier for increasing margins
    switch lower(marg)
        case {'space','comfortable','comf','low'}
            m_factor = 1.2;
            m_buffer = 0.2;
        case {'compact','tight','comp','dense'}
            m_factor = 1;
            m_buffer = 0.01;
        case {'loose','sparse','relaxed','relax'}
            m_factor = 1.3;
            m_buffer = 0.4;
        otherwise
            error("spacing specification not recognized, try 'compact'")
    end
    
    m_left = m_left * m_factor + m_buffer;
    m_right = m_right * m_factor + m_buffer;
    m_down = m_down * m_factor + m_buffer;
    m_up  = m_up  * m_factor + m_buffer;
    
end

if numel(frame) == 4 && isnumeric(frame)
    left = frame(1);
    right = frame(2);
    bottom = frame(3);
    top  = frame(4);
elseif numel(frame) == 1 && isnumeric(frame)
    left = frame; right = frame; bottom = frame; top = frame;
else
    error('value for frame not recognised; only 1 value or 4 value (L,R,D,U) arrays supported')
end

%% calculate uniform dimensions for the axes
ax_height = fig_height - bottom - top;
ax_width = fig_width - right - left;
[n_rows,n_cols] = size(pos_mat);
box_height = ax_height/n_rows - m_up - m_down;
box_width = ax_width/n_cols - m_left - m_right;

% if make sqare, make the box heights the same as the widths
if make_square
    box_height_change = box_width - box_height;
    fig_height = fig_height + box_height_change .* n_rows;
    set(fh,'Position',[3 3 fig_width fig_height]);
    set(fh,'PaperSize',[fig_width fig_height]);
    box_height = box_height + box_height_change;
    ax_height = fig_height - bottom - top;
end

if box_height < 0
    error('calculated subplot height is too small, consider englarigng the figure')
end

if box_width < 0
    error('calculated subplot width is too small, consider englarigng the figure')
end

%% resize the boxes
% resize the axis based on the margins determined above...
% the margin auto-detection considers labels, but sometimes MATLAB will
% fuck up label positions when resizing - therefore label spacing wrt the
% axes are saved and indexed prior to resizing.

% yal = nan(numel(ahs),2);
% xal = nan(2,numel(ahs));

yal = obj.y2ax;
xal = obj.x2ax;

%
% for i2 = 1:numel(ahs)
%     for i4 = 1:numel(ahs(i2).YAxis)
%         if ahs(i2).YAxis(i4).Label.Position(1) < 0 % if ax label to the left of origin, store
%             yal(i2,1) = i4;
%         else
%             yal(i2,2) = i4;
%         end
%     end
%
%     for i4 = 1:numel(ahs(i2).XAxis)
%         if ahs(i2).XAxis(i4).Label.Position(2) < 0 % if ax label to the left of origin, store
%             xal(2,i2) = i4;
%         else
%             xal(1,i2) = i4;
%         end
%     end
% end
%




n = 1;
for ii = 1:n_rows
    for iii = 1:n_cols
        
        %save axis label positions prior to resizing...
        xlp = NaN(numel(ahs(n).XAxis),3);
        ylp = NaN(numel(ahs(n).YAxis),3);
        
        for i4 = 1:numel(ahs(n).YAxis)
            
            ylp(i4,:) = ahs(n).YAxis(i4).Label.Position; % index the y-label positions
            % calculate the y-label spacing...
            if (yal(n,2) == i4) % if it's on the right, subtract plot width
                yls(i4) = ylp(i4,1) - ahs(n).Position(3);
            else %otherwise, just use the negative value
                yls(i4) = ylp(i4,1);
            end
        end
        
        for i4 = 1:numel(ahs(n).XAxis)
            xlp(i4,:) = ahs(n).XAxis(i4).Label.Position;
        end
        
        set(ahs(n),'Units','Centimeters');
        set(ahs(n),'Position',...
            [left + m_left + ax_width*(iii-1)/n_cols,...
            bottom + m_down + ax_height*(ii-1)/n_rows,...
            box_width,...
            box_height])
        
        % reposition axis labels in case matlab fucking auto-moved them...
        
        % reposition the y-labels
        for i4 = 1:numel(ahs(n).YAxis)
            %             ahs(n).YAxis(i4).Label.Position(1) = ylp(i4,1);
            %
            
            
            %tick font dims
            [font_width,font_height] = gfx_fontsize(ahs(1).YAxis(1).TickLabel,ahs(1).YAxis(1).Label.FontSize,ahs(1).YAxis(1).Label.FontName,'centimeters');
            
            switch lower(ylabel_placement)
                case {'m','mid','middle','c','center'}
                    ahs(n).YAxis(i4).Label.HorizontalAlignment = 'center';
                    ahs(n).YAxis(i4).Label.VerticalAlignment = 'middle';
                    ahs(n).YAxis(i4).Label.Position(2) = box_height/2;
                    if (yal(n,1) == i4) % if left ax
                        ahs(n).YAxis(i4).Label.Position(1) = -(left + m_left)./4 - font_width;
                    else
                        ahs(n).YAxis(i4).Label.Position(1) = (left + m_left)./4 + font_width + box_width;
                    end
                    %                     ahs(n).YAxis(i4).Label.Position(1) = ylp(1)
                case {'b','bottom','d','down','s','south'}
                    ahs(n).YAxis(i4).Label.HorizontalAlignment = 'left';
                    %                     ahs(n).YAxis(i4).Label.Position(2) = 0;
                case {'t','top','u','up','n','north'}
                    ahs(n).YAxis(i4).Label.HorizontalAlignment = 'right';
                    %                     ahs(n).YAxis(i4).Label.Position(2) = box_height;
                otherwise
                    error(["ylabel_placement '" ylabel_placement "' not recognized"])
            end
            
            if ylp(i4,1) > 0 % if it's on the right, subtract plot width
                %                 ahs(n).YAxis(i4).Label.Position(1) = yls(i4) + ylabel_adjust;
                ahs(n).YAxis(i4).Label.Position(1) = ahs(n).YAxis(i4).Label.Position(1) + ylabel_adjust(2);
            else
                %                 ahs(n).YAxis(i4).Label.Position(1) = yls(i4) - ylabel_adjust;
                ahs(n).YAxis(i4).Label.Position(1) = ahs(n).YAxis(i4).Label.Position(1) + ylabel_adjust(1);
            end
        end
        
        % repoisition the x-labels
        for i4 = 1:numel(ahs(n).XAxis)
            ahs(n).XAxis(i4).Label.Position(2) = xlp(i4,2);
            
            %tick font dims
            [font_width,font_height] = gfx_fontsize(ahs(1).XAxis(1).TickLabel,ahs(1).XAxis(1).Label.FontSize,ahs(1).XAxis(1).Label.FontName,'centimeters');
            
            switch lower(xlabel_placement)
                case {'m','mid','middle','c','center'}
                    ahs(n).XAxis(i4).Label.HorizontalAlignment = 'center';
                    ahs(n).XAxis(i4).Label.VerticalAlignment = 'middle';
                    ahs(n).XAxis(i4).Label.Position(1) = box_width/2;
                    
                    if (xal(2,n) == i4) % if left ax
                        ahs(n).XAxis(i4).Label.Position(2) = -(bottom + m_down)./4 - font_height;
                    else
                        ahs(n).XAxis(i4).Label.Position(2) = (bottom + m_down)./4 + font_height + box_height;
                    end
                case {'l','left','w','west'}
                    ahs(n).XAxis(i4).Label.HorizontalAlignment = 'left';
                    %                     ahs(n).XAxis(i4).Label.Position(1) = box_width;
                case {'r','right','e','east'}
                    ahs(n).XAxis(i4).Label.HorizontalAlignment = 'right';
                    %                     ahs(n).XAxis(i4).Label.Position(1) = 0;
                otherwise
                    error(["xlabel_placement '" xlabel_placement "' not recognized"])
            end
            
            ahs(n).XAxis(i4).Label.Position(2) = ahs(n).XAxis(i4).Label.Position(2) + xlabel_adjust(1);
            
        end
        n = n+1;
    end
end

%% add single centered y-axis label for subplots
if ylabel_single
    if numel(ahs(n_cols).YAxis) == 2 % if two axis
        if ahs(n_cols).YAxis(1).Label.Position(1) > ahs(n_cols).YAxis(1).Label.Position(2); rlidx = 1; llidx = 2; else; rlidx = 2; llidx = 1; end % get location of right axis
        yrl_xpos = ahs(n_cols).YAxis(rlidx).Label.Position(1);
        yrl_str = ahs(n_cols).YAxis(rlidx).Label.String;
        yrl_ypos = (fig_height - bottom - top - m_up - m_down) ./ 2;
    else
        llidx = 1;
        rlidx = nan;
    end
    yll_xpos = ahs(1).YAxis(llidx).Label.Position(1);
    yll_str = ahs(1).YAxis(llidx).Label.String;
    yll_ypos = (fig_height - bottom - top - m_up - m_down) ./ 2;
    
    n = 1;
    for ii = 1:n_rows
        for iii = 1:n_cols
            for i4 = 1:numel(ahs(n).YAxis)
                ahs(n).YAxis(i4).Label.String = '';
            end
            n = n + 1;
        end
        
    end
    
    ahs(1).YAxis(llidx).Label.String = yll_str;
    ahs(1).YAxis(llidx).Label.Position(1:2) = [yll_xpos,yll_ypos];
    if ~isnan(rlidx)
        ahs(n_cols).YAxis(rlidx).Label.String = yrl_str;
        ahs(n_cols).YAxis(rlidx).Label.Position(1:2) = [yrl_xpos,yrl_ypos];
    end
end




%% add single centered x-axis label for subplots
if xlabel_single
    if numel(ahs(n_cols .* n_rows).XAxis) == 2 % if two axis
        if ahs(n_cols .* n_rows).XAxis(1).Label.Position(1) > ahs(n_cols .* n_rows).XAxis(1).Label.Position(2); tlidx = 1; blidx = 2; else; tlidx = 2; blidx = 1; end % get location of right axis
        xtl_ypos = ahs(n_cols .* n_rows).XAxis(blidx).Label.Position(2);
        xtl_str = ahs(n_cols .* n_rows).XAxis(blidx).Label.String;
        xtl_xpos = (fig_width - left - right - m_left - m_right) ./ 2;
    else
        blidx = 1;
        tlidx = nan;
    end
    xbl_ypos = ahs(1).XAxis(blidx).Label.Position(2);
    xbl_str = ahs(1).XAxis(blidx).Label.String;
    xbl_xpos = (fig_width - left - right - m_left - m_right) ./ 2;
    
    n = 1;
    for ii = 1:n_rows
        for iii = 1:n_cols
            for i4 = 1:numel(ahs(n).XAxis)
                ahs(n).XAxis(i4).Label.String = '';
            end
            n = n + 1;
        end
        
    end
    
    ahs(1).XAxis(blidx).Label.String = xbl_str;
    ahs(1).XAxis(blidx).Label.Position(1:2) = [xbl_xpos,xbl_ypos];
    if ~isnan(tlidx)
        ahs(n_cols .* n_rows).XAxis(tlidx).Label.String = xtl_str;
        ahs(n_cols .* n_rows).XAxis(tlidx).Label.Position(1:2) = [xtl_xpos,xtl_ypos];
    end
end





%
%
% if ischar(fix_ylabel)
%
%     set(fh,'CurrentAxes',ahs(1))
%     ah = gca;
%     delete(ah.YLabel);
%     ah.YLabel.String = fix_ylabel;
%     ah.YLabel.VerticalAlignment = 'middle';
%     ah.YLabel.Units = 'centimeters';
%     ylabel_pos = ah.YLabel.Position;
%     ylabel_hgt = (fig_hgt - top - ah.Position(2))/2;
%
%     ylabel_xadjust = 0.25;
%     ah.YLabel.Position = ...
%         [ylabel_pos(1) - ylabel_xadjust,....
%         ylabel_hgt,...
%         ylabel_pos(3)];
% end
%
% if ischar(fix_xlabel)
%     set(fh,'CurrentAxes',ahs(1))
%     ah = gca;
%     delete(ah.XLabel);
%     ah.XLabel.String = fix_xlabel;
%     ah.XLabel.HorizontalAlignment = 'center';
%     ah.XLabel.Units = 'centimeters';
%     xlabel_pos = ah.XLabel.Position;
%     xlabel_wdt = (fig_wdt - left - right)/2 - ah.Position(1) + left;
%     xlabel_yadjust = 0;
%
%     ah.XLabel.Position = ...
%         [xlabel_wdt,...
%         xlabel_pos(2) - xlabel_yadjust,....
%         xlabel_pos(3)];
%
% end


%% add legend (not 100% tested yet, fix cases as req)
if leg_pos ~= false
    
    % delete(findall(fh,'type','Legend'));
    if isempty(findall(fh,'type','legend'))
        lh = legend;
    else
        lh = findall(fh,'type','legend');
        %         lh = legend;
    end
    lh.Units = 'centimeters';
    %     lh.Interpreter = 'none';
    k2 = 1;
    switch lower(leg_pos)
        case {'bottom-mid','bottom-right','bottom-left','bm','br','bl'}
            lh.NumColumns = numel(lh.String);
            
            while lh.Position(3) > fig_width
                lh.NumColumns = ceil(lh.NumColumns/2);
                k2 = k2 + 1; if k2 > 10; break; end
            end
        case {'top-mid','top-right','top-left','tm','tr','tl'}
            lh.NumColumns = numel(lh.String);
            
            while lh.Position(3) > fig_width
                lh.NumColumns = lh.NumColumns - 1;
                k2 = k2 + 1; if k2 > 10; break; end
            end
        case {'right-mid','right-top','right-bottom','rm','rt','rb'}
            lh.NumColumns = 1;
            
        case {'left-mid','left-top','left-bottom','lm','lt','lb'}
            lh.NumColumns = 1;
    end
    
    leg_wdt = lh.Position(3);
    leg_hgt = lh.Position(4);
    
    switch lower(leg_pos)
        case {'bottom-mid','bm'}
            leg_x = fig_width/2 - leg_wdt/2;
            %             lY = bottom/2 - lH/2;
            leg_y = 0.2;
        case {'bottom-right','br'}
            leg_x = fig_width - right - m_right - leg_wdt;
            leg_y = bottom/2 - leg_hgt/2;
            
        case {'bottom-left','bl'}
            leg_x = left + m_left;
            leg_y = bottom/2 - leg_hgt/2;
            
        case {'top-mid','tm'}
            leg_x = fig_width/2 - leg_wdt/2;
            leg_y = fig_height - top/2 - leg_hgt/2;
            
        case {'top-right','tr'}
            leg_x = fig_width - right - m_right - leg_wdt;
            leg_y = fig_height - top/2 - leg_hgt/2;
            
        case {'top-left','tl'}
            leg_x = left + m_left;
            leg_y = fig_height - top/2 - leg_hgt/2;
            
        case {'right-mid','rm'}
            leg_x = fig_width - right/2 - leg_wdt/2;
            leg_y = fig_height/2 - leg_hgt/2;
            
        case {'right-top','rt'}
            leg_x = fig_width - right/2 - leg_wdt/2;
            leg_y = fig_height - top - m_up - leg_hgt;
            
        case {'right-bottom','rb'}
            leg_x = fig_width - right/2 - leg_wdt/2;
            leg_y = bottom + m_down;
            
        case {'left-mid','lm'}
            leg_x = left/2 + leg_wdt/2;
            leg_y = fH/2 - leg_hgt/2;
            
        case {'left-top','lt'}
            leg_x = left/2 + leg_wdt/2;
            leg_y = fig_height - top - m_up - leg_hgt;
            
        case {'left-bottom','lb'}
            leg_x = left/2 + leg_wdt/2;
            leg_y = bottom + m_down;
        case {'best'}
            legend('location','best')
            leg_x = lh.Position(1);
            leg_y = lh.Position(2);
        otherwise
            error(['legend placement ' leg_pos ' not recognized'])
    end
    
    
    if any(contains({'northwest','nw','northeast','ne','southeast','se','southwest','sw','best'},leg_pos))
        legend('location',leg_pos)
    else
        %         lY = lY - 0.5 * lH;
        set(lh,'position',[leg_x leg_y leg_wdt leg_hgt])
    end
    
    set(lh,'box','on')
end


    function cycle_figstrings(fh,fun)
        % this function will iteratively select each string element
        % contained within a figure and pass it through the function 'fun'
        
        fh.Name = fun(fh.Name);
        
        %% legend
        lh_cf = findobj(fh, 'Type', 'Legend');
        for f3 = 1:numel(lh_cf)
            for f4 = 1:numel(lh_cf(f3).String)
                lh_cf(f3).String{f4} = fun(lh_cf(f3).String{f4});
            end
        end
        
        %% apply string function to each of the string objects associated with axes
        ah1 = findobj(fh, 'Type', 'Axes');
        for f3 = 1:numel(ah1)
            ah1(f3).Title.String = fun(ah1(f3).Title.String);
            ah1(f3).XLabel.String = fun(ah1(f3).XLabel.String);
            
            if ischar(ah1(f3).XTickLabel)
                ah1(f3).XTickLabel = {ah1(f3).XTickLabel};
            end
            
            if ~isempty(ah1(f3).XTickLabel)
                if isempty(str2double(ah1(f3).XTickLabel{1}))
                    for f4 = 1:size(ah1(f3).XTickLabel,1)
                        ah1(f3).XTickLabel(f4,:) = fun(ah1(f3).XTickLabel(f4,:));
                    end
                end
            end
            
            % if the figure contains a right axis, apply function to right
            % axis elements
            % CAUTION: this will fail if the yyaxis right is not the most
            % recent axes selected, I don't know a good way around this
            % right now...
            contains_yright = false;
            
            
            if contains(ah1(f3).YAxisLocation,'right')
                contains_yright = true;
                ah1(f3).YLabel.String = fun(ah1(f3).YLabel.String);
                if ~isempty(ah1(f3).YTickLabel)
                    if isempty(str2double(ah1(f3).YTickLabel{1}))
                        for f4 = 1:size(ah1(f3).YTickLabel,1)
                            ah1(f3).YTickLabel(f4,:) = fun(ah1(f3).YTickLabel(f4,:));
                        end
                    end
                end
                yyaxis left
            end
            
            ah1(f3).YLabel.String = fun(ah1(f3).YLabel.String);
            
            if ischar(ah1(f3).XTickLabel)
                ah1(f3).YTickLabel = {ah1(f3).YTickLabel};
            end
            
            if ~isempty(ah1(f3).YTickLabel)
                if isempty(str2double(ah1(f3).YTickLabel{1}))
                    for f4 = 1:size(ah1(f3).YTickLabel,1)
                        ah1(f3).YTickLabel(f4,:) = fun(ah1(f3).YTickLabel(f4,:));
                    end
                end
            end
            if contains_yright
                yyaxis right
            end
            
        end
        
        %% dataseries (not really important since changing legend values directly anyways)
        ph = findobj(fh, 'Type', 'Line');
        for f3 = 1:numel(ph)
            ph(f3).DisplayName = fun(ph(f3).DisplayName);
        end
    end

    function [y_left,y_right] = get_yaxis_loc(ahs_y)
        % identify the left and right axis (order within axis handle
        % depends on order they were plotted in...)
        % if the label position is to the right of plot origin, it is right
        % label
        % if label to the left, left label
        % otherwise, NaN;
        
        y_left = NaN;
        y_right = NaN;
        
        for f2 = 1:numel(ahs_y.YAxis)
            if ahs_y.YAxis(f2).Label.Position(1) > 0
                y_right = f2;
            end
            if ahs_y.YAxis(f2).Label.Position(1) < 0
                y_left = f2;
            end
        end
    end

    function [x_top,x_bottom] = get_xaxis_loc(ahs_x)
        % same thing but for x-axis
        
        x_top = NaN;
        x_bottom = NaN;
        
        for f2 = 1:numel(ahs_y.XAxis)
            if ahs_x.YAxis(f2).Label.Position(2) > 0
                x_top = f2;
            end
            if ahs_x.YAxis(f2).Label.Position(2) < 0
                x_bottom = f2;
            end
        end
    end
end

