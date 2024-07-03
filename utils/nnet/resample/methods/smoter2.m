function [xsynth, ysynth] = smoter2(x,y,rf,rth,N,k)
%
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

w = rf(y); % sample relevance
rlo = (w > rth) & (y < median(y)); % rare low sample
rhi = (w > rth) & (y > median(y)); % rare high sample
r = find(rlo | rhi); % rare sample indices

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

ysynth = synth(:,1);
xsynth = synth(:,2:end);
% for i2 = 1:N
%     
% end

end