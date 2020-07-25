function dict = dict(obj,kwd)
% dictionaries of SWMM nomenclature
% call dictionaries using keyword

switch lower(kwd)
    case {'classes','class'}
        dict_cell = {...
            'options',          '[OPTIONS]',                'opt';...
            'files',            '[FILES]',                  'f';...
            'raingages',        '[RAINGAGES]',              'rg';...
            'evaporation',      '[EVAPORATION]',            'evp';...
            'subcatchments',    '[SUBCATCHMENTS]',          'sc';...
            'subareas',         '[SUBAREAS]',               'sa';...
            'lid_controls',     '[LID_CONTROLS]',           'lidc';...
            'lid_usage',        '[LID_USAGE]',              'lidu';
            'timeseries'        '[TIMESERIES]',             'ts';...
            'infiltration',     '[INFILTRATION]',           'infl';...
            'junctions',        '[JUNCTIONS]',              'j';...
            'outfalls',         '[OUTFALLS]',               'of';...
            'storage',          '[STORAGE]',                'su';...
            'outlets',          '[OUTLETS]',                'ol';...
            'orrifices',        '[ORIFICES]',               'or';...
            'weirs',            '[WEIRS]',                  'wrs';...
            'conduits',         '[CONDUITS]',               'c';...
            'xsections',        '[XSECTIONS]',              'xs';...
            'transects',        '[TRANSECTS]',              'trsc';...
            'coordinates',      '[COORDINATES]',            'xy';...
            'vertices',         '[VERTICIES]',              'vert';...
            'polygons',         '[Polygons]',               'poly';...
            'symbols',          '[SYMBOLS]',                'sym';...
            };
        
        % format as a table for readability
        dict = cell2table(dict_cell,'VariableNames',{'classname','classname_fmtd','abrv'});
        dict.Properties.RowNames = dict(:,1).Variables;
        dict = dict(:,2:3);

case {'map','draw','symbolspec','symspec'}
    colrs = colormap(lines(10));
    ms = 1;
    lw = 2;
    dict = struct();
    
    dict.subcatchments = makesymbolspec('Polygon',...
            {'Default','FaceColor',[0.9,0.9,0.9]});
        
    dict.junctions = makesymbolspec('Point',...
            {'Default','MarkerEdgeColor',colrs(2,:),'MarkerFaceColor',colrs(2,:),'Marker','o','MarkerSize',ms*6});
        
    dict.outfalls = makesymbolspec('Point',...
            {'Default','MarkerEdgeColor',colrs(1,:),'MarkerFaceColor',colrs(2,:),'Marker','^','MarkerSize',ms*6});
        
    dict.storage = makesymbolspec('Point',...
            {'Default','MarkerEdgeColor',colrs(3,:),'MarkerFaceColor',colrs(2,:),'Marker','sq','MarkerSize',ms*6});
        
    dict.conduits = makesymbolspec('Line',...
            {'Default','Color',colrs(1,:),'LineWidth',lw});
        
    dict.outlets = makesymbolspec('Line',...
            {'Default','Color',colrs(1,:),'LineWidth',lw});
        
    dict.connections = makesymbolspec('Line',...
            {'Default','Color',[0,0,0],'LineWidth',lw,'LineStyle',':'});

        
        
    case {'attributes'}
        dict.aquifers = ["Por", "WP", "FC", "Ksat", "Kslope", "Tslope", "ETu", "ETs", "Seep", "Ebot", "Egw", "Umc", "ETupat"];
        dict.backdrop = ["Type", "Val1", "Val2", "Val3", "Val4"]; % could improve, too lazy, won't ever need to edit backdrop through MATLAB...
        dict.buildup = ["LandUse", "Pollutant", "Function", "Coeff1", "Coeff2", "Coeff3", "Per_Unit"];
        dict.conduits = ["Name", "FromNode", "ToNode", "Length", "Roughness", "InOffset", "OutOffset", "InitFlow", "MaxFlow"];
        dict.controls = [];
        dict.coordinates = ["Node", "X_Coord", "Y_Coord"];
        dict.coverages = ["Subcatchment", "LandUse", "Percent"];
        dict.curves = ["Name","Type", "X_Value", "Y_Value"]; %%
        dict.dividers = ["Name", "Elevation", "DivertedLink", "Type", "Parameters"];
        dict.dwf = ["Node", "Constituent", "Baseline", "Patterns"];
        dict.evaporation = ["DataSource", "Parameters"];
        dict.events = ["StartDate", "EndDate"];
        dict.files = ["Usage", "Type", "Filename"];
        dict.groundwater = ["Aquifer", "Node", "Esurf", "A1", "B1", "A2", "B2", "A3", "Dsw", "Egwt","Ebot", "Wgr", "Umc"];
        dict.hydrographs = ["Hydrograph", "RainGage_Month", "Response", "R", "T", "K", "Dmax"];
        dict.iiflows = ["Node", "Unit Hydrograph", "Sewer Area"];
        dict.infiltration.horton = ["Subcatchment","MaxRate", "MinRate", "Decay", "DryTime", "MaxInfil"];
        dict.infiltration.modified_horton = ["Subcatchment","MaxRate", "MinRate", "Decay", "DryTime", "MaxInfil"];
        dict.infiltration.green_ampt = ["Subcatchment", "Suction", "Ksat", "IMD"];
        dict.infiltration.modified_green_ampt = ["Subcatchment", "Suction", "Ksat", "IMD"];
        dict.infiltration.curve_number = ["Subcatchment", "CurveNum", "empty", "DryTime"];
        dict.inflows  = ["Constituent", "TimeSeries", "Type", "Mfactor", "Sfactor", "BaseLine", "Pattern"]; % weird, other info
        dict.junctions = ["Name", "Elevation", "MaxDepth", "InitDepth", "SurDepth", "Aponded"];
        dict.labels = ["X_Coord", "Y_Coord", "Label"];
        dict.landuses = ["Name","SweepingInterval", "FractionAvailable", "LastSwept"];
        dict.lid_controls.types = ["BC","RG","GR","IT","PP","RB","RD","VS"];
        dict.lid_controls.headers = ["Name", "TypeLayer", "Parameters"];
        dict.lid_controls.surface = ["BermHeight","VegetationVolume","SurfaceRoughness","SurfaceSlope","SwaleSideSlope"];
        dict.lid_controls.soil = ["Thickness","Porosity","FieldCapacity","WiltingPoint","Conductivity","ConductivitySlope","SuctionHead"];
        dict.lid_controls.storage = ["Thickness","VoidRatio","SeepageRate","CloggingFactor"];
        dict.lid_controls.drain = ["FlowCoeff","FlowExp","Offset","DrainDelay","OpenLevel","ClosedLevel","ControlCurve"];
        dict.lid_controls.drainmat = ["Thickness","VoidFraction","Roughness"];
        dict.lid_controls.pavement = ["Thickness","VoidRatio","PervSurf","Permeability","CloggingFactor","RegenIntvl","RegenFactor"];
        dict.lid_controls.removals = ["BOD","BODRemoval","TSS","TSSRemoval"];
        dict.lid_usage = ["Subcatchment", "LID_Process", "Number", "Area", "Width", "InitSat", "FromImperv", "ToPerv", "RptFile", "DrainTo","FromPerv"];
        dict.loadings = ["Subcatchment", "Pollutant", "Buildup"];
        dict.losses = ["Link", "Kentry", "Kexit", "Kavg", "FlapGate", "Seepage"];
        dict.map = ["key", "value"];
        dict.orifices = ["Name", "FromNode", "ToNode", "Type", "Offset", "Qcoeff", "Gated", "CloseTime"];
        dict.options = ["FLOW_UNITS","INFILTRATION","FLOW_ROUTING","LINK_OFFSETS","MIN_SLOPE","ALLOW_PONDING","SKIP_STEADY_STATE","START_DATE","START_TIME","REPORT_START_DATE","REPORT_START_TIME","END_DATE","END_TIME","SWEEP_START","SWEEP_END","DRY_DAYS","REPORT_STEP","WET_STEP","DRY_STEP","ROUTING_STEP","RULE_STEP","INERTIAL_DAMPING","NORMAL_FLOW_LIMITED","FORCE_MAIN_EQUATION","VARIABLE_STEP","LENGTHENING_STEP","MIN_SURFAREA","MAX_TRIALS","HEAD_TOLERANCE","SYS_FLOW_TOL","LAT_FLOW_TOL","MINIMUM_STEP","THREADS"];
        dict.outfalls = ["Name","Elevation", "Type", "StageData", "Gated", "RouteTo"];
        dict.outlets = ["Name", "FromNode", "ToNode", "Offset", "Type", "QTable_Qcoeff", "Qexpon", "Gated"];
        dict.patterns = ["Name", "Type", "Multipliers"];
        dict.pollutants = ["Name", "Units", "Crain", "Cgw", "Crdii", "Kdecay", "SnowOnly", "Co_Pollutant", "Co_Frac", "Cdwf", "Cinit"];
        dict.polygons = ["Subcatchment", "X_Coord", "Y_Coord"];
        dict.profiles = ["Name", "Links"];
        dict.pumps = ["Name", "FromNode", "ToNode", "PumpCurve", "Status", "Sartup", "Shutoff"];
        dict.raingages = ["Name", "Format", "Interval", "SCF", "Source","SourceName","StationID","Units"];
%         dict.raingages.file = ["Name", "Format", "Interval", "SCF", "Source","SourceName",];
        dict.report = ["Reporting_Options", "value"];
        dict.snowpacks = ["Name", "Surface", "Parameters"];
        dict.storage = ["Name","Elev", "MaxDepth", "InitDepth", "Shape", "Curve_Name_Params", "N_A", "Fevap", "Psi", "Ksat", "IMD"];
        dict.subcatchments = ["Name", "RainGage", "Outlet", "Area","PercentImperv", "Width", "PercentSlope", "CurbLen", "Snowpack"];
        dict.subareas = ["Name","N_Imperv", "N_Perv", "S_Imperv", "S_Perv", "PctZero", "RouteTo", "PctRouted"];
        dict.symbols = ["Gage", "X_Coord", "Y_Coord"];
        dict.tags = ["Object", "ID", "Text"];
        dict.temperature = ["DataElement", "tab1", "Values"];
        dict.timeseries = ["Name","Date", "Time", "Value"]; %%
        dict.title = [];
        dict.transects = ["Param1","Param2","Param3","Param4","Param5","Param6","Param7","Param8","Param9","Param10","Param11"];
        dict.treatment = ["Node", "Pollutant", "Function"];
        dict.vertices = ["Link", "X_Coord", "Y_Coord"];
        dict.washoff = ["LandUse", "Pollutant", "Function", "Coeff1", "Coeff2", "SweepRmvl", "BmpRmvl"];
        dict.weirs = ["Name","FromNode", "ToNode", "Type", "CrestHt", "Qcoeff", "Gated", "EndCon", "EndCoeff", "Surcharge", "RoadWidth", "RoadSurf", "CoeffCurve"];
        dict.xsections = ["Link","Shape", "Geom1", "Geom2", "Geom3", "Geom4", "Barrels", "Culvert"];
        
        
        
    case {'results','res'}
        dict.AnalysisOptions = ["Opt","Val";"",""];
        dict.RunoffQuantityContinuity = ["RunoffType","Volume","Depth";"","ha-m","mm"];
        dict.RunoffQualityContinuity = ["RunoffType","BOD","TSS";"","kg","kg"];
        dict.FlowRoutingContinuity = ["FlowType","Volume","Volume2";"","ha-m","10e6L"];
        dict.QualityRoutingContinuity = ["FlowType","BOD","TSS";"","kg","kg"];
        dict.HighestFlowInstabilityIndexes = [];
        
        dict.RoutingTimeStepSummary = [];
        dict.SubcatchmentRunoffSummary = ["Subcatchment","TotalPrecip","TotalRunon","TotalEvap","TotalInfil","ImpervRunoff","PervRunoff","TotalRunoff","TotalRunoff2","PeakRunff","RunoffCoeff";"Name","mm","mm","mm","mm","mm","mm","mm","10e6L","cms",""];
        dict.LIDPerformanceSummary = ["Subcatchment","LIDControl","TotalInflow","EvapLoss","InfilLoss","SurfaceOutflow","DrainOutflow","initialStorage","FinalStorage","ContinuityError";"Name","Name","mm","mm","mm","mm","mm","mm","mm","%"];
        dict.SubcatchmentWashoffSummary = ["Subcatchment","BOD","TSS";"Name","kg","kg"];
        dict.NodeDepthSummary =  ["Node","Type","AvgDepth","MaxDepth","MaxHGL","DayOfMaxDepth","HourOfMaxDepth","MaxReportedDepth";"Name","","m","m","m","DD","HH:mm","m"];
        dict.NodeInflowSummary = ["Node","Type","MaxLatInflow","MaxTotalInflow","DayOfMaxInflow","HourOfMaxInflow","LatInflowVol","TotalInflowVol","FlowBalanceError";"Name","","cms","cms","DD","HH:mm","10e6L","10e6L","%"];
        dict.NodeFloodingSummary = ["Node";"Name"];
        dict.OutfallLoadingSummary = ["OutfallNode","FlowFreq","AvgFlow","MaxFlow","TotalVol","TotalBOD","TotalTSS";"Name","%","cms","cms","10e6L","kg","kg"];
        dict.LinkFlowSummary = ["Link","Type","MaxAbsFlow","DayOfMaxFlow","HourOfMaxFow","MaxAbsVel","Max/FullFlow","Max/FullDepth";"Name","","cms","DD","HH:mm","m/s","frac","frac"];
        dict.ConduitSurchargeSummary = ["Link";"Name"];
        dict.LinkPollutantLoadSummary = ["Link","BOD","TSS";"Name","kg","kg"];
end










end