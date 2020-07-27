function [mse, f1, f2, f3] = perf_mse_decomp(o,s)
%% get mse decomposition
ind = ~(isnan(o) | isnan(s));
o = o(ind);
s = s(ind);

% T = T.* mask;
% Y = Y.* mask;
% ind = ~(isnan(T) | isnan(Y));

%% Nasch-Sutcliffe CE
% NSE = 1 - sum((y - x).^2) / sum((x - mean(x)).^2); %Nash-Sutcliffe CE
%% Kling-Gupta decomposition (Gupta et al. 2009)
% Y = simulated & T = observed
std_s = std(s);
std_o = std(o);
mu_s = mean(s);
mu_o = mean(o);
cov_os = cov(o,s);
cov_os = cov_os(1,2);

r = cov_os / (std_s * std_o);
alpha = std_s / std_o;
beta_n = (mu_s - mu_o)/std_o;
beta = mu_s / mu_o;
% NSE = 2 * alpha * r - alpha^2 - BetaN^2;

ED = sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2);
kge = 1-ED;

% mse = 2 * std_s * std_o * (1 - r) + (std_s - std_o).^2 + (mu_s - mu_o).^2;

F1 = 2 * std_s * std_o * (1 - r);
F2 = (std_s - std_o)^2;
F3 = (mu_s - mu_o)^2;

sum_F = F1 + F2 + F3;
mse = sum_F;

f1 = F1 / sum_F;
f2 = F2 / sum_F;
f3 = F3 / sum_F;

%     terplot(5); hold on
%     colormap(jet)
%     [hd,hcb] = ternaryc([0.2;0.1],[0.3;0.2],[0.5;0.6],v(1:2),'o')
% 
% if nargin > 2
%     figure(203)
%     subplot(1,2,1)
%     pie([f1 f2 f3])
%         legend({'Correlation','Variance','Bias'},'Location','northwest')
%         title('Kling-Gupta decomposition')
%     subplot(1,2,2)
%     plot(T,Y,'o'); hold on
%     plot([min([T' Y']) max([T' Y'])],[min([T' Y']) max([T' Y'])],'--','Color','black','LineWidth',1,'DisplayName','1:1') %'HandleVisibility','off') 
%         xlim([min([T' Y']) max([T' Y'])])
%         ylim([min([T' Y']) max([T' Y'])])
%         title(['Correlation'])
%         xlabel('Observed');
%         ylabel('Modelled');
% end


end