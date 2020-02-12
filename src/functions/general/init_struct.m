function [mainStruct] = init_struct(mainStruct,subStruct)
%will create an empty structure with the same fields as subStruct
     if any(size(fieldnames(mainStruct)) == 0) %if the main struct is empty
        fields = fieldnames(subStruct)'; %create empty struct with correct fields
        fields{2,1} = {};
        mainStruct = struct(fields{:});
     end
end