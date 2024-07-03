classdef swmm
    properties
        dir_main = ""
        dir_results = ""
        dir_data = ""
%         dir_debug = ""
        dir_parent = ""
        dir_data_parent = "" % legacy, find from cd parent
        read_only {islogical} = false
        name = ""
        debug_log = {}
        inp = ""
        rpt = ""
        class_info = table()
        p = struct()
        shapes
    end
    
    properties (Dependent=true)
        
    end
    
    methods
        function obj = swmm(ffilepath)
            
            [model_loc,model_name,model_ext] = fileparts(ffilepath);
            assert(strcmp(model_ext,'.inp'),"model file path must have extension '.INP'");
            
            obj.dir_parent = model_loc;
            
            obj.read_only = false;
            obj.name = model_name;
            
            obj.debug_log = {};
            obj.inp = [model_loc,'\',model_name,'.inp'];
            obj.rpt = [model_loc,'\',model_name,'.rpt'];
            
            % initialize struct with SWMM parameter attributes
            temp = reshape([fields(obj.dict('attributes')),cell(numel(fields(obj.dict('attributes'))),1)]',[2*numel(fields(obj.dict('attributes'))),1]);
            obj.p = struct(temp{:});
            
            % read the INP data
            obj = obj.read_inp;
        end

        obj = new_project(obj, path_copy, varargin);
        obj = new_copy(obj, path_copy, varargin);
        obj = read_inp(obj);
        obj = write_inp(obj,ffile_inp);
        obj = runsim(obj,ffile_rpt);
        vars = classes2elements(obj,vars_classes);
        evnts = prerun(obj,evnts, varargin);
        
        perf = obj_fun(obj,pop,vars,evnts)
        obj = set_elements(obj,elements,pop)
        
        tt = results_tt(obj, queries);
        res = results_summary(obj);
        
        tt = eval(obj, event, queries);
        obj = dblog(obj,msg);
        obj = write_dblog(obj);
        obj = read_crd(obj);
        obj = draw(obj);
        obj = write_shp(obj);
        obj = delete_catchment(obj);
        dict_out = dict(obj,kwd);
        tt2dat(obj,ffilename_dat_new);
        obj = save_rff(obj,filenamne,tt);
        obj = save_hsf(obj,filename,prerun_duration);
        obj = use_rff(obj,filename);
        obj = use_rg(obj,filename);
        obj = use_hsf(obj,filename);
%         [datestr_array, timestr_array] = datetime2datestr(obj,datetime_array)
%         datetime_array = datestr2datetime(obj,datestr_array,timestr_array)
    end
    
    methods (Access=private)
    end
    
end
