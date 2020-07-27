function [nets,trs] = apply_gradboost(x,t,net,tr,M,learn_rate)

nets = cell(M,1);
trs = cell(M,1);
e = cell(M,1);
B = cell(M,1);
rho = nan(M,1);
F = cell(M,1);

nets{1} = net;
trs{1} = tr;
y = net(x);
e{1} = t-y;
B{1} = {};
F{1} = y;

options = optimoptions('fminunc','Display','off');

for m = 1+(1:M)
    net = initlay(net);
    
    [nets{m},trs{m}] = train(net,x,e{m-1});
    B{m} = nets{m}(x);
    
    fun_sse = @(p) nansum((e{m-1} - p * B{m}).^2);
    [rho(m),~,~,output]  = fminunc(fun_sse,1,options);
    
    F{m} = F{m-1} + learn_rate * rho(m) * B{m};
    e{m} = t - F{m};
    
    trs{m}.lsb_M = M;
    trs{m}.lsb_m = m;
    trs{m}.lsb_learn_rate = learn_rate;
    trs{m}.lsb_rho = rho(m);
    trs{m}.lsb_argminout = output;
    trs{m}.lsb_residuals = e{m};
    trs{m}.lsb_prediction = F{m};
    trs{m}.lsb_basemodel = B{m};
end


end

