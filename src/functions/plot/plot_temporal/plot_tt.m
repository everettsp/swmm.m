function ph = plot_tt(tt,varargin)
% plot timetable
% wrapper for timetabel input to plot()

assert(istimetable(tt),'input must be timetable')

for i2 = 1:width(tt)
    if any(cellfun(@(x) strcmpi(x,'DisplayName'),varargin))
        % if display names are contained in varargin (as cell array), use
        % them one by one
        dispname_idx = find(cellfun(@(x) strcmpi(x,'DisplayName'),varargin));
        dispnames = varargin(dispname_idx+1);
        assert(numel(dispnames) == width(tt),'number of DisplayNames must match number of tt variables')
        varargin_edit = varargin(~ismember(1:numel(varargin),[dispname_idx,dispname_idx+1]));
        ph = plot(tt(:,i2).Properties.RowTimes,tt(:,i2).Variables,varargin_edit{:},'DisplayName',dispnames{i2});
        hold on
    else
        % otherwise, use the timetable VariableNames as DisplayNames
        
        ph = plot(tt(:,i2).Properties.RowTimes,tt(:,i2).Variables,varargin{:},'DisplayName',tt.Properties.VariableNames{i2});
                hold on
    end
end

ah = gca();

if numel(unique(tt.Properties.VariableUnits)) == 1
    ah.YLabel.String = ['[',tt.Properties.VariableUnits{1},']'];
end
ah.XLabel.String = ['datetime',' ','[',ah.XTick(1).Format,']'];
end