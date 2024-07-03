function plot_fdc(q_in)
q = q_in(~isnan(q_in));
[q_sorted,~] = sort(q,'descend');
n = numel(q);
pe = (1:n) ./ (n+1);
plot(pe, q_sorted,'.-');
end