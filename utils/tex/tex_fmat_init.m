function [fmat] = tex_fmat_init(tbl)
    fmat = cell(size(tbl));
    [fmat{:}] = deal(@(x) x);
end

% 
% for j2 = find(contains(temp_table.Properties.VariableNames,'test'))
% %         if all(isnumeric(temp_table(:,j2).Variables))
%         [~,temp_max] = max(temp_table(:,j2).Variables);
%         fmat(temp_max,j2) = {@(x) cellstr(['\textbf{',char(x),'}'])};
% %         end
% end