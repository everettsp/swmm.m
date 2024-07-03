function [tbl] = tex_fmat_apply(tbl,fmat)
    for row = 1:height(tbl)
        for col = 1:width(tbl)
            ffun = fmat{row,col};
            tbl(row,col).Variables = ffun(tbl(row,col).Variables);
        end
    end
end