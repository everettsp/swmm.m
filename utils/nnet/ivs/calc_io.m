function [ivs_rank, ivs_details] = calc_io(x,t,ys,nets,varargin) %build saliency feature mask

par = inputParser;
addParameter(par,'alpha',0.05)
addParameter(par,'summarize','false')
parse(par,varargin{:})
alpha = par.Results.alpha;

ivs_details = struct();

num_models = numel(nets);
num_inputs = size(x,2);

fun_mse = @(x,y) mean((x-y).^2);
fun_aic = @(mse,dof,n) n * log(mse) + 2 * dof;

aic = zeros(1,num_models);

for ii = 1:num_models
    net_copy = nets{ii};
    y = ys(:,ii);
    idx = ~(isnan(t) | isnan(y));
    n = length(y(idx));
    dof = length(getwb(net_copy)); %number of model parameters
    mse = fun_mse(t(itx),y(idx));
    aic(ii) = fun_aic(mse,dof,n);
end

aic_io = zeros(num_inputs,num_models);
mse_io = zeros(num_inputs,num_models);
mask = false(num_inputs,1);

for j = 1:num_inputs
    for ii = 1:num_models
        
        %remove neural pathway for input j
        j_io = true(size(x,2),1)';
        j_io(j) = false; %omission (logical index)
        net_copy = nets{ii}; %copy net
        [b,wgt_in,wgt_hid] = separatewb(net_copy,getwb(net_copy));
        wgt_in{1} = wgt_in{1}(:,j_io); %remove weights corresponding to Cj
        net_io = unconfigure(net_copy);
        net_io = configure(net_io,x(:,j_io)',t');
        wb = formwb(net_io,b,wgt_in,wgt_hid);
        net_io = setwb(net_io,wb);
        
        % calculate omission response...
        y_io = net_io(x(:,j_io)');
        y_io = y_io'; %calculate new output
        ys_io(:,ii) = y_io;
        
        % calculate new AIC
        idx = ~(isnan(t) | isnan(y_io)); %nan index for aic calculation
        dof_io = length(getwb(net_copy)); %number of model parameters
        n_io = length(y_io(idx)); %number of samples
        mse_io(j,ii) = fun_mse(t(idx),y(idx)); %mean squared error
        aic_io(j,ii) = fun_aic(mse_io(j,ii),dof_io,n_io); %akaike information crit
        
    end
    
    % if AIC increases, keep input
    [~,ks_p] = kstest2(aic_io(j,:),aic,'Tail','Larger'); %1 means reject null hypot that they are from same PDF;
    mask(j) = ks_p > alpha && aic_io(j,:) > median(aic);
    
end

% store detailed values
[~,ivs_rank] = sort(median(aic_io,2),'descend');
ivs_details.aic = aic;
ivs_details.aic_io = aic_io;
ivs_details.mask = mask;
ivs_details.ranking = ivs_rank;
ivs_details.ks_p = ks_p;
ivs_details.alpha = alpha;

end
