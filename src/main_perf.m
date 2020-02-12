
configuration_descriptions = {'uncalibrated','GA','EC (3hr)','EC (6hr)','EC (12hr)','EC (24hr)'};

tt_uncal.Properties.VariableNames = {'uncal'};
tt_cal.Properties.VariableNames = {'cal'};

tt_comparison = [tt_uncal,tt_cal,dat(1).tt_gahpo,dat(2).tt_gahpo,dat(3).tt_gahpo,dat(4).tt_gahpo];
perf = struct();
k2 = 1;
% event_num = [1 2 3 4 5];
for i2 = 1:2%1:10
% idx = events(i2).timesteps;
if i2 == 1
    idx = [dat(1).nets_info{1}.trainInd;dat(1).nets_info{1}.valInd];
elseif i2 == 2
    idx = dat(1).nets_info{1}.testInd;
else
    idx = [];
end
    
%     idx = dat(1).nets_info{1}.testInd;
% idx = dat(1).nets_info{1}.testInd;
for i3 = 1:width(tt_comparison)

    x = tt_obs(idx,:).Variables;
    y = tt_comparison(idx,i3).Variables;
    
    perf(k2).desc = ['event-' num2str(i2) '_' configuration_descriptions{i3}];
%     perf(k2).desc = [configuration_descriptions{i3}];
    perf(k2).nse = perf_nse(x,y);
    perf(k2).pad = perf_pad(x,y,'relative');
    perf(k2).me = perf_me(x,y,'relative');
    
    [mse,f1,f2,f3]= perf_mse_decomp(x,y);
    perf(k2).mse = mse;
    perf(k2).mse_corr = f1 * mse;
    perf(k2).mse_var = f2 * mse;
    perf(k2).mse_bias = f3 * mse;

%     subplot(3,2,i3)
%     plot_corr(x,y)
%     title(configuration_descriptions{i3})
%     ah = gca;
%     ah.Title.Interpreter = 'none';
%     if mod(i3,2) ~= 0
%         ylabel('predicted flow [m^3/s]')
%     end
%     if i3 == 5 || i3 == 6
%         xlabel('observed flow [m^3/s]')
%     end
    k2 = k2 + 1;
% end
end
end
%%

apply_sqlims;
autoformat([1 0.95],'compact','style','word')
fh = gcf; 
fh.Name = 'compare_corr';
save_fig(path_save)
% writetable(struct2table(perf),[path_project 'results/perf.xlsx'])