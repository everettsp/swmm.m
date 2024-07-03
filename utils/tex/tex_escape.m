function tbl = tex_escape(tbl)
% add backslash to tex special characters in table (must already be
% converted to string)
escape_symbols = {'&','%','$','#','_'};
for i2 = 1:numel(escape_symbols)
    symbol = escape_symbols{i2};
    tbl.Variables = strrep(tbl.Variables,symbol,['\',symbol]);
    tbl.Properties.VariableNames = strrep(tbl.Properties.VariableNames,symbol,['\',symbol]);
    tbl.Properties.RowNames = strrep(tbl.Properties.RowNames,symbol,['\',symbol]);
end
end