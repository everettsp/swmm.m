function [kge,mse_cor,mse_var,mse_bias] = perf_kge(x,y,f)
%% get Kling-Gupta Efficiency performance measures
ind = ~(isnan(x) | isnan(y));
x = x(ind);
y = y(ind);

% T = T.* mask;
% Y = Y.* mask;
% ind = ~(isnan(T) | isnan(Y));

%% Nasch-Sutcliffe CE
% NSE = 1 - sum((y - x).^2) / sum((x - mean(x)).^2); %Nash-Sutcliffe CE
%% Kling-Gupta decomposition (Gupta et al. 2009)
% Y = simulated & T = observed
std_y = std(y);
std_x = std(x);
mu_y = mean(y);
mu_x = mean(x);
cov_xy = cov(x,y);
cov_xy = cov_xy(1,2);

r = cov_xy / (std_y * std_x);
alpha = std_y / std_x;
% BetaN = (mu_y - mu_x) / std_x;
beta = mu_y / mu_x;

% NSE = 2 * alpha * r - alpha^2 - BetaN^2;

ED = sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2);
kge = 1-ED;

mse_cor = 2 * std_y * std_x * (1 - r);
mse_var = (std_y - std_x)^2;
mse_bias = (mu_y - mu_x)^2;

mse_total = mse_cor + mse_var + mse_bias;
fMSEc = mse_cor / mse_total;
fMSEv = mse_var / mse_total;
fMSEb = mse_bias / mse_total;



%     terplot(5); hold on
%     colormap(jet)
%     [hd,hcb] = ternaryc([0.2;0.1],[0.3;0.2],[0.5;0.6],v(1:2),'o')

if nargin > 2
    figure(203)
    subplot(1,2,1)
    pie([fMSEc fMSEv fMSEb])
        legend({'Correlation','Variance','Bias'},'Location','northwest')
        title('Kling-Gupta decomposition')
    subplot(1,2,2)
    plot(T,Y,'o'); hold on
    plot([min([T' Y']) max([T' Y'])],[min([T' Y']) max([T' Y'])],'--','Color','black','LineWidth',1,'DisplayName','1:1') %'HandleVisibility','off') 
        xlim([min([T' Y']) max([T' Y'])])
        ylim([min([T' Y']) max([T' Y'])])
        title(['Correlation'])
        xlabel('Observed');
        ylabel('Modelled');
end


end