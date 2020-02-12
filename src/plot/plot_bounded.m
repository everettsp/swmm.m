function fh = plot_bounded(x,y,varargin)



bounds = [25 50 75];
y_crit = prctile(y,bounds);

ph = plot(x,y_crit(2,:),varargin{:});
hold on

data_starts = find(~any(isnan(y)) & any(isnan([nan(size(y,1),1),y(:,1:end-1)]))); %lag down
data_ends = find(~any(isnan(y)) & any(isnan([y(:,2:end),nan(size(y,1),1)]))); %shit up

% edge conditions
if data_ends(1) < data_starts(1)
    data_starts = [1 data_starts];
end

if data_starts(end) > data_starts(end)
    data_ends = [data_ends height(tt_mod)];
end

% plot continuous segments
for i2 = 1:numel(data_starts)
    idx = data_starts(i2):data_ends(i2);
	temp = fill([x(idx), fliplr(x(idx))],[y_crit(1,idx), fliplr(y_crit(3,idx))],...
        ph.Color,'EdgeColor',ph.Color,'FaceAlpha',0.25,'EdgeAlpha',0.75,'LineStyle','-');
    
    if i2 == 999 %commented out rn...
        temp.DisplayName = [ph.DisplayName '(' num2str(bounds(3)) '%conf.)'];
    else
        temp.HandleVisibility = 'off';
    end
end

fh = gcf;

end

