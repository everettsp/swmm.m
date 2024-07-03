% calculate runoff stats

% events = events_flow(tt_obs,events);
%%

kill
colmat = [gp.c.green;gp.c.yellow;gp.c.red];
ecl = setup_eventclass(events);

figure('Name','events_hyethydro');
for i2 = 1:numel(events)
    subplot(6,2,i2)
    [i2c,i2r] = ind2sub([2,4],i2);
    
    plt.hy(events(i2).tt(:,'intensity'),'FaceColor',gp.c.blue,'EdgeColor',gp.c.blue,'LineWidth',1);
    hold on
    
    colr = colmat(events(i2).class,:);
    plt.tt(events(i2).tt_fg,'-','Color',ecl(events(i2).class == [ecl.class]).col,'LineWidth',2);

    ylim_default = ylim;
    ylim(ylim_default .* [1,1.5])
    
    ah = gca;
    ah = datetime2elapsed(ah,4);
%     ah.XAxis.TickLabelFormat = 'd-MMM-yy';
%     ah.XGrid = 'on';
% %     ah.XMinorGrid = 'on';
%     ah.XAxis.MinorTickValues = ah.XAxis.Limits(1):hours(1):ah.XAxis.Limits(2);
%     ah.XAxis.TickValues = ah.XAxis.Limits(1):hours(4):ah.XAxis.Limits(2);
%     
%     if numel(ah.XTick) < 10
%         ah.XTickLabels = (0:(numel(ah.XTick)-1)) ./ 2;
% %     elseif numel(ah.XTick) < 30
%         ah.XTickLabels = repmat({''},[numel(ah.XTick),1]);
%         ah.XTickLabels(1:end) = num2cell((0:(numel(ah.XTick)-1)).*4);
% %     else
%         ah.XTickLabels = repmat({''},[numel(ah.XTick),1]);
%         ah.XTickLabels(1:end) = num2cell((0:(numel(ah.XTick)-1)).*4);
%     end
%     ah.XLim(1) = ah.XLim(1) - hours(1);
%     ah.MinorGridLineStyle = '-';
%     if i2 == 4
        ah.YAxis(1).Label.String = 'flow [m^{3}s^{-1}]';
%     elseif i2 == 6
        ah.YAxis(2).Label.String = 'rainfall intensity [mmh^{-1}]';
        ah.XAxis.Label.String = 'elapsed time [hours]';
        ah.Title.String = datestr(ah.XLim(1),'dd-mmm-yy');
%     else
        ah.Title.FontWeight = 'normal';

%         ah.YAxis(2).Label.String = '';
%         ah.YAxis(1).Label.String = '';
%     end
    
end

gp.apply([1,0.7],'margins',[.5,.5,.5,0.5],...
    'top',0,'bottom',1,'right',1,'left',1,...
    'ylabel_single',true,'ylabel_adjust',[-0.3,0.2],...
    'xlabel_single',true,'xlabel_adjust',[-.2,0])

save_fig(path_figs);

%%
% format for latex
events_tbl = struct2table(events);

events_tbl = events_tbl(:,{'start_date','duration','total','intensity_peak','q_mean','qp','class'});

events_tbl.start_date = datestr(events_tbl.start_date,'dd-mm-yy HHMM');
% events_tbl.end_date = datestr(events_tbl.end_date,'dd-mmm-yy');
events_tbl.duration = hours(events_tbl.duration);
events_tbl.duration = compose('%g',round(events_tbl.duration,1,'decimal'));
events_tbl.total = compose('%g',round(events_tbl.total,1,'decimal'));
events_tbl.q_mean = compose('%g',round(events_tbl.q_mean,1,'decimal'));
events_tbl.qp = compose('%g',round(events_tbl.qp ,1,'decimal'));
events_tbl.class = compose('%g',events_tbl.class);

events_tbl.Properties.VariableNames = {'start datetime','duration','sum','peak rainfall rate','mean flow rate','peak flow rate','class'};
events_tbl.Properties.VariableUnits = {'','[hrs]','[mm]','[mm/hr]','[cms]','[cms]',''};


filename = [path_tbls,'\tbl_events'];

table2latex(events_tbl,[filename,'.tex'],'include_units',true);
writetable(events_tbl,[filename,'.xlsx']);



%%

ga_vars = ga_load_vars();
ga_vars.uncertainty = compose('%2.2f',round(ga_vars.uncertainty,1,'decimal'));
ga_vars.constraint_lower = compose('%g',round(ga_vars.constraint_lower,1,'decimal'));
ga_vars.constraint_upper = compose('%g',round(ga_vars.constraint_upper ,1,'decimal'));

ga_vars.attribute = strrep(ga_vars.attribute,'_','\_');
ga_vars.Properties.VariableNames = strrep(ga_vars.Properties.VariableNames,'_','\_');
fmat = @(x) cellstr(['$\mathrm{',char(x),'}$']);
ga_vars.attribute = cellfun(fmat,ga_vars.attribute);
ga_vars.Properties.VariableNames = cellfun(fmat,ga_vars.Properties.VariableNames);

filename_tex = [path_tbls,'\tbl_ga_vars.tex'];
table2latex(ga_vars,filename_tex,'include_units',true);


