function y = undo_nanmask(x, nanmask)
n = numel(nanmask);
y = nan(n,1);
y(~nanmask) = x;
end