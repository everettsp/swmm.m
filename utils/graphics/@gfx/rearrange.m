function [obj] = rearrange(obj,varargin)


par = inputParser;
addParameter(par,'tol',0.01)
parse(par,varargin{:})
tol = par.Results.tol;


ahs = findall(obj.fh,'type','axes'); %axes handles


a2 = false(size(obj.fh.Children));
for i2 = 1:numel(obj.fh.Children)
    a2(i2) = strcmp(obj.fh.Children(i2).Type,'axes');
end

n_axes = size(ahs,1); %number of axis handles

pos_axes = zeros(n_axes,2); %subfigure positions [x,y]
for i2 = 1:n_axes
    pos_axes(i2,:) = ahs(i2).Position(1:2);
end




pos_axes = round(pos_axes,2);
% pos_axes = round(pos_axes * 5)/5; %round to nearest 0.2, since axes are not always nicely alligned...
[~,ind] = sortrows(pos_axes,[2 1],'ascend'); %order from L->R then D->U
% ahs = ahs(ind);
obj.fh.Children(a2) = ahs(ind);
obj.ahs = ahs(ind);
clear ind

n_rows = 0;
n_cols = 0;
k1 = 0;
while (n_rows * n_cols) ~= numel(ahs)
    n_rows = numel(uniquetol(pos_axes(:,2),tol));
    n_cols = numel(uniquetol(pos_axes(:,1),tol));
    tol = tol + 0.01;
    
    % break crit for runaway case (maybe if init. tol too big?)
    k1 = k1 + 1;
    if k1 > 1e4
        break
    end
end

obj.posmat = flipud(reshape(1:n_axes,n_cols,n_rows)');
% obj.ahs = ahs;

[obj.nrows,obj.ncols] = size(obj.posmat);
obj.nahs = numel(obj.posmat);


end