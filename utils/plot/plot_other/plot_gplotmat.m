function plot_gplotmat(x,x_classes,x_labels,varargin)


% gp = gfx('elsevier','lassonde');

par = inputParser;
addParameter(par,'plotargs',{})
addParameter(par,'colmat',[1,1,0;1,0,1;0,1,1;1,0,0;0,1,0;0,0,1])

parse(par,varargin{:});
plotargs = par.Results.plotargs;
colmat = par.Results.colmat;
num_classes = numel(unique(x_classes));
num_vars = size(x,2);
k2 = 0;
classes = unique(x_classes);

for i2 = 1:num_vars
    for i3 = 1:num_vars
        k2 = k2 + 1;
        subplot(num_vars,num_vars,k2);
        %
        for i4 = 1:num_classes
            colr = colmat(i4,:);
            idx = x_classes == classes(i4);
            if i2 == i3
                histogram(x(idx,i2),'FaceColor',colr);
                hold on
            else
                plot(x(idx,i3),x(idx,i2),'o','DisplayName',num2str(classes(i4)),'Color',colr,'MarkerFaceColor',colr,plotargs{:});
                hold on
            end
        end
        

        ahs = findall(gcf,'type','axes');
        
%         xticks('auto');% = linspace(ahs(1).XLim(1),ahs(1).XLim(2),5);
%         yticks('auto');
%         ahs(1).YTick('auto');% = linspace(ahs(1).XLim(1),ahs(1).XLim(2),5);

%         ahs(1).XTickLabels = num2cell(ahs(1).XTick);
%         ahs(1).XTickLabels([1,end]) = {[],[]};
%         ahs(1).YTick = linspace(ahs(1).YLim(1),ahs(1).YLim(2),5);
%         ahs(1).YTickLabels = num2cell(ahs(1).YTick);
%         ahs(1).YTickLabels([1,end]) = {[],[]};
        
        
%         if (i3 == 2) && (i2 == 1); ahs(2).YTickLabels = ahs(1).YTickLabels; end % fix ylims for top-left plot
        if i3 > 1; ahs(1).YTickLabels = []; else; ahs(1).YLabel.String = x_labels{i2};end
        if i2 ~= num_vars; ahs(1).XTickLabels = []; else; ahs(1).XLabel.String = x_labels{i3}; end

        
        ahs(1).XTickLabels = [];
        ahs(1).YTickLabels = [];
        ahs(1).XTick = [];
        ahs(1).YTick = [];
        
    end
end

for i2 = 1:numel(ahs)
    ahs(i2).YLabel.Interpreter = 'None';
    ahs(i2).XLabel.Interpreter = 'None';
end