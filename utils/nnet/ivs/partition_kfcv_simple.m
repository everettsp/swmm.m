function inds = partition_kfcv_simple(n,k,j2)%,ynPlot)
% returns inds for block sample k-fold cross-validation
% requires inputs (num_samples, num_folds, fold_ids)

divs = divisors(n);
if ~any(k == divs) % num samples MUST be divisible by number of folds
    [~,k_ind] = min(abs(divs - k));
    k_reco = divs(k_ind);
    error(['n mod k must be 0; trim data or find new k; clostest k value is ',num2str(k_reco)])
end

assert(all(ismember(j2,(1:k))), 'fold ind must not exceed number of folds');
assert(mod(n,k) == 0,['n mod k must be 0; trim data or find new k; possible k values include: ' num2str(divisors(n))]);
assert(any(size(j2) == 1), 'fold IDs must be 1D array')

fold_len = floor(n./k);
inds = NaN(fold_len .* numel(j2),1);

for i2 = 1:numel(j2)
    inds((1:fold_len) + (fold_len .* (i2 - 1))) = (1:fold_len) + fold_len .* (j2(i2)-1);
end

end