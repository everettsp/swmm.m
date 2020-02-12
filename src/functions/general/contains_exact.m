function [ind] = contains_exact(masterList,subsetList)
%returns logical index of subset list items in master list
%similar to 'contains()' function but for exact string match

ind = zeros(length(masterList),1);
for i = 1:length(subsetList)
    position = find(strcmp(masterList,subsetList{i}));
    ind(position) = 1;
end
ind = logical(ind);
end