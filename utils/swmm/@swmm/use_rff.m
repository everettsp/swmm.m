function obj = use_rff(obj,ffile_rf)
if ~isempty(obj.p.files)
idx = contains(obj.p.files.Type,'RAINFALL');
else
    idx = false;
end

if any(idx); obj.p.files(idx,:) = []; end
new_swmm_file = table({'USE'},{'RAINFALL'},{['"',ffile_rf,'"']},'VariableNames',{'Usage','Type','Filename'});
obj.p.files = [obj.p.files; new_swmm_file];
end