    function tf = contains_exactly(list,val)
        tf = false(numel(list),1);
        for j1 = 1:numel(list)
            tf(j1) = strcmp(list{j1},val);
        end
%         ind = find(tf);
    end