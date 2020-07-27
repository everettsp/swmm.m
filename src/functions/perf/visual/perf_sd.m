function [perf_phase,perf_ampl,obs_class,mdl_class] = perf_sd(obs,mdl,obs_events,mdl_events,search_lr,minorProm,varargin)
%% for each event:
% find critical observed points (peaks and valleys) and classify rising/falling limbs
% find matching modelled critical points based on search window and assign rising/falling
% lead = 4;

% minorProm = 0.1; %prominence threshold for minor peaks (within an event), should be smaller than prom used to ID events


par = inputParser;
addParameter(par,'plt',false)
parse(par,varargin{:})
plt = par.Results.plt;

%initialize 'tags' for hydrological cases, see getHydroDict.m for cases
obs_class = -999 * ones(size(obs));
mdl_class = -999 * ones(size(mdl));

%tag critical points (starts and ends)
obs_class(obs_events(:,1)) = 4;
obs_class(obs_events(:,3)) = -4;

mdl_class(mdl_events(:,1)) = 4;
mdl_class(mdl_events(:,3)) = -4;

%get the number of events and cycle through each event...
num_events = size(obs_events,1);

for ii = 1:num_events
    obs_start = obs_events(ii,1); %start ind
    obs_end = obs_events(ii,3); %end ind
    obs_rng = obs_start:obs_end; %domain of event
    mdl_start = mdl_events(ii,1); %start ind
    mdl_end = mdl_events(ii,3); %end ind
    mdl_rng = mdl_start:mdl_end; %domain of event

    %assign minor critical points
    [~,obs_peaklocs,~,~] = findpeaks(obs(obs_start:obs_end),'WidthReference','halfheight','MinPeakProminence',minorProm);
    
    obs_class(obs_peaklocs + obs_start - 1) = 2; %assign minor peaks
    obs_class(obs_rng) = classify_valleys(obs(obs_rng),obs_class(obs_rng)); %assign minor valeys
    obs_class(obs_rng) = classify_limbs(obs_class(obs_rng)); %assign rises and falls between minor points
    
    %get the indices of the peaks (=2) or valleys (=-2)
    obs_crits = find(mod(abs(obs_class(obs_rng)),2) == 0) + obs_start -1;

    %% for each of the local extremums, find the predicted value within the
    %search window, sw [left right]
    for ii2 = 2:(numel(obs_crits)-1)
        
        %get the search window indices, clip so that it's within the start
        %and end time (add 1 buffer point since can't start event as peak
        %or valley
        
        search_inds = (obs_crits(ii2)-search_lr(1)):(obs_crits(ii2)+search_lr(2));
        
        %make sure search window does not overlap with any other critical points...
        search_inds = search_inds(((obs_crits(ii2-1)) < search_inds) & ((obs_crits(ii2+1)) > search_inds));
        mdl_crits = find(mod(abs(mdl_class(mdl_rng)),2) == 0) + mdl_start - 1;
        search_inds = search_inds(((mdl_crits(ii2-1)) < search_inds));
        
        %whether it's a peak or valley, classify modelled crit points
        if obs_class(obs_crits(ii2)) == 2 %peak
            [~,critId] = max(mdl(search_inds)); %get the index of the extrene
            mdl_class(search_inds(critId)) = obs_class(obs_crits(ii2)); %assign tag
            
        elseif obs_class(obs_crits(ii2)) == -2 %valley
            [~,critId] = min(mdl(search_inds));
            mdl_class(search_inds(critId)) = obs_class(obs_crits(ii2));
        end

    end

    %classify the remaining points such that it follows
    % sEvent -rise- peak -fall- valley -rise- peak -fall- eEvent
    mdl_class(mdl_rng) = classify_limbs(mdl_class(mdl_rng)); %assign 1 and -1 tags for rise/fall
end



%% calculate distances between polylines
perf_phase = zeros(num_events,1);
perf_ampl = zeros(num_events,1);

for ii = 1:num_events
    
    
    obs_start = obs_events(ii,1); 
    obs_end = obs_events(ii,3); 
    obs_rng = obs_start:obs_end;
    
    mdl_start = mdl_events(ii,1); 
    mdl_end = mdl_events(ii,3); 
    mdl_rng = mdl_start:mdl_end;
    
    %get critical indices for event based on tags
    obs_crits = find(mod(abs(obs_class(obs_rng)),2) == 0) + obs_start - 1;
    mdl_crits = find(mod(abs(mdl_class(mdl_rng)),2) == 0) + mdl_start - 1;
    
    
    
    %get the polyline distance between each critial point
    for ii2 = 1:(numel(obs_crits)-1)
        
        %domain of polylines
        obs_xpoly = obs_crits(ii2):obs_crits(ii2+1); %domain (obs.)
        mdl_xpoly = mdl_crits(ii2):mdl_crits(ii2+1); %domain (mod.)
        
        if plt
            subplot(num_events,1,ii)
        end
        
        [xlen,ylen] = get_polydist(obs_xpoly,obs(obs_xpoly),mdl_xpoly,mdl(mdl_xpoly),plt);

        
        xlen = xlen(2:(end-1)); %remove critical points from polyline calc
        ylen = ylen(2:(end-1));
        
        if isempty(xlen); xlen = 0; end
        if isempty(ylen); ylen = 0; end
        
        perf_phase(ii) = perf_phase(ii) + nanmean(xlen);
        perf_ampl(ii) = perf_ampl(ii) + nanmean(ylen);
        clear vars domO domM xDist yDist
        
        
        %% PLOT RISING AND RECEDING LIMBS
        if plt
            subplot(num_events,1,ii)
            hid = get_hydrodict;
            if numel(obs_xpoly) > 3 %observed
                tag = obs_class(obs_xpoly); tag = tag(2);
                ii5 = find(tag == [hid(:,1).code]);
                
                ph1 = plot(obs_xpoly,obs(obs_xpoly),hid(ii5).mark,'DisplayName',hid(ii5,1).descr,...
                    'Color',hid(ii5).col,'LineWidth',hid(ii5).lw,'MarkerSize',hid(ii5).size); hold on

                if (ii2 > 2)% || (ii ~= 1)
                    ph1.Annotation.LegendInformation.IconDisplayStyle = 'off'; 
                end; clear vars ph1
            end
            if numel(mdl_xpoly) > 3 %modelled
                tag = mdl_class(mdl_xpoly); tag = tag(2);
                ii5 = find(tag == [hid(:,1).code]);
                ph1 = plot(mdl_xpoly,mdl(mdl_xpoly),hid(ii5).mark,'DisplayName',hid(ii5,2).descr,...
                    'Color',hid(ii5,2).col,'LineWidth',hid(ii5).lw,'MarkerSize',hid(ii5).size);
                if (ii2 > 2)% || (ii ~= 1)
                    ph1.Annotation.LegendInformation.IconDisplayStyle = 'off'; 
                end; clear vars ph1
            end
            
        end
    end
    
    %add the critical points and take the average error (on an event basis)
    perf_phase(ii) = (perf_phase(ii) + sum(obs_crits-mdl_crits))/(2*numel(obs_crits)-1);
    
    perf_ampl(ii) = (perf_ampl(ii) + sum(obs(obs_crits)-mdl(mdl_crits)))/(2*numel(obs_crits)-1);
    
    %% PLOT CRITICAL POINTS
    if plt
        subplot(num_events,1,ii)
        
        %legend placeholder
        if plt
            lw = 2;
            plot([],'-','DisplayName','Error','Color',[0 0 0],'LineWidth',lw)
        end
        
        for ii6 = [2 5 6 7]
            critIdsT0 = obs_crits(obs_class(obs_crits) == hid(ii6).code);
            critIdsY0 = mdl_crits(mdl_class(mdl_crits) == hid(ii6).code);
            plot(critIdsT0,obs(critIdsT0),hid(ii6).mark,'DisplayName',hid(ii6).descr,...
                'Color',hid(ii6).col,'LineWidth',hid(ii6).lw,'MarkerSize',hid(ii6).size,'MarkerFaceColor',hid(ii6).col);
            hold on
            try
            ph1 = plot(critIdsY0,mdl(critIdsY0),hid(ii6).mark,'DisplayName',hid(ii6).descr,...
                'Color',hid(ii6).col,'LineWidth',hid(ii6).lw,'MarkerSize',hid(ii6).size,'MarkerFaceColor',hid(ii6).col);
            ph1.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            clear vars ph1
        end
    end
end


end

function [tagEvent] = classify_valleys(t,tagEvent)
    %% classify local minima, rising, and receding peaks of an observed event
    
    minor_peak_inds = find(tagEvent == 2);
    for ii3 = 1:(numel(minor_peak_inds)-1)
        if numel(minor_peak_inds(ii3):minor_peak_inds(ii3+1)) < 3
            error('minor peaks too close together, reconfigure parameters')
        end
        [~,minor_valley_ind] = min(t(minor_peak_inds(ii3):minor_peak_inds(ii3+1)));
        minor_valley_ind = minor_valley_ind + minor_peak_inds(ii3) - 1;
        tagEvent(minor_valley_ind) = -2;
    end
    
    if mod(sum(tagEvent == 2),2) == mod(sum(tagEvent == -2),2)
        error('number of minor valleys MUST be 1 fewer than number of minor peaks')
    end
end

function [classes] = classify_limbs(classes)
    %% classify rising, and receding peaks of a predicted event
    crits = find(mod(abs(classes),2) == 0);
    for ii = 1:2:(numel(crits)-2)
            classes((crits(ii)+1):(crits(ii+1)-1)) = 1;
            classes((crits(ii+1)+1):(crits(ii+2)-1)) = -1;
    end
end


function [xd,yd] = get_polydist(x2,y2,x3,y3,plt)

    if numel(x2) == 1 || numel(x3) == 1
            xd = x2 - x3;
            yd = y2 - y3;
            if numel(x2) == 1 && numel(x3) == 1
                disp('both polyline only have one element, calculating distance between points')
            else
                disp('one polyline only has one element, calculating distance between polyline and point')
            end
    else
        nv = 1+lcm(numel(x2)-1,numel(x3)-1); %number of vertices
        x2v = linspace(x2(1),x2(end),nv); %both x2 and x3 are given the same number of vertices, nv
        x2i = linspace(1,numel(x2v),numel(x2)); %indexes of original x2 points within x2v linespace
        y2v = interp1(x2(1):x2(end),y2,x2v); %interpolate values at key points

        x3v = linspace(x3(1),x3(end),nv);
        x3i = linspace(1,numel(x3v),numel(x3));
        y3v = interp1(x3(1):x3(end),y3,x3v);
        %% plot
        if plt
            cols = get_colmat('lassonde');
            lw = 2;

%             plot(x2,y2,'o','Color',cols(1,:),'LineWidth',lw,'DisplayName','poly A')
%             hold on
%             plot(x2v,y2v,'.-','Color',cols(1,:),'LineWidth',lw,'DisplayName','interp. vert. A')
%             plot(x3,y3,'o','Color',cols(2,:),'LineWidth',lw,'DisplayName','poly B')
%             plot(x3v,y3v,'.-','Color',cols(2,:),'LineWidth',lw,'DisplayName','interp. vert. B')

%             ph = plot([x2v;x3v],[y2v;y3v],':','Color','black'); hold on
%             for jj = 1:numel(ph); ph(jj).Annotation.LegendInformation.IconDisplayStyle = 'off'; end; clear vars jj ph %REMOVE LEGEND ENTRIES

            ph = plot([x2v(x2i);x3v(x2i)],[y2v(x2i);y3v(x2i)],'-','DisplayName','Error',...
            'Color',[0 0 0],'LineWidth',lw); hold on
            for jj = 1:numel(ph); ph(jj).Annotation.LegendInformation.IconDisplayStyle = 'off'; end; clear vars jj ph %REMOVE LEGEND ENTRIES

            ph = plot([x2v(x3i);x3v(x3i)],[y2v(x3i);y3v(x3i)],'-','DisplayName','Error',...
            'Color',[0 0 0],'LineWidth',lw); hold on
            for jj = 1:numel(ph); ph(jj).Annotation.LegendInformation.IconDisplayStyle = 'off'; end; clear vars jj ph %REMOVE LEGEND ENTRIES
            
%             legend()
        end
        xd = x2v - x3v;
        yd = y2v - y3v;
    end
end
