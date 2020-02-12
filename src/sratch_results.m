
col = gfx_colors('york');

%%
[~,j2] = max(gbl_obj{end});
gbl_obj{end}(j2)
gbl_pop{end}(j2,:)

% param_variance = prctile(gbl_pop{end}(:,:),[5 95]);
rel_change = 100*((gbl_pop{end}(j2,:) - [gbl_opt(:).init_val]) ./ [gbl_opt(:).init_val]);
% histogram(rel_change)

attributes = unique({gbl_opt(:).attribute});
attributes = attributes([11,6,5,3,4,8,9,10,2,1,7]);
mean_var = [];

for i2 = 1:numel(attributes)
    subplot(3,4,i2);
    attribute = attributes{i2};
    idx = strcmp({gbl_opt(:).attribute},attribute);
    xl = mean([gbl_opt(idx).uncertainty_val]);
    histogram(rel_change(idx),'NumBins',6,'FaceColor',col.blue,'FaceAlpha',1);
    title(attribute,'interpreter','none')
%     mean_var(i2) = mean(param_variance(idx));
    xlim(100*(xl .* [-1,1]));
end
%%
plot_uncertainty_envelope([gbl_obj{:}]',0:(numel(gbl_obj)-1))