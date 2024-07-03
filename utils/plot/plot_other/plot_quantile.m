function ah = plot_quantile(q,varargin)
q = q(~isnan(q));

[q_sorted,q_ind] = sort(q);
x = 1 - ((1:numel(q))./numel(q));
y = q_sorted;
plot(x,y,varargin{:})
ah = gca;
ah.YScale = 'log';
end
