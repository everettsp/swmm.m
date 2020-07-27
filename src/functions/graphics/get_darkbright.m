function col_new = get_darkbright(col,beta)
% beta greater than 0 for brighter
    tol = sqrt(eps);
    if beta > 0
       gamma = 1 - min(1-tol,beta);
    else
       gamma = 1/(1 + max(-1+tol,beta));
    end
    col_new = col.^gamma;
end

