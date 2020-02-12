function [swmm_option_namepairs, msg] = swmm_options(file_swmm, varargin)
% Reads options from SWMM .inp file
% Will write 
% MM/DD/YYYY
% parameter_names = {'START_DATE','REPORT_START_DATE','END_DATE'};
% parameter_values = {'01/01/2018','01/01/2018','01/01/2019'};
p = inputParser;
addParameter(p,'FLOW_UNITS','', @isstr)
addParameter(p,'INFILTRATION','', @isstr)
addParameter(p,'FLOW_ROUTING','', @isstr)
addParameter(p,'LINK_OFFSETS','', @isstr)
addParameter(p,'MIN_SLOPE','', @isstr)
addParameter(p,'ALLOW_PONDING','', @isstr)
addParameter(p,'SKIP_STEADY_STATE','', @isstr)
addParameter(p,'START_DATE','', @isstr)
addParameter(p,'START_TIME','', @isstr)
addParameter(p,'REPORT_START_DATE','', @isstr)
addParameter(p,'REPORT_START_TIME','', @isstr)
addParameter(p,'END_DATE','', @isstr)
addParameter(p,'END_TIME','', @isstr)
addParameter(p,'SWEEP_START','', @isstr)
addParameter(p,'SWEEP_END','', @isstr)
addParameter(p,'DRY_DAYS','', @isstr)
addParameter(p,'REPORT_STEP','', @isstr)
addParameter(p,'WET_STEP','', @isstr)
addParameter(p,'ROUTING_STEP','', @isstr)
addParameter(p,'RULE_STEP','', @isstr)
addParameter(p,'INERTIAL_DAMPING','', @isstr)
addParameter(p,'NORMAL_FLOW_LIMITED','', @isstr)
addParameter(p,'FORCE_MAIN_EQUATION','', @isstr)
addParameter(p,'VARIABLE_STEP','', @isstr)
addParameter(p,'LENGTHENING_STEP','', @isstr)
addParameter(p,'MIN_SURFAREA','', @isstr)
addParameter(p,'MAX_TRIALS','', @isstr)
addParameter(p,'HEAD_TOLERANCE','', @isstr)
addParameter(p,'SYS_FLOW_TOL','', @isstr)
addParameter(p,'LAT_FLOW_TOL','', @isstr)
addParameter(p,'MINIMUM_STEP','', @isstr)
addParameter(p,'THREADS','', @isstr)

p.CaseSensitive = true;
p.KeepUnmatched = false;
p.PartialMatching = false;
parse(p,varargin{:});
p.Results;
p_fieldnames = fieldnames(p.Results);
p_fieldnames = p_fieldnames(~contains(p_fieldnames,p.UsingDefaults));

% specify the swmm input file
if ~contains(file_swmm,'.inp')
    file_swmm = [file_swmm '.inp'];
end

 % if new name-pairs aren't input, just read the options
 % otherwise, rewrite the options based on name-value pairs

% read the content of the file
fid = fopen(file_swmm);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);
content = content_cell{1};
clear content_cell

content_new = content;

% parse the fields for the code below, which is used to index the parameter names
swmm_classes = swmm_list_classes(file_swmm);

line_start = find(strcmp(content,'[OPTIONS]')) + 2;
next_class = swmm_classes(find(strcmp(swmm_classes,'[OPTIONS]')) + 1);
line_end = find(strcmp(content,next_class)) - 2;

options_lines = (line_start) : line_end;

%remove empty rows
options_lines = line_start - 1 + find(~cellfun(@isempty,content(options_lines)));
swmm_option_namepairs = cell(numel(options_lines),2);

for i1 = 1:numel(options_lines)
    line_cycle = options_lines(i1);
    temp = strsplit(content{line_cycle}); % tidy up get name-value pairs
    swmm_option_namepairs{i1,1} = strtrim(temp{1}); % name
    if ~isempty(temp{2})
        swmm_option_namepairs{i1,2} = strtrim(temp{2}); % value
    end
end

msg = 'reading simulation options';

if ~isempty(p_fieldnames)
        n = numel(p_fieldnames);
        % parameter_values = cell(n,1);
        for i1 = 1:n
            parameter_name = p_fieldnames{i1};
            parameter_val = p.Results.(parameter_name);
            % identify line containing parameter
            % search within the parsed fields as a means to handle exact matches
            parameter_linenum = strcmp(swmm_option_namepairs(:,1),parameter_name);
            parameter_oldline = options_lines(parameter_linenum);
            
            padding_num = 20 - numel(char(swmm_option_namepairs{parameter_linenum,1})); % add whitespace so that field is 20 characters
            padding = repmat(' ', [1 padding_num]);
            parameter_newline = sprintf('%s\t%s',[swmm_option_namepairs{parameter_linenum,1} padding],parameter_val);
            content_new{parameter_oldline} = parameter_newline;
        end
        
        % write new content to file
        fid = fopen(file_swmm,'w');
        for i1 = 1:numel(content_new)
            fprintf(fid,'%s\n',content_new{i1,:});
        end
        fclose(fid);
        
        msg = [msg '; options'];
        fieldnames_str = '';
        for i2 = 1:numel(p_fieldnames)
            fieldnames_str = [fieldnames_str, p_fieldnames{i2}];
        end
        msg = [msg,' (', fieldnames_str ') modified successfully...'];
        
end
end