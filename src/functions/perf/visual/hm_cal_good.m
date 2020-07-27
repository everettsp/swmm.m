n = 100;


ers_t = randi([-4,4],n,1)
ers_a = (2 * rand(n,1) - 1)./10
ttx = tt_tgt(2000:2500,:);

global ttx
global er_a
global er_t


% evaluate on each of the 100 random transformations
b_init = 0.1;
b_opt = [];
cost = [];
for i2 = 1:n
    % apply transofmration
    er_t = ers_t(i2);
    er_a = ers_a(i2);
    
    
%     bs = 0.000001:0.000001:0.005;
%     costi = [];
    
%     for i3 = 1:numel(bs)

b = b_init;


[b_opt(i2),cost(i2)] = fmincon(@optfun,b,[],[],[],[],0,1)
%     optfun(b)
%     b = 0.001;
%         b = bs(i3);
        
%         [~,max_ind] = max(costi);
%         b_opt(i2) = bs(max_ind);
%     end
end
kill
plot3(ers_a,ers_t,-cost,'o')

%%


cost = [];
for i2 = 1:n
    er_t = ers_t(i2);
    er_a = ers_a(i2);
    cost(i2) = optfun(median(b_opt));
end
plot3(ers_a,ers_t,cost,'o')

%%

bs = -12:12
cost = [];
cost2 = [];
okok = [];
for i3 = 1:10
for i2 = 1:numel(bs)
    er_t = ers_t(i3);
    er_a = ers_a(i3);
    
    b = 1 * power(10,bs(i2));
    ttx0 = ttx;
    ttx0 = lag(ttx,-er_t);
    ttx0.Variables = ttx0.Variables - er_a;

    [hmt, hma] = perf_hm(ttx.Variables,ttx0.Variables,[1,1],b);
    cost(i2,i3) = sum(((er_a - hma).^2)) + sum(((b.^2) * (hmt - er_t).^2));
    okok(i2) = mean(hmt)
%     cost2(i2,i3) = sum((((hma-er_a).^2) .* (1/b.^2) + ((hmt-er_t).^2)));
end
end
plot(bs,cost,'o-')
% plot(bs,cost,'o-')
% plot(bs,cost2,'o-')
hold on
ah = gca;
% ah.YScale = 'log';

%%
function cost = optfun(b)
global ttx
global er_a
global er_t
ttx0 = ttx;
ttx0 = lag(ttx,-er_t);
ttx0.Variables = ttx0.Variables - er_a;
        [hmt, hma] = perf_hm(ttx.Variables,ttx0.Variables,[4,4],b);
        cost = sum((((hma-er_a).^2) + ((b.^2) * (hmt-er_t).^2)));
end
