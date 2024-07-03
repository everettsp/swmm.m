function results = main_stacking(mdl, events_rr, tt_flow, tt_precip, cv_obs, cv_mod, cv_mat, varargin)


par = inputParser;
addParameter(par,'filename','')
addParameter(par,'overwrite',false)
addParameter(par,'num_combinations',10)
parse(par,varargin{:})

filename = par.Results.filename; %results filename
overwrite = par.Results.overwrite; %whether to overwrite saved results file
num_combinations = par.Results.num_combinations; %number of event combinations to randomly sample

pf = perf_funs; %load performance functions

if ~isfile(filename) || overwrite
    tt_precip_lagged = tt_precip;% lag(tt_precip);
    tt_flow_lagged = lag(tt_flow,hours(12));

    tt_precip_mean = timetable(tt_precip_lagged.Properties.RowTimes,mean(tt_precip_lagged.Variables,2,'omitnan'));

    [~,flow_lags] = maxk(tt_ccf(tt_flow_lagged,tt_flow_lagged,0:100),3);
    [~,precip_lags] = maxk(tt_ccf(tt_flow_lagged,tt_precip_mean,0:100),3);

    tt_flow_inp = timetable(tt_flow_lagged.Properties.RowTimes);
    tt_precip_inp = timetable(tt_flow_lagged.Properties.RowTimes);

    for lag_num = 1:3
        tt_flow_inp(:,lag_num) = lag(tt_flow_lagged,flow_lags(lag_num));
        tt_precip_inp(:,lag_num) = lag(tt_flow_lagged,precip_lags(lag_num));

    end


    n_events = numel(events_rr);

    % load event formatting info - ensures consistent formatting across
    % class IDs
    ecl = setup_eventclass(events_rr);
    idx1 = ecl(1).idx;
    idx2 = ecl(2).idx;

    % cfg = setup_cfg();
    cfg = setup_eventclass(events_rr);

    cfg(1).idx = 0;
    cfg(1).class = 0;
    cfg(1).lbl = 'cal';
    cfg(2).idx = [idx1,idx2]';
    cfg(2).lbl = 'so';
    cfg(2).class = 0;
    cfg(2).type = 's';

    idx_mat = [];
    for i2 = 1:n_events
        idx = 1:n_events;
        idx = idx(idx ~= i2);
        idx_mat(i2,:,1) = idx;
    end
    cfg(2).idx = idx_mat;

    % randomly sample event combinations; dims [num_events,num_combinations,num_models]
    idx_mat = [];
    for i2 = 1:n_events
        i3 = 1;
        while i3 <= num_combinations
            idx1_rs = randsample(idx1,n_events/2-1);
            idx2_rs = randsample(idx2,n_events/2-1);
            idx = [idx1_rs,idx2_rs];
            if ~any(i2 == idx) % if predictor model index does not contain val. event, store
                idx_mat(i2,i3,:) = idx;
                i3 = i3 + 1;
            end
        end
    end


    % create a config file for different stacking scenarios
    for i2 = 3:6
        cfg(i2).idx = idx_mat;
    end

    %shortform for each config
    cfg(1).type = 'cal'; % calibration performance
    cfg(2).type = 's'; % single-event performance
    cfg(3).type = 'uni'; % uniformly weighted combination
    cfg(4).type = 'ww'; %non-uniformly weighed combination
    cfg(5).type = 'mlrx'; % mlr-based stacking with exogenous inputs
    cfg(6).type = 'nnx'; %ann-based stacking with exo inps

    % labels for each config
    cfg(1).lbl = 'CAL';
    cfg(2).lbl = 'SINGLE';
    cfg(3).lbl = 'UNIFORM';
    cfg(4).lbl = 'WEIGHTED';
    cfg(5).lbl = 'STACK_MLR';
    cfg(6).lbl = 'STACK_ANN';

    % assign fixed colors to each config for plotting
    clrs = colors('lassonde');
    cfg(1).col = clrs.black;
    cfg(2).col = clrs.red;
    cfg(3).col = clrs.blue;
    cfg(4).col = clrs.green;
    cfg(5).col = clrs.yellow;
    cfg(6).col = clrs.purple;

    % initialise cell array to store tgt/mod for train/test
    for i2 = 1:numel(cfg)
        cfg(i2).tgt_train = repmat({[]},[n_events,1]);
        cfg(i2).mod_train = repmat({[]},[n_events,1]);
        cfg(i2).tgt_test = repmat({[]},[n_events,1]);
        cfg(i2).mod_test = repmat({[]},[n_events,1]);
    end



    for i4 = 1:numel(cfg)
        for i2 = 1:numel(events_rr) % for each validation event
            disp(['training ',cfg(i4).type,' ensembles for event ',num2str(i2)])
            for i3 = 1:size(cfg(i4).idx,2) % for each unique combination of models
                if i4 == 1 % for calibration performance, set idx to 0 (it would technically be idx = i4, but we have to get round IF statement later)
                    idx = 0;
                else
                    idx = squeeze(cfg(i4).idx(i2,i3,:));
                end

                % get training inp and tgts
                switch lower(cfg(i4).type)
                    case {'nn','s','ww','mlr'} % prep inputs for NN with exogenous inputs
                        inp_train = [tt_cat(cv_mod(idx,idx)')'];
                        tgt_train = tt_cat(cv_obs(idx))';
                    case {'nnx','mlrx'} % prep inputs for NN with exogenous inputs
                        [tgt_train, rt] = tt_cat(cv_obs(idx));
                        tgt_train = tgt_train';

                        % for some reason, time-indexing tts is so slow -
                        % instead I use ismember to create a logical index
                        % with which to slice the timetable
                        tt_precip_idx = ismember(tt_precip_lagged.Properties.RowTimes,rt);
                        tt_flow_idx = ismember(tt_flow_lagged.Properties.RowTimes,rt);






                        inp_train = [tt_precip_inp(tt_precip_idx,:).Variables'; tt_flow_inp(tt_flow_idx,:).Variables'; tt_cat(cv_mod(idx,idx)')'];
                end

                % get combination weights and train stacking models
                switch lower(cfg(i4).type)
                    case {'uni'}
                        mod_train = mean(inp_train,1);
                    case {'mlr','mlrx'}
                        lrm = fitlm(inp_train',tgt_train');
                    case {'ww'}
                        options = optimset('MaxIter',20,'TolFun',1e-1);
                        ww0 = ones([1,size(inp_train,1)]) ./ size(inp_train,1);
                        fun = @(ww) -pf.kge(tgt_train',((inp_train') * (ww')));
                        [ww,fval,exitflag,output] = fminsearch(fun,ww0,options);
                        mod_train = ((inp_train') * (ww'))';

                    case {'nn','nnx'}
                        rng(0)
                        net = fitnet(8,'trainlm');
                        net.biasConnect = [false;false];
                        net.trainParam.showWindow = 0;
                        net.trainParam.max_fail = 4;

                        % net.trainParam.epochs = 50;
                        net.input.processFcns = {'removeconstantrows','mapminmax'};
                        net.output.processFcns = {'removeconstantrows','mapminmax'};
                        net.performFcn = 'mse';  % Mean Squared Error
                        net.plotFcns = {'plotperform','plottrainstate','ploterrhist','plotregression', 'plotfit'};

                        net.divideFcn = 'divideind';
                        %                 cv = cvpartition,'HoldOut',0.50);
                        %                 test_idx = cv.test;


                        n = (size(tgt_train,2));
                        ind_train = [];
                        ind_val = [];
                        blck = (1:10);
                        n_blck = ceil(n ./ blck(end));
                        for i6 = 0:2:(n_blck-2)
                            ind_train = [ind_train;(i6 .* blck(end) + blck)'];
                            ind_val = [ind_val;((i6 + 1) .* blck(end) + blck)'];
                        end
                        ind_train = ind_train(ind_train <= n);
                        ind_val = ind_val(ind_val <= n);

                        net.divideParam.trainInd = ind_train;
                        net.divideParam.valInd = ind_val;
                        clear vars test_idx cv

                        ensbl = net_ensbl;
                        ensbl = ensbl.init(net,8); %128
                        rs_replace = @(net,x,t) resample_weighted(net,x,t,ones(size(t)));
                        ensbl.train_fun = @(net,x,t,m) train_bag(net,x,t,m,'rsf',rs_replace);
                        ensbl = ensbl.train(inp_train,tgt_train);
                end
                % % %

                if ~any(i2 == idx) % if the validation event isn't in the idx
                    tgt_test = tt_cat(cv_obs(i2));

                    switch lower(cfg(i4).type)
                        case {'cal'}
                            mod_train = tt_cat(cv_mod(i2,i2)');
                            mod_test = mod_train;
                        case {'s'}
                            mod_train = tt_cat(cv_mod(i2,i2)');
                            mod_test = tt_cat(cv_mod(idx,i2)');
                        case {'uni'}
                            mod_train = mean(tt_cat(cv_mod(idx,idx)'),2);
                            mod_test = mean(tt_cat(cv_mod(idx,i2)'),2);
                        case {'ww'}
                            mod_train = tt_cat(cv_mod(idx,idx)') * ww';
                            mod_test = tt_cat(cv_mod(idx,i2)') * ww';
                        case {'nn'}
                            mod_train = ensbl.eval(inp_train)';
                            inp_test = tt_cat(cv_mod(idx,i2)')';
                            mod_test = ensbl.eval(inp_test)';
                        case {'nnx'}
                            mod_train = ensbl.eval(inp_train)';
                            [preds,rt] = tt_cat(cv_mod(idx,i2)');
                            inp_test = [tt_precip_inp(rt,:).Variables'; tt_flow_inp(rt,:).Variables'; preds'];
                            mod_test = ensbl.eval(inp_test)';
                        case {'mlrx'}
                            [preds,rt] = tt_cat(cv_mod(idx,i2)');
                            inp_test = [tt_precip_inp(rt,:).Variables'; tt_flow_inp(rt,:).Variables'; preds'];
                            mod_train = lrm.feval(inp_train');
                            mod_test = lrm.feval(inp_test');
                        case {'mlr'}
                            inp_test = tt_cat(cv_mod(idx,i2)')';
                            mod_train = lrm.feval(inp_train');
                            mod_test = lrm.feval(inp_test');
                    end

                    cfg(i4).mod_test{i2} = [cfg(i4).mod_test{i2},mod_test];
                    cfg(i4).tgt_test{i2} = tgt_test;

                    %                 cfg(i4).mod_train{i2} = [cfg(i4).mod_train{i2},mod_train];
                    %                 cfg(i4).tgt_train{i2} = tgt_train';
                end
            end

        end
        %     perf_mat = perf_mat(:,[idx1,idx2]);
        %     cfg(i4).kge = perf_mat;
        %     cfg(i4).perf_mean = nanmean(perf_mat);

    end

    %%
    for i4 = 1:numel(cfg)
        perf_mat= nan(size(cfg(i4).idx,[1,2]));

        perf = struct();
        perf_lbls = {'kge','pfe','mve'};
        perf.msec = perf_mat;
        perf.msev = perf_mat;
        perf.mseb = perf_mat;

        for i5 = 1:numel(perf_lbls) % initialise empty perf mats
            perf.(perf_lbls{i5}) = perf_mat;
        end

        for i2 = 1:n_events
            for i5 = 1:numel(perf_lbls)
                %                     perf_mat(i3,i2) = pf.kge(tgt_test',mod_test_ann');
                perf_fun = pf.(perf_lbls{i5});
                perf.(perf_lbls{i5})(i2,:) = perf_fun(cfg(i4).tgt_test{i2},cfg(i4).mod_test{i2});
            end
            [~,perf.msec(i2,:),perf.msev(i2,:),perf.mseb(i2,:)] = pf.kge(cfg(i4).tgt_test{i2},cfg(i4).mod_test{i2});
            cfg(i4).perf = perf;
        end
    end
    %
    % cfg(4).kge = cv_mat;
    % for i2 = 1:size(cv_mat,1)
    %     cfg(4).kge(i2,i2) = NaN;
    % end
    %     cfg_mdls(k4).cfg = cfg;
    %%


    results = struct();

    results.cfg = cfg;
    results.cv_mat = cv_mat;
    results.cv_mod = cv_mod;
    results.cv_obs = cv_obs;
    %     results.perf_tbl = perf_tbl;
    results.stacking_config = cfg;
    results.perf_lbls = perf_lbls;
    results.events_rr = events_rr;
    results.n_events = n_events;
    results.mdl = mdl;
    results.catchment = mdl(1).name;

    save(filename,'-struct','results')

elseif isfile(filename)
    results = load(filename);
else
    error('this should never come up')
end

