function [nets, ww, info] = train_adaboost(net, inp_0, obs_0, m, phi_fixed, error_exponent,resample_or_reweight,varargin)
% implementation of Adaboost.RT (Solomatine 2004; Solomatine 2006)
%
% REQUIRED PARAMETERS----------
% net_0 is an untrained artificial neural network (matlab object)
% inp_0 is input data (column-wise samples)
% obs_0 is target data
% n_boosts is the number of boosts (T)
% phi is the relative error threshold (phi)
% error_exponent is the exponent applied to the model error calculation (n)
% resample_or_reweight indicates whether to resample the input set or weight the training cost function
% 
% OPTIONAL PARAMETERS----------
% plot is a boolean statement indicating whether to produce summary plots


par = inputParser;
addParameter(par,'plot',false,@islogical)
parse(par,varargin{:})
make_plot = par.Results.plot;

net_0 = net;
inp = inp_0;
obs = obs_0;

if size(inp,2) ~= size(obs,2)
    error('dimensions must agee')
end

[~,n] = size(inp);

% get data partiton indices

if ~strcmp(net_0.DivideFcn,'divideind')
    error('adaboost only support pre-partitioned datasets (net.DivideFcn = divideind)')
end

idx_train = net_0.DivideParam.trainInd;
idx_val = net_0.DivideParam.valInd;
idx_test = net_0.DivideParam.testInd;

idx_adb = [idx_train(:); idx_val(:)];

n_train = numel(idx_train);
n_adb = numel(idx_adb);
% assign uniform weighting schemes to validation and test data
ew_val = ones(1,numel(idx_val)) ./ numel(idx_val);
ew_test = ones(1,numel(idx_test)) ./ numel(idx_test);

n_boosts = m;

% initialize adaboost parameters
adb_beta = NaN(n_boosts,1);
epsilon = NaN(n_boosts,1);
D = NaN(n_boosts,n_adb);
phi = NaN(n_boosts,1);

obs_train = NaN(n_boosts,n_adb);  % training observations
obs_train(1,:) = obs(idx_adb);    % training observations
ew_train = NaN(n_boosts,n_adb);   % weighting

D(1,:) = 1/n_adb;                 % weight matrix
out = NaN(n_boosts,n);              % ann prediction
out_mean = NaN(n_boosts,n);         % weighted mean prediction
are = NaN(n_boosts,n_adb);        % average relative error
phi_gt = false(n_boosts,n_adb);   % error true
train_loss = NaN(n_boosts,1);       % training error
val_loss = NaN(n_boosts,1);         % validation error
test_loss = NaN(n_boosts,1);        % testing error
loss_fcn = @(x,y) nansum((x-y).^2) ./ numel(x(~(isnan(x) | isnan(y)))); % mean squared error
nets = cell(m,1);

for t2 = 1:n_boosts
    switch lower(resample_or_reweight)                                      % specify whether to resample or reweight...
        case {'resample','sample','rs'}
            net_resample = net_0;                                             % copy the initialized ANN
            if t2 > 1                                                       % if not the first model, resample training obs
                idx_resample = randsample(idx_adb,n_adb,true,D(t2,:));  % get resample indices
                net_resample.DivideParam.trainInd = idx_resample;           % set training indices
                obs_train(t2,:) = obs(idx_resample);
            end
            obs_train(t2,:) = obs(idx_adb);                            % store the resampled trainig obs
            [nets{t2}, trns{t2}] = train(net_resample, inp, obs);      % train using the resampled train data
            
        case {'reweight','weight','rw','ew'}                                % initialize new error weight vector
            ew_train(t2,idx_adb) = D(t2,:);                               % get error weights from D matrix
%             ew_train(t2,idx_val) = ew_val;                                  % uniform weights for validaiton data
            ew_train(t2,idx_test) = ew_test;                                % uniform weights for test data
            nets{t2} = net_0;
            [nets{t2}, trns{t2}] = ...
                train(net_0, inp, obs,{},{},ew_train(t2,:));                  % train using weighted loss function
    end
    out(t2,:) = nets{t2}(inp);                                              % compute model output
    are(t2,:) = abs(obs(idx_adb)-out(t2,idx_adb))./obs(idx_adb);      % average relative error
    if t2 == 1
        phi_fixed = prctile(are(t2,:),phi_fixed);      % dynamically recalculate phi
    end
    phi(t2) = phi_fixed;
    
    phi_gt(t2,:) = are(t2,:) > phi(t2);                                     % get samples greater than phi
    
    if ~any(phi_gt(t2,:))
        disp('no error above threshold, terminating...')
        break
    end
    
    epsilon(t2) = nansum(D(t2,phi_gt(t2,:)));                               % calculate error
    adb_beta(t2) = epsilon(t2).^error_exponent;                             % calculate error
    ww = log(1./adb_beta(1:t2));                                            % model weight (RT method)
    
    
    ldx = ~(isnan(obs) | any(isnan(out(1:t2,:)),1)) & ismember((1:numel(obs)),idx_train); % model weight (+ method)
    ww2 = out(1:t2,ldx)'\obs(ldx)';
    out_mean(t2,:) = ww' * out(1:t2,:);
%     out_mean(t2,:) = ww' * out(1:t2,:) / sum(ww);                           % weighted mean prediction
    
    train_loss(t2) = loss_fcn(obs(idx_adb),out_mean(t2,idx_adb));
    val_loss(t2) = loss_fcn(obs(idx_val),out_mean(t2,idx_val));
    test_loss(t2) = loss_fcn(obs(idx_test),out_mean(t2,idx_test));
    
    if t2 ~= n_boosts                                                       % if it's not the final iteration
        D(t2+1,~phi_gt(t2,:)) = D(t2,~phi_gt(t2,:)) .* adb_beta(t2);        % update weights
        D(t2+1,phi_gt(t2,:)) = D(t2,phi_gt(t2,:));                          % update weights
        D(t2+1,:) = D(t2+1,:) / nansum(D(t2+1,:));                          % normalize
    end
end

% ADABOOST+ implementation...
% determine weighting based on validation data

    
[~,val_best] = (min(val_loss));     % find best boost number based on validation performance
out_best = out_mean(val_best,:);    % select mean prediction corresponding to best boost number

% net = nets{1};
% net_info = nets_info{1};

% save everything in a struct for visualization/troubleshooting
% this struct is quite large and can't always be saved as is for very large datasets
% recommended to only save essential fields, or change the format for record-keeping

% info.idx_train = idx_train;
% info.beta = adb_beta;
info.D = D;
% info.ww = ww;
% info.mw = ww;
% info.epsilon = epsilon;
% info.phi = phi;
% info.phi_gt = phi_gt;
% info.are = are;
% info.obs = obs;
% info.out = out;
% info.out_mean = out_mean;
% info.train_loss = train_loss;
% info.val_loss = val_loss;
% info.test_loss = test_loss;
% info.val_best = val_best;
% info.obs_train = obs_train;
% info.ew_train = ew_train;

% if make_plot
%     figure('Name','adaboost.rt: train-val-test loss function')
%     hold 'on'
%     plot(1:n_boosts,train_loss,'o-','DisplayName','train loss');
%     th = plot(1:n_boosts,val_loss,'x-','DisplayName','val loss');
%     plot(1:n_boosts,test_loss,'sq-','DisplayName','test loss');
%     plot(val_best,val_loss(val_best),'o','Color',th.Color,'LineWidth',2','MarkerSize',12,'DisplayName','val best');
%     legend('Location','best')
%     clear th
% end
end