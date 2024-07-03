function plot_stacking(results, path_figs, path_tbls)
unpack_struct(results);

plt = plt_funs();

fh = figure('Name',[catchment,'_combination_compare']);
% plt_fun = @(x,y,col,dn) plt.us(x',y','Color',col,'DisplayName',dn,'Percentile',95,'ShowMedian',true,'ShowMean',true,'UncertaintyStyle','cross')
% k2 = 1;
bp = boxplot2.empty;
colmat = nan(5,3);
k2 = 1;

% load event formatting info
ecl = setup_eventclass(events_rr);
idx1 = ecl(1).idx;
idx2 = ecl(2).idx;
ind12 = [idx1,idx2];

ylim_mat = [[-1,1];[-1.1,1.1];[-1.5,1.5]];
for i3 = 1:numel(perf_lbls)

    perf_str = perf_lbls{i3};

    data = nan(n_events,5,1000);

    %     idx_mdls = [5,1,2,3,4];
    cal_perf = cfg(1).perf.(perf_str)';
    idx_mdls = 2:6;
    for j2 = 1:numel(idx_mdls)
        i2 = idx_mdls(j2);
        colmat(j2,1:3) = cfg(i2).col;

        %         subplot(3,3,k2)
        data(1:n_events,j2,1:size(cfg(i2).perf.(perf_str)([1:n_events],:),2)) = ...
            cfg(i2).perf.(perf_str)([1:n_events],:);
        %         1 .* (cfg(i2).perf.(perf_str)(:,[1:12])' - cal_perf) ./ cal_perf;
    end

    subplot(3,1,i3)

    for i2 = 1:numel(cal_perf)
        cal_ind = ind12(i2);
        ph = plot(i2 + (-0.5:0.5),repmat(cal_perf(cal_ind),[1,2]),'-','Color',[0.5,0.5,0.5],'LineWidth',1.5,'HandleVisibility','off');
        if i2 == 1
            ph.HandleVisibility = 'on';
            hold on;
        end
    end

    if i3 ~= 1; plot([0.5,n_events+0.5],[0,0],'k-','HandleVisibility','off'); end

    [~,bp(k2)] = plt.bp(data([idx1,idx2],:,:));
    bp(k2).LineProp('LineWidth',1.5);
    xticklabels([idx1,idx2])
    xlim([0.5,n_events+0.5])
    ylim(ylim_mat(i3,:))
    k2 = k2 + 1;
    ylabel(upper(perf_str))
    xticks(1:n_events)
    xlabel('cluster 1 events                                                cluster 2 events')
    grid('on')
    box('on')


    xt = xticks;
    for i2 = 1:(numel(xt)-1)
        if i2 == numel(xt)/2
        plot([i2+0.5, i2+0.5],ylim_mat(i3,:),'k-','HandleVisibility','off','LineWidth',1.5);
        else
            plot([i2+0.5, i2+0.5],ylim_mat(i3,:),'k-','HandleVisibility','off');
        end
    end
end




for i2 = 1:numel(bp); bp(i2).MemberColors = colmat; end


gh = gfx2('fh',fh);
gh.remove_inner({'xticks','xlabels'});

lh = legend({cfg(1:end).lbl},'Interpreter','none');
lh.Interpreter = 'none';
gh.apply([gh.width.dc,gh.height.page/2.5],'margins',[0.1,0.1,0.1,0.1],'frame',[1,0.1,2,1],...
    'leg_pos','top-right','ylabel_adjust',-0.2,'xlabel_single',true)
% gh.enumerate()
gh.save(path_figs);


perf_tbl = table('RowNames',{cfg.lbl});

for perf_str = perf_lbls
    perf_str = char(perf_str);
    mean_perf = nan(numel(cfg),n_events);
    var_perf = nan(numel(cfg),n_events);
    for i4 = 1:numel(cfg)
        mean_perf(i4,:) = nanmean(cfg(i4).perf.(perf_str),2);
        var_perf(i4,:) = nanvar(cfg(i4).perf.(perf_str),[],2);
    end

    switch perf_str
        case {'pfe','mve'}
            mean_perf = abs(mean_perf);
            ordr = 'ascend';
        case {'kge'}
            ordr = 'descend';
    end

    [~,rnk_ind] = sort(mean_perf,1,ordr);
    [~,rnk] = sort(rnk_ind,1,'ascend');
    clear rnk_ind
    perf_tbl(:,[perf_str,' rank']) = table(mean(rnk,2));
    perf_tbl(:,[perf_str,' var']) = table(mean(var_perf,2));
end

tex = tex_tbl(perf_tbl);

expstr = @(x) [x(:).*10.^ceil(-log10(abs(x(:)+(x==0)))) floor(log10(abs(x(:)+(x==0))))];       % Updated: 2021 05 04
expstr2 = @(x) {sprintf('%.2fE%+d', expstr(str2num(char(x))))};

tex = tex.format('cols',[2,4,6],'stat','all','fun',{expstr2});


tex = tex.escape();
tex = tex.format('stat','min','cols',1:width(tex.tbl),'exclude',[1],'fun',tex.styles.bold());
tex = tex.format('rows',[1],'stat','all','fun',tex.styles.it());





tex = tex.format('cols',[1,2,3],'stat','all','fun',tex.styles.it());

tex.save([path_tbls,[catchment,'_combination_tbl','.tex']])

