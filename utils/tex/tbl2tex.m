% ----------------------------------------------------------------------- %
% Function table2latex(T, filename) converts a given MATLAB(R) table into %
% a plain .tex file with LaTeX formatting.                                %
%                                                                         %
%   Input parameters:                                                     %
%       - T:        MATLAB(R) table. The table should contain only the    %
%                   following data types: numeric, boolean, char or string.
%                   Avoid including structs or cells.                     %
%       - filename: (Optional) Output path, including the name of the file.
%                   If not specified, the table will be stored in a       %
%                   './table.tex' file.                                   %
% ----------------------------------------------------------------------- %
%   Example of use:                                                       %
%       LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};             %
%       Age = [38;43;38;40;49];                                           %
%       Smoker = logical([1;0;1;0;1]);                                    %
%       Height = [71;69;64;67;64];                                        %
%       Weight = [176;163;131;133;119];                                   %
%       T = table(Age,Smoker,Height,Weight);                              %
%       T.Properties.RowNames = LastName;                                 %
%       table2latex(T);                                                   %
% ----------------------------------------------------------------------- %
%   Version: 1.1                                                          %
%   Author:  Victor Martinez Cagigal                                      %
%   Date:    09/10/2018                                                   %
%   E-mail:  vicmarcag (at) gmail (dot) com                               %
% ----------------------------------------------------------------------- %
function tbl2tex(T, filename, varargin)

%     % Error detection and default parameters
%     if nargin < 2
%         filename = 'table.tex';
%         fprintf('Output path is not defined. The table will be written in %s.\n', filename);
%     elseif ~ischar(filename)
%         error('The output file name must be a string.');
%     else
if ~strcmp(filename(end-3:end), '.tex')
    filename = [filename '.tex'];
end
%     end
%
%
%     if nargin < 1, error('Not enough parameters.'); end

par = inputParser;
% addParameter(par,'bf',false(size(T)));
% addParameter(par,'it',false(size(T)));
addParameter(par,'justification','c');
addParameter(par,'include_units',false);
addParameter(par,'hlines',[]);
addParameter(par,'vlines',[]);

parse(par,varargin{:})
jstf = par.Results.justification;
include_units = par.Results.include_units;
hlines = par.Results.hlines;
vlines = par.Results.vlines;
% it = par.Results.it;


if ~istable(T), error('Input must be a table.'); end

col_names = strjoin(T.Properties.VariableNames, ' & ');
col_units = strjoin(T.Properties.VariableUnits, '& ');
row_names = T.Properties.RowNames;

% Parameters
[n_row,n_col] = size(T);

% if hlines = True, horizontal grid
if hlines
    hlines = (0:(n_row+1));
end

% if vlines = True, vertical grid
if vlines
    vlines = (0:n_col);
end
% 
% if ~isempty(row_names)
%     vlines(end+1) = height(T)+1;
% end


col_spec = [];

for c = 1:n_col
    if any(vlines-1 == c)
        col_spec = [col_spec,jstf,'|'];
    else
        col_spec = [col_spec,jstf];
    end
end


if any(vlines == 1)
    col_spec = ['|' col_spec];
end

if ~isempty(row_names)
    col_spec = ['l' col_spec];
    col_names = ['& ' col_names];
end

if any(vlines == 0)
    col_spec = ['|' col_spec];
end

% Writing header

fileID = fopen(filename, 'w');


fprintf(fileID, '\\begin{tabular}{%s}\n', col_spec);
% if any(hlines == 0)
    fprintf(fileID, '\\hline \n');
% end


fprintf(fileID, '%s \\\\ \n', col_names);
if include_units
    fprintf(fileID, '%s \\\\ \n', col_units);
end
fprintf(fileID, '\\hline \n');

% Writing the data
try
    for row = 1:n_row
        temp{1,n_col} = [];
        for col = 1:n_col
            value = T{row,col};
            if isstruct(value), error('Table must not contain structs.'); end
            while iscell(value), value = value{1,1}; end
            if isinf(value), value = '$\infty$'; end
            temp{1,col} = num2str(value);
            
        end
        if ~isempty(row_names)
            temp = [row_names{row}, temp];
        end
        
        fprintf(fileID, '%s \\\\ \n', strjoin(temp, ' & '));
        
        if any(row == hlines)% insert horizontal lines to break up table
            fprintf(fileID, '\\hline \n');
        end
        
        clear temp;
    end
catch
    error('Unknown error. Make sure that table only contains chars, strings or numeric values.');
end

% Closing the file
fprintf(fileID, '\\hline \n');
fprintf(fileID, '\\end{tabular}');
fclose(fileID);
end