function swmm_push(obj)%elements, readwrite)

fid = fopen(obj.inp,'r');
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
content = content_cell{1};
clear content_cell
fclose(fid);

for i2 = 1:numel(obj.class_list)
    class_name = obj.class_list{i2};
    dt = obj.(class_name);
    if ~isempty(dt)
        for i3 = 1:height(dt)
            line_num = dt(i3,:).line_num;
            dt_cell = table2cell(dt(i3,1:(end-1))); %don't include line_num field
            %         idx_num = cellfun(@isnumeric,dt_cell);
            dt_cell_char = cellfun(@num2str, dt_cell,'UniformOutput',false);
            dt_str = strjoin(dt_cell_char,'\t');
            content{line_num} = dt_str;
        end
    end
end

fid = fopen(obj.inp,'w+');
for i2 = 1:numel(content)
    fprintf(fid,'%s\n',content{i2,:});
end
fclose(fid);

end