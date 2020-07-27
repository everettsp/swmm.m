
kill
ii = 8;
iii = 1;


tt_x = nnd(ii).inputs;
tt_t = nnd(ii).targets;

date_start = datetime(2005,6,4,00,00,00);
date_range = timerange(date_start,datestr(addtodate(datenum(date_start),1,'month')));
date_range = 1:length(tt_t.Variables);

tt_x = tt_x(date_range,:);
tt_t = tt_t(date_range,:);

x = table2array(tt_x);
t = table2array(tt_t);

y = nan(size(t));

nets_lsb = nnd(ii).nets{iii};
trs_lsb = nnd(ii).trainings{iii};
num_boosts = length(nets_lsb);

% for iv = 1:num_boosts
%     net = nets_lsb{iv};
%     y = net(table2array(x)');
%     nse = fun_nse(t,y);
% end
Yb = zeros(size(t,1),num_boosts);


num_boosts = numel(nets_lsb);
net = nets_lsb{1};
Yb(:,1) = net(x')';
rho = 1;
learning_rate = 1;

for iv = 2:num_boosts
    net = nets_lsb{iv};
    tr = trs_lsb{iv};
    rho(iv) = tr.lsb_rho;
    learning_rate(iv) = tr.lsb_learn_rate;
    Yb(:,iv) = net(x')';
end

fun_nse = @(x,y) 1 - sum((x-y).^2) / sum((x-mean(x)).^2);
fun_rmse = @(x,y) (mean((x-y).^2))^0.5;

plot(t)
hold on
for iv = 1:num_boosts
    y = sum(Yb(:,1:iv) .* learning_rate(1:iv) .* rho(1:iv), 2);
    notnan = ~(isnan(y) | isnan(t));
    nse(iv) = fun_nse(t(notnan),y(notnan));
    rmse(iv) = fun_rmse(t(notnan),y(notnan));
    plt = plot(y,'-','DisplayName',['boost_' num2str(iv)],'LineWidth',2);
    plt.Color = [plt.Color 0.5];
end
legend('location','best')

%%

t2 = nets_lsb{1}(x')' - t;
y2 = nets_lsb{2}(x')';
plot(t2,y2,'o')
