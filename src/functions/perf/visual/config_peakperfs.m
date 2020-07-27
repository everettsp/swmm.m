function pfc = config_peakperfs(catchment,lead)
pfc = struct();

pfc.catchment = catchment;
pfc.lead = lead;

switch lower(pfc.catchment)
    case 'example'
        pfc.nEvents = 1; %number of events
        pfc.ied = 24;
        pfc.bfPercentile = 50;
        pfc.bfWindow = 3 * 24 * [1 1];
        pfc.smWindow = 24 * [1 1];
        pfc.raingauge = 'synthetic';
    case 'don'
        pfc.nEvents = 10; %number of events
        pfc.ied = 24;
        pfc.bfPercentile = 50;
        pfc.bfWindow = 3 * 24 * [1 1];
        pfc.smWindow = 24 * [1 1];
        pfc.raingauge = 'HY008_Precip_Sum';
    case 'bow'
        pfc.nEvents = 10; %number of events
        pfc.ied = 5*4;
        pfc.bfPercentile = 40;
        pfc.bfWindow = 3 * 7 * [1 1];
        pfc.smWindow = 8 * [1 1];
        pfc.raingauge = 'Calgary_Precip_Sum';
end
end