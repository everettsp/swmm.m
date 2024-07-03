function remove_inner(obj,elements)
% remove inner labels for figures with subplots
assert(ischar(elements) | iscell(elements),'ValueError: element must a string or cell of strings');

if ischar(elements)
    elements = {elements};
end

for i2 = 1:numel(elements)
    element = elements{i2};
    posarr = obj.posmat(:);
    for pos = posarr'
        
        
        x2ax = obj.x2ax(:,pos);
        y2ax = obj.y2ax(pos,:);
        switch lower(element)
            case {'xlabel','xlabels'}
                if ~isnan(x2ax(1)) && ~any(pos == obj.posmat(1,:)); obj.ahs(pos).XAxis(x2ax(1)).Label.String = ''; end
                if ~isnan(x2ax(2)) && ~any(pos == obj.posmat(end,:)); obj.ahs(pos).XAxis(x2ax(2)).Label.String = ''; end
            case {'xticks','xtick'}
                if ~isnan(x2ax(1)) && ~any(pos == obj.posmat(1,:)); obj.ahs(pos).XAxis(x2ax(1)).TickLabels = {}; end
                if ~isnan(x2ax(2)) && ~any(pos == obj.posmat(end,:)); obj.ahs(pos).XAxis(x2ax(2)).TickLabels = {}; end
            case {'ylabel','ylabels'}
                if ~isnan(y2ax(1)) && ~any(pos == obj.posmat(:,1)); obj.ahs(pos).YAxis(y2ax(1)).Label.String = ''; end
                if ~isnan(y2ax(2)) && ~any(pos == obj.posmat(:,end)); obj.ahs(pos).YAxis(y2ax(2)).Label.String = ''; end
            case {'yticks','ytick'}
                if ~isnan(y2ax(1)) && ~any(pos == obj.posmat(:,1)); obj.ahs(pos).YAxis(1).TickLabels = {}; end
                if ~isnan(y2ax(2)) && ~any(pos == obj.posmat(:,end)); obj.ahs(pos).YAxis(2).TickLabels = {}; end
            case {'title','titles'}
                if ~any(pos == obj.posmat(1,:)); obj.ahs(pos).Title.String = ''; end
            otherwise
                error(['ValueError: element ',element,' not one of {xlabel(s),xtick(s),ylabel(s),ytick(s)}'])
        end
    end
end


%
%
%     for pos = posmat(1,:); ahs(pos).YLim = [-1,1]; end
%
%     for pos = posmat(2,:); ahs(pos).YLim = [-1.1,1.1]; end
%
%     for pos = posmat(3,:); ahs(pos).YLim = [-1.5,1.5]; end
%
%     for pos = posmat(:)'; ahs(pos).YTick = -1:0.5:1; end
%
%     for pos = posmat(:)'; ahs(pos).Box = 'On'; end
%
%     for pos = posmat(:)'; ahs(pos).XGrid = 'On'; end
%
%     % for i2 = pos(:)'; ahs(i2).XMinorGrid = 'On'; end
%
%     for pos = posmat(:)'; ahs(pos).YGrid = 'On'; end
%
%
%
