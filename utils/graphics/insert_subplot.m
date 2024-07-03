%this script will insert open figures into a subplot
%figureNums is the figure numbers you want to insert

%if it's a subplot, do [figureNum subplotNum}

figureNums = [[2 1];[1 1]]';%[502 1]]';
%       [figure#   axis#]
titleStr = {'Peak error','SD error','HMA error'};


for ii = 1:size(figureNums,2)
fh = figure(999)
sph1 = subplot(1,size(figureNums,2),ii);

figure(figureNums(1,ii))
    fh = gcf;
    ah = fh.Children(figureNums(2,ii));
%     ahc = get(ah,'children');
    
%     if numel(figureNums{ii}) == 2
%         ahc = get(ahc,'children')
%     end
% ah = gca;

ahc = get(ah,'children');

figure(999)
copyobj(ahc,sph1)
legend('location','northeast')
ylim([0 105])
xticklabels('')
yticklabels('')
title(titleStr{ii})
% legend()
end


%% corrections
subplot(1,size(figureNums,2),1)
title('Timing error')
xlim([-12 12])
ylim([0.8 1])
grid on

subplot(1,size(figureNums,2),3)
title('Series distance')
ylim([1.5 3.25])
xlim auto
savexlim = xlim;
saveylim = ylim;
savexticks = xticks;
xticklabels(datestr(nnd(1).targets.Properties.RowTimes(savexticks),'dd-mmm'));
xtickangle(45)
% savexticks = xticks;
grid on

subplot(1,size(figureNums,2),2)
title('Peak flow error')
xlim(savexlim)
ylim(saveylim)
xticks(savexticks)
xticklabels(datestr(nnd(1).targets.Properties.RowTimes(savexticks),'dd-mmm'));
xtickangle(45)
grid on

%%
f = setupGraphics('poster','lassonde')
set(findall(fh,'-property','FontSize'),'FontSize',f.Tb);
set(findall(fh,'-property','FontName'),'FontName',f.F);
set(fh,'Units','Centimeters');
set(fh,'PaperUnits','Centimeters');
set(fh,'Position',[1 1 f.W f.H]);
set(fh,'PaperSize',[f.W f.H]);


savepath = nnc0.savepath;
filename = [savepath '\figures\' 'PeakErrorExamples'];
print(fh,filename,'-dtiffn','-r600')