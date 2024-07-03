function [n,idx,ldx] = split_divideparams(net,n_all)

ldx = struct();
idx = struct();
n = struct();

n.all = n_all;
idx.all = 1:n.all;

for s2 = ["train","val","test"]
    idx.(s2) = net.DivideParam.(strjoin([s2,"Ind"],''));
    ldx.(s2) = ismember(idx.all,idx.(s2));
    n.(s2) = sum(ldx.(s2));
end

ldx.cal = (ldx.train(:) | ldx.val(:))';
idx.cal = [idx.train(:); idx.val(:)];
end

