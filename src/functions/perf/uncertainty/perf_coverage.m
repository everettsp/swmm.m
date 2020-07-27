function [coverage] = perf_coverage(x,ys)
% x [n,1] - observed data
% ys [n,ensemble_members] - predictions
% adopted from
% Disentangling timing and amplitude errors in streamflow simulations
% Simon Paul Seibert, Uwe Ehret, and Erwin Zehe
% doi:10.5194/hess-20-3745-2016

ind = ~(isnan(x) | any(isnan(ys),2));
x = x(ind);
ys = ys(ind,:);

n = numel(x);

n_covered = sum((x < max(ys,[],2)) & (x > min(ys,[],2)));
coverage = n_covered / n;

end