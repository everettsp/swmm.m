
gp = get_gp('word','lassonde');
gp.lw0 = 1.5;

%%
kill
leads = [1 6 12 24];
for i6 = 1:numel(leads)
for event_num = 1:5
    kill
% event_num = 4;
tr = events(event_num).timesteps;

fh = figure;
fh.Name = ['compare_ts_event' num2str(event_num) '_' num2str(leads(i6)) 'hr'];

plot(tt_obs.Properties.RowTimes,tt_obs.Variables,...
    'DisplayName','observed','Color','black','LineStyle','-','LineWidth',gp.lw0)
hold on
plot(tt_uncal.Properties.RowTimes,tt_uncal.Variables,...
    'DisplayName','uncalibrated','Color',gp.c.purple,'LineStyle','-','LineWidth',gp.lw0)
plot(tt_cal.Properties.RowTimes,tt_cal.Variables,...
    'DisplayName','GA','Color',gp.c.yellow,'LineStyle','-','LineWidth',gp.lw0)
ylabel('flow [m^3/s]')

plot(tt_bcm.Properties.RowTimes,tt_bcm(:,i6).Variables,...
    'DisplayName',['BC (' num2str(leads(i6)) ')'],'Color',gp.c.green,'LineStyle','-','LineWidth',gp.lw0)
ylabel('flow [m^3/s]')

xlabel('datetime')

yyaxis right
ah = gca;
set(ah,'YDir','reverse')
ah.YAxis(2).Color = 'black';
bar(tt_event.Properties.RowTimes,mean(tt_event.Variables,2),...
    'DisplayName','precip.','FaceColor',gp.c.blue,'EdgeColor',gp.c.blue)
ylabel('precipitation [mm]')

ah.YAxis(2).Limits = ah.YAxis(2).Limits .* [0 1.5];
ah.YAxis(1).Limits = [0 max(tt_obs(tr,:).Variables) * 1.5];
ah.XAxis.Limits = [tr(1) tr(end)];
autoformat([1,0.3],'compact','style','word',...
    'bottom',0.8,'leg_placement','bottom-mid')

path_save = [path_project 'doc\report'];
save_fig(path_save);

end
end