function apply_abbrev(str_keyword,str_abbrev,varargin)

par = inputParser;
addParameter(par,'type','all')

parse(par,varargin{:})

type = par.Results.right;

fh = gcf;

switch lower(type)
    case {'all','legend','leg'}
        lh = findobj(fh, 'Type', 'Legend');
        lh.String
end

switch lower(type)
    case {'all','axes','ax','plots','ticks','labels'}
        
        lhs = findobj(fh, 'Type', 'Legend');
        
        for ii = 1:numel(lhs)
            lh = lhs(ii);
            str_cell = lh.String;
            
            for iii = 1:numel(str_cell)
                    lh.String{iii} = abbrev(lh.String,str_keyword,str_abbrev);

            end
        end
        
        
        ah = findobj(fh, 'Type', 'Axes');
        
        str_cell = lh.String;
        
        for ii = 1:numel(ahs)
            ah = ahs(ii);
            
            for iii = 1:numel(str_cell)
                for iv = 1:numel(str_keyword)
                    ah.String{iii} = abbrev(ah.String,str_keyword{iv},str_abbrev{iv});
                end
            end
            
            
        end
        
