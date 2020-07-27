function [xsynth, ysynth] = smoter(x,y,p,k)
%

if p < 1
    p = p .* 100;
end

% x:   target data
% y:   feature set
% rf:  relevance function
% rtt: relevance threshold
% N:   x100% to resample
% k:   nearest neighbours

% y = tt_tgt.Variables;
% x = tt_inp.Variables;
% rd = rd_funs;
% rf = rd.logi; % relevance function
% rth = 0.5; % relevance threshold
% N = 3;
% k = 5; % number of nearest neighbour

idx = isnan(y) | any(isnan(x),2);



y = y(~idx);
x = x(~idx,:);
d = [x,y];
nf = size(d,2); % number of features


hft = prctile(y,p);

% w = rf(y); % sample relevance
% rlo = (y < hft) & (y < median(y)); % rare low sample
rhi = (y >= hft) & (y > median(y)); % rare high sample
r = find(rhi); % rare sample indices

N = 100 ./ (100 - p);


nn_inds = nan(numel(r),k); % k nearest neighbours for each rare sample

for i2 = 1:numel(r)
    knn = knnsearch(d,d(r(i2),:),'k',k+1);
    nn_inds(i2,:) = knn(2:end);
end

k2 = 1; % counter
synth = nan(numel(r)*N,nf);
for i2 = 1:numel(r)
    for i3 = 1:N
        ki = randi(k); % random nearest neighbour
        diff = d(nn_inds(i2,ki),:) - d(r(i2),:); % diff. between rare sample and random nearest neighbour
        gap = rand; % random perm
        synth(k2,:) = d(r(i2),:) + gap .* diff;
        k2 = k2 + 1;
    end
end

ysynth = synth(:,end);
xsynth = synth(:,1:(end-1));
% for i2 = 1:N
%     
% end
% 
% histogram(y);
% hold on
% histogram(ysynth);
end