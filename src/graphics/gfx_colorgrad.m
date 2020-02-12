function [colgrad] = gfx_colorgrad(varargin)

resolution = [];
colmat = zeros(2,3);

k2 = 1;

for i2 = 1:nargin
    if size(varargin{i2},2) == 3
        colmat(k2,:) = varargin{i2};
        k2 = k2 + 1;
    elseif numel(varargin{i2}) == 1
        resolution = varargin{i2};
    else
        error('input not recognized as a colour or scalar')
    end
end

if not(isempty(resolution))
    resolution = 64;
end

% function makes a linear colour gradient between colA and colB
num_cols = size(colmat,1);
colgrad = nan((num_cols-1) * resolution, 3);

for i2 = 1:(num_cols-1)
idx_from = ((i2-1) * resolution + 1);
idx_to = resolution * i2;
    colgrad(idx_from:idx_to,:)  = [linspace(colmat(i2, 1),colmat(i2 + 1, 1),resolution)',...
        linspace(colmat(i2, 2),colmat(i2 + 1, 2),resolution)', linspace(colmat(i2, 3),colmat(i2 + 1, 3),resolution)'];

end

end