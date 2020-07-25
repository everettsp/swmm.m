function obj = use_rff(obj,ffile_rf)
idx = contains(obj.p.files.Type,'RAINFALL');
if any(idx); obj.p.files(idx,:) = []; end
new_swmm_file = table({'USE'},{'RAINFALL'},{['"',ffile_rf,'"']},'VariableNames',{'Usage','Type','Filename'});
obj.p.files = [obj.p.files; new_swmm_file];
end