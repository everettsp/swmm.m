function apply_font(font_name,font_size,varargin)
%% for an existing figure: modify figure font name, size, case, and abbreviate terms

%% parse inputs
%  case [upper, lower]: changes capitalization of all text within figure
%      can't find a 'find all strings' command for figures, so just adding
%      each possible case - ugly but it works, there may be exceptions...
%  abbrev [{key, value}]: cell key-value pair (for any number of columns),
%      will replace the keyword with the value, for example
%      {'validation',val'} will replace all instances of key word with
%      value word

par = inputParser;
addParameter(par,'case','unchanged')
addParameter(par,'abbrev',false)

parse(par,varargin{:})

font_abbrev = par.Results.abbrev;
font_case = par.Results.case;

if iscell(font_abbrev) && size(font_abbrev,2) ~= 2
    error('font abbrev input incorrect: should have two columns for abbreviation combinations')
end

%% grab figure handle
% set the font size and name for the entire figure
fh = gcf;

set(findall(fh,'-property','FontSize'),'FontSize',font_size);
set(findall(fh,'-property','FontName'),'FontName',font_name);

%%
%

switch lower(font_case)
    case {'lower','low'}
        fun_font = @(x) lower(x);
    case {'upper','up'}
        fun_font = @(x) upper(x);
    otherwise
        %do nothing
        fun_font = @(x) x;
end
cycle_figstr(fh,fun_font)


if iscell(font_abbrev)
    fun_abbrev = @(str_long) abbrev(str_long,font_abbrev(:,1),font_abbrev(:,2));
    cycle_figstr(fh,fun_abbrev)
end


    function cycle_figstr(fh,fun)
        % this function will iteratively select each string element
        % contained within a figure and pass it through the function 'fun'
        
        
        fh.Name = fun(fh.Name);
        
        %% legend
        lh = findobj(fh, 'Type', 'Legend');
        for ii = 1:numel(lh)
            for iii = 1:numel(lh(ii).String)
                lh(ii).String{iii} = fun(lh(ii).String{iii});
            end
        end
        
        %% apply string function to each of the string objects associated with axes
        ah = findobj(fh, 'Type', 'Axes');
        for ii = 1:numel(ah)
            ah(ii).Title.String = fun(ah(ii).Title.String);
            ah(ii).XLabel.String = fun(ah(ii).XLabel.String);
            
            if ischar(ah(ii).XTickLabel)
                ah(ii).XTickLabel = {ah(ii).XTickLabel};
            end
            
            if ~isempty(ah(ii).XTickLabel)
                if isempty(str2double(ah(ii).XTickLabel{1}))
                    for iii = 1:size(ah(ii).XTickLabel,1)
                        ah(ii).XTickLabel(iii,:) = fun(ah(ii).XTickLabel(iii,:));
                    end
                end
            end
            
            % if the figure contains a right axis, apply function to right
            % axis elements
            % CAUTION: this will fail if the yyaxis right is not the most
            % recent axes selected, I don't know a good way around this
            % right now...
            contains_yright = false;
            
            
            if contains(ah(ii).YAxisLocation,'right')
                contains_yright = true;
                ah(ii).YLabel.String = fun(ah(ii).YLabel.String);
                if ~isempty(ah(ii).YTickLabel)
                    if isempty(str2double(ah(ii).YTickLabel{1}))
                        for iii = 1:size(ah(ii).YTickLabel,1)
                            ah(ii).YTickLabel(iii,:) = fun(ah(ii).YTickLabel(iii,:));
                        end
                    end
                end
                yyaxis left
            end
            
            ah(ii).YLabel.String = fun(ah(ii).YLabel.String);
            
            if ischar(ah(ii).XTickLabel)
                ah(ii).YTickLabel = {ah(ii).YTickLabel};
            end
            
            if ~isempty(ah(ii).YTickLabel)
                if isempty(str2double(ah(ii).YTickLabel{1}))
                    for iii = 1:size(ah(ii).YTickLabel,1)
                        ah(ii).YTickLabel(iii,:) = fun(ah(ii).YTickLabel(iii,:));
                    end
                end
            end
            if contains_yright
                yyaxis right
            end
            
        end
        
        %% dataseries (not really important since changing legend values directly anyways)
        ph = findobj(fh, 'Type', 'Line');
        for ii = 1:numel(ph)
            ph(ii).DisplayName = fun(ph(ii).DisplayName);
        end
    end



end