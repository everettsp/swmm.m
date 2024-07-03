function [mainStruct] = update_fields(mainStruct,subStruct)
%this function adds field names contained in substruct to struct
%if field names are already the same, does nothing
       if numel(fieldnames(mainStruct)) ~= numel(fieldnames(subStruct))
           newFieldsIdx = ~contains_exact(fieldnames(subStruct),fieldnames(mainStruct));
           fields = fieldnames(subStruct)';
           newFields = fields(newFieldsIdx);
           init = cell(numel(mainStruct),1);
           for ii = 1:nnz(newFieldsIdx)
               [mainStruct.(newFields{ii})] = init{:};
           end
       end
end