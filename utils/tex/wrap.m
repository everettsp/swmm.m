function y = wrap(z)

if numel(z) == 1
    if iscell(z)
        z = z{1};
    elseif ischar(z)
        
        ztemp = cell(2,1);
        ztemp{1} = z;
        ztemp{2} = z;
        z = ztemp;
    else
        error('wrap argument must be char or cell')
    end
    
elseif numel(z) == 2
    assert(iscell(z),'if z has 2 arguments, must be a cell');
    
else
    error('z must have 1 or 2 arguments')
end