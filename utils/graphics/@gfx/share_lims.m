function share_lims(obj,axax)
if nargin == 1
    axax = 'all';
end

% if ischar(axax)
%     axis_str = axax;
%     switch lower(axis_str)
%         case 'x'
%             axax = 1;
%         case 'y'
%             axax = 2;
%         case {'xy','yx','both','all'}
%             axax = 0;
%         otherwise
%             error(['ValueError: axis ',axis_str,' not one of {x, y, xy}'])
%     end
% end

assert(any(1 == [0,1,2]),'ValueError: axis must be one of [0,1,2]')

if ismember(axax,{'cols','col','colwise','rowcol','colrow'})
    for i2 = 1:obj.ncols
        for i4 = 1:numel(obj.x2ax(:,i2))
            j4 = obj.x2ax(i4,i2);
            if ~isnan(j4)
                new_xlim = [min(cellfun(@(x) x(1),{obj.ahs(obj.posmat(:,i2)).XLim})),...
                    max(cellfun(@(x) x(2),{obj.ahs(obj.posmat(:,i2)).XLim}))];
                for i3 = 1:obj.nrows
                    obj.ahs(obj.posmat(i3,i2)).XAxis(j4).Limits = new_xlim;
                end
            end
        end
    end
end

if ismember(axax,{'rows','row','rowwise','rowcol','colrow'})
    for i2 = 1:obj.nrows
        for i4 = 1:numel(obj.y2ax(i2,:))
            j4 = obj.y2ax(i2,i4);
            if ~isnan(j4)
                new_ylim = [min(cellfun(@(x) x(1),{obj.ahs(obj.posmat(i2,:)).YLim})),...
                    max(cellfun(@(x) x(2),{obj.ahs(obj.posmat(i2,:)).YLim}))];
                for i3 = 1:obj.ncols
                    obj.ahs(obj.posmat(i2,i3)).YAxis(j4).Limits = new_ylim;
                end
            end
        end
    end
end

if ismember(axax,{'x','xy','yx','all','everything'})
    for i2 = 1:obj.ncols
        for i4 = 1:numel(obj.x2ax(:,i2))
            j4 = obj.x2ax(i4,i2);
            if ~isnan(j4)
                new_xlim = [min(cellfun(@(x) x(1),{obj.ahs(obj.posmat(:)).XLim})),...
                    max(cellfun(@(x) x(2),{obj.ahs(obj.posmat(:)).XLim}))];
                for i3 = 1:obj.nahs
                    obj.ahs(i3).XAxis(j4).Limits = new_xlim;
                end
            end
        end
    end
end

if ismember(axax,{'y','xy','yx','all','everything'})
    for i2 = 1:obj.ncols
        for i4 = 1:numel(obj.y2ax(i2,:))
            j4 = obj.y2ax(i2,i4);
            if ~isnan(j4)
                new_ylim = [min(cellfun(@(x) x(1),{obj.ahs(obj.posmat(:)).YLim})),...
                    max(cellfun(@(x) x(2),{obj.ahs(obj.posmat(:)).YLim}))];
                for i3 = 1:obj.nahs
                    obj.ahs(i3).YAxis(j4).Limits = new_ylim;
                end
            end
        end
    end
end


end