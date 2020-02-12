function swmm_delete_elements(ffile_model,swmm_elements)
% ffile_model is the full path of the SWMM .inp model
% swmm_elements is a list (cell) of elements to be deleted
% this script will search through all of the relevant class categories for
% the elements to delete


% list the all the classes
list_sections = swmm_list_classes(ffile_model);

% from the full list, filter certain classes that aren't relevant to
% deleting

ind_tables = [5:15 17:19 23:26];
list_sections = list_sections(ind_tables);
swmm_tables = cell(numel(list_sections),1);

% for each class, read the table
for i2 = 1:numel(list_sections)
    swmm_tables{i2} = swmm_read_class(ffile_model, list_sections{i2});
end

% search fields indicate where to query each element ID for deletion, since
% some elements, such as XSECTIONS, may not be selectable in ArcGIS, but
% are still associated with a deleted object
rows_delete = [];
search_fields = {'Name','From_Node','To_Node','Subcatchment','Link','Node','Gage'};
for i2 = 1:numel(swmm_tables)
    ldx_fields = ismember(swmm_tables{i2}.Properties.VariableNames,search_fields);
    
    swmm_names = swmm_tables{i2}(:,ldx_fields).Variables;
    
    delete_names = cellfun(@char,swmm_elements,'UniformOutput',false);
    delete_names = strtrim(delete_names);
    
    ldx_delete = any(ismember(swmm_names, delete_names),2);
    
    rows_delete = [rows_delete; swmm_tables{i2}.line_num(ldx_delete)];
end

ffile_inp = [ffile_model '.inp'];
fid = fopen(ffile_inp);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);
content = content_cell{1};

content = content(~ismember(1:numel(content),rows_delete));
fid = fopen(ffile_inp,'w+');
for i1 = 1:numel(content)
    fprintf(fid,'%s\n',content{i1,:});
end
fclose(fid);
end
