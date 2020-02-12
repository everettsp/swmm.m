classdef swmm_model
    properties
        dir_main
        dir_report
        name
        inp
        rpt
        class_list
        %         title % string, need exception
                options % name-pairs, need exception
        evaporation
        raingages
        subcatchments
        subareas
        infiltration
        storage
        %         lid_controls % no headers for attributes - need to code hard code
        %         all LID properties
        lid_usage
        junctions
        outfalls
        outlets
        orifices
        weirs
        conduits
        xsections
        transects
        timeseries
        losses
        curves
        %         report % report is just 3 options, no headings...
        %         tags
        %         map % no headings, need exception
        coordinates
        vertices
        polygons
        symbols
        shapes
    end
    
    properties (Dependent=true)

    end
    
    methods
        function obj = swmm_model(ffilepath)
            
            [model_loc,model_name,model_ext] = fileparts(ffilepath);
            assert(strcmp(model_ext,'.inp'),"model file path must have extension '.INP'");
            obj.dir_main = model_loc;
            obj.dir_report = [model_loc,'\report\'];
            obj.name = model_name;
            obj.inp = [model_loc,'\',model_name,'.inp'];
            obj.rpt = [model_loc,'\',model_name,'.rpt'];
            obj.class_list = {...
                %                 'title';...
                                'options';...
                'evaporation';...
                'raingages';...
                'subcatchments';...
                'subareas';...
                'infiltration';...
                'storage';...
                %                 'lid_controls';...
                'lid_usage';...
                'junctions';...
                'outfalls';...
                'outlets';...
                'orifices';...
                'weirs';...
                'conduits';...
                'xsections';...
%                 'transects';...
                'timeseries';...
                'losses';...
                'curves';...
                %                 'report';...
                %                 'tags';...
                %                 'map';...
                'coordinates';...
                'vertices';...
                'polygons';...
                'symbols'};
        end
        
        function obj = pull(obj)
            obj = swmm_pull(obj);
        end
        
        function obj = copy(obj,path_copy)
            [status,msg] = mkdir(path_copy);
            ffilename_copy = [path_copy,obj.name,'_copy','.inp'];
            copyfile(obj.inp,ffilename_copy,'f');
            obj = swmm_model(ffilename_copy);
        end
        
        function obj = push(obj)
            swmm_push(obj);
        end
        
        function obj = sim(obj)
            % create a .BAT file in windows temp. directory
            ffile_bat = [tempdir,obj.name,'.bat'];
            content = ['"' 'C:\Program Files (x86)\EPA SWMM 5.1.013\swmm5.exe' '" ',...
                '"',obj.inp,'" ',...
                '"',obj.rpt,'"'];
            fid = fopen(ffile_bat,'w+');
            fprintf(fid,'%s',content);
            fclose(fid);
            
            % call the .BAT file to run SWMM
            sys_cmd = ['call "' ffile_bat '"' '>NUL'];
            system(sys_cmd);
            delete(ffile_bat);
        end
        
        function swmm_tt = tt(obj, swmm_class, swmm_name)
            swmm_tt = swmm_timetable(obj.rpt, swmm_class, swmm_name);
        end
        
        function dblog(obj,msg)
            if ~exist(obj.dir_report,'dir')
                mkdir(obj.dir_report)
            end
            ffile_log = [obj.dir_report,'debug_log.txt'];
            % if input message is 'clear', delete file
            if any(strcmpi({'clear','clr','delete','new','overwrite'},(msg))) && exist(ffile_log)
                delete(ffile_log)
            end
            fid = fopen(ffile_log,'a+');
                msg_time = char(datetime);
                disp([msg_time,'        ',char(msg)])
                fprintf(fid, [msg_time,'\t\t',char(msg),'\n']);
                
            fclose(fid);
        end
        
        function obj = map(obj)
            obj.shapes = swmm_map(obj);
        end
            
        
    end
    
    methods (Access=private)
    end
    
end