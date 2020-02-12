function fh = plot_timeseries(tt_obs,tt_mod,varargin)
%input observed and ensemble timeseries, and percentiles (ie. [75 99])
%calculate percentiles and store in timetable

par = inputParser;
addParameter(par,'p',75)
addParameter(par,'precip',timetable())

parse(par,varargin{:})
p = par.Results.p;
tt_precip = par.Results.precip;

gfx = gfx_properties('word','lassonde');

%remove median if included (since it will always calculate this either way)

if p < 50
    p = 100 - p;
end

fh = figure;
fh.Name = 'observed verus modelled hydrographs';

plot(tt_obs.Time,tt_obs.Variables,'DisplayName','observed',...
    'LineStyle','-','Color',[0 0 0],'LineWidth',gfx.lw0);
hold on

plot(tt_mod.Time,median(tt_mod.Variables,2),'DisplayName','modelled median',...
    'LineStyle','--','Color',gfx.c.blue,'LineWidth',gfx.lw0);

tt_conf = timetable(tt_mod.Time);
tt_conf(:,['p' num2str(100-p)]) = table(prctile(tt_mod.Variables,100-p,2));
tt_conf(:,['p' num2str(p)]) = table(prctile(tt_mod.Variables,p,2));

% find the discontinuities in the data
data_starts = find(~any(isnan(tt_mod.Variables),2) & any(isnan([nan(1,width(tt_mod));tt_mod(1:end-1,:).Variables]),2)); %lag down
data_ends = find(~any(isnan(tt_mod.Variables),2) & any(isnan([tt_mod(2:end,:).Variables;nan(1,width(tt_mod))]),2)); %shit up

% edge conditions
if data_ends(1) < data_starts(1)
    data_starts = [1 data_starts];
end

if data_starts(end) > data_starts(end)
    data_ends = [data_ends height(tt_mod)];
end

% plot continuous segments
for i2 = 1:numel(data_starts)
    idx = data_starts(i2):data_ends(i2);
	temp = fill([tt_conf.Time(idx); flipud(tt_conf.Time(idx))],[tt_conf(idx,['p' num2str(100-p)]).Variables; flipud(tt_conf(idx,['p' num2str(p)]).Variables)],...
        gfx.c.blue,'EdgeColor',gfx.c.blue,'FaceAlpha',0.5,'EdgeAlpha',0.8);
    
    if i2 == 1
        temp.DisplayName = ['modelled ' num2str(p) '% conf.'];
    else
        temp.HandleVisibility = 'off';
    end
end
  

legend('location','best')

%if precipitation is input, plot hyetograph
if ~isempty(tt_precip)
    yyaxis right
    ah2 = gca;
    ah2.YDir = 'reverse';
    ah2.YColor = 'black';
    ylabel('Precipitation depth [mm]')
    bar(tt_precip.Time,tt_precip.Variables/10,1,...
        'EdgeColor',colmat(4,:),'FaceColor',colmat(4,:),'DisplayName','Precipitation')
    rightLims = ylim;
    ylim([rightLims(1) rightLims(2)*3])
end
