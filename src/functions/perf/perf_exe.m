function [nnp,pr] = perf_exe(nnc,nnd,varargin)
tic;
%initialize performance measure arrays
%% initialize array sizes
% pa = nan(I,1);
% ce = pa; te = pa; pi = pa; r = pa; mae = pa; rmse = pa; aic = pa;
% f = setup_graphics('word','lassonde');

par = inputParser;
addParameter(par, 'partition','all')
addParameter(par, 'pd',false)
addParameter(par, 'sd',false)
addParameter(par, 'hm',false)

parse(par,varargin{:})
partition = par.Results.partition;

%pr is progress report, track miscelanious performance measure params
pr = struct();
pr.experiment = nnc.experiment;
pr.partition = partition;

[~,t,~,ys,nets,trs] = unpack_data(nnd,'type','array');

%load configuration files for perf calculations and peak calculations
lead = nnc.model([nnc.model.io] == 0).shift;

%get precipitation array for event-identification scripts
%     ttShifted = lag(nnd.stations,-lead);
%     precip = ttShifted.('Calgary_Precip_Sum');

dispstat('','init'); %one time only init
dispstat(['Calculating performance for ' nnc.experiment],'keepthis','timespamp');
[~,num_ens] = size(ys);

for i2 = 1:num_ens %for each iteration
    dispstat(sprintf('Processing %d%%',round(100*i2/num_ens)),'timestamp');
    tr = trs{i2}; %grab training object
    if iscell(tr)
        tr = tr{1};
    end
    net = nets{i2};
    y = ys(:,i2);
    try
        p = numel(getwb(net)); %number of model parameters
    catch
        p = 0;
        boost_num = numel(net);
        
        for vi = 1:boost_num
            p = p + numel(getwb(net{vi}));
        end
    end
    
    %% get the data partition mask
    switch lower(partition)
        case {'train','training'}
            mask = tr.trainMask{1}';
        case {'val','validation'}
            mask = tr.valMask{1}';
        case {'test','testing' }
            mask = tr.testMask{1}';
        case {'cal','calibration'}
            mask = nan(size(tr.trainMask{1}'));
            mask(any([~isnan(tr.trainMask{1}) ; ~isnan(tr.valMask{1})])) = 1;
        otherwise
            mask = ones(size(tr.trainMask{1}'));
    end
    
    t = t .* mask;
    y = y .* mask;
    
    %% performance functons
    check_data(t,y);
    nnp.nse(i2) = perf_nse(t,y);
    nnp.te(i2) = perf_te(t,y);
    nnp.pi(i2) = perf_pi(t,y,lead);
    nnp.cc(i2) = perf_cc(t,y);
    nnp.mse(i2) = perf_mse(t,y);
    nnp.mae(i2) = perf_mae(t,y);
    nnp.rmse(i2) = (nnp.mse(i2))^0.5;
    nnp.aic(i2) = perf_aic(t,y,p);
    [nnp.kge(i2),nnp.msec(i2),nnp.msev(i2),nnp.mseb(i2)] = perf_kge(t,y); %get kge performance metrics
    
    
    
    nnp.time(i2) = sum(tr.time);
    nnp.epochs(i2) = tr.num_epochs;
    
    if par.Results.pd
        %automated event identification
        pr.event_prom = .3;%.3;
        
        pr.event_threshold = 90;
        pr.event_sw = [lead lead];
        
        [tIds,yIds] = get_events(t,y,...
            pr.event_prom,pr.event_threshold,pr.event_sw);
        
        nnp.tIds(:,:,i2) = tIds; nnp.yIds(:,:,i2) = yIds;
        
        
        %event-based standard perforance measures
        event_nse = NaN(1,size(tIds,1));
        event_rmse = NaN(1,size(tIds,1));
        event_te = NaN(1,size(tIds,1));
        
        for i3 = 1:size(tIds,1)
            event_range = tIds(i3,1):tIds(i3,3);
            event_nse(i3) = perf_nse(t(event_range),y(event_range));
            event_rmse(i3) = perf_mse(t(event_range),y(event_range))^0.5;
            event_te(i3) = perf_te(t(event_range),y(event_range));
        end
        
        nnp.nse_events(:,i2) = event_nse;
        nnp.rmse_events(:,i2) = event_rmse;
        nnp.te_events(:,i2) = event_te;
        %end event-based standard performance measures
        
        %calculate peak error
        [pdt,pda] = perf_pd(t,y,tIds,yIds,'plt',0);
        nnp.pdt(:,i2) = pdt; nnp.pda(:,i2) = pda;
        clear vars pte pae
        
        %calculate series distance error
        if par.Results.sd
            pr.sd_minor_prom = 0.05;
            pr.sd_sw = pr.event_sw;
            [sdt,sda,~,~] = perf_sd(t,y,tIds,yIds,pr.sd_sw,pr.sd_minor_prom,'plt',0);
            nnp.sdt(:,i2) = sdt; nnp.sda(:,i2) = sda;
            %         nnp.tClass(:,ii) = tClass; nnp.yClass(:,ii) = yClass;
            clear vars sdte sdae
        end
        if par.Results.hm
            pr.hm_b = 0.01;
            pr.hm_sw = pr.event_sw;
            [hmt,hma] = perf_hm(t,y,tIds,yIds,pr.hm_sw,pr.hm_b,'plt',0);
            nnp.hmt(:,i2) = hmt; nnp.hma(:,i2) = hma;
            clear vars hmate hmaae
        end
        
    end
    
end

%% uncertainty measures

if par.Results.pd
    for i3 = 1:size(tIds,1)
        range_event = tIds(i3,1):tIds(i3,3);
        nnp.cvg_events(i3,1) = perf_coverage(t(range_event),ys(range_event,:));
        nnp.prc_events(i3,1) = perf_prc(t(range_event),ys(range_event,:));
        clear range_event
        
    end
end
nnp.cvg = perf_coverage(t,ys);
nnp.prc = perf_prc(t,ys);


pr.runtime = toc;
dispstat('Finished.','keepprev'); fprintf('\n')
end
