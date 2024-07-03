function apply_sqlims(varargin)
% function handle as input, 'buffer_ratio' will add more whitespace based on
% automatic limit values; 'same_plusminus' will give LR/UD same abs val


par = inputParser;
addParameter(par,'fh',gcf)
addParameter(par,'buff_ratio',1)
addParameter(par,'center',false)
addParameter(par,'dim','both')
parse(par,varargin{:})
fh = par.Results.fh;
buff_ratio = par.Results.buff_ratio;
center = par.Results.center;
dim = par.Results.dim;


sph = findobj(fh,'Type','Axes');

num_sp = numel(sph);

%% get a list of the limits for all subplots
old_xlims = nan(num_sp,2);
old_ylims = nan(num_sp,2);

for ii = 1:num_sp
    old_xlims(ii,:) = sph(ii).XLim;
    old_ylims(ii,:) = sph(ii).YLim;
%     old_xlabels = sph(ii).XLabel.String;
%     old_ylabels = sph(ii).YLabel.String;
%     old_yticks = sph(ii).YTickLabels;
%     old_xticks = sph(ii).XTickLabels;
end

%% find the maximum existing limits and set all limits to those values
new_xlims = nan(1,2);
new_ylims = nan(1,2);

if center %if -x and x (and -y and y) should the same abs value
    max_xlims = max(max(abs(old_xlims)));
    new_xlims = [-max_xlims max_xlims];
    
    max_ylims = max(max(abs(old_ylims)));
    new_ylims = [-max_ylims max_ylims];
    
else
    new_xlims(1) = min(old_xlims(:,1));
    new_xlims(2) = max(old_xlims(:,2));
    
    new_ylims(1) = min(old_ylims(:,1));
    new_ylims(2) = max(old_ylims(:,2));
end

%% set the new limits

for ii = 1:num_sp
    set(fh,'CurrentAxes',sph(ii))
    
    switch dim
        case {'x','horz','horizontal'}
            sph(ii).XLim = buff_ratio * new_xlims;
            xticklabels('auto')
        case {'y','vert','vertical'}
            sph(ii).YLim = buff_ratio * new_ylims;
            yticklabels('auto')
        otherwise
            sph(ii).XLim = buff_ratio * new_xlims;
            xticklabels('auto')
            sph(ii).YLim = buff_ratio * new_ylims;
            yticklabels('auto')
    end
    
end

end