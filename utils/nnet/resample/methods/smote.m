function [xsynth, ysynth] = smote(x,y,varargin)
%

par = inputParser;
addParameter(par,'k',5)
addParameter(par,'N',10)
addParameter(par,'fun_binary','')
parse(par,varargin{:})

k = par.Results.k;
N = par.Results.N;
fun_binary = par.Results.fun_binary;


if islogical(y)
    y = double(y);
end

idx = isnan(y) | any(isnan(x),2);

y = y(~idx);
x = x(~idx,:);
d = [x,y];
nf = size(d,2); % number of features


% w = rf(y); % sample relevance
% rlo = (y < hft) & (y < median(y)); % rare low sample

is_binary = all(y == 0 | y == 1 | isnan(y));
if is_binary
    y_binary = y;
else
    if ~isa(fun_binary, 'function_handle')
        error("'fun_binary' input must be a function with input 'y' and output 'y' in binary")
    end
    y_binary = fun_binary(y);
end


r = find(~(y_binary == 0)); % rare sample indices
nn_inds = nan(numel(r),k); % k nearest neighbours for each rare sample

for i2 = 1:numel(r)
    knn = knnsearch(d(r,:),d(r(i2),:),'k',k+1); % search for nearest points that are also minority
    nn_inds(i2,:) = r(knn(2:end)); % nn inds within the full data sequence
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

end