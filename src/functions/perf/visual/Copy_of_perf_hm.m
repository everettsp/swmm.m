function [hmt,hma] = perf_hm(t,y,tIds,yIds,w,b,varargin)
%HMA as per pseudocode provided in Ewen 2011
% synthetic hydrographs
% qo = [3 3 4 20 62 85 33 20 5];
% qs = [5 12 65 43 34 28 13 12 22];


par = inputParser;
addParameter(par,'plt',false)
parse(par,varargin{:})
plt = par.Results.plt;


nEvents = size(tIds,1);

for ii = 1:nEvents
    qo = t(tIds(ii,1):tIds(ii,3))';
    qs = y(tIds(ii,1):tIds(ii,3))';
    w1 = w(1);
    w2 = w(2);
    % w1 = lead;
    % w2 = lead;
    % b = 0.001; %important parameter... (m/ts) smaller -> timing more important
    ef = @(qs,qo,j,k) ((qs(j) - qo(k))^2) + (b^2) * ((j - k)^2);

    n = numel(qo);
    largeNum = 1000000;
    C =  largeNum * ones(numel(qs),numel(qo),2);
    A1 = zeros(numel(qs),numel(qo));
    for j = 1:(1+w1)
        k = 1;
        e = ef(qs,qo,j,k);
        C(j,1,1) = e;
        A1(j,k) = e;
    end

    for k = 2:n


        for j = (k-w2):(k+w1)
            if (j<1) || (j>n)
                continue
            end
            e = ef(qs,qo,j,k);

            %calc. repeated ray (connected to same qs(j) as previous observed
            %point)
            %I think to add more than one repeat, would need to increase the
            %third dimension such that 1 = no repeat, 2 = one repeat, 3 = two
            %repeats, etc.

            C(j,k,2) = e + C(j,k-1,1);
            A1(j,k) = e;
            if j > 1
                m = min(squeeze(C(j-1,k-1,:)));
                if j > 2
                    %this calc. is the skip, it will find minimum path out of
                    %last simulated timestep AND the one before that, such that
                    %if a value at index j-2 is minimum, it will skip the j-1
                    %ray
                    m = min([m min(squeeze(C(j-2,k-1,:)))]);
                end
                C(j,k,1) = e + m; 
            end
        end


            %invalidate pathways
            %this basically BLOCKS a repeat, but right now only for it's own
            %timestep, need to develop these rules further

        [jMin,jInd] = min(squeeze(C(:,k-1,:)));
        [~,lInd] = min(jMin);
        C(jInd(1),k,1) = 9 * largeNum;
    %     C(jInd(1)+(2:(w2+1)),k,1) = C(jInd(1)+(2:(w2+1)),k,1) + largeNum;
        if lInd == 2
            C(jInd(2),k,2) = 9 * largeNum;
    %         C(jInd(1)+(2:(w2+1)),k,2) = C(jInd(1)+(2:(w2+1)),k,2) + largeNum;
        end


    end

    % [~,rayInds] = min(C(:,:,:));
    % C = C(1:100,1:100,:);

    [~,rayInds] = min(min(C,[],3),[],1);


    hmt(ii) = mean((1:n) - rayInds);
    hma(ii) = mean( qo - qs(rayInds));

Fsim = min(min(squeeze(C(:,n,:))));
rays = [qo;qs(rayInds)];
% C = C .* double(C<largeNum);

    if plt
        cols = get_colmat('lassonde');
        lw = 2;
        ms = 2;
        subplot(nEvents,1,ii)
        
        ph = plot([1:n;rayInds],rays,'-','DisplayName','Error',...
            'LineWidth',lw/2,'MarkerSize',ms,'Color',[0 0 0]);
        hold on
        for jj = 1:numel(ph)
            ph(jj).Annotation.LegendInformation.IconDisplayStyle = 'off';
        end; clear vars ph jj
        
        plot(qo,'o-','DisplayName','Observed',...
            'LineWidth',lw','MarkerSize',ms,'Color',cols(4,:))

        plot(qs,'o-','DisplayName','Modelled',...
            'LineWidth',lw,'MarkerSize',ms,'Color',cols(3,:))
        
        %dummy legend
        plot([],'-','DisplayName','Error',...
            'LineWidth',lw/2,'MarkerSize',ms,'Color',[0 0 0]);
%         legend('location','best')
    end


end


end