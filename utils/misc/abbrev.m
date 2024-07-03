function [str_shortened] = abbrev(str_long,str_keywords,str_abbrevs)
%% replace a keyword contained in a long string with its abbreviation

%if inputs are not cells, convert to cells
if ~iscell(str_keywords)
    str_keywords = {str_keywords};
end

if ~iscell(str_abbrevs)
    str_abbrevs = {str_abbrevs};
end

idx = NaN(size(str_keywords));

for ii = 1:numel(str_keywords)
    str_keyword = str_keywords{ii};
    idx(ii) = contains(str_long,str_keyword);
end
idx = logical(idx);
if ~any(idx)
    str_shortened = str_long;
else
    
    
    str_keyword = str_keywords{idx};
    str_abbrev = str_abbrevs{idx};
    
    
    %get the number of characters and find the character index of keyword
    char_num = numel(str_keyword);
    char_start = regexp(str_long,str_keyword);
    str_remove = str_long(~ismember(1:numel(str_long),char_start:(char_start+char_num-1)));
    
    %depending on where the keyword is located, add abbreviated to string
    if char_start == 1
        str_shortened = [str_abbrev str_remove];
    elseif (char_start + char_num - 1) == numel(str_long)
        str_shortened = [str_remove str_abbrev];
    else
        str_shortened = [str_remove(1:(char_start-1)) str_abbrev str_remove(char_start:end)];
    end
    
end