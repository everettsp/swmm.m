function [obs_events,mdl_events] = get_events(obs,mdl,obs_prom,hiflo,matchintvl,f)

if nargin < 5
    matchintvl = [10 10]; disp('search window not input, using default value')
elseif nargin < 4
    hiflo = 60; disp('threshold not input, using default value')
elseif  nargin < 3
    obs_prom = 0.1;  disp('prominence not input, using default value')
end

if nargin == 6
    figure
    findpeaks(obs,'Annotate','extents','WidthReference','halfheight','MinPeakProminence',obs_prom);
end
    
[obs_events] = getProminentPeaks(obs,hiflo,obs_prom);
% [yIds] = getProminentPeaks(y,hft,promO);

obs_events_num = size(obs_events,1);
% nEventsM = size(yIds,1);

%amount overlapping
% ovlpPrcntO = NaN(nEventsO,1);
% ovlpPrcntM = NaN(nEventsM,1);

%indices in counterpart of matching events...
% attIndO = NaN(nEventsO,1);
% attIndM = NaN(nEventsM,1);


mdl_events = zeros(size(obs_events));
mdl_events(:,[1 3]) = obs_events(:,[1 3]);

%for each observed event, cycle through the modelled events, calculate overlap
%if there's any overlap, modify attInd and overlap percent
for ii = 1:obs_events_num
    obs_start = obs_events(ii,1); %start ind
    obs_end = obs_events(ii,3); %end ind
    obs_rng = obs_start:obs_end; %domain
    search_ind = (obs_events(ii,2)-matchintvl(1)):(obs_events(ii,2)+matchintvl(2));
    [~,match_ind] = max(mdl(search_ind));
    mdl_events(ii,2) = match_ind + search_ind(1) - 1;
    
%     for ii2 = 1:nEventsM
%         sEventM = yIds(ii2,1); %start ind
%         eEventM = yIds(ii2,3); %end ind
%         dEventM = sEventM:eEventM; %domain
%         ovlp = intersect(dEventO,dEventM);
        
%         %overlap must be at least 3 points
%         if  (tIds(ii,2) - yIds(ii2,2)) <= sw(1) && (tIds(ii,2) - yIds(ii2,2)) >= -sw(2) %%  %(numel(ovlp)/numel(dEventO)) < 0.50
%             disp('match found')
%             ovlpPrcntO(ii) = numel(ovlp)/numel(dEventO);
%             ovlpPrcntM(ii2) = numel(ovlp)/numel(dEventM);
%             attIndM(ii2) = ii; %store the index of the match
%             attIndO(ii) = ii2; % ^^
%             break
%         end
        
%         %if it doesn't find a match, store the overlap of 0
%         ovlpPrcntO(ii) = numel(ovlp)/numel(dEventO);
%     end
%     %if it doesn't find a match, store the overlap of 0
%     ovlpPrcntM(ii2) = numel(ovlp)/numel(dEventM);

%for now just make yIds the same as tIds...
% yIds = yIds(attIndO(~isnan(attIndO)),:);
% yIds(:,[1 3]) = tIds(:,[1 3]);
end

% minOvlp = 0.20; %minimum overlap between events
% matches = minOvlp < ovlpPrcntO & minOvlp < ovlpPrcntM(attIndO);
% 
% disp([num2str(nEventsO) ' obs. and ' num2str(nEventsM) ' mod. events identified'])
% disp([num2str(nnz(matches)) '/' num2str(numel(matches)) ' obs. events matched, remainder discareded'])
% 
% 
% 
% tIds = tIds(matches,:);
% yIds = yIds(attIndO(matches),:);
% clear vars numEventsO numEventsM ovlpPrcntO ovlpPrcntM attIndO attIndM
% %at this point, tIds and yIds must contain the same number of events

end

function [eventIds] = getProminentPeaks(x,highflowPercent,peakProminence)
%% this function returns the start, major peak, and end indices for a hydrological timeseries
% input t = timeseries (array), prct = high flow percentile, prom = peak prominence
% output [start peak end] where events are distinguished by rows

if nargin < 2
    highflowPercent = 60;
end

if nargin < 3
    peakProminence = .5;
end

x_hf = x; %high flows only
t_threshold = prctile(x,highflowPercent);
eventIdx = x_hf >= t_threshold;
x_hf(eventIdx==0) = NaN;

% tDatum = t - min(t);
% [pks,locs,w,p] = findpeaks(tDatum,'WidthReference','halfheight','MinPeakProminence',prom);

%ugly workaround for getting width locations
fh = figure(9999);

findpeaks(x_hf,'Annotate','extents','WidthReference','halfheight','MinPeakProminence',peakProminence)
[~,x_locs,~,~] = findpeaks(x_hf,'WidthReference','halfheight','MinPeakProminence',peakProminence);

ax = gca;
lines = ax.Children;
wloc = [lines(2).XData' lines(1).XData'];
wloc = wloc(~any(isnan(wloc),2),:);
wloc = wloc(1:2:end,:);
close(fh)

eventIds = [wloc(:,1) x_locs wloc(:,2)];

%make sure start/end times are not the same for any events
if size(eventIds,1) > 1
    for ii = 2:size(eventIds,1)
        if eventIds(ii,1) == eventIds(ii-1,3)
            eventIds(ii-1,3) = eventIds(ii-1,3)-1;
        end
    end
end

end
% clf; plot(t); hold on; findpeaks(t90,'Annotate','extents','WidthReference','halfheight','MinPeakProminence',.3); hold on
% findpeaks(t90,'Annotate','extents','WidthReference','halfheight','MinPeakProminence',.1)


