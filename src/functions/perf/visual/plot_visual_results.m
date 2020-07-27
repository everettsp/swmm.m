kill
figure
num_event = 2;





[~,t,~,ys,~,~] = unpack_data(nnd(1),'type','array');
[~,tt,~,~,~,~] = unpack_data(nnd(1),'type','timetable');

%%
y = ys(:,3);
lead = 4;

event_prom = .3;
event_threshold = 90;
event_sw = [2 lead];

[tIds,yIds] = get_events(t,y,...
    event_prom, event_threshold, event_sw);

% peak difference
[pdt,pda] = perf_pd(t,y,tIds,yIds,'plt',0);

% series distance
sd_minor_prom = 0.10;
sd_sw = event_sw;

[sdt,sda,~,~] = perf_sd(t,y,tIds,yIds,...
    sd_sw, sd_minor_prom,'plt',0);

% hydrograph matching
hm_b = 0.03;
hm_sw = event_sw;
[hmt,hma] = perf_hm(t,y,tIds,yIds, hm_sw, hm_b,'plt',0);
clear vars hmate hmaae


%% plot
kill
num_events = length(tIds);
cols = cell2mat(f.Col);
time_dom = tt.Time;
for ii = 1:num_events
    figure(11)
    subplot(1,num_events,ii)
    plot(time_dom(tIds(ii,1):tIds(ii,3)),t(tIds(ii,1):tIds(ii,3)),'DisplayName','observed',...
        'Color',[0 0 0])
    hold on
    plot(time_dom(tIds(ii,1):tIds(ii,3)),y(tIds(ii,1):tIds(ii,3)),'DisplayName','predicted',...
        'Color',cols(3,:))
    grid on
    grid minor
    
    %     xlim([tIds(ii,1) tIds(ii,3)])
    ah = gca;
    ah.XTickLabelRotation =30;
    xtick_size = 6; %days
    xtick_num = ceil(days(ah.XTick(end) - ah.XTick(1))/xtick_size);
    ah.XTick = ah.XTick(1) : days(xtick_size) : (ah.XTick(1) + (days(xtick_size) * xtick_num));
    ah.XRuler.MinorTickValues =  ah.XTick(1):day(3): ah.XTick(end);
    
    if ii == num_events
        legend('location','southwest')
    elseif ii == 1
        ylabel('water level [m]')
    end
    
    
    figure(12)
    ah = subplot(1,num_events,ii);
    
    plot(pdt(ii),pda(ii),'o','DisplayName','PD',...
        'Color',cols(4,:),'MarkerFaceColor',cols(4,:),'MarkerSize',10)
    hold on
    
    plot(sdt(ii),sda(ii),'o','DisplayName','SD',...
        'Color',cols(5,:),'MarkerFaceColor',cols(5,:),'MarkerSize',10)
    plot(hmt(ii),hma(ii),'o','DisplayName','HM',...
        'Color',cols(6,:),'MarkerFaceColor',cols(6,:),'MarkerSize',10)
    ah.YLim = [-.5 .5];
    ah.XLim = [-3 3];
    ah.XTick = ah.XLim(1): 1 :ah.XLim(2);
    ah.YTick = ah.YLim(1): 0.25 :ah.YLim(2);
    grid on
    straight_line(ah)
    apply_trimticks(ah);
    if ii == num_events
        legend('location','southwest')
        
    elseif ii == 1
        ylabel('amplitude error [m]')
        
        
    end
    if ii > 1
        yticklabels('')
    end
end
%%
savepath = 'C:\Users\everett\Google Drive\MASc York University\0_research\flow_forecasting\doc\paper_peakflow';


figure(11)
set(gcf,'Name','ts_baseline')
apply_touchup(f.W,f.H/5,...
    .6,.1,.6,.2,...
    'font_name', f.F,'font_size', f.Tb,'font_case','lower',...
    'bottom',1,'left',.8,'top',.5,'right',0.3,...
    'leg',true,'leg_placement','top-right')

% save_fig(savepath)

figure(12)
set(gcf,'Name','vm_baseline')
apply_touchup(f.W,f.H/5.5,...
    .1,.1,.6,.2,...
    'bottom',.6,'left',.8,...
    'font_name', f.F,'font_size', f.Tb,'font_case','lower',...
    'leg',true,'leg_placement','bottom-right',...
    'xlabel','timing error [6-hour]')

% save_fig(savepath)
