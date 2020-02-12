

% scripts to load ArcGIS export tables containing lists of elements to
% delete in SWMM because for some reason there is no batch delete in
% EPASWMM so I am taking three days of my life to develop a convoluted
% method for spatial deletion
% in ARCGIS - select by area (i.e. select everything in non-useful
% subcatchments) and batch export to db table then xls table
% use this script after running 'swmm_draw.m'

% this needs to be executed perfectly or the entire model will get fucked
% up and not run... back it up back it up

%%

%% merge 'delete tables' (ArcGIS batch output)
% swmm_initialize(path_model)

swmm_names = {'subcatchments','junctions', 'outfalls', 'storage', 'conduits', 'outlets'};
swmm_elements = [];
for i2 = 1:numel(swmm_names)
    
ffile_table = [path_project '\gis\' 'TableToExcel_OutputExcelFile_CopyRows_OutTable_' swmm_names{i2} '.xls'];

opts = detectImportOptions(ffile_table); % preview(file_precip,opts)
data = readtable(ffile_table,opts);

element_names = data.Name;
swmm_elements = [swmm_elements;element_names];
end

swmm_elements = replace(swmm_elements,"'","");

% delete the elements
swmm_delete_elements(ffile_model,swmm_elements)


%% run the model
swmm_execute(ffile_model)

%% there WILL be errors, identify the elements causing errors and delete them...
fid = fopen([ffile_model '.rpt'],'r');
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);
content = content_cell{1};

error_lines = find(contains(content','ERROR'));

swmm_elements = cell(numel(error_lines),1);

for i2 = 1:numel(error_lines)    
    element_line = strsplit(content{error_lines(i2) + 1},'\t');
    swmm_elements{i2} = element_line{1};
    disp(element_line{1});
end

%%
swmm_delete_elements(ffile_model,swmm_elements)

%% run the model
swmm_execute(ffile_model)

