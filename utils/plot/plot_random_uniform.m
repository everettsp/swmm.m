function plot_random_uniform(results_uniform, path_figs)
%%
gp = gfx('tex','lassonde');
plt = plt_funs;


unpack_struct(results_uniform);

% dat = load(['01_multi_event\results\calibration\',catchment,'_se.mat']);
% events = dat.events;
% load event formatting info


% load old results
old_results = load(['C:\Users\everett\Google Drive\02_phd\00_projects_major\02_swmm_calibration\04_paper\results\stacking\',catchment,'_uniform.mat']);


ecl = setup_eventclass(old_results.events_rr);
idx1 = ecl(1).idx;
idx2 = ecl(2).idx;


% 
% 
% % plot cross-validation matrix
% fh = figure("Name",[catchment,'_single_cvmat']);
% plot_cmat(cv_mat([idx1,idx2],[idx1,idx2]))
% yticks(1:numel(events_rr))
% xticks(1:numel(events_rr))
% yticklabels([idx1,idx2])
% xticklabels([idx1,idx2])
% colormap(gp.c.rwb);
% cb = colorbar("Ticks",[0,0.25,0.5,0.75,1],"TickLabels",{'\leq-1','-0.5','0','0.5','1'});
% ylabel('(class 2)     calibration events     (class 1)')
% xlabel('(class 1)     validation events     (class 2)')
% hold on
% plot([numel(events_rr)/2+0.5,numel(events_rr)/2+0.5],[0,numel(events_rr)+0.5],'k-','HandleVisibility','off')
% plot([0,numel(events_rr)+0.5],[numel(events_rr)/2+0.5,numel(events_rr)/2+0.5],'k-','HandleVisibility','off')
% 
% gh = gfx2('fh',fh);
% gh.apply([gp.pgw_sc,gp.pgw_sc],'margins',[0.2,0.2,2,0.2],'frame',[0.9,1.9,0,0.2]);
% gh.save(path_figs);
% 
% 
% fh = figure('Name',[catchment,'_num_mdl_compare']);
% k2 = 1;
% for i2 = [idx1,idx2]%reshape([idx1;idx2],[1,numel([idx1;idx2])])
%     subplot(5,4,k2);
%     k3 = 1;
%     
%     plt.ue([0.5;19.5],[cfg(end).kge(:,i2),cfg(end).kge(:,i2)]','Color',[.2,.2,.2],'MedStyle','-','Percentile',95)
%     
%     plot([0.5;19.5],[cv_mat(i2,i2),cv_mat(i2,i2)]',':','Color',[.2,.2,.2])
%     
%     hold on
%     for i4 = 1
%         xdata = [];
%         ydata = nan(1000);
%         for i3 = 1:9
%             xdata(i3) = cfg(k3).num_mdl;
%             ydata(1:numel(cfg(k3).kge(i2,:)),i3) = cfg(k3).kge(i2,:);
%             k3 = k3 + 1;
%         end
%         
%         ydata = ydata(~all(isnan(ydata),2),:);
%         ydata = ydata(:,~all(isnan(ydata)));
%         
%         col = ecl(cfg(k3-1).class == [ecl.class]).col;
%         [ah,ue] = plt.ue(xdata',ydata,'Color',col,'LineWidth',1.5,'MedStyle','-','Percentile',95);
%         ue.MedPlot.MarkerSize = 3;
%         
%         %         ah.YAxis.Color = ;
%         %         ah.YLabel.String = ['evemt ',num2str(i2)];
%     end
%     ylim([-0.5,1]);
%     xlim([1,19])
%     xlimz = xlim;
%     ylimz = ylim;
%     text(xlimz(1)+0.85*(xlimz(2)-xlimz(1)),ylimz(1)+0.15*(ylimz(2)-ylimz(1)),num2str(i2),'HandleVisibility','Off',...
%         'Color',ecl(events_rr(i2).class == [ecl.class]).col,'FontWeight',"bold")
%     
%     set(gca,{'XGrid'},{'On'})
%     set(gca,{'YGrid'},{'On'})
%     set(gca,{'Box'},{'On'})
%     
%     ylabel('KGE [-]')
%     xlabel('number of models')
%     
%     
%     k2 = k2 + 1;
%     
% end
% 
% %%
% % [fh,pos] = reorder_subplots(fh);
% % ahs = findall(fh,'type','axes'); %axes handles
% 
% 
% gh = gfx2('fh',fh);
% 
% gh.remove_inner({'xlabel','ylabel','xticks','yticks'})
% 
% 
% % for i2 = pos(end,:); ahs(i2).XLabel.String = 'number of models'; end
% % for i2 = reshape(pos(1:(end-1),:),1,[]); ahs(i2).XTickLabels = []; end
% % for i2 = pos(:,1)'; ahs(i2).YLabel.String = 'KGE [-]'; end
% % 
% % set(ahs,{'XGrid'},{'On'})
% % set(ahs,{'YGrid'},{'On'})
% % set(ahs,{'Box'},{'On'})
% % set(ahs,{'XLim'},{[1,19]})
% 
% phs = get(gca, 'Children');
% % ah.Children = ah.Children([5,4,1,2,3]);
% legend(phs(fliplr(1:numel(phs))), {'Single model','Cal.','ECB'});
% 
% gh.apply([gh.width.dc,gh.height.page*0.4],'margins',[0.8,0.2,0.2,0.2],'left',0.8,'bottom',1,'top',1,...
%     'ylabel_single',true,'xlabel_single',true,'leg_pos','top-right','xlabel_adjust',0);
% 
% % gh.enumerate()
% gh.save(path_figs);
% 
% %%
% 
% 
zdata_balanced = nan(20,100);
zdata_random = nan(20,100);


fh = figure('Name',[catchment,'_num_mdl_compare_rel']);
k2 = 1;
for i2 = [idx1,idx2]%reshape([idx1;idx2],[1,numel([idx1;idx2])])
    subplot(5,4,k2);
    k3 = 1;
    
    single_model_perf = nanmean(old_results.cfg(end).kge(:,i2));
%     plot([0.5;9.5],[0,0]',':','Color','black','HandleVisibility','off')
    %     plot([0.5;19.5],[cv_mat(i2,i2),cv_mat(i2,i2)]',':','Color',[.2,.2,.2])
    
    hold on
    for i4 = 1
        xdata = [];
        ydata = nan(1000);
        for i3 = 1:9
            xdata(i3) = i3;
            ydata(1:numel(cfg(k3).kge(i2,:)),i3) = cfg(k3).kge(i2,:);
            k3 = k3 + 1;
        end
        
        ydata = ydata(~all(isnan(ydata),2),:);
        ydata = ydata(:,~all(isnan(ydata)));
        
        ydata_diff = (ydata - single_model_perf);% ./ single_model_perf;
        
        zdata_random(k2,:) = ydata(:,end);

        col = gp.c.blue;
        [ah,ue] = plt.ue(xdata',ydata_diff,'Color',col,'LineWidth',1.5,'ShowMean',true,'ShowMedian',false,'MeanStyle','.-','Percentile',95);
        ue.MedPlot.MarkerSize = 3;
        
        %         ah.YAxis.Color = ;
        %         ah.YLabel.String = ['evemt ',num2str(i2)];
    end


    k3 = 1;
    hold on
    for i4 = 1
        xdata = [];
        ydata = nan(1000);
        for i3 = 1:9
            xdata(i3) = i3;
            ydata(1:numel(old_results.cfg(k3).kge(i2,:)),i3) = old_results.cfg(k3).kge(i2,:);
            k3 = k3 + 1;
        end
        
        ydata = ydata(~all(isnan(ydata),2),:);
        ydata = ydata(:,~all(isnan(ydata)));
        
        ydata_diff = (ydata - single_model_perf);% ./ single_model_perf;
        
        zdata_balanced(k2,:) = ydata(:,end);


        col = gp.c.yellow;
        [ah,ue] = plt.ue(xdata',ydata_diff,'Color',col,'LineWidth',1.5,'ShowMean',true,'ShowMedian',false,'MeanStyle','.-','Percentile',95);
        ue.MedPlot.MarkerSize = 3;
        
        %         ah.YAxis.Color = ;
        %         ah.YLabel.String = ['evemt ',num2str(i2)];
    end











    ylim([-1,1]);
    xlim([0.5,9.5])
    xlimz = xlim;
    ylimz = ylim;
    yticks(-0.8:0.4:0.8)
%     yticklabels({'','-1','0','1',''});
    text(xlimz(1)+0.95*(xlimz(2)-xlimz(1)),ylimz(1)+0.05*(ylimz(2)-ylimz(1)),num2str(i2),'HandleVisibility','Off',...
        'Color',ecl(old_results.events_rr(i2).class == [ecl.class]).col,'FontWeight',"bold",'HorizontalAlignment','right','VerticalAlignment','bottom')
    xlabel("number of models in each class")
    ylabel("KGE - KGE_{single model}");
    set(gca,{'XGrid'},{'On'})
    set(gca,{'YGrid'},{'On'})
    set(gca,{'Box'},{'On'})
    
    
    k2 = k2 + 1;
    
end




phs = get(gca, 'Children');
legend(phs(fliplr(1:numel(phs))), {'random events','clustered events'});


gh = gfx2('fh',fh);

gh.remove_inner({'xlabels','xticks','ylabels','yticks'});
gh.apply([gh.width.sc,gh.height.page*0.4],'margins',0.02,'frame',[1.2,0,1,0.8],'leg_pos','top-right','xlabel_single',true,'ylabel_single',true)
% gh.enumerate()
%%
gh.save(path_figs)



zdata = nan(20,100,2);

zdata(:,:,1) = zdata_balanced;

zdata(:,:,2) = zdata_random;


fh = figure('Name',[catchment,'_random_event_compare']);
okok = (zdata(:,:,1) - zdata(:,:,2));
boxplot(okok','symbol', '')

h = findobj(gca,'Tag','Box');
for j=1:10
    patch(get(h(j),'XData'),get(h(j),'YData'),gp.c.purple,'FaceAlpha',.5);
    patch(get(h(j+10),'XData'),get(h(j+10),'YData'),gp.c.green,'FaceAlpha',.5);

end

xticklabels([idx1,idx2]);
hold on
xlabel('event ID')
ylabel({'KGE_{clustered} - KGE_{random}'})
ah = gca;
plot([10.5,10.5],ah.YLim,'k-')
plot([0.5,20.5],[0,0],'k-')
grid on

gh = gfx2('fh',fh);
gh.apply([gh.width.dc,gh.height.page*0.4],'margins',[1,1,0.2,0.2])
gh.save(path_figs)




%%
figure('Name',[catchment,'_random_param_compare'])


classes = {'subcatchments','subcatchments'};
param_names = {'PercentImperv','Width'};
units = {'%','m'}

for i3 = 1:numel(classes)
subplot(2,1,i3)
ylabel([param_names{i3},' [',units{i3},']']);
xlabel('subcatchment ID')
param_data_random = [];
param_data = [];

for i2 = 1:numel(mdl)
    param_data_random(:,i2) = mdl(i2).p.(classes{i3}).(param_names{i3});
end

for i2 = 1:numel(mdl)
    param_data(:,i2) = old_results.mdl(i2).p.(classes{i3}).(param_names{i3});
end

box on
grid on
param_data_all = [];
param_data_all(:,:,1) = param_data;
param_data_all(:,:,2) = param_data_random;

if i3 == 1;
    param_data_all(param_data_all > 100) = 100;
end


param_data_all = permute(param_data_all,[1,3,2]);
plt.bp(param_data_all,'MemberColors',[gp.c.blue;gp.c.yellow])

xlim([0.5,height(mdl(1).p.subcatchments) + .5])
if i3 == 2
    
    lh = legend();

    lh.String = {'balanced','random'};
end

end

fw = gfx2();
fw.remove_inner({'xlabels','xticks','ylabels'});
fw.apply([gh.width.dc,gh.height.page*0.4],'margins',[0.1,0.1,0.15,0.15],'frame',[1.3,0.1,1.2,0.6],'leg_pos','top-right','xlabel_single',true,'ylabel_single',false)
fw.save(path_figs)





% plt.bp(permute(zdata,[1,3,2]))
% 
% 
% 
% %%
% 
% fh = figure('Name',[catchment,'_num_mdl_compare_var']);
% k2 = 1;
% for i2 = [idx1,idx2]%reshape([idx1;idx2],[1,numel([idx1;idx2])])
%     subplot(5,4,k2);
%     k3 = 1;
%     
%     %     plt.ue([0.5;19.5],[cfg(end).kge(:,i2),cfg(end).kge(:,i2)]','Color',[.2,.2,.2],'MedStyle','-','Percentile',95)
%     
%     single_model_perf = nanmean(cfg(end).kge(:,i2));
% %     plot([0.5;9.5],[0,0]',':','Color','black','HandleVisibility','off')
%     %     plot([0.5;19.5],[cv_mat(i2,i2),cv_mat(i2,i2)]',':','Color',[.2,.2,.2])
%     
%     hold on
%     for i4 = 1:3
%         xdata = [];
%         ydata = nan(1000);
%         for i3 = 1:9
%             xdata(i3) = i3;
%             ydata(1:numel(cfg(k3).kge(i2,:)),i3) = cfg(k3).kge(i2,:);
%             k3 = k3 + 1;
%         end
%         
%         ydata = ydata(~all(isnan(ydata),2),:);
%         ydata = ydata(:,~all(isnan(ydata)));
%         
% %                 single_model_var = var(cfg(end).kge(:,i2),'omitnan');
% 
%         ydata = var(ydata);
%         
%         
% %         ydata = (ydata - single_model_var) ./ single_model_var;
%         
%         %         ydata = (ydata - single_model_perf) ./ single_model_perf;
%         
%         col = ecl(cfg(k3-1).class == [ecl.class]).col;
%         ah = plot(xdata',ydata,'.-','Color',col,'LineWidth',1.5,'MarkerFaceColor',col);
%         %         ue.MedPlot.MarkerSize = 3;
%         
%         %         ah.YAxis.Color = ;
%         %         ah.YLabel.String = ['evemt ',num2str(i2)];
%     end
%     %     ylim([-2,2]);
%     xlim([0.5,9.5])
%     xlimz = xlim;
%     ylimz = ylim;
%     %     yticks(-2:1:2)
%     %     yticklabels({'','-1','0','1',''});
%     text(xlimz(1)+0.95*(xlimz(2)-xlimz(1)),ylimz(1)+0.95*(ylimz(2)-ylimz(1)),num2str(i2),'HandleVisibility','Off',...
%         'Color',ecl(events_rr(i2).class == [ecl.class]).col,'FontWeight',"bold",'HorizontalAlignment','right','VerticalAlignment','top')
%     
%     k2 = k2 + 1;
%     
% end
% 
% 
% ahs = findall(fh,'type','axes'); %axes handles
% for i2 = 1:numel(ahs)
%     ahs(i2).XLabel.String = 'number of models in each class';
%     ahs(i2).XGrid = 'on';
%     ahs(i2).YLabel.String = 'variance of KGE';
%     ahs(i2).YGrid = 'on';
%     ahs(i2).Box = 'on';
% end
% 
% phs = get(gca, 'Children');
% legend(phs(fliplr(1:numel(phs))), {'ECB','EC1','EC2'});
% 
% fw = gfx2();
% 
% fw.remove_inner({'xlabels','xticks','ylabels'});
% % fw.enumerate()
% 
% fw.apply([gh.width.sc,gh.height.page*0.4],'margins',[1,0,.3,.2],'frame',[.25,.1,.8,.8],'leg_pos','top-right','xlabel_single',true,'ylabel_single',true)
% fw.save(path_figs)

% %%
% 
% kill
% fh = figure('Name',[catchment,'_cv_temporal']);
% date_array = [events_rr.start_date];
% days_elapsed = days(date_array - date_array(1));
% % days_elapsed = log10(days_elapsed);
% cv_diag = diag(cv_mat);
% 
% cols = colormap(hsv(20));
% trends_before = [];
% trends_after = [];
% 
% for i2 = 1:numel(events_rr)
%     if any(idx1 == i2)
%         subplot(2,1,1)
%         title('cluster 1 events')
%     else
%         subplot(2,1,2)
%         title('cluster 2 events')
%     end
% 
%     rel_perf = (cv_mat(i2,:) - cv_diag')./cv_diag';
%     plot(days_elapsed(i2),rel_perf(i2),'o','Color',cols(i2,:),'MarkerFaceColor',cols(i2,:),'MarkerSize',6,'DisplayName',[num2str(i2)])
%     hold on
%     plot(days_elapsed(i2:20),rel_perf(i2:20),'.-','Color',cols(i2,:),'Linewidth',1,'HandleVisibility','off')
%     if i2 > 1;  plot(days_elapsed(1:i2),rel_perf(1:i2),'.-','Color',cols(i2,:),'Linewidth',1,'HandleVisibility','off'); end
%        
%     
% %     p = polyfit(days_elapsed(1:i2),rel_perf(1:i2),1);
% %     plot(days_elapsed(1:i2),days_elapsed(1:i2) * p(1) + p(2),'--','Color','k','HandleVisibility','off')
% % 
% %     trends_before(i2) = p(1);
% 
%     p = polyfit(days_elapsed(i2:20),rel_perf(i2:20),1);
%     plot(days_elapsed(i2:20),days_elapsed(i2:20) * p(1) + p(2),'--','Color','k','linewidth',2,'HandleVisibility','off')
%     
%     trends_after(i2) = p(1);
%     ylabel('KGE relative to cal.')
%     xlabel('days elapsed')
%     lh = legend('Location','best','NumColumns',2)
%     lh.Title.String = 'event number';
%     grid on
% end
% 
% 
% gh = gfx2('fh',fh);
% gh.remove_inner({'xlabels','ylabels','xticks','yticks'});
% gh.share_lims('x')
% gh.share_lims('rows')
% gh.apply([1,0.8],'frame',[1.2,0,1,0.4],'margins',[0.05,0.25,0.25,0.25],'xlabel_single',true);
% 
% % lh = findall(fh,'type','legend');
% 
% gh.save(path_figs,'formats',{'pdf','fig','png'});
