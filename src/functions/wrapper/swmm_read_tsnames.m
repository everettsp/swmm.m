function elements_list = swmm_read_tsnames(file_swmm,varargin)
%
% par = inputParser;
% addParameter(par,'file_type','inp')
% parse(par,varargin{:})
%
%
% file_type = par.Results.file_type;
%
% switch lower(file_type)
%     case {'rpt','output','report','out','o'}
%         file_type = 'rpt';
%     case {'inp','input','i'}
%         file_type = 'inp';
%     otherwise
%         error("file_type not recognized, use either 'inp' or 'rpt' for input or output files, respectively")
% end

file_swmm_out = [file_swmm '.' file_type];

fid = fopen(file_swmm_out);
content_cell = textscan(fid,'%s','Delimiter',{'\n'});
fclose(fid);

content = content_cell{1};
clear content_cell

line_start = find(contains(content','<<< '));

num_elements = numel(line_start);
elements_list = cell(num_elements,1);

for i1 = 1:num_elements
    line_str = content{line_start(i1)};
    line_split = strsplit(line_str);
    elements_list{i1} = line_split{3};
end


end