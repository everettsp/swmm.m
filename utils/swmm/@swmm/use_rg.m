function mdl2 = use_rg(mdl,ffile_rg)

% set raingages to dat file
mdl2 = mdl;
num_rg = height(mdl2.p.raingages);
mdl2.p.raingages.SourceName = repmat({['"',ffile_rg,'"']},[num_rg,1]);

% remove use cases for RFF files
idx = contains(mdl.p.files.Type,'RAINFALL') && contains(mdl.p.files.Usage,'USE');
if any(idx); mdl.p.files(idx,:) = []; end
end