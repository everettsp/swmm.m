function ok = init_struct(fieldnames,val)
if size(fieldnames,2) ~= 1
    fieldnames = fieldnames';
end
if nargin < 2
    val = '';
end

temp = reshape([fieldnames,repmat({val},[numel(fieldnames),1])]',[2*numel(fieldnames),1]);
ok = struct(temp{:});
end