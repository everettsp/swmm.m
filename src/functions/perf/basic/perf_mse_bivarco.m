function [mse_bias, mse_var, mse_cov] = perf_mse_bivarco(x,y)

assert(size(x,1) == size(y,1));
assert(size(x,2) == 1);
assert(size(y,2) > 1);

[n, m] = size(y);

% bias_u = mean(mean(x - repmat(mean(y),[n, 1])));
% bias_u = mean(mean((mean(y) - x),2));
% bias_u = mean((mean(y,2) - x).^2)

cov_i = NaN(n,m);

bias_u = mean(mean(y - x,2));

for i2 = 1:m
    idx = i2 ~= (1:m);
    
%     mean(y(:,idx))
    
    cov_i(:,i2) = sum((y(:,idx) - mean(y(:,idx))) .* repmat(y(:,~idx) - mean(y(:,~idx)),[1 (m-1)]),2);
end

cov_u = (1/n) .* sum((1/(m * (m-1))) .* sum(cov_i,2));
var_u = (1/n) .* sum((1/m.^2) .* sum((mean(y) - y).^2,2));



mse_bias = bias_u.^2;
% mse_bias = bias_u;
mse_var = (1/m) .* var_u;
mse_cov = (1 - (1/m)) .* cov_u;

% mse_var = var_u;
% mse_cov = cov_u;

mse_direct = (1/n) .* sum((x - mean(y,2)).^2);
mse_total = mse_bias + mse_var + mse_cov;


bv = mean(mean(mean(y,2)) - x).^2 + (1/m.^2) .* sum((mean(y,2) - mean(mean(y,2))).^2)
emse = mean((mean(y,2) - x).^2)

end