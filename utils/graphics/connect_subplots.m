function connect_subplots()


ahs = findall(fh,'type','axes'); %axes handles

set(fh,'Units','normalized');
for i5 = 1:numel(fh.Children)
    ahs(i5).Units = 'normalized';
    ahs(i5).Title.Position(1) = 0;
end


[fh,pos] = reorder_subplots(fh);
ahs = findall(fh,'type','axes'); %axes handles

zoomline_col = gp.c.purple;


fh.Children = fh.Children([2,1]);



fh.Children(1).XLabel.String = '';
%     fh.Children(2).XTickLabels = '';


k2 = 1;

k2 = 2;



x1 = fh.Children(2).Position(1);

y1 = fh.Children(2).Position(2) + fh.Children(2).Position(4);


x2 = fh.Children(1).Position(1) + fh.Children(1).Position(3) * ...
    interp1(linspace(fh.Children(1).XLim(1),fh.Children(1).XLim(2),100),linspace(0,1,100),fh.Children(2).XLim(1));




y2 = fh.Children(1).Position(2);% + fh.Children(1).Position(4);
x3 = x2;
y3 = fh.Children(1).Position(2) + fh.Children(1).Position(4);
l1 = annotation('line',[x1,x2],[y1,y2],'LineWidth',gp.lw0,'LineStyle','-','Color',zoomline_col);
l2 = annotation('line',[x2,x3],[y2,y3],'LineWidth',gp.lw0,'LineStyle','-','Color',zoomline_col);

x1 = fh.Children(2).Position(1) + fh.Children(2).Position(3);
y1 = fh.Children(2).Position(2) + fh.Children(2).Position(4);
x2 = fh.Children(1).Position(1) + fh.Children(1).Position(3) * ...
    interp1(linspace(fh.Children(1).XLim(1),fh.Children(1).XLim(2),100),linspace(0,1,100),fh.Children(2).XLim(2));
y2 = fh.Children(1).Position(2);% + fh.Children(1).Position(4);
x3 = x2;
y3 = fh.Children(1).Position(2) + fh.Children(1).Position(4);
annotation('line',[x1,x2],[y1,y2],'LineWidth',gp.lw0,'LineStyle','-','Color',zoomline_col);
annotation('line',[x2,x3],[y2,y3],'LineWidth',gp.lw0,'LineStyle','-','Color',zoomline_col);

x1 = fh.Children(1).Position(1) + fh.Children(1).Position(3) * ...
    interp1(linspace(fh.Children(1).XLim(1),fh.Children(1).XLim(2),100),linspace(0,1,100),fh.Children(2).XLim(2));
x2 = fh.Children(1).Position(1) + fh.Children(1).Position(3) * ...
    interp1(linspace(fh.Children(1).XLim(1),fh.Children(1).XLim(2),100),linspace(0,1,100),fh.Children(2).XLim(1));

y1 = fh.Children(1).Position(2) + fh.Children(1).Position(4);
y2 = fh.Children(1).Position(2);
annotation('line',[x1,x2],[y1,y1],'LineWidth',gp.lw0,'LineStyle','-','Color',zoomline_col);
annotation('line',[x1,x2],[y2,y2],'LineWidth',gp.lw0,'LineStyle','-','Color',zoomline_col);

fh.Children(2).XColor = zoomline_col;
fh.Children(2).YColor = zoomline_col;
fh.Children(2).XLabel.Position(2) = fh.Children(2).XLabel.Position(2) + 0.5;
axes(fh.Children(1));
legend('location','northwest','Interpreter',"tex")
