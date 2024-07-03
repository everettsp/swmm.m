function plot_cvmat(cv_mat,cv_obs)

kill
fh = figure;
colrs = colors('lassonde');

k2 = 1;
plt = plt_funs();
event_inds= [1,4,6,8];


for i2 = 1:numel(event_inds)
    for i3 = 1:numel(event_inds)
        j2 = event_inds(i2);
        j3 = event_inds(i3);
        
        if j2 == j3
            colr = colrs.red;
        else
            colr = colrs.blue;
        end
        
        subplot(numel(event_inds),numel(event_inds),k2)
        tt = cv_mat{j2,j3};
        tt_obs = cv_obs{j3};
        plt.tt(tt_obs,'-','color',colrs.black,'LineWidth',1)
        hold on
        plt.tt(tt,'.-','color',colr,'LineWidth',1)
        
        ylabel(['$$\hat{y_',num2str(i2),'}$$'],'Interpreter','Latex')
%         ylim([0,25])
        xlim([tt(1,:).Properties.RowTimes,tt(end,:).Properties.RowTimes])
        xticklabels('')
        xlabel(datestr(tt(1,:).Properties.RowTimes,'dd-mmm-yy'))
        k2 = k2 + 1;
        box('off')
        grid('on')
    end
end

gh = gfx2('fh',fh);
gh.remove_inner({'xlabels','xticks','yticks','ylabels'})
gh.share_lims('y')
gh.apply([gh.width.sc,gh.width.sc],'margins',[0,0,0.1,0.1])

end
