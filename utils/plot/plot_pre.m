function plot_pre(mdl,events_rr,path_figs, path_tbls)

cols = colors('lassonde');
    catchment = mdl.name;
    % plot hydrographs (one from each class)
    fh = figure('Name',[catchment,'_hydrographs']);
    ecl = setup_eventclass(events_rr);
    subplot(1,2,1)
    events_c1 = events_rr([events_rr.class] == 1);
    [~,ind] = min([events_c1.class_ed]);
    plot_hy(events_c1(ind).tt(:,'intensity'),'FaceColor',cols.blue,'EdgeColor',cols.blue,'LineWidth',1,'BarWidth',2);
    hold on
    plot_tt(events_c1(ind).tt_fg,'-','Color',ecl(1).col,'LineWidth',2);
    datetime2elapsed(gca,4);
    grid on

    subplot(1,2,2)
    events_c2 = events_rr([events_rr.class] == 2);
    [~,ind] = min([events_c2.class_ed]);
    plot_hy(events_c2(ind).tt(:,'intensity'),'FaceColor',cols.blue,'EdgeColor',cols.blue,'LineWidth',1,'BarWidth',2);
    hold on
    plot_tt(events_c2(ind).tt_fg,'-','Color',ecl(2).col,'LineWidth',2);
    datetime2elapsed(gca,4);
    clear events1 events2
    grid on

    fw = gfx2('fh',fh);
    for i2 = 1:fw.nahs
        fw.ahs(i2).YAxis(1).Label.String = 'flow [m^{3}s^{-1}]';
        fw.ahs(i2).YAxis(2).Label.String = 'rainfall intensity [mmh^{-1}]';
        fw.ahs(i2).XAxis.Label.String = 'elapsed time [hours]';
        fw.ahs(i2).Title.String = datestr(fw.ahs(i2).XLim(1),'dd-mmm-yy');
        fw.ahs(i2).Title.FontWeight = 'normal';
        fw.ahs(i2).XTickLabelRotation = 30;
    end

    fw = fw.check_second_axes();
    % fw.share_lims(2);
    fw.remove_inner({'ylabel'});


    fw.apply([0.5,0.25],'margins',[0.6,0.6,0.1,0.1],'frame',[0.25,0.25,1,0.4],'xlabel_single','bottom-mid','ylabel_adjust',[-0.1,0.1])
%     fw.enumerate()
    fw.save(path_figs);

    
    
    tbl = tex_tbl(ga_load_vars('normal'));
    tbl.save([path_tbls,'uncertainty.tex'])

    
end
