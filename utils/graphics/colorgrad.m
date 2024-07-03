function [cg] = colorgrad(cols_cell,varargin)

num_cols = numel(cols_cell);
colmat = zeros(num_cols,3);
for i2 = 1:num_cols
    colmat(i2,1:3) = cols_cell{i2};
end

par = inputParser;
addParameter(par,'resolution',64*5)
addParameter(par,'scale','linear')
parse(par,varargin{:})
scale = par.Results.scale;
resolution = par.Results.resolution;

% function makes a linear colour gradient between colA and colB
num_cols = size(colmat,1);
cg = nan((num_cols-1) * resolution, 3);

switch lower(scale)
    case {'lin','linear'}
        fun_scale = @linspace;
    case {'log','logarithmic'}
        fun_scale = @logspace;
    otherwise
        error("scaling function not rtecognized, try 'linear'");
end

% resolution2 = floor(resolution/(num_cols)-1);

for i2 = 1:(num_cols-1)
idx_from = ((i2-1) * resolution + 1);
idx_to = resolution * i2;
    cg(idx_from:idx_to,:)  = [fun_scale(colmat(i2, 1),colmat(i2 + 1, 1),resolution)',...
        fun_scale(colmat(i2, 2),colmat(i2 + 1, 2),resolution)', fun_scale(colmat(i2, 3),colmat(i2 + 1, 3),resolution)'];

end

end