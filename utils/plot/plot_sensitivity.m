function plot_sensitivity(results, path_figs)
data_scatter = cell(2,1);
unpack_struct(results);
% events_rr = events;
ecl = setup_eventclass(events_rr);

fh = figure('Name',[catchment,'_sa_bp']);
for i2 = 1: 2% sa objs
    for i4 = 1:2 %clusters
        idx = ecl(i4).idx;
        for i3 = 1:numel(idx)
            j3 = idx(i3);
            data(:,i4,i3) = events_sa(j3).prams.(['mu',num2str(i2)]);
        end
    end
    data_scatter{i2} = data;
end

xlabels = {'$I (Q_{total})$','$I (Q_{peak})$'};

for i2 = 1: 2% sa objs
    
    subplot(1,2,i2)
    [ah,hh] = plot_bp(data_scatter{i2},'orientation','horizontal');
    hh.MemberColors = [ecl(1).col;ecl(2).col];
    hh.LineProp('linewidth',1.5);
    ah.XMinorGrid = 'on';
    box on
    ah.YTick = 1:10;
    ah.YTickLabels = strrep(sa_prams.attribute,'_','\_');
    % ah.YLim = [0,11];
    % ah.XLim = [0,1.5];
    ah.YLabel.Interpreter = 'None';
    ah.XLabel.String = xlabels{i2};
    ah.XLabel.Interpreter = 'LaTex';
    % lh = legend('Location','northeast')
    % lh.String = {'Q_{total}','Q_{peak}'}
    
    % ah.XLabel.Position(2) = ah.XLabel.Position(2) + 0.4;
end
gh = gfx2('fh',fh);
gh.share_lims('x');
gh.remove_inner({'yticks','ylabels'})
gh.apply([gh.width.sc,gh.width.sc/2],'margins',[.2,.3,1,.2],'left',2.2);
gh.save(path_figs)
%%
kill
xlabels = {'total flow','peak flow'};
fh = figure('Name',[catchment,'_sa_scatter']);
for i2 = 1:2
    subplot(1,2,i2);
    data = data_scatter{i2};
    
    clrs = colors('lassonde');
    param_clrs = repmat([clrs.red;clrs.blue;clrs.yellow;clrs.purple;clrs.green],[2,1]);
    param_symbols = repmat({'sq';'*'},[5,1]);
    
    ylabels = strrep(sa_prams.attribute,'_','\_');
    adjust_annotation = 0.02;
    
    for k2 = 1:size(data,1)
        us = plot_us(squeeze(data(k2,1,:)),squeeze(data(k2,2,:)),'Percentile',100,'SinglePoint',true,...
            'MedMarker',param_symbols{k2},'Color',param_clrs(k2,:));
        
        if us.MedPlot.XData > 0.1 || us.MedPlot.YData > 0.1
            if us.MedPlot.XData < us.MedPlot.YData
                flip_annotation = -1;
                align_annotation = 'Right';
            else
                flip_annotation = 1;
                align_annotation = 'Left';
            end
            text(us.MedPlot.XData + flip_annotation * adjust_annotation,...
                us.MedPlot.YData - flip_annotation * adjust_annotation,...
                ylabels{k2},'HorizontalAlignment',align_annotation)
        end
        hold on
    end
    
    ah = gca;
    maxlim = max([ah.XLim,ah.YLim]);
    minlim = min([ah.XLim,ah.YLim]);
    % plot([minlim,maxlim],[minlim,maxlim],'--','Color',clrs.black)
    plot([0,1],[0,1],'--','Color',clrs.black)
    
    grid('on')
    box('on')
    xlabel('uncalibrated model sensitivity (cluster 1 event)');
    ylabel('uncalibrated model sensitivity (cluster 2 event)');
    title(xlabels{i2});
    % ah.Title.Interpreter = 'LaTeX';
end

gh = gfx2();
gh.share_lims('all')
gh.remove_inner({'yticks','ylabels'})
gh.apply([gh.width.dc,gh.width.dc/2],'margins',[0.1],'frame',[1.2,0.6,1,0.8],'xlabel_single',true)
% gh.enumerate()
gh.save(path_figs)