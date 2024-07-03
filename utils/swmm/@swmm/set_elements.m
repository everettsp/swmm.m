function [mdl] = set_elements(mdl,vars,pop)
% assert(size(pop,2) == size(vars,1),'vars and pop must have same length')

classes = unique(vars.class);
for i2 = 1:numel(classes)
    attributes = unique(vars.attribute(strcmp(vars.class,classes{i2})));
    for i3 = 1:numel(attributes)
        % index of matching class and attribute
        idx = strcmp(vars.class,classes{i2}) & strcmp(vars.attribute,attributes{i3});
        [~,ind] = ismember(mdl.p.(classes{i2})(:,1).Variables,vars.name(idx));
        pop2 = pop(idx);
        mdl.p.(classes{i2}).(attributes{i3}) = pop2(ind)';
    end
end
clear pop2 idx ind i2 i3
end