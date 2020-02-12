



gp = get_gp('word','lassonde');
colg = get_colgrad([1 1 1],gp.c.purple,'grad_num',40);


%%
num_pop = numel(gbl_obj{1});
num_gens = numel(gbl_obj);
cal_num = 508;

num_gens = numel(gbl_obj);
num_params = numel(gbl_opt);

ys = NaN(size(gbl_mod{1}{1}.Variables,1),num_pop);
y25 = [];
y50 = [];
y75 = [];

for i2 = 1:num_gens
    
    for i3 = 1:num_pop
        ys(:,i3) = gbl_mod{i2}{i3}.Variables;
    end
    
    yc = prctile(ys,[25 50 75],2);
    y25(:,i2) = yc(:,1);
    y50(:,i2) = yc(:,2);
    y75(:,i2) = yc(:,3);
end


data_nse = [gbl_obj{:}];

% data_entropy = zeros(num_params,num_gens);
% for i2 = 1:num_gens
%     for i3 = 1:num_params
%         x = gbl_pop{i2}(:,i3); % get the parameter population
%         data_entropy(i3,i2) = get_entropy(x,12);
%     end
% end


%%






%%
kill
fh = figure(1);
fh.Name = 'ga_param';
tt_obs = gbl_obs;

% fh.Color = [1 1 1];
% hold on

% boxplot(data_entropy)
%%

fun_decay = @(ii) 1.00 ./ exp(0.4*(ii-1));
plot(gbl_opt(cal_num).init_val,0,...
    'sq','Color',gp.c.yellow,'MarkerFaceColor',gp.c.yellow,...
    'LineWidth',2,'MarkerSize',6)
hold on
th = text(0.35,22,['generation ' num2str(0)],'FontSize',20);
xlabel('K_s_a_t [mm/hr]')
ylabel('count')

fh = figure(2);
fh.Name = 'ga_objective';

% fh = figure(4);
% fh.Name = 'ga_entropy';

fh = figure(3);
fh.Name = 'ga_timeseries';
plot(tt_obs.Properties.RowTimes,tt_obs.Variables,'DisplayName','observation',...
    'Color',[0 0 0],'LineWidth',2)

yyaxis right
bar(tt_event.Properties.RowTimes,mean(tt_event.Variables,2),...
    'EdgeColor',gp.c.blue,'FaceColor',gp.c.blue,'DisplayName','Precipitation')
rightLims = ylim;
ah2 = gca;
ah2.YDir = 'reverse';
ah2.YColor = 'black';
ylabel('precipitation depth [mm]')
ylim([rightLims(1) rightLims(2)*3])

ah = gca;
ah.XLim(1) = ah.XLim(1) + days(3);
ah.YLabel.String = 'flow [cms]';
legend('Location','best')
yyaxis left
hold on


for i2 = 1:num_gens
    fh = figure(1);
    x = gbl_pop{i2}(:,cal_num);
    histogram(x,10)
    
    hold on
    ah = gca;
    ah.XLim = [0.3 0.9];
    ah.YLim = [0 25];
    %     ah.Children(1).FaceColor = gp.c.purple;
    %     ah.Children(1).FaceAlpha = fun_decay(i3);
    %     ah.Children(1).EdgeAlpha = fun_decay(i3);
    
    hh = findobj(ah.Children,'Type','Histogram');
    hh(1).FaceColor = gp.c.purple;
    hh(1).FaceAlpha = 1;
    hh(1).EdgeAlpha = 1;
    for i3 = 1:numel(hh(1:end))
        hh(i3).FaceAlpha = fun_decay(i3);
        hh(i3).EdgeAlpha = fun_decay(i3);
    end
    
    hh(1).BinWidth = 0.03;
    
    delete(th)
    th = text(0.35,22,['generation ' num2str(i2-1)],'FontSize',20);
    %     ah.Children(1).Color = gp.c.purple;
    %     plot(gbl_opt_vars(cal_num).init_val,0,...
    %         'sq','Color',cols.r,'MarkerFaceColor',cols.r,...
    %         'LineWidth',2,'MarkerSize',6)
    autoformat([0.5 0.5],'compact','style','pptw_body','bottom',0.6)
    save_gif([path_project 'doc\figures\gif\' fh.Name],(i2-1)/(num_gens-1))
    
    %%
    fh = figure(2);
    fh.Name = 'event3_obj-fcn';
    boxplot(data_nse(:,1:i2),...
        'PlotStyle','compact','Color',gp.c.purple,'MedianStyle','target','BoxStyle','filled','Symbol','.','OutlierSize',0.3)
    ylabel('NSE [-]')
    ah = gca;
    ah.YLim(2) = 1;
    xticks(1:2:num_gens)
    xticklabels((num2cell(0:2:(num_gens-1))))
    xlabel('generation')
    autoformat([0.5 0.5],'compact','style','pptw_body','bottom',0.6)
    grid on
    save_gif([path_project 'doc\figures\gif\' fh.Name],(i2-1)/(num_gens-1))
    
    %%
    fh = figure(3);
    rt = gbl_mod{i2}{1}.Properties.RowTimes;
    
    fill(([rt; flipud(rt)]),[y25(:,i2);flipud(y75(:,i2))],gp.c.purple,'LineStyle','-','Marker','none');
    hold on
    %     plot(rowtimes,y50(:,i2),...
    %         'Color',gp.c.purple,'LineWidth',1)
    
    ah = gca;
    ah.Children(1).FaceColor = gp.c.purple;
    ah.Children(1).EdgeColor = gp.c.purple;
    for i3 = 1:numel(ah.Children(1:(end-1)))
        ah.Children(i3).FaceAlpha = fun_decay(i3);
        ah.Children(i3).EdgeAlpha = fun_decay(i3);
    end
    

    autoformat([1 0.5],'compact','style','pptw_body')

%     for i3 = 2:numel(ah.Children(1:(end-1)))
%         ah.Children(i3).HandleVisibility = 'off';
%     end
%     legend({'observation','modelled'})
%     for i3 = 2:numel(ah.Children(1:(end-1)))
%         ah.Children(i3).HandleVisibility = 'on';
%     end
    delete(legend)
%     fh = figure(4);
% %     boxplot(data_entropy(:,1:i2),...
%         'PlotStyle','compact','Color',gp.c.purple,'MedianStyle','line','BoxStyle','filled','Symbol','.','OutlierSize',0.1)
    save_gif([path_project 'doc\figures\gif\' fh.Name],(i2-1)/(num_gens-1))
    
end