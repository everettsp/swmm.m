function summary_table = swmm_summary(ffile_model,name_section)
% right now this script ONLY handles raingage and subcatchments, the other
% stuff is a MASSIVE pain in the ass and I don't anticipate ever needing it
if ~contains(ffile_model,'.rpt')
    ffile_model = [ffile_model '.rpt'];
end

fid = fopen(ffile_model);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);

content = content_cell{1};
clear content_cell

% we can't automatically parse the headings for each section, since they each have 3
% lines and each line has a different number of fields
% so we need to hard code this - there aren't that many sections and so
% long as they always stay the same, it's not a problem...


names_sections = {...
    'Rainfall File Summary'      ,...
    'Subcatchment Runoff Summary',...
    'Node Depth Summary'         ,...
    'Node Inflow Summary'        ,...
    'Storage Volume Summary'     ,...
    'Link Flow Summary'          ,...
    'Flow Classification Summary',...
    'Conduit Surcharge Summary'  };

headers{1} = {'Station_ID','First_Date','Last_Date','Recording_Frequency','Prediods_wPrecip','Periods_Missing','Periods_Malfunc'};
headers{2} = {'Subcatchment','Total_Precip','Total_Runon','Total_Evap','Total_Infil','Imperv_Runoff','Perv_runoff','Total_Runoff','Total_Runoff2','Peak_Runoff','Runoff_Coeff'};
headers{3} = {'Node','Type','Average_Depth','Maximum_Depth','Maximum_HGL','DayofMax_Occurence','TimeofMax_Occurence','Reported_Max_Depth'};
headers{4} = {'Node','Type','Maximum_Lateral_Inflow','Maximum_Total_Inflow','DayofMax_Occuurence','Time_Max_Occurence','Lateral_Inflow_Volume','Total_Inflow_volume','Flow_Balance_Error'};
headers{5} = {'Storage_Unit','Average_Volume','Average_Pcnt_Full','Evap_Pct_Loss','ExfillPcnt_Loss','Maximum_Volume','Max_Pcnt_Full','DayofMax_Occurence','TimeofMax_Occurrence','Maximum_Outflow'};
headers{6} = {'Link','Type','Maximum_Flow','DayofMax_Occurence','TimeofMax_Occurence','Maximum_Veloc','Max_Full','Max_Full2'};
headers{7} = {''};
headers{8} = {''};

units{1} = {''};
units{2} = {'','mm','mm','mm','mm','mm','mm','mm','10E6ltr','cms','unitless'};
units{3} = {'','','Meters','Meters','Meters','days','hrmin','meters'};
units{4} = {'','','CMS','CMS','days','hrmin','10E6ltr','10E6ltr','Percent'};
units{5} = {'','1000m3','Percent','Percent','Percent','100m3','Percent','days','hrmin','CMS'};
units{6} = {'','','CMS','days','hrmin','mpersec','Flow','Depth'};
units{7} = {''};
units{8} = {''};

% idx = contains(names_sections,'Subcatchment Runoff');

section_splits = find(contains(content','----------------------------------------------------------------------------'));
line_sections = section_splits(1:2:end);
num_sections = numel(line_sections);
summary_table = table();

idx = find(contains(lower(names_sections),lower(name_section)));

if ~any(idx)
    fprintf("couldn't find %s in section names, try one of the following:\n",name_section)
    disp(names_sections);
    error('')
end

for i2 = idx
    
    line_start = line_sections(i2) + 1;
    line_cycle = line_start;
    while ~isempty(content{line_cycle})
        line_cycle = line_cycle + 1;
    end
    line_end = line_cycle - 1;
    lines_section = line_start:line_end;
    num_elements = numel(lines_section);
    
    
    % for each attribute
    summary_table = table();
    num_attributes = numel(headers{i2});
    for i4 = 1:num_attributes
        
        % get the data
        value_attribute = {};
        for i3 = 1:num_elements
            value_cells = strsplit(content{lines_section(i3)},'  ');
            value_attribute{i3,1} = value_cells{i4};
        end
        
        %format the data
        if ~any(isnan(str2double(value_attribute)))
            value_attribute = str2double(value_attribute);
        end
        
        %store the data
        summary_table(:, headers{i2}{i4}) = table(value_attribute);
    end
    summary_table.Properties.VariableUnits = units{i2};
end
end