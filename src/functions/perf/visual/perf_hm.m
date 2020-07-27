function [hmt,hma] = perf_hm(qo_in,qss_in,w,b,varargin)
%HMA as per pseudocode provided in Ewen 2011
% synthetic hydrographs
% qo = [3 3 4 20 62 85 33 20 5];
% qs = [5 12 65 43 34 28 13 12 22];


par = inputParser;
addParameter(par,'plt',false)
parse(par,varargin{:})
plt = par.Results.plt;

num_qs = size(qss_in,2);
for i5 = 1:num_qs
    qs_in = qss_in(:,i5);
    hmt_aggr = [];
    hma_aggr = [];
    
    
    % fill small nan gaps, iterate through larger non-nan sections
    nan_idx = (isnan(qo_in) | isnan(qs_in))';
    nan_idx_padded = [1, nan_idx, 1];
    nan_seg_ends = strfind(nan_idx_padded, [1,0]);
    nan_seg_starts = strfind(nan_idx_padded, [0,1]) - 1;
    
    nan_seg_starts = nan_seg_starts(nan_seg_starts ~= (numel(qo_in)));
    nan_seg_ends = nan_seg_ends(nan_seg_ends ~= 1);
    
    
    
    seg_lens = nan_seg_ends - nan_seg_starts;
    nan_fill_idx = seg_lens < 5; % if consecutive nan series is small, fill with fill_interp
    
    for i2 = 1:nnz(nan_fill_idx)
        sec_end = (nan_seg_ends(i2) + 1);
        sec_start = (nan_seg_starts(i2) - 1);
        qo_in(sec_start:sec_end) = fillmissing(qo_in(sec_start:sec_end),'linear');
        qs_in(sec_start:sec_end) = fillmissing(qs_in(sec_start:sec_end),'linear');
    end
    
    if nan_idx(1)
        nan_seg_starts = [1,nan_seg_starts];
    else
        nan_seg_ends = [0,nan_seg_ends];
    end
    
    if nan_idx(end)
        nan_seg_ends = [nan_seg_ends,numel(nan_idx)];
    else
        nan_seg_starts = [nan_seg_starts,(numel(nan_idx)+1)];
    end
    
    sec_starts = (nan_seg_ends + 1);
    sec_starts = sec_starts(sec_starts < numel(nan_idx));
    
    sec_ends = (nan_seg_starts - 1);
    sec_ends = sec_ends(sec_ends > 0);
    
    
    nan_itr_idx = ~nan_fill_idx;
    
    for i3 = 1:(nnz(nan_itr_idx) + 1)
        sec_start = (sec_starts(i3));
        sec_end = (sec_ends(i3));
        
        qo = qo_in(sec_start:sec_end);
        qs = qs_in(sec_start:sec_end);
        
        
        
        w1 = w(1);
        
        w2 = w(2);
        % w1 = lead;
        % w2 = lead;
        % b = 0.001; %important parameter... (m/ts) smaller -> timing more important
        ef = @(qs,qo,j,k) ((qs(j) - qo(k))^2) + (b^2) * ((j - k)^2);
        
        n = numel(qo);
        largeNum = 100000000;
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
        
        
        
        hmt_array = ((1:n) - rayInds)';
        hma_array = qo - qs(rayInds);
        
        hmt_aggr = [hmt_aggr; hmt_array]; % aggregate hmt array (for each long non-nan segment...)
        hma_aggr = [hma_aggr; hma_array];
        
        Fsim = min(min(squeeze(C(:,n,:))));
        rays = [qo,qs(rayInds)];
        
    end
    hmt(:,i5) = hmt_aggr;
    hma(:,i5) = hma_aggr;
    
end
C = C .* double(C<largeNum);
lw = 2;
ms = 2;
ph = plot([1:n;rayInds],rays','-','DisplayName','Error',...
    'LineWidth',lw/2,'MarkerSize',ms,'Color',[0 0 0]);
hold on
for jj = 1:numel(ph)
    ph(jj).Annotation.LegendInformation.IconDisplayStyle = 'off';
end; clear vars ph jj

plot(qo,'o-','DisplayName','Observed',...
    'LineWidth',lw','MarkerSize',ms)

plot(qs,'o-','DisplayName','Modelled',...
    'LineWidth',lw,'MarkerSize',ms)

%dummy legend
plot([],'-','DisplayName','Error',...
    'LineWidth',lw/2,'MarkerSize',ms,'Color',[0 0 0]);
%         legend('location','best')

end