function res = results_summary(obj)
% read summaries of SWMM simulation results
% returns a struct containing all continuity and summary tables

fid = fopen(obj.rpt);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);

content = content_cell{1};
content_nospc = replace(content," ","");

% identify all comments in file (lines begining with ';;')
content_double = double(char(content));
lines_ast = find(all(content_double(:,1) == [42,42,42],2)); % lines with ***
lines_dsh = find(all(content_double(:,1) == [45,45,45],2)); % lines with ---
lines_lt = find(all(content_double(:,1) == [60,60,60],2)); % lines with <<<
lines_empty = find(all(content_double(:,1) == [32,32,32],2)); % lines with <<<
clear content_cell

lines_ast = lines_ast(lines_ast < lines_lt(1));
lines_dsh = lines_dsh(lines_dsh < lines_lt(1));

for i2 = 1:2:numel(lines_ast)
    for i3 = 1:2:numel(lines_dsh)
        line_sech = lines_ast(i2) + 1;
        
    end
end

res = struct();

dict = obj.dict("results");
summary_section_names = fields(dict);

get_next_line = @(x,y) min(y((y - x) > 0));
summary_table = table();

for i2 = 1:numel(fields(dict))
    
    
    try
        headers = cellstr(dict.(summary_section_names{i2})(1,:));
    catch
        continue
    end
    
    line_sech = find(contains(content_nospc,summary_section_names{i2}));
    
    if isempty(line_sech)
        continue
    end
    
    if contains(summary_section_names{i2},{'Options','Continuity'})

        line_ast2 = get_next_line(line_sech,lines_ast);
        line_sec1 = line_ast2 + 1;
        line_sec2 = get_next_line(line_sec1,lines_empty) - 1;
        lines_sec = line_sec1:line_sec2;
        sec_cells_single = cellfun(@(x) strsplit(x,{' .','. ','   '}), content(lines_sec),'UniformOutput',false);
        summary_cells = cell(numel(sec_cells_single),numel(headers)+1);

        for i3 = 1:numel(sec_cells_single)
            summary_cells(i3,1:numel(sec_cells_single{i3})) = sec_cells_single{i3};
        end
        summary_cells = strtrim(summary_cells(:,2~=(1:(numel(headers) + 1))));
        summary_table = cell2table(summary_cells,'VariableNames',headers);
    elseif contains(summary_section_names{i2},{'Summary'})
        line_sec1 = get_next_line(get_next_line(line_sech,lines_dsh),lines_dsh) + 1;
        if line_sec1 > get_next_line(get_next_line(line_sech,lines_ast),lines_ast) % section is empty
            continue
        end
        line_sec2 = get_next_line(line_sec1,lines_empty) - 1;
        lines_sec = line_sec1:line_sec2;
        sec_cells_single = cellfun(@(x) strsplit(x,{'  '}), content(lines_sec),'UniformOutput',false);
        summary_cells = cell(numel(sec_cells_single),numel(headers));
        
        for i3 = 1:numel(sec_cells_single)
            summary_cells(i3,1:numel(sec_cells_single{i3})) = sec_cells_single{i3};
        end
        
        summary_cells = strtrim(summary_cells);
        summary_cells = cell2num(summary_cells);
        summary_table = cell2table(summary_cells,'VariableNames',headers);
    else
        disp('error')
    end
    res.(summary_section_names{i2}) = summary_table;
end
