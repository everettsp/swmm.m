function ltx = tex_funs()
ltx = struct();
ltx.bold = @ltx_bold;
ltx.it = @ltx_it;
ltx.italics = @ltx_it;
ltx.wrap = @ltx_wrap;

ltx.fmat_apply = @tex_fmat_apply;
ltx.fmat_init = @tex_fmat_init;
ltx.save = @tbl2tex;
ltx.round = @tex_round;
ltx.escape = @tex_escape;


end

function y = ltx_bold
y = {@(x) cellstr(['\textbf{',char(x),'}'])};
end

function y = ltx_it
y = {@(x) cellstr(['\textbf{',char(x),'}'])};
end

function y = ltx_wrap(z)

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

y = {@(x) cellstr([z{1},char(x),z{2}])};
end