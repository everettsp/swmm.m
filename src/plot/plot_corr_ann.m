function fh = plot_corr_ann(t,ys,nets_info,varargin)
%plots correlation for ensemble modelling, colorizing training and testing
%tr is the training object from the neural network
%2 colours

par = inputParser;
addParameter(par,'p',75)
addParameter(par,'subplot_names',{'training','validation';'testing','all'})
addParameter(par,'gp',gfx_properties('word','lassonde'))
parse(par,varargin{:})

p = par.Results.p;
gp = par.Results.gp;
subplot_names = par.Results.subplot_names;

if p < 50
    p = 100 - p;
end

idx_test = nets_info{1}.testInd;
idx_train = nets_info{1}.trainInd;
idx_val = nets_info{1}.valInd;
idx_cal = [idx_train;idx_val];

y_up = prctile(ys,p,2);
y_down = prctile(ys,100-p,2);
y_med = median(ys,2);

fh = figure;
fh.Name = 'correlation between observed and modelled values';
[num_rows,num_cols] = size(subplot_names);

for i2 = 1:num_rows
    for i3 = 1:num_cols
        subplot(num_rows,num_cols,sub2ind([num_rows,num_cols],i2,i3))
        title(subplot_names{i2,i3})

        switch lower(subplot_names{i2,i3})
            case {'cal','calibration','all'}
                plot([t(idx_cal) t(idx_cal)]',[y_up(idx_cal) y_down(idx_cal)]','DisplayName',['calibration (' num2str(p) '% conf.)'],...
                    'LineStyle','-','LineWidth',gp.lw,'Color',gp.c.blue,'HandleVisibility','off');
                hold on
                plot(t(idx_cal),y_med(idx_cal),'sq','Color',gp.c.blue,'DisplayName','Test (median)')
        end
        switch lower(subplot_names{i2,i3})
            case {'train','training','all'}
                plot([t(idx_train) t(idx_train)]',[y_up(idx_train) y_down(idx_train)]','DisplayName',['calibration (' num2str(p) '% conf.)'],...
                    'LineStyle','-','LineWidth',gp.lw,'Color',gp.c.blue,'HandleVisibility','off');
                hold on
                plot(t(idx_train),y_med(idx_train),'o','Color',gp.c.blue,'DisplayName','Test (median)')
        end
        switch lower(subplot_names{i2,i3})
            case {'val','validation','all'}
                plot([t(idx_val) t(idx_val)]',[y_up(idx_val) y_down(idx_val)]','DisplayName',['calibration (' num2str(p) '% conf.)'],...
                    'LineStyle','-','LineWidth',gp.lw,'Color',gp.c.yellow,'HandleVisibility','off');
                hold on
                plot(t(idx_val),y_med(idx_val),'sq','Color',gp.c.yellow,'DisplayName','Test (median)')
        end
        switch lower(subplot_names{i2,i3})
            case {'test','testing','all'}
                plot([t(idx_test) t(idx_test)]',[y_up(idx_test) y_down(idx_test)]','DisplayName',['calibration (' num2str(p) '% conf.)'],...
                    'LineStyle','-','LineWidth',gp.lw,'Color',gp.c.green,'HandleVisibility','off');
                hold on
                plot(t(idx_test),y_med(idx_test),'^','Color',gp.c.green,'DisplayName','Test (median)')
        end
        
        lims = [min([xlim ylim]) max([xlim ylim])];
        xlim(lims)
        ylim(lims)
        
        plot([-9999 9999],[-9999 9999],'--','Color',[0 0 0],'LineWidth',gp.lw0,'DisplayName','1:1','HandleVisibility','on')

        if i2 == 1
            ylabel('modelled')
        end
        
        if i3 == num_rows
            xlabel('observed')
        end
        
    end
end
apply_sqlims;

end