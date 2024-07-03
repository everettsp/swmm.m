function plot_uncertainty(results_uncertainty, path_figs)

unpack_struct(results_uncertainty);

ecl = setup_eventclass(events_rr);
idx1 = ecl(1).idx;
idx2 = ecl(2).idx;

gp = gfx('tex','lassonde');
colmat = [gp.c.blue;gp.c.purple;gp.c.red;gp.c.yellow;gp.c.green;[0,0,1]];
%
% figure("Name",[catchment,'_vars_histo']);
% pram_names = ga_load_vars(scenarios{1}).attribute;
%
%
% for i3 = 1:numel(events_rr)
% for i2 = find(contains_exact(scenarios,{'normal','high_uncertainty'}))'
%     sc_names = mdl{i2,i3}.p.subcatchments.Name;
%     x = mean(ga_info{i2}(end).Population);
%     for i4 = 1:numel(pram_names)
%         subplot(2,5,i4)
%         idx = contains(mdl{i2,i3}.classes2elements(ga_load_vars).attribute,pram_names{i4});
%
%         if ~isempty(x(idx))
%             histogram(x(idx),'NumBins',10,'FaceAlpha',0.1,'Normalization',"probability",'DisplayStyle',"stairs",...
%                 'EdgeColor',colmat(i2,:),'LineWidth',1.6,"DisplayName",labels{i2})
%             %             hh = smoothhist(x(idx),20);
%             %             hh.Color = colmat(i2,:)
%             %             hh.DisplayName = scenarios{i2};
%             title(pram_names{i4},'Interpreter',"none");
%             if i4 == 10
%                 legend('Location','best','Interpreter',"none");
%             end
%         end
%         hold on
%     end
% end
%
% end
% gp.apply([gp.pgw_dc,10],'leg_pos','bottom-mid','margins','compact','bottom',0.8)
% save_fig(path_figs)
%
%


kill
fh = figure("Name",[catchment,'_optvars'])

event_symbols = {'o-','+-'};
for i3 = 1:numel(events_rr)
    % for i2 = find(contains_exact(scenarios,{'normal','high_uncertainty'}))'
    for i2 = 1:numel(scenarios)
        %     j5 = idx_events(i5);
        %     j5 = i5;
        %     load([mdl.dir_results,catchment,'_se_uncertainty_event',num2str(j5),'.mat']);
        %     subplort(1,2,i3)
        num_gens = numel(ga_info{i2});
        num_pop = size(ga_info{i2}(1).Population,1);
        x = nan(num_pop,num_gens);
        y = nan(1,num_gens);
        for g3 = numel(ga_info{i2,i3}):-1:1

            %         for g3 = 1:num_gens
            for g4 = 1:num_pop
                x(g4,g3) = -ga_info{i2,i3}(g3).Score(g4);
                y(g3) = (ga_info{i2,i3}(g3).toc) ./ 60 ./ 60;
            end
        end
        if length(y) < 20; upper = length(y); else upper = 20; end
        [ok,ue] = plot_ue(y(1:upper),x(:,1:upper),'Color',colmat(i2,:),'DisplayName',labels{i2},'MedStyle',event_symbols{i3});
        if i3 ~= 1
            ue.HandleVisibility = 'off';
        end

        if events_rr(i3).class == 1;
            textcol = ecl(1).col;
            event_text = 'C1';
        elseif events_rr(i3).class == 2;
            textcol = ecl(2).col;
            event_text = 'C2';
        else
            error('cannot set text colour')
        end
        if i2 == 4
            text(y(20).*1.05,nanmean(x(:,20)),event_text,'Color',textcol,'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top');
        end

        ue.MedPlot.MarkerSize = 4;
        hold on
        %     end
        ylabel("KGE")
        xlabel("time [hrs]")
        grid("on")
        box("on")
    end
end
gh = gfx2('fh',fh);
legend("location",'southeast',"Interpreter",'none','NumColumns',4)
gh.apply([gh.width.sc,gh.width.sc],'frame',[0.2,0,0.2,1.1],'leg_pos','top-right')
save_fig(path_figs)