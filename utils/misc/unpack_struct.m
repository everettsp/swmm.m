function unpack_struct(structure)
    fn = fieldnames(structure);
    for i2 = 1:numel(fn)
        fni = string(fn(i2));
        field = structure.(fni);
        assignin('caller', fni, field);
    end
%% orig recursive function only works when assignin to base, since nested struct would be assigned to recurve ws
%     for i = 1:numel(fn)
%         fni = string(fn(i));
%         field = structure.(fni);
%         if (isstruct(field))
%             unpack_struct(field);
%             continue;
%         end
%         assignin('caller', fni, field);
%     end
end