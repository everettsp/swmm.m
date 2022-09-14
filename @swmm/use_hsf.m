function obj = use_hsf(obj,ffile_hs)
% add use case for hotstart file
if ~isempty(obj.p.files)
idx = contains(obj.p.files.Type,'HOTSTART');
if any(idx); obj.p.files(idx,:) = []; end
end

new_swmm_file = table({'USE'},{'HOTSTART'},{['"',ffile_hs,'"']},'VariableNames',{'Usage','Type','Filename'});
obj.p.files = [obj.p.files; new_swmm_file];
end