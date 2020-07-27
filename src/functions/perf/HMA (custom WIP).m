


qo = [3 3 4 20 62 85 33 20 5];
qs = [5 12 65 43 34 28 13 12 22];

qo = [3 3 4 20 62 85 33 20 1];
qs = [5 12 65 43 34 28 1 1 22];

w1 = 1;
w2 = 3;
b = 0.01;
js=1;
n = numel(qo);
largeNum = 1000000;
C = largeNum * ones(numel(qs),numel(qo),2);
% A1 = zeros(numel(qs),numel(qo));

%define penalty function
ef = @(qs,qo,j,k) ((qs(j) - qo(k))^2) + (b^2) * ((j - k)^2);


for j = 1:(1+w1)
    k = 1;
    e = ((qs(j) - qo(k))^2) + (b^2) * ((j - k)^2);
    C(j,1,1) = e;
    A1(j,k) = e;
end

for k = 2:n
    for j = (k-w2):(k+w1)
        if (j<1) || (j>n)
            disp('outside hydrograph cycle')
            continue
        end
        e = ef(qs,qo,j,k);
        %calc. repeated ray (connected to same qs(j) as previous observed
        %point)
        %I think to add more than one repeat, would need to increase the
        %third dimension such that 1 = no repeat, 2 = one repeat, 3 = two
        %repeats, etc.
        
        
        C(j,k,2) = e + C(j,k-1,1);
        
        %this MORE SKIPS edit is correct, but causing a conflict for some
        %reason. May need to hard code forward time rule????????
        
%         A1(j,k) = e;
        j0 = (j-(1:(js+1)));
        j0 = j0(j0>0); %temporary j ind
        m0 = squeeze(C(j0,(k-1),:));    
        m = min(m0(:));
        clear vars j0 m0
        
        if size(m,1) ~= 0
            C(j,k,1) = e + m; 
        end
    end
end

figure(1)
clf
[~,rayInds] = min(min(C,[],3),[],1);
% C = C .* double(C<largeNum);
Fsim = min(min(squeeze(C(:,n,:))));
rays = [qo;qs(rayInds)];

plot(qo,'o-','DisplayName','Observed')

hold on
plot(qs,'o-','DisplayName','Simulated')
plot([1:n;rayInds],rays,':','DisplayName','Rays','HandleVisibility','off',...
    'Color','black')
legend('location','best')

