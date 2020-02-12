%% dummy legend
fh = figure(999)
groupInds = [2 3 4 5 6];
legendStr = {nnc(1:5).ew}';
cols = [f.Col{2};f.Col{3};f.Col{4};f.Col{5};f.Col{6};];
groupInds = [1 2 4]
colMat = cell2mat(f.Col);
colMat = colMat(groupInds,:);
for ii = 1:numel(groupInds)
    plot(0,'-','LineWidth',10,'Color',colMat(ii,:),'DisplayName',);
%     plot(0,'o-','LineWidth',4,'Color',colMat(ii,:));

    hold on
end





set(fh,'Units','Centimeters');
set(fh,'PaperUnits','Centimeters');
set(findall(fh,'-property','FontSize'),'FontSize',f.Tb);
set(findall(fh,'-property','FontName'),'FontName',f.F);
set(fh,'Position',[1 1 30 5]);
set(fh,'PaperSize',[30 5]);
legend('Location','SouthOutside','NumColumns',3)


%%

subplot(2,1,1)
imagesc(1:10000)

colormap(f.ColG)
colorbar
fh = gcf;
set(fh,'Units','Centimeters');
set(fh,'PaperUnits','Centimeters');
set(findall(fh,'-property','FontSize'),'FontSize',f.Tb);
set(findall(fh,'-property','FontName'),'FontName',f.F);

subplot(2,1,2)
legendStr = {'Observed','Modelled','Peak (O)','Ensemble KDE'}';
plot(1,'LineWidth',f.lw1/2,'Color',f.Col{4})
hold on
plot(10,'LineWidth',f.lw1/2,'Color',f.Col{3})
plot(3,'o',...
    'Color',[1 0 1],'LineWidth',0.5,'MarkerSize',12)
plot(3,'+',...
    'Color',[1 0 1],'LineWidth',0.5,'MarkerSize',16)     
set(fh,'Units','Centimeters');
set(fh,'PaperUnits','Centimeters');
set(findall(fh,'-property','FontSize'),'FontSize',f.Tb);
set(findall(fh,'-property','FontName'),'FontName',f.F);

columnlegend(4,legendStr','Location','SouthOutside')
