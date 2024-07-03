function [t] = merge_tables(t1,t2)
t1colmissing = setdiff(t2.Properties.VariableNames, t1.Properties.VariableNames);
t2colmissing = setdiff(t1.Properties.VariableNames, t2.Properties.VariableNames);
t1 = [t1 array2table(repmat({''},[height(t1), numel(t1colmissing)]), 'VariableNames', t1colmissing)];
t2 = [t2 array2table(repmat({''},[height(t2), numel(t2colmissing)]), 'VariableNames', t2colmissing)];

vc1 = cell(width(t1),1);
vc2 = cell(width(t2),1);

for i2 = 1:width(t1)
    vc1{i2} = class(t1.(t1.Properties.VariableNames{i2}));
    vc2{i2} = class(t2.(t2.Properties.VariableNames{i2}));
end

if ~(any([isempty(t1),isempty(t2)]))
    idx = find(ismember(strcmp([vc1,vc2],'double'),[0,1],'rows') | ismember(strcmp([vc1,vc2],'double'),[1,0],'rows'));
    % | ismember(strcmp([vc1,vc2],'double'),[1,0],'rows'));

    for i2 = 1:numel(idx)
        t1.(t1.Properties.VariableNames{idx(i2)}) = nan(height(t1),1);
        t2.(t2.Properties.VariableNames{idx(i2)}) = nan(height(t2),1);
    end
end
t = [t1; t2];

end

