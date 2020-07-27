function [prc] = perf_prc(x,ys,varargin)
% x [n,1] - observed data
% ys [n,ensemble_members] - predictions
% adopted from
% Disentangling timing and amplitude errors in streamflow simulations
% Simon Paul Seibert, Uwe Ehret, and Erwin Zehe
% doi:10.5194/hess-20-3745-2016

par = inputParser;
addParameter(par,'scale',true)

parse(par,varargin{:})
scale = par.Results.scale;


ind = ~(isnan(x) | any(isnan(ys),2));

x = x(ind);
ys = ys(ind,:);

n = numel(x);

if scale
    prc = (1/n) * sum(...
        (max(ys,[],2) - min(ys,[],2)) ./ x);
else
    prc = (1/n) * sum(max(ys,[],2) - min(ys,[],2));
end

end