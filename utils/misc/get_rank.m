function rnk = get_rank(x,kwd,dim)


if nargin < 2
    kwd = 'ascend';
end

if nargin < 3
    dim = 1;
end

assert(any(ismember(kwd,{'ascend','descend'})),'second arg must be ascend or descend')

[~,ncols] = size(x);
transpose_1d = ncols == 1;


if dim == 2 || transpose_1d
    x = x';
elseif dim == 1
else
    error('input array cannot exceed 2 dims')
end

rnk = nan(size(x));

for i2 = 1:size(x,dim)
    [~,idx] = sort(x(i2,:),kwd);
    rnk(i2,idx) = 1:length(x(i2,:));
end

if dim == 2 || transpose_1d
    rnk = rnk';
end


end